class AppException implements Exception {
  final String message;
  final int? statusCode;

  AppException({required this.message, this.statusCode});

  @override
  String toString() => message;
}

class ServerException extends AppException {
  ServerException({required super.message, super.statusCode});
}

class NetworkException extends AppException {
  NetworkException({super.message = 'No internet connection'});
}

class ValidationException extends AppException {
  ValidationException({required super.message, super.statusCode = 400});
}
