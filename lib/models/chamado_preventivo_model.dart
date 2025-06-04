import 'package:flutter/material.dart';

class ChamadoPreventivoModel {
  final String filial;
  final String num;
  final String dataSolicitacao;
  final String horaSolicitacao;
  final String dataInicio;
  final String horaInicio;
  final String dataFim;
  final String horaFim;
  final String chapa;
  final String codigoBem;
  final String descricao;
  final String linha;
  final String defeito;
  final String descricaoDefeito;
  final String observacao;
  final String setor;
  final String mecanico;
  final String status;

  ChamadoPreventivoModel({
    required this.filial,
    required this.num,
    required this.dataSolicitacao,
    required this.horaSolicitacao,
    required this.dataInicio,
    required this.horaInicio,
    required this.dataFim,
    required this.horaFim,
    required this.chapa,
    required this.codigoBem,
    required this.descricao,
    required this.linha,
    required this.defeito,
    required this.descricaoDefeito,
    required this.observacao,
    required this.setor,
    required this.mecanico,
    required this.status,
  });

  factory ChamadoPreventivoModel.fromJson(Map<String, dynamic> json) {
    return ChamadoPreventivoModel(
      filial: json['filial']?.toString().trim() ?? '',
      num: json['num']?.toString().trim() ?? '',
      dataSolicitacao: json['dtsoli']?.toString().trim() ?? '',
      horaSolicitacao: json['hrsoli']?.toString().trim() ?? '',
      dataInicio: json['dtini']?.toString().trim() ?? '',
      horaInicio: json['hrini']?.toString().trim() ?? '',
      dataFim: json['dtfim']?.toString().trim() ?? '',
      horaFim: json['hrfim']?.toString().trim() ?? '',
      chapa: json['chapa']?.toString().trim() ?? '',
      codigoBem: json['codbem']?.toString().trim() ?? '',
      descricao: json['descri']?.toString().trim() ?? '',
      linha: json['linha']?.toString().trim() ?? '',
      defeito: json['defeito']?.toString().trim() ?? '',
      descricaoDefeito: json['descdef']?.toString().trim() ?? '',
      observacao: json['obs']?.toString().trim() ?? '',
      setor: json['setor']?.toString().trim() ?? '',
      mecanico: json['mecan']?.toString().trim() ?? '',
      status: json['status']?.toString().trim() ?? '',
    );
  }

  String get statusText {
    switch (status) {
      case '1':
        return 'Aberto';
      case '2':
        return 'Pausado';
      case '3':
        return 'Em Atendimento';
      case '4':
        return 'Finalizado';
      default:
        return 'Desconhecido';
    }
  }

  Color get statusColor {
    switch (status) {
      case '1':
        return Colors.blue;
      case '2':
        return Colors.orange;
      case '3':
        return Colors.green;
      case '4':
        return Colors.grey;
      default:
        return Colors.black;
    }
  }

  String get dataSolicitacaoFormatada {
    if (dataSolicitacao.length != 8) return dataSolicitacao;
    return '${dataSolicitacao.substring(6, 8)}/${dataSolicitacao.substring(4, 6)}/${dataSolicitacao.substring(0, 4)}';
  }

  String get dataInicioFormatada {
    if (dataInicio.length != 8) return dataInicio;
    return '${dataInicio.substring(6, 8)}/${dataInicio.substring(4, 6)}/${dataInicio.substring(0, 4)}';
  }

  String get dataFimFormatada {
    if (dataFim.length != 8) return dataFim;
    return '${dataFim.substring(6, 8)}/${dataFim.substring(4, 6)}/${dataFim.substring(0, 4)}';
  }
} 