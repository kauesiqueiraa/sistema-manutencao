import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../exceptions/api_exception.dart';
import '../models/preventivo_model.dart';

class PreventivoService {
  final Dio _dio;
  final String _baseUrl = dotenv.env['BASE_TESTE_URL'] ?? '';

  PreventivoService(this._dio);

  Future<List<PreventivoModel>> getPreventivos({
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
        return jsonList.map((json) => PreventivoModel.fromJson(json)).toList();
      }

      throw ApiException(
        message: 'Erro ao buscar preventivos',
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
    String? pausa,
  }) async {
    try {
      Map<String, dynamic> data = {'num': numero, 'status': status};

      switch (status) {
        case '3': // Iniciar ou Retomar Atendimento
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
              'pausa': 'N',
              'dtfim': "",
            });
          }
          break;

        case '2': // Pausar
          data.addAll({
            'pausa': 'S',
            'obsmec': observacaoMecanico ?? '',
          });
          break;

        case '4': // Finalizar
          if (observacaoMecanico == null || observacaoMecanico.isEmpty) {
            throw ApiException(
              message: 'É necessário informar uma observação ao finalizar o preventivo',
            );
          }
          data.addAll({
            'dtfim': getDataAtual(),
            'hrfim': getHoraAtual(),
            'obsmec': observacaoMecanico,
            'pausa': 'N'
          });
          break;
      }

      final response = await _dio.put(
        '$_baseUrl/rest/zws_zmc/update',
        data: data,
      );

      if (response.statusCode != 200) {
        throw ApiException(
          message: 'Erro ao atualizar status do preventivo',
          statusCode: response.statusCode,
          data: response.data,
        );
      }
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    } catch (e) {
      throw ApiException.fromError(e);
    }
  }

  String getDataAtual() {
    final now = DateTime.now();
    return '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
  }

  String getHoraAtual() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';
  }
} 