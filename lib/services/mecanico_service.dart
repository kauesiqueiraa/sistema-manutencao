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

  Future<bool> findStatusMecanicoByMat(String mat) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/rest/WSMECANI/retmec',
        queryParameters: {
          'empfil': '0401',
          'matricula': mat,
        },
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        for (var mecanico in data) {
          if (mecanico['status'] == 'D=Disponivel') {
            return true;
          }
        }
        //se não encontrar o mecanico, retorna null
        return false;
      }
      return false;
    } catch (e) {
      throw Exception('Erro ao buscar mecânicos: $e');
    }
  }

  Future<void> updateMecanicoStatus(String mat, String status) async {
    try {
      final Response<dynamic> response = await _dio.put(
        '$_baseUrl/rest/WSMECANI/',
        options: Options(
          headers: {'Content-Type': 'application/json', },
          responseType: ResponseType.plain, 
        ),
        data:{
          'matricula': mat,
          'status': status,
        },
      );

      if (response.statusCode != 200) {
      throw Exception('Erro ao atualizar: statusCode ${response.statusCode}');
    }
    } catch (e){
      throw Exception ('Erro ao atualizar status do Mecanico'); 
    }
  }
} 