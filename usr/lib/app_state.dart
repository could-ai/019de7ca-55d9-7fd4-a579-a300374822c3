import 'package:flutter/material.dart';
import 'models.dart';

class AppState extends ChangeNotifier {
  User? _currentUser;
  User? get currentUser => _currentUser;

  // Mock Data
  final List<User> _users = [
    User(id: 'p1', name: 'John Doe', email: 'patient@test.com', role: UserRole.patient),
    Doctor(id: 'd1', name: 'Dr. Smith', email: 'doctor@test.com', specialty: 'Cardiology', schedule: ['Monday 9 AM', 'Wednesday 2 PM']),
    User(id: 'a1', name: 'Admin User', email: 'admin@test.com', role: UserRole.admin),
  ];

  final List<Appointment> _appointments = [
    Appointment(
      id: 'app1',
      patientId: 'p1',
      doctorId: 'd1',
      dateTime: DateTime.now().add(const Duration(days: 1)),
      status: AppointmentStatus.confirmed,
      billAmount: 150.0,
      isPaid: false,
    ),
  ];

  List<User> get users => _users;
  List<Doctor> get doctors => _users.whereType<Doctor>().toList();
  List<Appointment> get appointments => _appointments;

  bool login(String email, String password) {
    try {
      _currentUser = _users.firstWhere((u) => u.email == email);
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }

  bool registerPatient(String name, String email, String password) {
    if (_users.any((u) => u.email == email)) return false;
    _users.add(User(id: DateTime.now().millisecondsSinceEpoch.toString(), name: name, email: email, role: UserRole.patient));
    notifyListeners();
    return true;
  }

  // Patient Actions
  void bookAppointment(String doctorId, DateTime dateTime) {
    if (_currentUser == null) return;
    _appointments.add(Appointment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      patientId: _currentUser!.id,
      doctorId: doctorId,
      dateTime: dateTime,
      billAmount: 100.0, // Base fee
    ));
    notifyListeners();
  }

  void payBill(String appointmentId) {
    final idx = _appointments.indexWhere((a) => a.id == appointmentId);
    if (idx != -1) {
      _appointments[idx].isPaid = true;
      notifyListeners();
    }
  }

  // Doctor Actions
  void updateAppointment(String appointmentId, {String? diagnosis, String? prescription, AppointmentStatus? status}) {
    final idx = _appointments.indexWhere((a) => a.id == appointmentId);
    if (idx != -1) {
      final old = _appointments[idx];
      _appointments[idx] = Appointment(
        id: old.id,
        patientId: old.patientId,
        doctorId: old.doctorId,
        dateTime: old.dateTime,
        status: status ?? old.status,
        diagnosis: diagnosis ?? old.diagnosis,
        prescription: prescription ?? old.prescription,
        billAmount: old.billAmount,
        isPaid: old.isPaid,
      );
      notifyListeners();
    }
  }

  // Admin Actions
  void updateDoctorSchedule(String doctorId, List<String> schedule) {
    final idx = _users.indexWhere((u) => u.id == doctorId && u is Doctor);
    if (idx != -1) {
      final old = _users[idx] as Doctor;
      _users[idx] = Doctor(id: old.id, name: old.name, email: old.email, specialty: old.specialty, schedule: schedule);
      notifyListeners();
    }
  }

  void updateAppointmentStatus(String appointmentId, AppointmentStatus status) {
    final idx = _appointments.indexWhere((a) => a.id == appointmentId);
    if (idx != -1) {
      _appointments[idx].status = status;
      notifyListeners();
    }
  }
}
