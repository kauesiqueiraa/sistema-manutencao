import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:sistema_manutencao/services/dio_service.dart';
import '../models/auth_model.dart';

class AuthService {
  final String _baseUrl = dotenv.env['API_URL'] ?? '';

  Future<AuthModel> login(String username, String password) async {
    DioService.setBasicAuth(username, password);
    try {
      final response = await DioService.dio.post(
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
      DioService.clearBasicAuth();
      throw Exception('Erro ao fazer login: $e');
    }
  }

  void logout() {
    DioService.clearBasicAuth();
  }
} 