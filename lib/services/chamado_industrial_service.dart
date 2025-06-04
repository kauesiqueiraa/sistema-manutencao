import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/chamado_industrial_model.dart';

class ChamadoIndustrialService {
  final Dio _dio;
  final String _baseUrl = dotenv.env['BASE_TESTE_URL'] ?? '';

  ChamadoIndustrialService(this._dio);

  Future<List<ChamadoIndustrialModel>> getChamados({
    String? status,
    String? dataInicio,
    String? dataFim,
  }) async {
    try {
      final queryParams = {
        'empfil': '0401',
        if (status != null) 'status': status,
        if (dataInicio != null) 'periodo': '$dataInicio-$dataFim',
      };

      final response = await _dio.get(
        '$_baseUrl/rest/zws_zmc/get_all',
        queryParameters: queryParams,
        options: Options(
          headers: {'Content-Type': 'application/json'},
          responseType: ResponseType.plain,
        ),
      );

      if (response.statusCode == 200) {
        final String responseData = response.data.toString();
        final List<dynamic> jsonList = jsonDecode(responseData);
        return jsonList.map((json) => ChamadoIndustrialModel.fromJson(json)).toList();
      }
      throw Exception('Falha ao carregar chamados');
    } catch (e) {
      throw Exception('Erro ao buscar chamados: $e');
    }
  }

  Future<void> atualizarStatus({
    required String numero,
    required String status,
    String? dataInicio,
    String? dataFim,
  }) async {
    try {
      final response = await _dio.put(
        '$_baseUrl/rest/zws_zmc/update',
        data: {
          'empfil': '0401',
          'status': status,
          if (dataInicio != null && dataFim != null)
            'periodo': '$dataInicio-$dataFim',
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
        '$_baseUrl/rest/zws_zmc/mecanico',
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