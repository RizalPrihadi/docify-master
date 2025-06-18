// ignore_for_file: unused_local_variable

import 'dart:io';

import 'package:dio/dio.dart';
import 'package:docify/models/admin_model.dart';
import 'package:docify/models/doctor_model.dart';
import 'package:docify/models/patient_model.dart';
import 'package:docify/utilities/abstract_model.dart';
import 'package:docify/utilities/global_methods.dart';
import 'package:docify/utilities/stored_user_template.dart';
import 'package:docify/utilities/user_roles.dart';
import 'package:logger/logger.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:path/path.dart';

final Logger logger = Logger();
final dio = Dio();

class AuthService {
  Future<UserModel?> checkLogin() async {
    final Map<String, dynamic>? userJson = await getDataFromLocal('user');
    if (userJson == null) {
      return null;
    }
    final StoredUser storedUser = StoredUser.fromJson(userJson);
    switch (storedUser.role) {
      case UserRole.admin:
        return AdminModel.fromJson(storedUser.data);
      case UserRole.dokter:
        return DoctorModel.fromJson(storedUser.data);
      case UserRole.pasien:
        return PatientModel.fromJson(storedUser.data);
    }
  }

  Future<dynamic> updateLocalProfile(UserRole role, String token) async {
    try {
      String? url = dotenv.env['BACKEND_URL'];

      switch (role) {
        case UserRole.admin:
          url = '$url/admin';
        case UserRole.dokter:
          url = '$url/dokters';
        case UserRole.pasien:
          url = '$url/pasiens';
      }

      dio.options.headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };

      var response = await dio.get('$url/profile');
      print(response.data);
      if (response.statusCode == 200) {
        response.data['data']['token'] = token;

        final storedUser = StoredUser(data: response.data['data'], role: role);

        await storeDataToLocal('user', storedUser.toJson());

        logger.i('Update Local success.');

        print(storedUser.data);
        switch (role) {
          case UserRole.admin:
            return AdminModel.fromJson(storedUser.data);
          case UserRole.dokter:
            return DoctorModel.fromJson(storedUser.data);
          case UserRole.pasien:
            return PatientModel.fromJson(storedUser.data);
        }
      } else {
        throw Exception('Update Local failed: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      String errorMessage =
          e.response?.data?['message'] ?? e.message ?? 'Unknown error';
      logger.e('DioError: $errorMessage');

      throw Exception(errorMessage);
    } catch (e) {
      logger.e('Unexpected error: ${e.toString()}');
      rethrow;
    }
  }

  Future<dynamic> login(String email, String password, UserRole role) async {
    try {
      String? url = dotenv.env['BACKEND_URL'];

      switch (role) {
        case UserRole.admin:
          url = '$url/admin';
        case UserRole.dokter:
          url = '$url/dokters';
        case UserRole.pasien:
          url = '$url/pasiens';
      }

      dio.options.headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      var response = await dio.post(
        '$url/login',
        data: {'email': email, 'password': password},
      );
      if (response.statusCode == 200) {
        response.data['data']['token'] = response.data['token'];

        final storedUser = StoredUser(data: response.data['data'], role: role);

        await storeDataToLocal('user', storedUser.toJson());

        final data = (response.data as Map<String, dynamic>)['data'];
        logger.i('Login success.');

        switch (role) {
          case UserRole.admin:
            return AdminModel.fromJson(data);
          case UserRole.dokter:
            return DoctorModel.fromJson(data);
          case UserRole.pasien:
            return PatientModel.fromJson(data);
        }
      } else {
        throw Exception('Login failed: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      String errorMessage =
          e.response?.data?['message'] ?? e.message ?? 'Unknown error';
      logger.e('DioError: $errorMessage');

      throw Exception(errorMessage);
    } catch (e) {
      logger.e('Unexpected error: ${e.toString()}');
      rethrow;
    }
  }

  Future<void> register(String email, String name, String nomorTelepon, String jenisKelamin, String password) async {
    try {
      String? baseUrl = dotenv.env['BACKEND_URL'];

      dio.options.headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      var response = await dio.post(
        '$baseUrl/pasiens/register',
        data: {'email': email, 'nama': name, 'nomor_telepon': nomorTelepon, 'jenis_kelamin': jenisKelamin, 'password': password},
      );
      if (response.statusCode == 200) {
        logger.i('Register success.');
      } else {
        throw Exception('Register failed: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      String errorMessage =
          e.response?.data?['message'] ?? e.message ?? 'Unknown error';
      logger.e('DioError: $errorMessage');

      throw Exception(errorMessage);
    } catch (e) {
      logger.e('Unexpected error: ${e.toString()}');
      rethrow;
    }
  }

  Future<PatientModel> changeProfile(PatientModel patient, File? foto, String token) async {
    try {
      String? baseUrl = dotenv.env['BACKEND_URL'];

      FormData formData = FormData.fromMap({
        "_method": "PUT",
        if (foto != null)
          "foto": await MultipartFile.fromFile(
            foto.path,
            filename: basename(foto.path),
        ),
        "nama": patient.nama,
        "nomor_telepon": patient.nomorTelepon,
        "jenis_kelamin": patient.jenisKelamin,
        if (patient.password != null && patient.password!.isNotEmpty)
          "password": patient.password,
      });

      var response = await dio.post(
        '$baseUrl/pasiens/profile',
        data: formData,
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
      );
      if (response.statusCode == 200) {
        response.data['data']['token'] = token;
        final storedUser = StoredUser(
          data: response.data['data'],
          role: UserRole.pasien,
        );
        await storeDataToLocal('user', storedUser.toJson());
        logger.i('Change Profile success.');

        return PatientModel.fromJson(storedUser.data);
      } else {
        throw Exception('Change Profile failed: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      String errorMessage =
          e.response?.data?['message'] ?? e.message ?? 'Unknown error';
      logger.e('DioError: $errorMessage');

      throw Exception(errorMessage);
    } catch (e) {
      logger.e('Change Profile error: $e');
      rethrow;
    }
  }

  Future<DoctorModel> changeDoctorProfile(
    DoctorModel doctor,
    File? foto,
    String token,
  ) async {
    try {
      String? baseUrl = dotenv.env['BACKEND_URL'];

      FormData formData = FormData.fromMap({
        "_method": "PUT",
        if (foto != null)
          "foto": await MultipartFile.fromFile(
            foto.path,
            filename: basename(foto.path),
          ),
        "nama": doctor.nama,
        "spesialisasi": doctor.spesialisasi,
        "rumah_sakit": doctor.rumahSakit,
        "biodata": doctor.biodata,
        "nomor_telepon": doctor.nomorTelepon,
        if (doctor.password != null && doctor.password!.isNotEmpty)
          "password": doctor.password,
      });

      var response = await dio.post(
        '$baseUrl/dokters/profile',
        data: formData,
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
      );
      if (response.statusCode == 200) {
        response.data['data']['token'] = token;
        final storedUser = StoredUser(
          data: response.data['data'],
          role: UserRole.pasien,
        );
        await storeDataToLocal('user', storedUser.toJson());
        logger.i('Change Profile success.');

        return DoctorModel.fromJson(storedUser.data);
      } else {
        throw Exception('Change Profile failed: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      String errorMessage =
          e.response?.data?['message'] ?? e.message ?? 'Unknown error';
      logger.e('DioError: $errorMessage');

      throw Exception(errorMessage);
    } catch (e) {
      logger.e('Change Profile error: $e');
      rethrow;
    }
  }

  Future<void> changeDoctorLocation(
    DoctorLocation doctorLocation,
    String token,
  ) async {
    try {
      String? baseUrl = dotenv.env['BACKEND_URL'];

      dio.options.headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };

      var response = await dio.patch(
        '$baseUrl/dokters/profile',
        data: doctorLocation.toJson(),
      );
      if (response.statusCode == 200) {
        logger.i('Change Location success.');
      } else {
        throw Exception('Change Location failed: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      String errorMessage =
          e.response?.data?['message'] ?? e.message ?? 'Unknown error';
      logger.e('DioError: $errorMessage');

      throw Exception(errorMessage);
    } catch (e) {
      logger.e('Change Location error: $e');
      rethrow;
    }
  }

  Future<void> deleteAccount(UserRole role, String token) async {
    try {
      String? baseUrl = dotenv.env['BACKEND_URL'];

      dio.options.headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };

      var response = await dio.delete('$baseUrl/${role.name}s/profile');
      if (response.statusCode == 200) {
        await removeDataFromLocal('user');
        logger.i('Delete Profile success.');
      } else {
        throw Exception('Delete Profile failed: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      String errorMessage =
          e.response?.data?['message'] ?? e.message ?? 'Unknown error';
      logger.e('DioError: $errorMessage');

      throw Exception(errorMessage);
    } catch (e) {
      logger.e('Delete Profile error: $e');
      rethrow;
    }
  }

  Future<void> logout(UserRole role, String token) async {
    try {
      String? baseUrl = dotenv.env['BACKEND_URL'];

      dio.options.headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };

      var response = await dio.post(
        '$baseUrl/${(role.name == 'admin' ? 'admin' : role.name + 's')}/logout',
      );
      if (response.statusCode == 200) {
      } else {
        throw Exception('Logout failed: ${response.statusMessage}');
      }
      await removeDataFromLocal('user');
    } on DioException catch (e) {
      String errorMessage =
          e.response?.data?['message'] ?? e.message ?? 'Unknown error';
      logger.e('DioError: $errorMessage');

      throw Exception(errorMessage);
    } catch (e) {
      logger.e('Logout error: $e');
      rethrow;
    }
  }
}
