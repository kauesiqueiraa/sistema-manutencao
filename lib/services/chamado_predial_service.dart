import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/chamado_predial_model.dart';

class ChamadoPredialService {
  final Dio _dio;
  final String _baseUrl = dotenv.env['BASE_TESTE_URL'] ?? '';

  ChamadoPredialService(this._dio);

  String _getDataAtual() {
    final now = DateTime.now();
    return '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
  }

  String _getHoraAtual() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }

  Future<List<ChamadoPredialModel>> getChamados() async {
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
        // return data.map((json) => ChamadoPredialModel.fromJson(json)).toList();
        return data
            .map((json) => ChamadoPredialModel.fromJson(json))
            .where((chamado) => chamado.status != '4') // Remove chamados finalizados
            .toList();
      }
      return [];
    } catch (e) {
      throw Exception('Erro ao buscar chamados: $e');
    }
  }

  Future<void> atualizarStatus({
    required String numero,
    required String status,
    String? mecanico,
    String? mecanico2,
    String? dataInicio,
    String? horaInicio,
    String? dataInicioPausa,
    String? horaInicioPausa,
    String? dataFimPausa,
    String? horaFimPausa,
    String? dataFim,
    String? horaFim,
    String? observacaoMecanico,
  }) async {
    try {
      Map<String, dynamic> data = {'num': numero, 'status': status};

      switch (status) {
        case '3': // Iniciar ou Retomar Atendimento
          if (dataInicio == '00/00/00') {
            // Iniciar Atendimento
            data.addAll({
              'mecani': mecanico ?? '',
              'mecan2': mecanico2 ?? '',
              'dtini': _getDataAtual(),
              'hrini': _getHoraAtual(),
            });
          } else {
            // Retomar Atendimento
            data.addAll({
              'dtfpsa': _getDataAtual(),
              'hrfpsa': _getHoraAtual(),
            });
          }
          break;

        case '2': // Pausar
          data.addAll({
            'dtipsa': _getDataAtual(),
            'hripsa': _getHoraAtual(),
            'obsmec': observacaoMecanico ?? '',
          });
          break;

        case '4': // Finalizar
          if (observacaoMecanico == null || observacaoMecanico.isEmpty) {
            throw Exception('É necessário informar uma observação ao finalizar o chamado');
          }
          data.addAll({
            'dtfim': _getDataAtual(),
            'hrfim': _getHoraAtual(),
            'obsmec': observacaoMecanico,
          });
          break;
      }

      final response = await _dio.put(
        '$_baseUrl/rest/zws_zmp/update',
        data: data,
      );

      if (response.statusCode != 200) {
        throw Exception('Falha ao atualizar status do chamado');
      }
    } catch (e) {
      throw Exception('Erro ao atualizar status do chamado: $e');
    }
  }
}