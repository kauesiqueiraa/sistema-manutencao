import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/user_model.dart';

class UserService {
  final Dio _dio = Dio();
  final String _baseUrl = dotenv.env['API_URL'] ?? '';

  Future<UserModel> getUserData(String username, String token) async {
    try {
      final response = await _dio.get(
        'http://172.16.50.9:9103/rest/users',
        queryParameters: {'userName': username},
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        final resources = response.data['resources'] as List;
        if (resources.isNotEmpty) {
          return UserModel.fromJson(resources.first);
        }
        throw Exception('Usuário não encontrado');
      } else {
        throw Exception('Falha ao buscar dados do usuário');
      }
    } catch (e) {
      throw Exception('Erro ao buscar dados do usuário: $e');
    }
  }
} 