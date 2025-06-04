import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/mecanico_model.dart';

class MecanicoService {
  final Dio _dio;
  final String _baseUrl = dotenv.env['BASE_TESTE_URL'] ?? '';

  MecanicoService(this._dio);

  Future<List<MecanicoModel>> getMecanicos({required String setor}) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/rest/WSMECANI/retmec',
        queryParameters: {
          'empfil': '0401',
          'setor': setor,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => MecanicoModel.fromJson(json)).toList();
      }
      throw Exception('Falha ao carregar mecânicos');
    } catch (e) {
      throw Exception('Erro ao buscar mecânicos: $e');
    }
  }

  Future<MecanicoModel?> findMecanicoByUserId(String userId) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/rest/WSMECANI/retmec',
        queryParameters: {
          'empfil': '0401',
          'setor': 'I',
        },
      );

      if (response.statusCode == 200) {
        
        final List<dynamic> data = response.data;
        
        // Procura o mecânico que tem o mesmo ID do usuário
        for (var mecanico in data) {
          if (mecanico['iduser']?.toString() == userId) {
            return MecanicoModel.fromJson(mecanico);
          }
        }
      }
      return null;
    } catch (e) {
      throw Exception('Erro ao buscar mecânicos: $e');
    }
  }
} 