import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:sistema_manutencao/services/dio_service.dart';
import 'package:sistema_manutencao/utils/time_date.dart';
import '../exceptions/api_exception.dart';
import '../models/chamado_industrial_model.dart';
// import '../services/mecanico_service.dart';

class ChamadoIndustrialService {
  final String _baseUrl = dotenv.env['BASE_TESTE_URL'] ?? '';
  // final MecanicoService _mecanicoService;

  ChamadoIndustrialService();
  // ChamadoIndustrialService(this._dio, this._mecanicoService);

  Future<List<ChamadoIndustrialModel>> getChamados({
    String? status,
    String? dataInicio,
    String? dataFim,
  }) async {
    try {
      final queryParams = {
        'empfil': '0401',
        if (status != null) 'status': status,
        if (dataInicio != null) 'periodo': '$dataInicio$dataFim',
      };

      final response = await DioService.dio.get(
        '$_baseUrl/rest/zws_zmc_new/get_all',
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

      throw ApiException(
        message: 'Erro ao buscar chamados',
        statusCode: response.statusCode,
        data: response.data,
      );
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    } catch (e) {
      throw ApiException.fromError(e);
    }
  }

  Future<void> atualizarStatus({
    required String numero,
    required String status,
    String? mecanico,
    String? mecanico2,
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
          // Verifica se o mecânico está disponível
          // final mecanicoDisponivel = await _mecanicoService.findStatusMecanicoByMat(mecanico!);
          // if (!mecanicoDisponivel) {
          //   throw Exception('Você já está atendendo outro chamado. Finalize ou pause o atendimento atual antes de iniciar um novo.');
          // }
          // await _mecanicoService.updateMecanicoStatus(mecanico, 'A');
          
          if (dataInicio == '') {
            // Iniciar Atendimento
            data.addAll({
              'mecan': mecanico ?? '',
              'dtini': getDataAtual(),
              'hrini': getHoraAtual(),
            });
          } else {
            // Retomar Atendimento
            data.addAll({
              'mecan': mecanico ?? '',
            });
          }
          break;

        case '2': // Pausar
          // await _mecanicoService.updateMecanicoStatus(mecanico!, 'D');
          data.addAll({
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
          // await _mecanicoService.updateMecanicoStatus(mecanico!, 'D');
          data.addAll({
            'dtfim': getDataAtual(),
            'hrfim': getHoraAtual(),
            'obsmec': observacaoMecanico,
          });
          break;
      }

      final response = await DioService.dio.put(
        '$_baseUrl/rest/zws_zmc_new/update',
        data: data,
      );

      if (response.statusCode != 200) {
        throw Exception('Falha ao atualizar status do chamado');
      }
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    } catch (e) {
      throw ApiException.fromError(e);
    }
  }

  Future<void> addSecondMecanic(String num, String mecanico2) async {
    try { 
      final response = await DioService.dio.put(
        '$_baseUrl/rest/zws_zmc_new/mecanico',
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