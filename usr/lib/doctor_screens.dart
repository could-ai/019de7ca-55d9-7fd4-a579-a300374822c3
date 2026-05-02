import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'app_state.dart';
import 'models.dart';

class DoctorDashboard extends StatelessWidget {
  const DoctorDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Doctor Dashboard'),
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
              leading: const Icon(Icons.list_alt, size: 40),
              title: const Text('My Appointments'),
              subtitle: const Text('View and manage patient appointments'),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const DoctorAppointmentListScreen()));
              },
            ),
          ),
        ],
      ),
    );
  }
}

class DoctorAppointmentListScreen extends StatelessWidget {
  const DoctorAppointmentListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AppState>().currentUser!;
    final appointments = context.watch<AppState>().appointments.where((a) => a.doctorId == user.id).toList();
    final allUsers = context.watch<AppState>().users;

    return Scaffold(
      appBar: AppBar(title: const Text('Appointment List')),
      body: appointments.isEmpty
          ? const Center(child: Text('No appointments.'))
          : ListView.builder(
              itemCount: appointments.length,
              itemBuilder: (context, index) {
                final appt = appointments[index];
                final patient = allUsers.firstWhere((u) => u.id == appt.patientId, orElse: () => User(id: '', name: 'Unknown', email: '', role: UserRole.patient));
                
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: Text('Patient: ${patient.name}'),
                    subtitle: Text('Date: ${DateFormat('yyyy-MM-dd HH:mm').format(appt.dateTime)}\nStatus: ${appt.status.name}'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => PatientDetailsScreen(appointment: appt, patient: patient)));
                    },
                  ),
                );
              },
            ),
    );
  }
}

class PatientDetailsScreen extends StatefulWidget {
  final Appointment appointment;
  final User patient;

  const PatientDetailsScreen({super.key, required this.appointment, required this.patient});

  @override
  State<PatientDetailsScreen> createState() => _PatientDetailsScreenState();
}

class _PatientDetailsScreenState extends State<PatientDetailsScreen> {
  late TextEditingController _diagnosisCtrl;
  late TextEditingController _prescriptionCtrl;

  @override
  void initState() {
    super.initState();
    _diagnosisCtrl = TextEditingController(text: widget.appointment.diagnosis);
    _prescriptionCtrl = TextEditingController(text: widget.appointment.prescription);
  }

  @override
  void dispose() {
    _diagnosisCtrl.dispose();
    _prescriptionCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Patient Details')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Patient: ${widget.patient.name}', style: Theme.of(context).textTheme.titleLarge),
            Text('Email: ${widget.patient.email}'),
            const SizedBox(height: 16),
            Text('Appointment: ${DateFormat('yyyy-MM-dd HH:mm').format(widget.appointment.dateTime)}'),
            Text('Status: ${widget.appointment.status.name.toUpperCase()}'),
            const Divider(),
            Expanded(
              child: ListView(
                children: [
                  TextField(
                    controller: _diagnosisCtrl,
                    decoration: const InputDecoration(labelText: 'Diagnosis', border: OutlineInputBorder()),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _prescriptionCtrl,
                    decoration: const InputDecoration(labelText: 'Prescription', border: OutlineInputBorder()),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      context.read<AppState>().updateAppointment(
                        widget.appointment.id,
                        diagnosis: _diagnosisCtrl.text,
                        prescription: _prescriptionCtrl.text,
                        status: AppointmentStatus.completed,
                      );
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Records Saved & Appointment Completed')));
                      Navigator.pop(context);
                    },
                    child: const Text('Save Records'),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
