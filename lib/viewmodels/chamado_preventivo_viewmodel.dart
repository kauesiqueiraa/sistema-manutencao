import 'package:flutter/material.dart';
import 'package:sistema_manutencao/utils/time_date.dart';
import '../models/chamado_preventivo_model.dart';
import '../models/produto_selecionado_model.dart';
import '../services/chamado_preventivo_service.dart';
import '../services/produto_service.dart';

class ChamadoPreventivoViewModel extends ChangeNotifier {
  final ChamadoPreventivoService _service;
  final ProdutoService _produtoService;
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
  Map<String, List<ProdutoSelecionadoModel>> produtosPorChamado = {};

  ChamadoPreventivoViewModel(this._service, this._produtoService);

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

  List<ProdutoSelecionadoModel> getProdutosChamado(String chamadoNumero) {
    return produtosPorChamado[chamadoNumero] ?? [];
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

  void adicionarProdutos(String chamadoNumero, List<ProdutoSelecionadoModel> produtos) {
    if (produtosPorChamado.containsKey(chamadoNumero)) {
      produtosPorChamado[chamadoNumero]!.addAll(produtos);
    } else {
      produtosPorChamado[chamadoNumero] = produtos;
    }
    notifyListeners();
  }

  Future<void> finalizarChamado(
      String chamadoNumero,
      List<ProdutoSelecionadoModel> produtos,
      String chapa,
    ) async {
    try {
      _isLoading = true;
      _error = '';
      notifyListeners();

      // Salva os produtos no ZHP
      if (produtos.isNotEmpty) {
        List<Future> productRequests = [];
        int itemCount = 1;

        for (int i = 0; i < produtos.length; i++) {
          final produto = produtos[i];
          final itemFormatted = itemCount.toString().padLeft(3, '0');

          productRequests.add(_produtoService.saveInZHP(
            chamadoNumero,
            produto.codigo,
            produto.descricao,
            int.parse(produto.quantidade),
            chapa, // máquina
            itemFormatted,
            chamadoNumero, // OS
          ));
          itemCount++;
        }
        await Future.wait(productRequests);
      }

      Map<String, dynamic> automatedCalendar = {
        'empresa': "040",
        'filial': "01",
        'chapa':  chapa,
        'datapreve': getDataAtual(),
      };
      // Atualiza o calendário de chamados preventivos
      await _service.automatedCalendar(automatedCalendar);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
} 