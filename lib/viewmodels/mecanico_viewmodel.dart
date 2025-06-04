import 'package:flutter/material.dart';
import '../models/mecanico_model.dart';
import '../services/mecanico_service.dart';

class MecanicoViewModel extends ChangeNotifier {
  final MecanicoService _service;
  List<MecanicoModel> _mecanicos = [];
  bool _isLoading = false;
  String _error = '';
  String _setorSelecionado = 'I';

  MecanicoViewModel(this._service);

  List<MecanicoModel> get mecanicos => _mecanicos;
  bool get isLoading => _isLoading;
  String get error => _error;
  String get setorSelecionado => _setorSelecionado;

  Future<void> carregarMecanicos() async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      _mecanicos = await _service.getMecanicos(setor: _setorSelecionado);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void alterarSetor(String setor) {
    if (_setorSelecionado != setor) {
      _setorSelecionado = setor;
      carregarMecanicos();
    }
  }
} 