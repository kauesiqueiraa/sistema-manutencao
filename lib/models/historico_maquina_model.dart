import 'package:flutter/material.dart';

class HistoricoMaquinaModel {
  final String id;
  final String maquinaId;
  final String tipo;
  final String descricao;
  final String data;
  final String hora;
  final String responsavel;
  final String setorAnterior;
  final String setorNovo;
  final String observacoes;

  HistoricoMaquinaModel({
    required this.id,
    required this.maquinaId,
    required this.tipo,
    required this.descricao,
    required this.data,
    required this.hora,
    required this.responsavel,
    required this.setorAnterior,
    required this.setorNovo,
    required this.observacoes,
  });

  factory HistoricoMaquinaModel.fromJson(Map<String, dynamic> json) {
    return HistoricoMaquinaModel(
      id: json['id']?.toString().trim() ?? '',
      maquinaId: json['maquinaid']?.toString().trim() ?? '',
      tipo: json['tipo']?.toString().trim() ?? '',
      descricao: json['descricao']?.toString().trim() ?? '',
      data: json['data']?.toString().trim() ?? '',
      hora: json['hora']?.toString().trim() ?? '',
      responsavel: json['responsavel']?.toString().trim() ?? '',
      setorAnterior: json['setoranterior']?.toString().trim() ?? '',
      setorNovo: json['setornovo']?.toString().trim() ?? '',
      observacoes: json['observacoes']?.toString().trim() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'maquinaid': maquinaId,
      'tipo': tipo,
      'descricao': descricao,
      'data': data,
      'hora': hora,
      'responsavel': responsavel,
      'setoranterior': setorAnterior,
      'setornovo': setorNovo,
      'observacoes': observacoes,
    };
  }

  String get tipoText {
    switch (tipo) {
      case '1':
        return 'Cadastro';
      case '2':
        return 'Transferência de Setor';
      case '3':
        return 'Manutenção';
      case '4':
        return 'Atualização';
      case '5':
        return 'Inativação';
      default:
        return 'Desconhecido';
    }
  }

  Color get tipoColor {
    switch (tipo) {
      case '1':
        return Colors.green;
      case '2':
        return Colors.blue;
      case '3':
        return Colors.orange;
      case '4':
        return Colors.purple;
      case '5':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String get dataFormatada {
    if (data.length != 8) return data;
    return '${data.substring(6, 8)}/${data.substring(4, 6)}/${data.substring(0, 4)}';
  }

  String get dataHoraCompleta {
    return '$dataFormatada $hora';
  }
} 