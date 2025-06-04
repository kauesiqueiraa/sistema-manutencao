import 'package:flutter/material.dart';
import '../models/chamado_preventivo_model.dart';
import '../services/chamado_preventivo_service.dart';

class ChamadoPreventivoViewModel extends ChangeNotifier {
  final ChamadoPreventivoService _service;
  List<ChamadoPreventivoModel> _chamados = [];
  bool _isLoading = false;
  String _error = '';
  String _statusFiltro = '123'; // Padrão: mostrar todos exceto finalizados
  DateTime? _dataInicio;
  DateTime? _dataFim;
  String _chapaFiltro = '';
  String _linhaFiltro = '';

  ChamadoPreventivoViewModel(this._service);

  List<ChamadoPreventivoModel> get chamados => _chamados;
  bool get isLoading => _isLoading;
  String get error => _error;
  String get statusFiltro => _statusFiltro;
  DateTime? get dataInicio => _dataInicio;
  DateTime? get dataFim => _dataFim;
  String get chapaFiltro => _chapaFiltro;
  String get linhaFiltro => _linhaFiltro;

  List<ChamadoPreventivoModel> get chamadosFiltrados {
    if (_statusFiltro.isEmpty) return _chamados;
    return _chamados.where((c) => _statusFiltro.contains(c.status)).toList();
  }

  Future<void> carregarChamados() async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      String? dataInicioStr;
      String? dataFimStr;

      if (_dataInicio != null && _dataFim != null) {
        dataInicioStr = '${_dataInicio!.year}${_dataInicio!.month.toString().padLeft(2, '0')}${_dataInicio!.day.toString().padLeft(2, '0')}';
        dataFimStr = '${_dataFim!.year}${_dataFim!.month.toString().padLeft(2, '0')}${_dataFim!.day.toString().padLeft(2, '0')}';
      }

      _chamados = await _service.getChamados(
        status: _statusFiltro,
        dataInicio: dataInicioStr,
        dataFim: dataFimStr,
        chapa: _chapaFiltro.isNotEmpty ? _chapaFiltro : null,
        linha: _linhaFiltro.isNotEmpty ? _linhaFiltro : null,
      );
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void alterarFiltroStatus(String status) {
    _statusFiltro = status;
    notifyListeners();
  }

  void alterarPeriodo(DateTime? inicio, DateTime? fim) {
    _dataInicio = inicio;
    _dataFim = fim;
    notifyListeners();
  }

  void alterarFiltroChapa(String chapa) {
    _chapaFiltro = chapa;
    notifyListeners();
  }

  void alterarFiltroLinha(String linha) {
    _linhaFiltro = linha;
    notifyListeners();
  }

  Future<void> atualizarStatus({
    required String numero,
    required String status,
    required String mecanico,
    String? observacaoMecanico,
  }) async {
    try {
      String? dataInicioStr;
      String? horaInicioStr;

      if (status == '3') { // Em Atendimento
        final now = DateTime.now();
        dataInicioStr = '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
        horaInicioStr = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';
      }

      await _service.atualizarStatus(
        numero: numero,
        status: status,
        mecanico: mecanico,
        dataInicio: dataInicioStr,
        horaInicio: horaInicioStr,
        observacaoMecanico: observacaoMecanico,
      );
      await carregarChamados();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
} 