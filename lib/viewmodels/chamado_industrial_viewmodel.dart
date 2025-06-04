import 'package:flutter/material.dart';
import '../models/chamado_industrial_model.dart';
import '../services/chamado_industrial_service.dart';

class ChamadoIndustrialViewModel extends ChangeNotifier {
  final ChamadoIndustrialService _service;
  List<ChamadoIndustrialModel> _chamados = [];
  bool _isLoading = false;
  String _error = '';
  String _statusFiltro = '123'; // Padrão: mostrar todos exceto finalizados
  DateTime? _dataInicio;
  DateTime? _dataFim;

  ChamadoIndustrialViewModel(this._service);

  List<ChamadoIndustrialModel> get chamados => _chamados;
  bool get isLoading => _isLoading;
  String get error => _error;
  String get statusFiltro => _statusFiltro;
  DateTime? get dataInicio => _dataInicio;
  DateTime? get dataFim => _dataFim;

  List<ChamadoIndustrialModel> get chamadosFiltrados {
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

  Future<void> atualizarStatus({
    required String numero,
    required String status,
  }) async {
    try {
      String? dataInicioStr;
      String? dataFimStr;

      if (_dataInicio != null && _dataFim != null) {
        dataInicioStr = '${_dataInicio!.year}${_dataInicio!.month.toString().padLeft(2, '0')}${_dataInicio!.day.toString().padLeft(2, '0')}';
        dataFimStr = '${_dataFim!.year}${_dataFim!.month.toString().padLeft(2, '0')}${_dataFim!.day.toString().padLeft(2, '0')}';
      }

      await _service.atualizarStatus(
        numero: numero,
        status: status,
        dataInicio: dataInicioStr,
        dataFim: dataFimStr,
      );
      await carregarChamados();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> adicionarMecanico({
    required String numero,
    required String mecanico2,
  }) async {
    try {
      await _service.adicionarMecanico(
        numero: numero,
        mecanico2: mecanico2,
      );
      await carregarChamados();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
} 