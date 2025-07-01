import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:sistema_manutencao/exceptions/api_exception.dart';
import 'package:sistema_manutencao/services/dio_service.dart';
import 'package:sistema_manutencao/services/mecanico_service.dart';
import 'package:sistema_manutencao/utils/time_date.dart';
import '../models/chamado_predial_model.dart';

class ChamadoPredialService {
  final String _baseUrl = dotenv.env['BASE_TESTE_URL'] ?? '';
  final MecanicoService _mecanicoService;

  ChamadoPredialService(this._mecanicoService);

  Future<List<ChamadoPredialModel>> getChamados() async {
    try {
      final response = await DioService.dio.get(
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

  Future<bool> atualizarStatus({
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
          final mecanicoDisponivel = await _mecanicoService.findStatusMecanicoByMat(mecanico!);
          if (!mecanicoDisponivel) {
            return false;
          }
          await _mecanicoService.updateMecanicoStatus(mecanico, 'A');

          if (dataInicio == '00/00/00') {
            // Iniciar Atendimento
            data.addAll({
              'mecani': mecanico,
              'mecan2': mecanico2 ?? '',
              'dtini': getDataAtual(),
              'hrini': getHoraAtual(),
            });
          } else {
            // Retomar Atendimento
            data.addAll({
              'dtfpsa': getDataAtual(),
              'hrfpsa': getHoraAtual(),
            });
          }
          break;

        case '2': // Pausar
          await _mecanicoService.updateMecanicoStatus(mecanico!, 'D');
          data.addAll({
            'dtipsa': getDataAtual(),
            'hripsa': getHoraAtual(),
            'obsmec': observacaoMecanico ?? '',
          });
          break;

        case '4': // Finalizar
          if(mecanico2 != null && mecanico2.isNotEmpty) {
            await addSecondMecanic(numero, mecanico2);
          }
          if (observacaoMecanico == null || observacaoMecanico.isEmpty) {
            throw Exception('É necessário informar uma observação ao finalizar o chamado');
          }
          await _mecanicoService.updateMecanicoStatus(mecanico!, 'D');
          data.addAll({
            'dtfim': getDataAtual(),
            'hrfim': getHoraAtual(),
            'obsmec': observacaoMecanico,
          });
          break;
      }

      final response = await DioService.dio.put(
        '$_baseUrl/rest/zws_zmp/update',
        data: data,
      );

      if (response.statusCode != 200) {
        throw Exception('Falha ao atualizar status do chamado');
      }
      return true;
    } catch (e) {
      throw Exception('Erro ao atualizar status do chamado: $e');
    }
  }

  Future<void> addSecondMecanic(String num, String mecanico2) async {
    try { 
      final response = await DioService.dio.put(
        '$_baseUrl/rest/zws_zmp/mecanico',
        data: {
          'num': num,
          'mecan2': mecanico2,
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Falha ao adicionar o segundo mecânico');
      }
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    } catch (e) {
      throw ApiException.fromError(e);
    }
  }
}