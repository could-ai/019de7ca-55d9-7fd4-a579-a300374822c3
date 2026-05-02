import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'app_state.dart';
import 'models.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => context.read<AppState>().logout(),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildAdminCard(context, Icons.people, 'Manage Users', 'View doctors and patients', const ManageUsersScreen()),
          _buildAdminCard(context, Icons.schedule, 'Manage Schedules', 'Manage doctor availability', const ManageSchedulesScreen()),
          _buildAdminCard(context, Icons.monitor_heart, 'Monitor Appointments', 'View all system appointments', const MonitorAppointmentsScreen()),
          _buildAdminCard(context, Icons.account_balance_wallet, 'Manage Billing', 'View system revenue', const ManageBillingScreen()),
          _buildAdminCard(context, Icons.bar_chart, 'Reports', 'System statistics and reports', const ReportsScreen()),
        ],
      ),
    );
  }

  Widget _buildAdminCard(BuildContext context, IconData icon, String title, String subtitle, Widget screen) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        leading: Icon(icon, size: 40),
        title: Text(title),
        subtitle: Text(subtitle),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => screen)),
      ),
    );
  }
}

class ManageUsersScreen extends StatelessWidget {
  const ManageUsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final users = context.watch<AppState>().users;
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Users')),
      body: ListView.builder(
        itemCount: users.length,
        itemBuilder: (context, index) {
          final u = users[index];
          return ListTile(
            leading: CircleAvatar(child: Text(u.role.name[0].toUpperCase())),
            title: Text(u.name),
            subtitle: Text('${u.email} - ${u.role.name}'),
          );
        },
      ),
    );
  }
}

class ManageSchedulesScreen extends StatelessWidget {
  const ManageSchedulesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final doctors = context.watch<AppState>().doctors;
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Doctor Schedules')),
      body: ListView.builder(
        itemCount: doctors.length,
        itemBuilder: (context, index) {
          final doc = doctors[index];
          return Card(
            margin: const EdgeInsets.all(8),
            child: ExpansionTile(
              title: Text('Dr. ${doc.name}'),
              subtitle: Text(doc.specialty),
              children: doc.schedule.map((s) => ListTile(title: Text(s))).toList()
                ..add(ListTile(
                  leading: const Icon(Icons.add),
                  title: const Text('Add Schedule Slot (Demo)'),
                  onTap: () {
                    final newSchedule = List<String>.from(doc.schedule)..add('New Slot ${DateTime.now().second}');
                    context.read<AppState>().updateDoctorSchedule(doc.id, newSchedule);
                  },
                )),
            ),
          );
        },
      ),
    );
  }
}

class MonitorAppointmentsScreen extends StatelessWidget {
  const MonitorAppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appts = context.watch<AppState>().appointments;
    final users = context.read<AppState>().users;

    return Scaffold(
      appBar: AppBar(title: const Text('Monitor Appointments')),
      body: ListView.builder(
        itemCount: appts.length,
        itemBuilder: (context, index) {
          final a = appts[index];
          final patientName = users.firstWhere((u) => u.id == a.patientId, orElse: ()=>User(id:'',name:'Unknown',email:'',role:UserRole.patient)).name;
          final doctorName = users.firstWhere((u) => u.id == a.doctorId, orElse: ()=>User(id:'',name:'Unknown',email:'',role:UserRole.doctor)).name;

          return ListTile(
            title: Text('$patientName -> Dr. $doctorName'),
            subtitle: Text('${DateFormat('yyyy-MM-dd HH:mm').format(a.dateTime)} | Status: ${a.status.name}'),
            trailing: DropdownButton<AppointmentStatus>(
              value: a.status,
              items: AppointmentStatus.values.map((s) => DropdownMenuItem(value: s, child: Text(s.name))).toList(),
              onChanged: (val) {
                if(val != null) context.read<AppState>().updateAppointmentStatus(a.id, val);
              },
            ),
          );
        },
      ),
    );
  }
}

class ManageBillingScreen extends StatelessWidget {
  const ManageBillingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appts = context.watch<AppState>().appointments.where((a) => a.billAmount != null).toList();
    final totalRevenue = appts.where((a) => a.isPaid).fold(0.0, (sum, a) => sum + (a.billAmount ?? 0));
    final pendingRevenue = appts.where((a) => !a.isPaid).fold(0.0, (sum, a) => sum + (a.billAmount ?? 0));

    return Scaffold(
      appBar: AppBar(title: const Text('Manage Billing')),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.teal.shade50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(children: [const Text('Collected'), Text('\$${totalRevenue.toStringAsFixed(2)}', style: const TextStyle(fontSize: 24, color: Colors.green))]),
                Column(children: [const Text('Pending'), Text('\$${pendingRevenue.toStringAsFixed(2)}', style: const TextStyle(fontSize: 24, color: Colors.orange))]),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: appts.length,
              itemBuilder: (context, index) {
                final a = appts[index];
                return ListTile(
                  title: Text('Appt ID: ${a.id}'),
                  subtitle: Text('Amount: \$${a.billAmount}'),
                  trailing: Text(a.isPaid ? 'PAID' : 'PENDING', style: TextStyle(color: a.isPaid ? Colors.green : Colors.orange, fontWeight: FontWeight.bold)),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appts = context.watch<AppState>().appointments;
    final users = context.watch<AppState>().users;
    final doctors = context.watch<AppState>().doctors;

    return Scaffold(
      appBar: AppBar(title: const Text('System Reports')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildStatCard('Total Users', users.length.toString(), Icons.people),
          _buildStatCard('Total Doctors', doctors.length.toString(), Icons.medical_services),
          _buildStatCard('Total Appointments', appts.length.toString(), Icons.calendar_today),
          _buildStatCard('Completed Appointments', appts.where((a) => a.status == AppointmentStatus.completed).length.toString(), Icons.check_circle),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, size: 40, color: Colors.teal),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 16, color: Colors.grey)),
                Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              ],
            )
          ],
        ),
      ),
    );
  }
}
