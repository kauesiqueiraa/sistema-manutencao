import 'package:flutter/material.dart';
import '../models/produto_model.dart';
import '../services/produto_service.dart';

class ProdutoViewModel extends ChangeNotifier {
  final ProdutoService _service;
  List<ProdutoModel> _produtos = [];
  bool _isLoading = false;
  String _error = '';

  ProdutoViewModel(this._service);

  List<ProdutoModel> get produtos => _produtos;
  bool get isLoading => _isLoading;
  String get error => _error;

  Future<void> buscarProdutos(String query) async {
    if (query.isEmpty) {
      _produtos = [];
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      _produtos = await _service.buscarProdutos(query);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
} 