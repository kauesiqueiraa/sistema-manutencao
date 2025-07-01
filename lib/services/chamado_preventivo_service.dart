import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:sistema_manutencao/services/dio_service.dart';
import 'package:sistema_manutencao/services/mecanico_service.dart';
import 'package:sistema_manutencao/utils/time_date.dart';
import '../models/chamado_preventivo_model.dart';
import '../exceptions/api_exception.dart';

class ChamadoPreventivoService {
  final String _baseUrl = dotenv.env['BASE_TESTE_URL'] ?? '';
  final MecanicoService _mecanicoService;

  ChamadoPreventivoService(this._mecanicoService);

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

    final response = await DioService.dio.get(
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
    String? mecanico,
    String? dataInicio,
    String? horaInicio,
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
            throw Exception('Você já está atendendo outro chamado. Finalize ou pause o atendimento atual antes de iniciar um novo.');
          }
          await _mecanicoService.updateMecanicoStatus(mecanico, 'A');
          if (dataInicio == '') {
            // Iniciar Atendimento
            data.addAll({
              'mecan': mecanico,
              'dtini': getDataAtual(),
              'hrini': getHoraAtual(),
            });
          } else {
            // Retomar Atendimento
            data.addAll({
              'dtfim': "",
            });
          }
          break;

        case '2': // Pausar
          await _mecanicoService.updateMecanicoStatus(mecanico!, 'D');
          data.addAll({
            'obsmec': observacaoMecanico ?? '',
          });
          break;

        case '4': // Finalizar
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
        '$_baseUrl/rest/zws_zmd/update',
        // options: Options(
        //   headers: {
        //     'Content-Type': 'application/json',
        //   },
        //   responseType: ResponseType.plain,
        // ),
        data: data,
      );

      if (response.statusCode != 200) {
        throw Exception('Erro ao atualizar status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro ao atualizar status do chamado: $e');
    }
  }

  Future<void> automatedCalendar(Map<String, dynamic> automatedCalendar) async {
    try {
      final jsonData = jsonEncode(automatedCalendar);

      final response = await DioService.dio.post(
        '$_baseUrl/rest/wsreppre',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
          responseType: ResponseType.plain,
        ),
        data: jsonData,
      );
      if (response.statusCode != 200) {
        throw Exception('Falha ao gerar nova preventiva. Código: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException.fromError(e);
    }
  }
} 