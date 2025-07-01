import 'package:flutter/material.dart';
import 'package:sistema_manutencao/models/setor_model.dart';
import 'package:sistema_manutencao/services/inventory_service.dart';

class InventoryViewmodel extends ChangeNotifier{
  final InventoryService _inventoryService;

  List<SetorModel> _sectors = [];
  List<dynamic> _machines = [];
  bool _isLoading = false;
  bool chapaExist = false;
  String _error = '';

  List<SetorModel> get sectors => _sectors;
  List<dynamic> get machines => _machines;
  bool get isLoading => _isLoading;
  String get error => _error;

  InventoryViewmodel(this._inventoryService);

  Future<void> loadSectors(String setor) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      _sectors = await _inventoryService.fetchSectors(setor);
    } catch (e) {
      _error = 'Erro ao carregar setores: $e';
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadSectorInMaintence(String setor) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      _sectors = await _inventoryService.fetchSectors(setor);
    } catch (e) {
      print(e);
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> searchMachine(String chapa) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      _machines = await _inventoryService.searchMachineByChapa(chapa);
    } catch (e) {
      print(e);
    }
    _isLoading = false;
    notifyListeners();
  }

  void createNewMachine(Map<String, dynamic> machine) {
    _machines.add(machine);
    notifyListeners();
  }

  Future<void> searchChapa(String chapa) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final maquina = await _inventoryService.searchChapa(chapa);
      if (maquina.isNotEmpty) {
        _machines = maquina;
        chapaExist = true;
      } else {
        chapaExist = false;
      }
    } catch (e) {
      _error = 'Erro ao buscar máquinas por chapa: $e';
    }
  }
}