import 'dart:io';

import 'package:dio/dio.dart';
import 'package:docify/models/appointment_model.dart';
import 'package:docify/models/medical_record_model.dart';
import 'package:docify/models/pagination_model.dart';
import 'package:docify/utilities/appointment_status.dart';
import 'package:docify/utilities/user_roles.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart';

final Logger logger = Logger();
final dio = Dio();

class AppointmentService {
  Future<PaginationModel> fetchAllAppointments(
    DateTime? startDate,
    DateTime? endDate,
    int? perPage,
    int? page,
    String? status,
    UserRole role,
    String token,
  ) async {
    try {
      String? baseUrl = dotenv.env['BACKEND_URL'];
      dio.options.headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };

      final queryParams = {
        'page': page ?? 1,
        'per_page': perPage ?? 10,
        'start_date': startDate?.toIso8601String(),
        'end_date': endDate?.toIso8601String(),
      };

      if (status != null) queryParams['status'] = status;

      var response = await dio.get(
        '$baseUrl/${role.name}s/janji-temus',
        queryParameters: queryParams,
      );

      print(response.data);

      if (response.statusCode == 200) {
        final data = response.data['data'] as List<dynamic>;
        List<AppointmentModel> appointments =
            data
                .map(
                  (item) =>
                      AppointmentModel.fromJson(item as Map<String, dynamic>),
                )
                .toList();
        MetaModel metaModel = MetaModel.fromJson(response.data['meta']);
        PaginationModel paginationModel = PaginationModel(
          data: appointments,
          meta: metaModel,
        );
        logger.i('Get All Appointments success.');
        return paginationModel;
      } else {
        throw Exception(
          'Get All Appointments failed: ${response.statusMessage}',
        );
      }
    } on DioException catch (e) {
      String errorMessage =
          e.response?.data?['message'] ?? e.message ?? 'Unknown error';
      logger.e('DioError: $errorMessage');

      throw Exception(errorMessage);
    } catch (e) {
      logger.e('Get All Appointments error: $e');
      rethrow;
    }
  }

  Future<AppointmentModel> createAppointment(
    AppointmentModel appointment,
    String token,
  ) async {
    try {
      String? baseUrl = dotenv.env['BACKEND_URL'];

      dio.options.headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };

      var response = await dio.post(
        '$baseUrl/pasiens/janji-temus',
        data: appointment.toJson(),
      );
      if (response.statusCode == 201) {
        AppointmentModel responseAppointment = AppointmentModel.fromJson(
          response.data['data'],
        );
        logger.i('Create Appointment success.');
        return responseAppointment;
      } else {
        throw Exception('Create Appointment failed: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      String errorMessage =
          e.response?.data?['message'] ?? e.message ?? 'Unknown error';
      logger.e('DioError: $errorMessage');

      throw Exception(errorMessage);
    } catch (e) {
      logger.e('Create Appointment error: $e');
      rethrow;
    }
  }

  Future<MedicalRecordModel> createMedicalRecord(
    File file,
    String catatan,
    AppointmentModel appointment,
    String token,
  ) async {
    try {
      String? baseUrl = dotenv.env['BACKEND_URL'];

      String fileName = basename(file.path);

      FormData formData = FormData.fromMap({
        "file": await MultipartFile.fromFile(
          file.path,
          filename: fileName,
        ),
        "catatan": catatan,
      });

      dio.options.headers = {
        'Content-Type': 'multipart/form-data',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };

      var response = await dio.post(
        '$baseUrl/dokters/janji-temus/${appointment.id}/rekam-medis',
        data: formData,
      );
      if (response.statusCode == 201) {
        MedicalRecordModel responseMedicalRecord = MedicalRecordModel.fromJson(
          response.data['data'],
        );
        logger.i('Create Medical Record success.');
        return responseMedicalRecord;
      } else {
        throw Exception(
          'Create Medical Record failed: ${response.statusMessage}',
        );
      }
    } on DioException catch (e) {
      String errorMessage =
          e.response?.data?['message'] ?? e.message ?? 'Unknown error';
      logger.e('DioError: $errorMessage');

      throw Exception(errorMessage);
    } catch (e) {
      logger.e('Create Medical Record error: $e');
      rethrow;
    }
  }

  Future<void> deleteMedicalRecord(
    AppointmentModel appointment,
    String token,
  ) async {
    try {
      String? baseUrl = dotenv.env['BACKEND_URL'];

      dio.options.headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };

      var response = await dio.delete(
        '$baseUrl/dokters/janji-temus/${appointment.id}/rekam-medis/${appointment.medicalRecord!.id}',
      );
      if (response.statusCode == 200) {
        logger.i('Delete Medical Record success.');
      } else {
        throw Exception(
          'Delete Medical Record failed: ${response.statusMessage}',
        );
      }
    } on DioException catch (e) {
      String errorMessage =
          e.response?.data?['message'] ?? e.message ?? 'Unknown error';
      logger.e('DioError: $errorMessage');

      throw Exception(errorMessage);
    } catch (e) {
      logger.e('Delete Medical Record error: $e');
      rethrow;
    }
  }

  Future<void> updateStatus(
    AppointmentModel appointment,
    AppointmentStatus status,
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
        '$baseUrl/dokters/janji-temus/${appointment.id}',
        data: {'status': status.name},
      );
      if (response.statusCode == 200) {
        logger.i('Update Appointment Status success.');
      } else {
        throw Exception(
          'Update Appointment Status failed: ${response.statusMessage}',
        );
      }
    } on DioException catch (e) {
      String errorMessage =
          e.response?.data?['message'] ?? e.message ?? 'Unknown error';
      logger.e('DioError: $errorMessage');

      throw Exception(errorMessage);
    } catch (e) {
      logger.e('Update Appointment Status error: $e');
      rethrow;
    }
  }
}
