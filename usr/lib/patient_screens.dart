import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'app_state.dart';
import 'models.dart';

class PatientDashboard extends StatelessWidget {
  const PatientDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Patient Dashboard'),
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
          Card(
            child: ListTile(
              leading: const Icon(Icons.medical_services, size: 40),
              title: const Text('Channel a Doctor'),
              subtitle: const Text('Book an appointment'),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const BookAppointmentScreen()));
              },
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              leading: const Icon(Icons.calendar_today, size: 40),
              title: const Text('My Appointments'),
              subtitle: const Text('View status and details'),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const AppointmentStatusScreen()));
              },
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              leading: const Icon(Icons.payment, size: 40),
              title: const Text('Billing & Payment'),
              subtitle: const Text('Manage your bills'),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const BillingScreen()));
              },
            ),
          ),
        ],
      ),
    );
  }
}

class BookAppointmentScreen extends StatefulWidget {
  const BookAppointmentScreen({super.key});

  @override
  State<BookAppointmentScreen> createState() => _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends State<BookAppointmentScreen> {
  String? selectedDoctorId;
  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  @override
  Widget build(BuildContext context) {
    final doctors = context.read<AppState>().doctors;

    return Scaffold(
      appBar: AppBar(title: const Text('Book Appointment')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Select Doctor'),
              value: selectedDoctorId,
              items: doctors.map((d) => DropdownMenuItem(value: d.id, child: Text('${d.name} (${d.specialty})'))).toList(),
              onChanged: (val) => setState(() => selectedDoctorId = val),
            ),
            const SizedBox(height: 16),
            ListTile(
              title: Text(selectedDate == null ? 'Select Date' : DateFormat('yyyy-MM-dd').format(selectedDate!)),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (date != null) setState(() => selectedDate = date);
              },
            ),
            ListTile(
              title: Text(selectedTime == null ? 'Select Time' : selectedTime!.format(context)),
              trailing: const Icon(Icons.access_time),
              onTap: () async {
                final time = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );
                if (time != null) setState(() => selectedTime = time);
              },
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                if (selectedDoctorId != null && selectedDate != null && selectedTime != null) {
                  final dt = DateTime(
                    selectedDate!.year, selectedDate!.month, selectedDate!.day,
                    selectedTime!.hour, selectedTime!.minute,
                  );
                  context.read<AppState>().bookAppointment(selectedDoctorId!, dt);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Appointment Booked Successfully!')));
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select all fields')));
                }
              },
              child: const Text('Book Now'),
            )
          ],
        ),
      ),
    );
  }
}

class AppointmentStatusScreen extends StatelessWidget {
  const AppointmentStatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AppState>().currentUser!;
    final appointments = context.watch<AppState>().appointments.where((a) => a.patientId == user.id).toList();
    final doctors = context.watch<AppState>().doctors;

    return Scaffold(
      appBar: AppBar(title: const Text('My Appointments')),
      body: appointments.isEmpty
          ? const Center(child: Text('No appointments found.'))
          : ListView.builder(
              itemCount: appointments.length,
              itemBuilder: (context, index) {
                final appt = appointments[index];
                final doctor = doctors.firstWhere((d) => d.id == appt.doctorId, orElse: () => Doctor(id: '', name: 'Unknown', email: '', specialty: ''));
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: Text('Dr. ${doctor.name} - ${doctor.specialty}'),
                    subtitle: Text('Date: ${DateFormat('yyyy-MM-dd HH:mm').format(appt.dateTime)}\nStatus: ${appt.status.name.toUpperCase()}'),
                    isThreeLine: true,
                    trailing: Icon(
                      appt.status == AppointmentStatus.completed ? Icons.check_circle : Icons.pending,
                      color: appt.status == AppointmentStatus.completed ? Colors.green : Colors.orange,
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class BillingScreen extends StatelessWidget {
  const BillingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AppState>().currentUser!;
    final appointments = context.watch<AppState>().appointments.where((a) => a.patientId == user.id && a.billAmount != null).toList();
    final doctors = context.watch<AppState>().doctors;

    return Scaffold(
      appBar: AppBar(title: const Text('Billing & Payment')),
      body: appointments.isEmpty
          ? const Center(child: Text('No bills found.'))
          : ListView.builder(
              itemCount: appointments.length,
              itemBuilder: (context, index) {
                final appt = appointments[index];
                final doctor = doctors.firstWhere((d) => d.id == appt.doctorId, orElse: () => Doctor(id: '', name: 'Unknown', email: '', specialty: ''));
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: Text('Consultation: Dr. ${doctor.name}'),
                    subtitle: Text('Amount: \$${appt.billAmount!.toStringAsFixed(2)}\nStatus: ${appt.isPaid ? "Paid" : "Unpaid"}'),
                    trailing: appt.isPaid
                        ? const Icon(Icons.check_circle, color: Colors.green)
                        : ElevatedButton(
                            onPressed: () {
                              context.read<AppState>().payBill(appt.id);
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Payment Successful!')));
                            },
                            child: const Text('Pay Now'),
                          ),
                  ),
                );
              },
            ),
    );
  }
}
