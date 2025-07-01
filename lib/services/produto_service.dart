import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:sistema_manutencao/services/dio_service.dart';
import 'package:sistema_manutencao/utils/time_date.dart';
import '../models/produto_model.dart';
import '../exceptions/api_exception.dart';

class ProdutoService {
  final String _baseUrl = dotenv.env['BASE_TESTE_URL'] ?? '';

  ProdutoService();

  Future<List<ProdutoModel>> buscarProdutos(String query) async {
    try {
      final response = await DioService.dio.get(
        '$_baseUrl/rest/zws_sb1/get_all',
        queryParameters: {
          'descri': query,
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
          responseType: ResponseType.plain,),
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> datas = jsonDecode(response.data);
        final List<dynamic> data = datas['objects'] ?? [];
        return data.map((json) => ProdutoModel.fromJson(json)).toList();
      }
      throw ApiException(
        message: 'Erro ao buscar produtos',
        statusCode: response.statusCode,
        data: response.data,
      );
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException.fromError(e);
    }
  }

  // Produtos utilizados no chamados
  Future<void> saveInZHP(String num, String cod, String descri, int qtd, String chapa, String item, String os) async {
    try {
      final response = await DioService.dio.post(
        '$_baseUrl/rest/zws_zhp/',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
          responseType: ResponseType.plain,
        ),
        data: {
          "filial": "  ",
          "cod": num,
          "codnum": os, 
          "chapa": chapa, // chapa do chamado
          "dtini": getDataAtual(),
          "hrini": getHoraAtual(),
          "dtfim": getDataAtual(),
          "hrfim": getHoraAtual(),
          "item": item, 
          "codpro": cod, // aqui vem o código do produto
          "descri": descri, // aqui vem a descri do produto
          "qtd": qtd, // quantidade informada ao selecionar o produto
          "obs": "", 
          "img": ""
        }
      );
      if (response.statusCode != 200) {
        throw Exception('Falha ao finalizar o chamado. Código: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException.fromError(e);
    }
  }
} 