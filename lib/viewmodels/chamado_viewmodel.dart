import 'package:flutter/material.dart';
import '../models/chamado_model.dart';
import '../services/chamado_service.dart';

class ChamadoViewModel extends ChangeNotifier {
  final ChamadoService _service;
  List<ChamadoModel> _chamados = [];
  bool _isLoading = false;
  String _error = '';
  String _statusFiltro = '';

  ChamadoViewModel(this._service);

  List<ChamadoModel> get chamados => _chamados;
  bool get isLoading => _isLoading;
  String get error => _error;
  String get statusFiltro => _statusFiltro;

  List<ChamadoModel> get chamadosFiltrados {
    if (_statusFiltro.isEmpty) return _chamados;
    return _chamados.where((c) => c.status == _statusFiltro).toList();
  }

  Future<void> carregarChamados() async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      _chamados = await _service.getChamados();
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

  Future<void> atualizarStatus({
    required String numero,
    required String status,
    required String mecanico,
    String? mecanico2,
    String? dataInicio,
    String? horaInicio,
    String? dataInicioPausa,
    String? dataFim,
    String? horaFim,
  }) async {
    try {
      await _service.atualizarStatus(
        numero: numero,
        status: status,
        mecanico: mecanico,
        mecanico2: mecanico2,
        dataInicio: dataInicio,
        horaInicio: horaInicio,
        dataInicioPausa: dataInicioPausa,
        dataFim: dataFim,
        horaFim: horaFim,
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