import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/chamado_preventivo_model.dart';

class ChamadoPreventivoService {
  final Dio _dio;
  final String _baseUrl = dotenv.env['BASE_TESTE_URL'] ?? '';

  ChamadoPreventivoService(this._dio);

  Future<List<ChamadoPreventivoModel>> getChamados({
    String? status,
    String? dataInicio,
    String? dataFim,
    String? chapa,
    String? linha,
  }) async {
    final queryParams = {
      if (status != null) 'status': status,
      if (dataInicio != null) 'dataInicio': dataInicio,
      if (dataFim != null) 'dataFim': dataFim,
      if (chapa != null) 'chapa': chapa,
      if (linha != null) 'linha': linha,
    };

    final response = await _dio.get(
      '$_baseUrl/rest/zws_zmd/get_all',
      queryParameters: queryParams,
      options: Options(
        responseType: ResponseType.plain,
      ),
    );

    if (response.statusCode != 200) {
      throw Exception('Erro ao buscar chamados: ${response.statusCode}');
    }

    final String responseData = response.data.toString();
    final Map<String, dynamic> jsonResponse = jsonDecode(responseData);
    final List<dynamic> jsonList = jsonResponse['objects'] ?? [];
    
    return jsonList.map((json) => ChamadoPreventivoModel.fromJson(json)).toList();
  }

  Future<void> atualizarStatus({
    required String numero,
    required String status,
    required String mecanico,
    String? dataInicio,
    String? horaInicio,
    String? observacaoMecanico,
  }) async {
    final data = {
      'numero': numero,
      'status': status,
      'mecanico': mecanico,
      if (dataInicio != null) 'dataInicio': dataInicio,
      if (horaInicio != null) 'horaInicio': horaInicio,
      if (observacaoMecanico != null) 'observacaoMecanico': observacaoMecanico,
    };

    final response = await _dio.put(
      '$_baseUrl/rest/zws_zmd',
      data: data,
    );

    if (response.statusCode != 200) {
      throw Exception('Erro ao atualizar status: ${response.statusCode}');
    }
  }
} 