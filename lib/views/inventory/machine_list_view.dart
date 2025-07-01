import 'package:flutter/material.dart';
import 'package:sistema_manutencao/services/inventory_service.dart';
import 'package:sistema_manutencao/services/dio_service.dart';

class MachineListView extends StatefulWidget {
  final String setorKey;
  final String setorDesc;
  const MachineListView({Key? key, required this.setorKey, required this.setorDesc}) : super(key: key);

  @override
  State<MachineListView> createState() => _MachineListViewState();
}

class _MachineListViewState extends State<MachineListView> {
  late final InventoryService _service;
  bool _isLoading = true;
  String _error = '';
  List<dynamic> _machines = [];

  @override
  void initState() {
    super.initState();
    _service = InventoryService();
    _loadMachines();
  }

  Future<void> _loadMachines() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });
    try {
      final machines = await _service.getInventory(widget.setorKey);
      setState(() {
        _machines = machines;
      });
    } catch (e) {
      setState(() {
        _error = 'Erro ao carregar máquinas: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showHistory(BuildContext context, String chapa) async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return FutureBuilder<List<dynamic>>(
          future: _service.fetchHistoryByChapa(chapa),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.all(24.0),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            if (snapshot.hasError) {
              return Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text('Erro ao buscar histórico: ${snapshot.error}', style: const TextStyle(color: Colors.red)),
              );
            }
            final history = snapshot.data ?? [];
            if (history.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(24.0),
                child: Text('Nenhum histórico encontrado.'),
              );
            }
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Histórico da Máquina', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 300,
                    child: ListView.builder(
                      itemCount: history.length,
                      itemBuilder: (context, index) {
                        final h = history[index];
                        return ListTile(
                          title: Text(h['descricao'] ?? ''),
                          subtitle: Text('Data: ${h['data'] ?? ''} - Setor: ${h['linha'] ?? ''}'),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Máquinas - ${widget.setorDesc}')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
              ? Center(child: Text(_error))
              : _machines.isEmpty
                  ? const Center(child: Text('Nenhuma máquina encontrada.'))
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: _machines.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final machine = _machines[index];
                        final isAtiva = (machine['dtfim'] ?? '00/00/00') == '00/00/00';
                        return Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  isAtiva ? Icons.check_circle : Icons.cancel,
                                  color: isAtiva ? Colors.green : Colors.red,
                                  size: 32,
                                ),
                                const SizedBox(width: 18),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(machine['descricao'] ?? 'Sem descrição', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 4),
                                      Text('Chapa: ${machine['chapa'] ?? ''}', style: TextStyle(color: Colors.grey[700], fontSize: 14)),
                                      Text('Setor Atual: ${machine['linha'] ?? ''}', style: TextStyle(color: Colors.grey[700], fontSize: 14)),
                                      Text('Data da Entrada: ${machine['data'] ?? ''}', style: TextStyle(color: Colors.grey[700], fontSize: 14)),
                                      Text('Status: ${isAtiva ? 'Ativo' : 'Inativo'}', style: TextStyle(color: isAtiva ? Colors.green : Colors.red, fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          ElevatedButton.icon(
                                            onPressed: () => _showHistory(context, machine['chapa']),
                                            icon: const Icon(Icons.history),
                                            label: const Text('Histórico'),
                                            style: ElevatedButton.styleFrom(minimumSize: const Size(10, 36)),
                                          ),
                                          // Adicione outros botões de ação aqui se desejar
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}