import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:sistema_manutencao/models/setor_model.dart';
import 'package:sistema_manutencao/services/dio_service.dart';

class InventoryService {
  final String baseUrl = dotenv.env['BASE_TESTE_URL'] ?? '';
  
  // searchInventory
  InventoryService();
  Future<List<dynamic>> getInventory(String sector) async {
    try {
      final response = await DioService.dio.get(
        "$baseUrl/rest/zws_zlm/get_all?",
        options: Options(
          headers: {'Content-Type': 'application/json'},
          responseType: ResponseType.plain,
        ),
      );
      if (response.statusCode == 200) {
        var decodedResponse = jsonDecode(response.data);
        List<dynamic> data = decodedResponse['objects'];
        return data.where((status) => status['linha'] == sector && status['dtfim'] == '00/00/00').toList();
      } else {
        throw Exception('Falha ao buscar máquinas do setor');
      }
    } catch (e) {
      throw Exception('Erro ao buscar máquinas do setor');
    }
  }

  Future<List<SetorModel>> fetchSectors(String setor) async {
    try {
      final query = setor == 'manuntecao' ? "ctab=XK" : "ctab=X8";
     
      final response = await DioService.dio.get("$baseUrl/rest/ZWSX5/get_all?$query");
      if (response.statusCode == 200) {
        List<dynamic> data = response.data['objects'];
        Set<SetorModel> uniqueSetor = data
            .where((e) => e['chave'] != '')
            .map((e) => SetorModel(e['chave'].trim(), e['descri'].trim())).toSet();
        return uniqueSetor.toList();
      }
      return [];
    } catch (e) {
      throw Exception('Erro ao buscar setores');
    }
  }

  Future<List<dynamic>> fetchHistoryByChapa(String chapa) async {
    try {
      final response = await DioService.dio.get(
        "$baseUrl/rest/zws_zlm/get_all?",
        options: Options(
          headers: {'Content-Type': 'application/json'},
          responseType: ResponseType.plain,
        ),
      );
      if (response.statusCode == 200) {
        var decodedResponse = jsonDecode(response.data);
        List<dynamic> data = decodedResponse['objects'];

        List<dynamic> history = data.where((item) => item['chapa'] == chapa).toList();

        history.sort((a, b) {
          DateTime dateA = a['dtfim'] == '00/00/00'
              ? DateTime(9999, 12, 31)
              : DateTime.parse(a['dtfim'].replaceAll('/', '-'));
          DateTime dateB = b['dtfim'] == '00/00/00'
              ? DateTime(9999, 12, 31)
              : DateTime.parse(b['dtfim'].replaceAll('/', '-'));
          
          return dateB.compareTo(dateA);
        });
        return history;
      }
      return [];
    } catch (e) {
      throw Exception('Erro ao buscar histórico da máquina');
    }
  }

  Future<List<dynamic>> searchMachineByChapa(String chapa) async {
    try {
      final response = await DioService.dio.get(
        "$baseUrl/rest/zws_zlm/get_all?",
        options: Options(
          headers: {'Content-Type': 'application/json'},
          responseType: ResponseType.plain,
        ),
      );
      if (response.statusCode == 200) {
        var decodedResponse = jsonDecode(response.data);
        List<dynamic> data = decodedResponse['objects'];

        return data.where((status) => status['chapa'].trim() == chapa && status['dtfim'] == '00/00/00').toList();
      }
       return [];
    } catch (e) {
      throw Exception('Erro ao buscar máquinas do setor');
    }
  }

  Future<void> updateMachineSector(String chapa, String dtfim, String hrfim, String linha) async {
    try {
      final response = await DioService.dio.put(
        "$baseUrl/rest/zws_zlm/update",
        data: {
          'chapa': chapa,
          'linha': linha,
          'dtfim': dtfim,
          'hrfim': hrfim,
        }
      );
      if (response.statusCode == 200) {
        return;
      }
      throw Exception('Erro ao atualizar o Setor da máquina');
    } catch (e) {
      throw Exception('Erro ao atualizar máquina');
    }
  }

  Future<void> updateNewMachineSector(Map<String, dynamic> machine) async {
    try {
      machine.updateAll((key, value) {
        if (value is String) {
          return value.trim();
        }
        return value;
      });
      final jsonData = json.encode(machine);

      final response = await DioService.dio.post(
        "$baseUrl/rest/zws_zlm/",
        options: Options(
          headers: {'Content-Type': 'application/json'},
          responseType: ResponseType.plain,
        ),
        data: jsonData,
      );
      if (response.statusCode != 200) {
        throw Exception("Erro ao Inserir máquina no novo setor ${response.data}");
      }
    } catch (e) {
      throw Exception('Erro ao Inserir linha no BD, maquina não foi para novo setor! Erro: $e');
    }
  }

  Future<List<dynamic>> searchChapa(String chapa) async {
    try {
      final response = await DioService.dio.get("$baseUrl/rest/ZWSATF/get_all?cchapa=$chapa");

      if (response.statusCode == 200) {
        List<dynamic> data = response.data['objects'];

        List<Map<String, dynamic>> maquina = data
          .map<Map<String, dynamic>>((maquina) {
            return (maquina as Map<String, dynamic>).map((key, value) {
              return MapEntry(key, value.toString().trim());
          });
        }).toList();
        return maquina.where((maquina) => maquina['chapa'] == chapa.trim()).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Erro ao buscar máquinas por chapa: $e');
    }
  }

}