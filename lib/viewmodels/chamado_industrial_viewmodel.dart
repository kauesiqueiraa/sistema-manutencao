import 'package:flutter/foundation.dart';
import 'package:sistema_manutencao/services/mecanico_service.dart';
import '../models/chamado_industrial_model.dart';
import '../services/chamado_industrial_service.dart';
import 'package:flutter/material.dart';
import '../models/mecanico_model.dart';
import '../exceptions/api_exception.dart';

class ChamadoIndustrialViewModel extends ChangeNotifier {
  final ChamadoIndustrialService _service;
  final MecanicoService _mecanicoService;
  List<ChamadoIndustrialModel> _chamados = [];
  List<ChamadoIndustrialModel> _chamadosFiltrados = [];
  List<Map<String, String>> _mecanicos = [];
  bool _isLoading = false;
  String _error = '';
  String _statusFiltro = '123'; // Padrão: mostrar todos exceto finalizados
  DateTime? _dataInicio;
  DateTime? _dataFim;
  String _chapaFiltro = '';
  String _linhaFiltro = '';
  String _userMatricula = '';
  List<MecanicoModel> _mecanicosList = [];

  ChamadoIndustrialViewModel(this._service, this._mecanicoService);

  List<ChamadoIndustrialModel> get chamados => _chamados;
  List<ChamadoIndustrialModel> get chamadosFiltrados => _chamadosFiltrados;
  List<Map<String, String>> get mecanicos => _mecanicos;
  bool get isLoading => _isLoading;
  String get error => _error;
  String get statusFiltro => _statusFiltro;
  DateTime? get dataInicio => _dataInicio;
  DateTime? get dataFim => _dataFim;
  String get chapaFiltro => _chapaFiltro;
  String get linhaFiltro => _linhaFiltro;
  String get userMatricula => _userMatricula;
  List<MecanicoModel> get mecanicosList => _mecanicosList;

  void setUserMatricula(String matricula) {
    _userMatricula = matricula;
    notifyListeners();
  }

  Future<void> carregarChamados() async {
    try {
      _isLoading = true;
      _error = '';
      notifyListeners();

      String? dataInicioStr;
      String? dataFimStr;

      if (_dataInicio != null && _dataFim != null) {
        dataInicioStr = '${_dataInicio!.year}${_dataInicio!.month.toString().padLeft(2, '0')}${_dataInicio!.day.toString().padLeft(2, '0')}';
        dataFimStr = '${_dataFim!.year}${_dataFim!.month.toString().padLeft(2, '0')}${_dataFim!.day.toString().padLeft(2, '0')}';
      }

      final chamados = await _service.getChamados(
        status: _statusFiltro,
        dataInicio: dataInicioStr,
        dataFim: dataFimStr,
      );
      _chamados = chamados;

      _aplicarFiltros();
    } on ApiException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = 'Ocorreu um erro inesperado. Por favor, tente novamente.';
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
    carregarChamados();
  }

  void alterarPeriodo(DateTime? inicio, DateTime? fim) {
    _dataInicio = inicio;
    _dataFim = fim;
    carregarChamados();
    notifyListeners();
  }

  void resetarPeriodo() {
    _dataInicio = null;
    _dataFim = null;
    notifyListeners();
  }

  void alterarFiltroChapa(String chapa) {
    _chapaFiltro = chapa;
    _aplicarFiltros();
    notifyListeners();
  }

  void alterarFiltroLinha(String linha) {
    _linhaFiltro = linha;
    _aplicarFiltros();
    notifyListeners();
  }

  Future<void> atualizarStatus({
    required String numero,
    required String status,
    String? mecanico,
    String? mecanico2,
    String? dataInicio,
    String? horaInicio,
    String? dataFim,
    String? horaFim,
    String? observacaoMecanico,
    String? pausa,
  }) async {
    try {
      _isLoading = true;
      _error = '';
      notifyListeners();

      await _service.atualizarStatus(
        numero: numero,
        status: status,
        mecanico: mecanico,
        mecanico2: mecanico2,
        dataInicio: dataInicio,
        horaInicio: horaInicio,
        dataFim: dataFim,
        horaFim: horaFim,
        observacaoMecanico: observacaoMecanico,
      );

      // Atualiza a lista de chamados
      await carregarChamados();
      notifyListeners();
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
    } catch (e) {
      _error = 'Ocorreu um erro inesperado ao atualizar o status.';
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> carregarMecanicos() async {
    try {
      _error = '';
      final mecanicosList = await _mecanicoService.getMecanicos(setor: 'I');
      _mecanicos = mecanicosList.map((mecanico) => {
        'nome': mecanico.nome,
        'matricula': mecanico.matricula,
      }).toList();
      _mecanicosList = mecanicosList;
      notifyListeners();
    } catch (e) {
      _error = 'Ocorreu um erro inesperado ao adicionar o mecânico.';
      notifyListeners();
    }
  }

  Future<bool> mecanicoDiponivel(String matricula) async {
    try {
      _isLoading = true;
      _error = '';
      notifyListeners();

      final disponivel = await _mecanicoService.findStatusMecanicoByMat(matricula);
      // se retornar true, o mecanico está disponível
      // se retornar false, o mecanico está indisponível e deve ser mostrado um Dialog na tela
      return disponivel;

    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    return false;
  }
} 