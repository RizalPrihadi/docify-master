import 'package:dio/dio.dart';
import 'package:docify/models/doctor_model.dart';
import 'package:docify/models/pagination_model.dart';
import 'package:docify/utilities/user_roles.dart';
import 'package:logger/logger.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

final Logger logger = Logger();
final dio = Dio();

class DoctorService {
  Future<PaginationModel> fetchAllDoctors(
    String? nama,
    int? perPage,
    int? page,
    String token,
    UserRole role,
  ) async {
    try {
      String? baseUrl = dotenv.env['BACKEND_URL'];
      dio.options.headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };

      final queryParams = {'page': page, 'per_page': perPage, 'nama': nama};

      var response = await dio.get(
        '$baseUrl${role == UserRole.pasien ? '/pasiens' : ''}/dokters',
        queryParameters: queryParams,
      );
      if (response.statusCode == 200) {
        final data = response.data['data'] as List<dynamic>;
        List<DoctorModel> doctors =
            data
                .map(
                  (item) => DoctorModel.fromJson(item as Map<String, dynamic>),
                )
                .toList();
        MetaModel metaModel = MetaModel.fromJson(response.data['meta']);
        PaginationModel paginationModel = PaginationModel(
          data: doctors,
          meta: metaModel,
        );
        logger.i('Get All Doctors success.');
        return paginationModel;
      } else {
        throw Exception('Get All Doctors failed: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      String errorMessage =
          e.response?.data?['message'] ?? e.message ?? 'Unknown error';
      logger.e('DioError: $errorMessage');

      throw Exception(errorMessage);
    } catch (e) {
      logger.e('Get All Doctors error: $e');
      rethrow;
    }
  }

  Future<DoctorModel> createDoctor(DoctorModel doctor, String token) async {
    try {
      String? baseUrl = dotenv.env['BACKEND_URL'];
      dio.options.headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };

      var response = await dio.post('$baseUrl/dokters', data: doctor.toJson());
      if (response.statusCode == 201) {
        DoctorModel responseDoctor = DoctorModel.fromJson(
          response.data['data'],
        );
        logger.i('Create Doctor success.');
        return responseDoctor;
      } else {
        throw Exception('Create Doctor failed: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      String errorMessage =
          e.response?.data?['message'] ?? e.message ?? 'Unknown error';
      logger.e('DioError: $errorMessage');

      throw Exception(errorMessage);
    } catch (e) {
      logger.e('Create Doctor error: $e');
      rethrow;
    }
  }

  Future<void> deleteDoctor(String id, String token) async {
    try {
      String? baseUrl = dotenv.env['BACKEND_URL'];
      dio.options.headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };

      var response = await dio.delete('$baseUrl/dokters/$id');
      if (response.statusCode == 200) {
        logger.i('Delete Doctor success.');
      } else {
        throw Exception('Delete Doctor failed: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      String errorMessage =
          e.response?.data?['message'] ?? e.message ?? 'Unknown error';
      logger.e('DioError: $errorMessage');

      throw Exception(errorMessage);
    } catch (e) {
      logger.e('Delete Doctor error: $e');
      rethrow;
    }
  }
}
