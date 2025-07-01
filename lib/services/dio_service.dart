import 'package:dio/dio.dart';
import 'dart:convert';

class DioService {
  static final Dio _dio = Dio(BaseOptions(
    baseUrl: 'http://172.16.50.9:9107',
    // baseUrl: 'http://172.16.50.12:9002',
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 3),
  ));

  static String? _basicAuth;

  static void setBasicAuth(String user, String password) {
    _basicAuth = 'Basic ${base64Encode(utf8.encode('$user:$password'))}';
  }

  static void clearBasicAuth() {
    _basicAuth = null;
  }

  static void _ensureInterceptor() {
    if (_dio.interceptors.isEmpty ||
        !_dio.interceptors.any((i) => i is InterceptorsWrapper)) {
      _dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            if (_basicAuth != null) {
              options.headers['Authorization'] = _basicAuth;
            } else {
              options.headers.remove('Authorization');
            }
            return handler.next(options);
          },
        ),
      );
    }
  }

  static Dio get dio {
    _ensureInterceptor();
    return _dio;
  }
} 