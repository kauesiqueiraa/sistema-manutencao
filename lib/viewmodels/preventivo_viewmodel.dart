import 'package:flutter/material.dart';
import '../exceptions/api_exception.dart';
import '../models/preventivo_model.dart';
import '../services/preventivo_service.dart';
import '../services/mecanico_service.dart';

class PreventivoViewModel extends ChangeNotifier {
  final PreventivoService _service;
  final MecanicoService _mecanicoService;
  List<PreventivoModel> _preventivos = [];
  List<PreventivoModel> _preventivosFiltrados = [];
  List<Map<String, String>> _mecanicos = [];
  bool _isLoading = false;
  String _error = '';
  String _statusFiltro = '123';
  DateTime? _dataInicio;
  DateTime? _dataFim;
  String _chapaFiltro = '';
  String _linhaFiltro = '';
  String _userMatricula = '';

  PreventivoViewModel(this._service, this._mecanicoService);

  List<PreventivoModel> get preventivos => _preventivos;
  List<PreventivoModel> get preventivosFiltrados => _preventivosFiltrados;
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

  Future<void> carregarPreventivos() async {
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

      final preventivos = await _service.getPreventivos(
        status: _statusFiltro,
        dataInicio: dataInicioStr,
        dataFim: dataFimStr,
      );
      _preventivos = preventivos;
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
    _preventivosFiltrados = _preventivos.where((preventivo) {
      if (_chapaFiltro.isNotEmpty && !preventivo.chapa.toLowerCase().contains(_chapaFiltro.toLowerCase())) {
        return false;
      }
      if (_linhaFiltro.isNotEmpty && !preventivo.linha.toLowerCase().contains(_linhaFiltro.toLowerCase())) {
        return false;
      }
      return true;
    }).toList();
  }

  void alterarFiltroStatus(String status) {
    _statusFiltro = status;
    carregarPreventivos();
  }

  void alterarPeriodo(DateTime? inicio, DateTime? fim) {
    _dataInicio = inicio;
    _dataFim = fim;
    carregarPreventivos();
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
        pausa: pausa,
      );

      await carregarPreventivos();
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

  Future<void> iniciarAtendimento(String numeroPreventivo, String matricula) async {
    try {
      _isLoading = true;
      _error = '';
      notifyListeners();

      if (matricula.isEmpty) {
        throw ApiException(message: 'Usuário não é um mecânico');
      }

      await _service.atualizarStatus(
        numero: numeroPreventivo,
        status: '3',
        mecanico: matricula,
        dataInicio: '00/00/00',
      );

      await carregarPreventivos();
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
    } catch (e) {
      _error = 'Ocorreu um erro inesperado ao iniciar o atendimento.';
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> pausarAtendimento(String numeroPreventivo, String observacao) async {
    try {
      _isLoading = true;
      _error = '';
      notifyListeners();

      await _service.atualizarStatus(
        numero: numeroPreventivo,
        status: '2',
        observacaoMecanico: observacao,
      );

      await carregarPreventivos();
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
    } catch (e) {
      _error = 'Ocorreu um erro inesperado ao pausar o atendimento.';
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> finalizarAtendimento(String numeroPreventivo, String matricula, String observacao) async {
    try {
      _isLoading = true;
      _error = '';
      notifyListeners();

      await _service.atualizarStatus(
        numero: numeroPreventivo,
        status: '4',
        mecanico2: matricula,
        observacaoMecanico: observacao,
      );

      await carregarPreventivos();
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
    } catch (e) {
      _error = 'Ocorreu um erro inesperado ao finalizar o atendimento.';
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
    } on ApiException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = 'Ocorreu um erro inesperado ao carregar mecânicos.';
    } finally {
      notifyListeners();
    }
  }
} 