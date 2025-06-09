import 'package:dio/dio.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final String? errorCode;
  final dynamic data;

  ApiException({
    required this.message,
    this.statusCode,
    this.errorCode,
    this.data,
  });

  factory ApiException.fromDioError(DioException error) {
    String message;
    int? statusCode;
    String? errorCode;
    dynamic data;

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        message = 'O servidor demorou muito para responder. Por favor, tente novamente.';
        break;
      case DioExceptionType.badResponse:
        statusCode = error.response?.statusCode;
        data = error.response?.data;
        
        // Tenta obter a mensagem de erro do servidor
        if (data is Map<String, dynamic>) {
          message = data['message'] ?? 'Ocorreu um erro na requisição.';
          errorCode = data['errorCode'];
        } else {
          message = 'Ocorreu um erro na requisição.';
        }
        break;
      case DioExceptionType.cancel:
        message = 'A requisição foi cancelada.';
        break;
      case DioExceptionType.connectionError:
        message = 'Não foi possível conectar ao servidor. Verifique sua conexão com a internet.';
        break;
      case DioExceptionType.unknown:
        message = 'Ocorreu um erro inesperado. Por favor, tente novamente.';
        break;
      default:
        message = 'Ocorreu um erro inesperado. Por favor, tente novamente.';
    }

    return ApiException(
      message: message,
      statusCode: statusCode,
      errorCode: errorCode,
      data: data,
    );
  }

  factory ApiException.fromError(dynamic error) {
    if (error is DioException) {
      return ApiException.fromDioError(error);
    }

    return ApiException(
      message: error.toString(),
    );
  }

  @override
  String toString() => message;
} 