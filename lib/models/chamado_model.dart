import 'package:flutter/material.dart';

class ChamadoModel {
  final String filial;
  final String status;
  final String num;
  final String setor;
  final String solict;
  final String mecanico;
  final String mecanico2;
  final String emp;
  final String dataSolicitacao;
  final String horaSolicitacao;
  final String dataInicio;
  final String horaInicio;
  final String dataFim;
  final String horaFim;
  final String dataInicioPausa;
  final String horaInicioPausa;
  final String dataFimPausa;
  final String horaFimPausa;
  final String objetivo;
  final String observacao;
  final String observacaoMecanico;

  ChamadoModel({
    required this.filial,
    required this.status,
    required this.num,
    required this.setor,
    required this.solict,
    required this.mecanico,
    required this.mecanico2,
    required this.emp,
    required this.dataSolicitacao,
    required this.horaSolicitacao,
    required this.dataInicio,
    required this.horaInicio,
    required this.dataFim,
    required this.horaFim,
    required this.dataInicioPausa,
    required this.horaInicioPausa,
    required this.dataFimPausa,
    required this.horaFimPausa,
    required this.objetivo,
    required this.observacao,
    required this.observacaoMecanico,
  });

  factory ChamadoModel.fromJson(Map<String, dynamic> json) {
    return ChamadoModel(
      filial: json['filial']?.toString().trim() ?? '',
      status: json['status']?.toString().trim() ?? '',
      num: json['num']?.toString().trim() ?? '',
      setor: json['setor']?.toString().trim() ?? '',
      solict: json['solict']?.toString().trim() ?? '',
      mecanico: json['mecani']?.toString().trim() ?? '',
      mecanico2: json['mecan2']?.toString().trim() ?? '',
      emp: json['emp']?.toString().trim() ?? '',
      dataSolicitacao: json['dtsoli']?.toString().trim() ?? '',
      horaSolicitacao: json['hrsoli']?.toString().trim() ?? '',
      dataInicio: json['dtini']?.toString().trim() ?? '',
      horaInicio: json['hrini']?.toString().trim() ?? '',
      dataFim: json['dtfim']?.toString().trim() ?? '',
      horaFim: json['hrfim']?.toString().trim() ?? '',
      dataInicioPausa: json['dtipsa']?.toString().trim() ?? '',
      horaInicioPausa: json['hripsa']?.toString().trim() ?? '',
      dataFimPausa: json['dtfpsa']?.toString().trim() ?? '',
      horaFimPausa: json['hrfpsa']?.toString().trim() ?? '',
      objetivo: json['objeti']?.toString().trim() ?? '',
      observacao: json['obs']?.toString().trim() ?? '',
      observacaoMecanico: json['obsmec']?.toString().trim() ?? '',
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
} 