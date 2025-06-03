import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/auth_model.dart';

class AuthService {
  final Dio _dio = Dio();
  final String _baseUrl = dotenv.env['API_URL'] ?? '';

  Future<AuthModel> login(String username, String password) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/oauth2/v1/token',
        options: Options(
          headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
            'Accept': 'application/json',
          },
        ),
        data: {
          'username': username,
          'password': password,
          'grant_type': 'password',
        },
      );

      if (response.statusCode == 201) {
        return AuthModel.fromJson(response.data);
      } else {
        throw Exception('Falha na autenticação');
      }
    } catch (e) {
      throw Exception('Erro ao fazer login: $e');
    }
  }
} 