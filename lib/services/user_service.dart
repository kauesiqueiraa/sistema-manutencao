import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:sistema_manutencao/services/dio_service.dart';
import '../models/user_model.dart';

class UserService {
  final String _baseUrl = dotenv.env['BASE_TESTE_URL'] ?? '';

  Future<UserModel> getUserData(String username) async {
    try {
      final response = await DioService.dio.get(
        '$_baseUrl/rest/users',
        queryParameters: {'userName': username},
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