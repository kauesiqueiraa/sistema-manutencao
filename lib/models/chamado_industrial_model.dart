import 'package:flutter/material.dart';

class ChamadoIndustrialModel {
  final String filial;
  final String num;
  final String linha;
  final String chapa;
  final String maq;
  final String solict;
  final String mecanico;
  final String mecanico2;
  final String dataSolicitacao;
  final String horaSolicitacao;
  final String dataInicio;
  final String horaInicio;
  final String dataFim;
  final String horaFim;
  final String dataFim2;
  final String horaFim2;
  final String origem;
  final String item;
  final String proximo;
  final String dataCotacao;
  final String horaCotacao;
  final String pausa;
  final String qtdOp;
  final String observacao;
  final String defeito;
  final String descricaoDefeito;
  final String status;

  ChamadoIndustrialModel({
    required this.filial,
    required this.num,
    required this.linha,
    required this.chapa,
    required this.maq,
    required this.solict,
    required this.mecanico,
    required this.mecanico2,
    required this.dataSolicitacao,
    required this.horaSolicitacao,
    required this.dataInicio,
    required this.horaInicio,
    required this.dataFim,
    required this.horaFim,
    required this.dataFim2,
    required this.horaFim2,
    required this.origem,
    required this.item,
    required this.proximo,
    required this.dataCotacao,
    required this.horaCotacao,
    required this.pausa,
    required this.qtdOp,
    required this.observacao,
    required this.defeito,
    required this.descricaoDefeito,
    required this.status,
  });

  factory ChamadoIndustrialModel.fromJson(Map<String, dynamic> json) {
    return ChamadoIndustrialModel(
      filial: json['filial']?.toString().trim() ?? '',
      num: json['num']?.toString().trim() ?? '',
      linha: json['linha']?.toString().trim() ?? '',
      chapa: json['chapa']?.toString().trim() ?? '',
      maq: json['maq']?.toString().trim() ?? '',
      solict: json['solict']?.toString().trim() ?? '',
      mecanico: json['mecan']?.toString().trim() ?? '',
      mecanico2: json['mecan2']?.toString().trim() ?? '',
      dataSolicitacao: json['dtsoli']?.toString().trim() ?? '',
      horaSolicitacao: json['hrsoli']?.toString().trim() ?? '',
      dataInicio: json['dtini']?.toString().trim() ?? '',
      horaInicio: json['hrini']?.toString().trim() ?? '',
      dataFim: json['dtfim']?.toString().trim() ?? '',
      horaFim: json['hrfim']?.toString().trim() ?? '',
      dataFim2: json['dtfim2']?.toString().trim() ?? '',
      horaFim2: json['hrfim2']?.toString().trim() ?? '',
      origem: json['origem']?.toString().trim() ?? '',
      item: json['item']?.toString().trim() ?? '',
      proximo: json['proximo']?.toString().trim() ?? '',
      dataCotacao: json['dtcot']?.toString().trim() ?? '',
      horaCotacao: json['hrcot']?.toString().trim() ?? '',
      pausa: json['pausa']?.toString().trim() ?? '',
      qtdOp: json['qtdop']?.toString().trim() ?? '',
      observacao: json['obs']?.toString().trim() ?? '',
      defeito: json['defeito']?.toString().trim() ?? '',
      descricaoDefeito: json['descdef']?.toString().trim() ?? '',
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
        return Colors.green;
      case '2':
        return Colors.pink;
      case '3':
        return Colors.yellow;
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
} 