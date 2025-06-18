import 'package:docify/models/pagination_model.dart';
import 'package:docify/models/patient_model.dart';
import 'package:docify/providers/auth_provider.dart';
import 'package:docify/services/patient_service.dart';
import 'package:docify/utilities/user_roles.dart';
import 'package:flutter/material.dart';

class PatientProvider with ChangeNotifier {
  final PatientService patientService;
  final AuthProvider authProvider;
  List<PatientModel> patients = [];
  bool _isLoading = false;

  MetaModel metaModel = MetaModel(
    currentPage: 0,
    perPage: 20,
    total: 0,
    lastPage: 0,
  );

  bool get isLoading => _isLoading;

  PatientProvider(this.patientService, this.authProvider);

  Future<void> getAllPatients({
    String? nama,
    int? perPage,
    int? page,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final role = authProvider.role;

      if (role != UserRole.admin && role != UserRole.pasien) {
        throw Exception(
          "Unauthorized: Only admin and patient can access doctor list.",
        );
      }

      final user = authProvider.user();
      final token = user.token as String;
      final PaginationModel pagination = await patientService.fetchAllPatients(
        nama,
        perPage,
        page,
        token,
      );
      metaModel = pagination.meta;
      patients = pagination.data as List<PatientModel>;
    } catch (e) {
      print('PatientProvider: Error occurred: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deletePatient(String id) async {
    try {
      _isLoading = true;
      notifyListeners();

      final role = authProvider.role;

      if (role != UserRole.admin) {
        throw Exception(
          "Unauthorized: Only admin can delete patient.",
        );
      }

      final user = authProvider.user();
      final token = user.token as String;
      await patientService.deletePatient(id, token);
    } catch (e) {
      print('PatientProvider: Error occurred: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
