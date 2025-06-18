import 'package:docify/models/doctor_model.dart';
import 'package:docify/models/pagination_model.dart';
import 'package:docify/providers/auth_provider.dart';
import 'package:docify/services/doctor_service.dart';
import 'package:docify/utilities/user_roles.dart';
import 'package:flutter/material.dart';

class DoctorProvider with ChangeNotifier {
  final DoctorService doctorService;
  final AuthProvider authProvider;
  List<DoctorModel> doctors = [];
  bool _isLoading = false;

  MetaModel metaModel = MetaModel(
    currentPage: 0,
    perPage: 20,
    total: 0,
    lastPage: 0,
  );

  bool get isLoading => _isLoading;

  DoctorProvider(this.doctorService, this.authProvider);

  Future<void> getAllDoctors({
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
      final PaginationModel pagination = await doctorService.fetchAllDoctors(
        nama,
        perPage,
        page,
        token,
        authProvider.role,
      );
      metaModel = pagination.meta;
      doctors = pagination.data as List<DoctorModel>;
    } catch (e) {
      print('DoctorProvider: Error occurred: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addDoctor({
    required String email,
    required String nama,
    required String spesialisasi,
    required String rumahSakit,
    required String password,
    required String biodata,
    required String nomorTelepon,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final role = authProvider.role;

      if (role != UserRole.admin) {
        throw Exception(
          "Unauthorized: Only admin can add new doctor into list.",
        );
      }

      final user = authProvider.user();
      final token = user.token as String;
      final doctor = DoctorModel(
        email: email,
        nama: nama,
        spesialisasi: spesialisasi,
        rumahSakit: rumahSakit,
        biodata: biodata,
        nomorTelepon: nomorTelepon,
        password: password,
      );
      await doctorService.createDoctor(doctor, token);
    } catch (e) {
      print('DoctorProvider: Error occurred: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteDoctor(String id) async {
    try {
      _isLoading = true;
      notifyListeners();

      final role = authProvider.role;

      if (role != UserRole.admin) {
        throw Exception(
          "Unauthorized: Only admin can delete doctor.",
        );
      }

      final user = authProvider.user();
      final token = user.token as String;
      await doctorService.deleteDoctor(id, token);
    } catch (e) {
      print('DoctorProvider: Error occurred: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
