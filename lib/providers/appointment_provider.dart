import 'dart:io';

import 'package:docify/models/appointment_model.dart';
import 'package:docify/models/doctor_model.dart';
import 'package:docify/models/medical_record_model.dart';
import 'package:docify/models/pagination_model.dart';
import 'package:docify/providers/auth_provider.dart';
import 'package:docify/services/appointment_service.dart';
import 'package:docify/utilities/appointment_status.dart';
import 'package:docify/utilities/user_roles.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class AppointmentProvider with ChangeNotifier {
  bool _isLoading = false;
  final AppointmentService appointmentService;
  final AuthProvider authProvider;
  List<AppointmentModel> appointments = [];

  MetaModel metaModel = MetaModel(
    currentPage: 0,
    perPage: 20,
    total: 0,
    lastPage: 0,
  );

  bool get isLoading => _isLoading;

  AppointmentProvider(this.appointmentService, this.authProvider);

  Future<void> getAllAppointments({
    DateTime? startDate,
    DateTime? endDate,
    int? perPage,
    int? page,
    String? status,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final role = authProvider.role;

      if (role != UserRole.dokter && role != UserRole.pasien) {
        throw Exception(
          "Unauthorized: Only doctor and patient can access doctor list.",
        );
      }

      final user = authProvider.user();
      final token = user.token as String;
      final PaginationModel pagination = await appointmentService
          .fetchAllAppointments(
            startDate,
            endDate,
            perPage,
            page,
            status != 'semua' ? status : null,
            role,
            token,
          );
      metaModel = pagination.meta;
      appointments = pagination.data as List<AppointmentModel>;
    } catch (e) {
      print('AppointmentProvider: Error occurred: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addAppointment({
    required DateTime pickedDateTime,
    required DoctorModel doctor,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final role = authProvider.role;

      if (role != UserRole.pasien) {
        throw Exception(
          "Unauthorized: Only patient can create an appointment.",
        );
      }

      final user = authProvider.user();
      final token = user.token as String;
      final appoinment = AppointmentModel(
        doctorId: doctor.id,
        status: AppointmentStatus.belum,
        waktu: pickedDateTime,
      );
      await appointmentService.createAppointment(appoinment, token);
    } catch (e) {
      print('DoctorProvider: Error occurred: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void sortAttendancesByDate(PickerDateRange object, String? status) {
    try {
      getAllAppointments(
        startDate: object.startDate,
        endDate: object.endDate,
        status: status,
      );
    } catch (error) {
      throw Exception('An unexpected error occurred: $error');
    }
  }

  Future<AppointmentModel> addMedicalRecord({
    required File file,
    required String catatan,
    required AppointmentModel appointment,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final role = authProvider.role;

      if (role != UserRole.dokter) {
        throw Exception("Unauthorized: Only doctor can create medical record.");
      }

      final user = authProvider.user();
      final token = user.token as String;
      final MedicalRecordModel medicalRecord = await appointmentService
          .createMedicalRecord(file, catatan, appointment, token);
      appointment.medicalRecord = medicalRecord;
      return appointment;
    } catch (e) {
      print('DoctorProvider: Error occurred: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteMedicalRecord(AppointmentModel appointment) async {
    try {
      _isLoading = true;
      notifyListeners();

      final role = authProvider.role;

      if (role != UserRole.dokter) {
        throw Exception("Unauthorized: Only doctor can delete medical record.");
      }

      final user = authProvider.user();
      final token = user.token as String;
      await appointmentService.deleteMedicalRecord(appointment, token);
      appointment.medicalRecord = null;
    } catch (e) {
      print('DoctorProvider: Error occurred: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> updateStatus(AppointmentModel appointment, AppointmentStatus status) async {
    try {
      _isLoading = true;
      notifyListeners();

      final role = authProvider.role;

      if (role != UserRole.dokter) {
        throw Exception("Unauthorized: Only doctor can update appointment status.");
      }

      final user = authProvider.user();
      final token = user.token as String;
      await appointmentService.updateStatus(appointment, status, token);
    } catch (e) {
      print('DoctorProvider: Error occurred: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
