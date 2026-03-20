import 'package:dio/dio.dart';
import 'package:deadline_ai/core/errors/exceptions.dart';

class ApiClient {
  final Dio _dio;
  String? _authToken;

  ApiClient({required String baseUrl})
      : _dio = Dio(
          BaseOptions(
            baseUrl: baseUrl,
            connectTimeout: const Duration(seconds: 20),
            receiveTimeout: const Duration(seconds: 20),
          ),
        );

  void setAuthToken(String? token) {
    _authToken = token;
  }

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      return await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: _requestOptions(),
      );
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data?['error']?['message']?.toString() ??
            e.message ??
            'Request failed',
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      return await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: _requestOptions(),
      );
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data?['error']?['message']?.toString() ??
            e.message ??
            'Request failed',
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<Response<T>> delete<T>(String path) async {
    try {
      return await _dio.delete<T>(
        path,
        options: _requestOptions(),
      );
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data?['error']?['message']?.toString() ??
            e.message ??
            'Request failed',
        statusCode: e.response?.statusCode,
      );
    }
  }

  Options _requestOptions() {
    final headers = <String, dynamic>{};
    if (_authToken != null && _authToken!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $_authToken';
    }

    return Options(headers: headers);
  }
}
