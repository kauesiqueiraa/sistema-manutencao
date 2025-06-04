import 'package:dio/dio.dart';

class DioService {
  static final Dio _dio = Dio(BaseOptions(
    baseUrl: 'http://172.16.50.12:9002',
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 3),
  ));

  static Dio get dio => _dio;
} 