# Medical Channeling System App

A comprehensive Flutter application for a hospital or clinic channeling system that caters to three distinct roles: Patient, Doctor, and Admin. The app features state management via Provider and presents a full flow from appointment booking to billing and diagnosis records.

## Features

### Authentication
- Role-based Login (Patient, Doctor, Admin)
- Patient Registration
- Forgot Password mock flow

### Patient Role
- **Dashboard:** Overview of actions available to the patient.
- **Channel a Doctor (Book Appointment):** Select doctor, choose available date and time.
- **View Appointment Status:** Track the status of appointments (Pending, Confirmed, Completed).
- **Billing and Payment:** View consultation fees and process mock payments.

### Doctor Role
- **Dashboard:** Direct access to daily tasks.
- **Appointment List:** View scheduled patients for the day.
- **Patient Details:** Review patient information prior to consultation.
- **Diagnosis and Prescription:** Add clinical diagnosis and prescription notes.
- **Save Patient Records:** Mark appointments as completed and record the consultation details.

### Admin Role
- **Manage Users:** Overview and manage all registered doctors and patients.
- **Manage Doctor Schedules:** Assign and monitor availability slots for doctors.
- **Monitor Appointments (Channeling System):** System-wide view to track or update appointment statuses.
- **Manage Billing System:** Track paid and pending revenues across the clinic.
- **View Reports:** Access system statistics (user count, completed appointments, etc.).

## Tech Stack
- **Flutter:** UI Toolkit
- **Provider:** State Management
- **Intl:** Date and Time formatting

## Setup and Run Instructions
1. Ensure you have the [Flutter SDK](https://flutter.dev/docs/get-started/install) installed.
2. Clone this repository.
3. Run `flutter pub get` to install dependencies.
4. Run `flutter run` on an emulator or physical device.

**Demo Credentials:**
- Patient: `patient@test.com` / `password`
- Doctor: `doctor@test.com` / `password`
- Admin: `admin@test.com` / `password`

---

## About CouldAI
This app was generated with [CouldAI](https://could.ai), an AI app builder for cross-platform apps that turns prompts into real native iOS, Android, Web, and Desktop apps with autonomous AI agents that architect, build, test, deploy, and iterate production-ready applications.