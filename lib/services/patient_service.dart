import 'package:dio/dio.dart';
import 'package:docify/models/pagination_model.dart';
import 'package:docify/models/patient_model.dart';
import 'package:logger/logger.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

final Logger logger = Logger();
final dio = Dio();

class PatientService {
  Future<PaginationModel> fetchAllPatients(
    String? nama,
    int? perPage,
    int? page,
    String token,
  ) async {
    try {
      String? baseUrl = dotenv.env['BACKEND_URL'];
      dio.options.headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };

      final queryParams = {'page': page, 'limit': perPage, 'nama': nama};

      var response = await dio.get(
        '$baseUrl/pasiens',
        queryParameters: queryParams,
      );
      if (response.statusCode == 200) {
        final data = response.data['data'] as List<dynamic>;
        List<PatientModel> patients =
            data
                .map(
                  (item) => PatientModel.fromJson(item as Map<String, dynamic>),
                )
                .toList();
        MetaModel metaModel = MetaModel.fromJson(response.data['meta']);
        PaginationModel paginationModel = PaginationModel(
          data: patients,
          meta: metaModel,
        );
        logger.i('Get All Patients success.');
        return paginationModel;
      } else {
        throw Exception('Get All Patients failed: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      String errorMessage =
          e.response?.data?['message'] ?? e.message ?? 'Unknown error';
      logger.e('DioError: $errorMessage');

      throw Exception(errorMessage);
    } catch (e) {
      logger.e('Get All Patients error: $e');
      rethrow;
    }
  }

  Future<void> deletePatient(String id, String token) async {
    try {
      String? baseUrl = dotenv.env['BACKEND_URL'];
      dio.options.headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };

      var response = await dio.delete('$baseUrl/pasiens/$id');
      if (response.statusCode == 200) {
        logger.i('Delete Patient success.');
      } else {
        throw Exception('Delete Patient failed: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      String errorMessage =
          e.response?.data?['message'] ?? e.message ?? 'Unknown error';
      logger.e('DioError: $errorMessage');

      throw Exception(errorMessage);
    } catch (e) {
      logger.e('Delete Patient error: $e');
      rethrow;
    }
  }
}
