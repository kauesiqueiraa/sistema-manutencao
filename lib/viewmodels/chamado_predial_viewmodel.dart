import 'package:flutter/foundation.dart';
import 'package:sistema_manutencao/services/mecanico_service.dart';
import '../models/chamado_predial_model.dart';
import '../services/chamado_predial_service.dart';
import 'package:flutter/material.dart';
import '../models/mecanico_model.dart';

class ChamadoPredialViewModel extends ChangeNotifier {
  final ChamadoPredialService _service;
  final MecanicoService _mecanicoService;
  List<ChamadoPredialModel> _chamados = [];
  List<ChamadoPredialModel> _chamadosFiltrados = [];
  List<Map<String, String>> _mecanicos = [];
  bool _isLoading = false;
  String _error = '';
  String _statusFiltro = '';
  DateTime? _dataInicio;
  DateTime? _dataFim;
  String _chapaFiltro = '';
  String _linhaFiltro = '';
  String _userMatricula = '';
  List<MecanicoModel> _mecanicosList = [];

  ChamadoPredialViewModel(this._service, this._mecanicoService);

  List<ChamadoPredialModel> get chamados => _chamados;
  List<ChamadoPredialModel> get chamadosFiltrados => _chamadosFiltrados;
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

      final chamados = await _service.getChamados();
      _chamados = chamados;

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
      // Se o filtro de status for 4, mostra apenas finalizados
      if (_statusFiltro == '4') {
        return chamado.status == '4';
      }
      // Se não for 4, mostra todos exceto finalizados
      if (chamado.status == '4') {
        return false;
      }
      // Aplica os outros filtros
      if (_statusFiltro.isNotEmpty && chamado.status != _statusFiltro) {
        return false;
      }
      if (_dataInicio != null && DateTime.parse(chamado.dataSolicitacao).isBefore(_dataInicio!)) {
        return false;
      }
      if (_dataFim != null && DateTime.parse(chamado.dataSolicitacao).isAfter(_dataFim!)) {
        return false;
      }
      if (_chapaFiltro.isNotEmpty && !chamado.emp.toLowerCase().contains(_chapaFiltro.toLowerCase())) {
        return false;
      }
      if (_linhaFiltro.isNotEmpty && !chamado.setor.toLowerCase().contains(_linhaFiltro.toLowerCase())) {
        return false;
      }
      return true;
    }).toList();
  }

  void alterarFiltroStatus(String status) {
    _statusFiltro = status;
    _aplicarFiltros();
    notifyListeners();
  }

  void alterarPeriodo(DateTime? inicio, DateTime? fim) {
    _dataInicio = inicio;
    _dataFim = fim;
    _aplicarFiltros();
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
    String? dataInicioPausa,
    String? horaInicioPausa,
    String? dataFimPausa,
    String? horaFimPausa,
    String? dataFim,
    String? horaFim,
    String? observacaoMecanico,
  }) async {
    try {
      // Validação da observação do mecânico apenas para finalização
      if (status == '4' && (observacaoMecanico == null || observacaoMecanico.isEmpty)) {
        _error = 'É necessário informar uma observação ao finalizar o chamado';
        notifyListeners();
        return;
      }

      await _service.atualizarStatus(
        numero: numero,
        status: status,
        mecanico: mecanico,
        mecanico2: mecanico2,
        dataInicio: dataInicio,
        horaInicio: horaInicio,
        dataInicioPausa: dataInicioPausa,
        horaInicioPausa: horaInicioPausa,
        dataFimPausa: dataFimPausa,
        horaFimPausa: horaFimPausa,
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
        dataInicio: '00/00/00',
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

  Future<void> adicionarSegundoMecanico(String numeroChamado, String matricula, String segundoMecanico) async {
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
        mecanico2: segundoMecanico,
        dataInicio: '00/00/00',
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

  Future<void> carregarMecanicos() async {
    try {
      final mecanicosList = await _mecanicoService.getMecanicos(setor: 'I');
      _mecanicos = mecanicosList.map((mecanico) => {
        'nome': mecanico.nome,
        'matricula': mecanico.matricula,
      }).toList();
      _mecanicosList = mecanicosList;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
} 