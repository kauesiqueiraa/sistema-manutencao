import 'package:flutter/material.dart';
import '../models/chamado_preventivo_model.dart';
import '../services/chamado_preventivo_service.dart';

class ChamadoPreventivoViewModel extends ChangeNotifier {
  final ChamadoPreventivoService _service;
  List<ChamadoPreventivoModel> _chamados = [];
  List<ChamadoPreventivoModel> _chamadosFiltrados = [];
  final List<Map<String, String>> _mecanicos = [];
  bool _isLoading = false;
  String _error = '';
  String _statusFiltro = '123'; // Padrão: mostrar todos exceto finalizados
  DateTime? _dataInicio;
  DateTime? _dataFim;
  String _chapaFiltro = '';
  String _linhaFiltro = '';
  String _userMatricula = '';

  ChamadoPreventivoViewModel(this._service);

  List<ChamadoPreventivoModel> get chamados => _chamados;
  List<ChamadoPreventivoModel> get chamadosFiltrados => _chamadosFiltrados;
  List<Map<String, String>> get mecanicos => _mecanicos;
  bool get isLoading => _isLoading;
  String get error => _error;
  String get statusFiltro => _statusFiltro;
  DateTime? get dataInicio => _dataInicio;
  DateTime? get dataFim => _dataFim;
  String get chapaFiltro => _chapaFiltro;
  String get linhaFiltro => _linhaFiltro;
  String get userMatricula => _userMatricula;

  void setUserMatricula(String matricula) {
    _userMatricula = matricula;
    notifyListeners();
  } 

  // List<ChamadoPreventivoModel> get chamadosFiltrados {
  //   if (_statusFiltro.isEmpty) return _chamados;
  //   return _chamados.where((c) => _statusFiltro.contains(c.status)).toList();
  // }

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
        // chapa: _chapaFiltro.isNotEmpty ? _chapaFiltro : null,
        // linha: _linhaFiltro.isNotEmpty ? _linhaFiltro : null,
        

      );
      _aplicarFiltros();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _aplicarFiltros() {
    _chamadosFiltrados = _chamados.where((chamado) {
      if (_chapaFiltro.isNotEmpty && !chamado.chapa.toLowerCase().contains(_chapaFiltro.toLowerCase())) {
        return false;
      }
      if (_linhaFiltro.isNotEmpty && !chamado.linha.toLowerCase().contains(_linhaFiltro.toLowerCase())) {
        return false;
      }
      return true;
    }).toList();
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
    String? mecanico,
    String? dataInicio,
    String? horaInicio,
    String? dataFim,
    String? horaFim,
    String? observacaoMecanico,
  }) async {
    try {
      // String? dataInicioStr;
      // String? horaInicioStr;

      // if (status == '3') { // Em Atendimento
      //   final now = DateTime.now();
      //   dataInicioStr = '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
      //   horaInicioStr = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';
      // }

      await _service.atualizarStatus(
        numero: numero,
        status: status,
        mecanico: mecanico,
        dataInicio: dataInicio,
        horaInicio: horaInicio,
        dataFim: dataFim,
        horaFim: horaFim,
        observacaoMecanico: observacaoMecanico,
      );
      await carregarChamados();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> iniciarAtendimento(String numeroChamado, String matricula) async {
    try {
      _isLoading = true;
      _error = '';
      notifyListeners();

      if (matricula.isEmpty) {
        throw Exception('Usuário não é um mecânico');
      }

      await _service.atualizarStatus(
        numero: numeroChamado,
        status: '3',
        mecanico: matricula,
        dataInicio: '',
      );

      // Atualiza a lista de chamados
      await carregarChamados();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> finalizarAtendimento(String numeroChamado, String matricula, String observacao) async {
    try {
      _isLoading = true;
      _error = '';
      notifyListeners();

      if (matricula.isEmpty) {
        throw Exception('Usuário não é um mecânico');
      }

      await _service.atualizarStatus(
        numero: numeroChamado,
        status: '4',
        mecanico: matricula,
        observacaoMecanico: observacao,
      );

      // Atualiza a lista de chamados
      await carregarChamados();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
} 