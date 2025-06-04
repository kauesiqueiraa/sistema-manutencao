import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/chamado_model.dart';

class ChamadoService {
  final Dio _dio;
  final String _baseUrl = dotenv.env['BASE_TESTE_URL'] ?? '';

  ChamadoService(this._dio);

  Future<List<ChamadoModel>> getChamados() async {
    try {
      final response = await _dio.get(
        '$_baseUrl/rest/zws_zmp/get_all',
        options: Options(
          headers: {'Content-Type': 'application/json'},
          responseType: ResponseType.plain,
        ),
      );

      if (response.statusCode == 200) {
        var decodedResponse = jsonDecode(response.data);
        final List<dynamic> data = decodedResponse['objects'] ?? [];
        return data.map((json) => ChamadoModel.fromJson(json)).toList();
      }
      throw Exception('Falha ao carregar chamados');
    } catch (e) {
      throw Exception('Erro ao buscar chamados: $e');
    }
  }

  Future<void> atualizarStatus({
    required String numero,
    required String status,
    required String mecanico,
    String? mecanico2,
    String? dataInicio,
    String? horaInicio,
    String? dataInicioPausa,
    String? dataFim,
    String? horaFim,
  }) async {
    try {
      final response = await _dio.put(
        '$_baseUrl/rest/zws_zmp/update',
        data: {
          'num': numero,
          'status': status,
          'mecani': mecanico,
          'mecan2': mecanico2 ?? '',
          'dtini': dataInicio ?? '',
          'hrini': horaInicio ?? '',
          'dtipsa': dataInicioPausa ?? '',
          'dtfim': dataFim ?? '',
          'hrfim': horaFim ?? '',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Falha ao atualizar status do chamado');
      }
    } catch (e) {
      throw Exception('Erro ao atualizar status do chamado: $e');
    }
  }

  Future<void> adicionarMecanico({
    required String numero,
    required String mecanico2,
  }) async {
    try {
      final response = await _dio.put(
        '$_baseUrl/rest/zws_zmp/mecanico',
        data: {
          'num': numero,
          'mecan2': mecanico2,
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Falha ao adicionar mecânico');
      }
    } catch (e) {
      throw Exception('Erro ao adicionar mecânico: $e');
    }
  }
} 