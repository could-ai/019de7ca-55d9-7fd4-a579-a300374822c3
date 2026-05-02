enum UserRole { patient, doctor, admin }

class User {
  final String id;
  final String name;
  final String email;
  final UserRole role;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });
}

class Doctor extends User {
  final String specialty;
  final List<String> schedule;

  Doctor({
    required super.id,
    required super.name,
    required super.email,
    required this.specialty,
    this.schedule = const [],
  }) : super(role: UserRole.doctor);
}

enum AppointmentStatus { pending, confirmed, completed, cancelled }

class Appointment {
  final String id;
  final String patientId;
  final String doctorId;
  final DateTime dateTime;
  AppointmentStatus status;
  final String? diagnosis;
  final String? prescription;
  final double? billAmount;
  bool isPaid;

  Appointment({
    required this.id,
    required this.patientId,
    required this.doctorId,
    required this.dateTime,
    this.status = AppointmentStatus.pending,
    this.diagnosis,
    this.prescription,
    this.billAmount,
    this.isPaid = false,
  });
}
