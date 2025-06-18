import 'dart:io';

import 'package:docify/models/admin_model.dart';
import 'package:docify/models/doctor_model.dart';
import 'package:docify/models/patient_model.dart';
import 'package:docify/services/auth_service.dart';
import 'package:docify/utilities/abstract_model.dart';
import 'package:docify/utilities/global_methods.dart';
import 'package:docify/utilities/user_roles.dart';
import 'package:flutter/material.dart';

class AuthProvider with ChangeNotifier {
  bool? _isLoggedIn;
  dynamic _user;
  late UserRole _role;
  bool _isLoading = false;
  final AuthService authService;

  DoctorModel get doctor => _user as DoctorModel;
  AdminModel get admin => _user as AdminModel;
  PatientModel get patient => _user as PatientModel;

  bool get isLoggedIn => _isLoggedIn!;
  UserRole get role => _role;
  bool get isLoading => _isLoading;

  AuthProvider(this.authService);

  dynamic user() {
    switch (_role) {
      case UserRole.admin:
        return _user as AdminModel;
      case UserRole.dokter:
        return _user as DoctorModel;
      case UserRole.pasien:
        return _user as PatientModel;
    }
  }

  Future<void> checkLogin() async {
    try {
      UserModel? user = await authService.checkLogin();
      if (user == null) {
        _isLoggedIn = false;
      } else {
        _user = user;
        _isLoggedIn = true;
        if (user is AdminModel) {
          _role = UserRole.admin;
        } else if (user is DoctorModel) {
          _role = UserRole.dokter;
        } else {
          _role = UserRole.pasien;
        }
      }
      notifyListeners();
    } catch (e) {
      print('AuthProvider: Error occurred: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> login(String email, String password, String role) async {
    try {
      final userRole = userRoleFromString(role);
      _user = await authService.login(email, password, userRole);
      _isLoggedIn = true;
      if (_user is AdminModel) {
        _role = UserRole.admin;
      } else if (_user is DoctorModel) {
        _role = UserRole.dokter;
      } else {
        _role = UserRole.pasien;
      }
    } catch (e) {
      print('AuthProvider: Error occurred: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> register(String email, String name, String nomorTelepon, String jenisKelamin, String password) async {
    try {
      _isLoading = true;
      await authService.register(email, name, nomorTelepon, jenisKelamin, password);
    } catch (e) {
      print('AuthProvider: Error occurred: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    try {
      _isLoading = true;
      final user = this.user();
      final token = user.token as String;
      await authService.logout(role, token);
      _isLoggedIn = false;
      notifyListeners();
    } catch (e) {
      print('AuthProvider: Error occurred: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> changeProfile({
    required String nama,
    required String jenisKelamin,
    required String nomorTelepon,
    File? foto,
    required String password,
  }) async {
    try {
      _isLoading = true;
      final user = this.user() as PatientModel;
      final token = user.token as String;
      user.nama = nama;
      user.jenisKelamin = jenisKelamin;
      user.nomorTelepon = nomorTelepon;
      user.password = password.isNotEmpty ? password : null;
      PatientModel patient = await authService.changeProfile(user, foto, token);
      _user = patient;
    } catch (e) {
      print('AuthProvider: Error occurred: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> changeDoctorProfile({
    required String nama,
    required String password,
    required String spesialisasi,
    required String rumahSakit,
    required String biodata,
    required String nomorTelepon,
    File? foto,
  }) async {
    try {
      _isLoading = true;
      final user = this.user() as DoctorModel;
      final token = user.token as String;
      user.nama = nama;
      user.spesialisasi = spesialisasi;
      user.rumahSakit = rumahSakit;
      user.biodata = biodata;
      user.nomorTelepon = nomorTelepon;
      user.password = password.isNotEmpty ? password : null;
      DoctorModel doctor = await authService.changeDoctorProfile(user, foto, token);
      _user = doctor;
    } catch (e) {
      print('AuthProvider: Error occurred: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> changeDoctorLocation({
    required double longitude,
    required double latitude,
  }) async {
    try {
      _isLoading = true;
      final user = this.user() as DoctorModel;
      final token = user.token as String;
      final DoctorLocation doctorLocation = new DoctorLocation(
        latitude: latitude,
        longitude: longitude,
      );
      await authService.changeDoctorLocation(doctorLocation, token);
      _user = await authService.updateLocalProfile(role, token);
    } catch (e) {
      print('AuthProvider: Error occurred: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteAccount() async {
    try {
      _isLoading = true;
      final user = this.user();
      final token = user.token as String;
      await authService.deleteAccount(role, token);
      _user = null;
    } catch (e) {
      print('AuthProvider: Error occurred: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
