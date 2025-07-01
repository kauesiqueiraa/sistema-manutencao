import 'package:flutter/material.dart';
import 'package:sistema_manutencao/services/inventory_service.dart';
import 'package:sistema_manutencao/services/dio_service.dart';
import 'package:provider/provider.dart';
import 'package:sistema_manutencao/viewmodels/inventory_viewmodel.dart';

class MachineView extends StatefulWidget {
  const MachineView({Key? key}) : super(key: key);

  @override
  State<MachineView> createState() => _MachineViewState();
}

class _MachineViewState extends State<MachineView> {
  final InventoryService _service = InventoryService();
  final TextEditingController _searchController = TextEditingController();
  Map<String, dynamic>? _machine;
  bool _isLoading = false;
  String _error = '';
  List<dynamic> _history = [];
  bool _showHistory = false;

  Future<void> _searchMachine() async {
    setState(() {
      _isLoading = true;
      _error = '';
      _machine = null;
      _history = [];
      _showHistory = false;
    });
    try {
      final result = await _service.searchMachineByChapa(_searchController.text.trim());
      if (result.isNotEmpty) {
        setState(() {
          _machine = result.first;
        });
      } else {
        setState(() {
          _error = 'Máquina não encontrada.';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Erro ao buscar máquina: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadHistory() async {
    if (_machine == null) return;
    setState(() {
      _isLoading = true;
      _error = '';
    });
    try {
      final history = await _service.fetchHistoryByChapa(_machine!['chapa']);
      setState(() {
        _history = history;
        _showHistory = true;
      });
    } catch (e) {
      setState(() {
        _error = 'Erro ao buscar histórico: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _changeSector() async {
    if (_machine == null) return;
    final setores = await InventoryService().fetchSectors('outros');
    String? setorSelecionado;
    final result = await showDialog<String>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Alterar setor da máquina'),
            content: DropdownButtonFormField<String>(
              value: setorSelecionado,
              items: setores.map((s) => DropdownMenuItem(
                value: s.chave,
                child: Text(s.descri),
              )).toList(),
              onChanged: (v) => setState(() => setorSelecionado = v),
              decoration: const InputDecoration(labelText: 'Novo setor'),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
              ElevatedButton(
                onPressed: setorSelecionado == null ? null : () => Navigator.pop(context, setorSelecionado),
                child: const Text('Alterar'),
              ),
            ],
          );
        },
      ),
    );
    if (result != null && result.isNotEmpty) {
      setState(() { _isLoading = true; _error = ''; });
      try {
        await _service.updateMachineSector(
          _machine!['chapa'],
          DateTime.now().toString().substring(0,10).replaceAll('-', '/'),
          TimeOfDay.now().format(context),
          result,
        );
        setState(() { _error = 'Setor alterado com sucesso!'; });
      } catch (e) {
        setState(() { _error = 'Erro ao alterar setor: $e'; });
      } finally {
        setState(() { _isLoading = false; });
      }
    }
  }

  String _getStatus(Map<String, dynamic> machine) {
    // Considera ativa se dtfim == '00/00/00', inativa caso contrário
    return (machine['dtfim'] == '00/00/00') ? 'Ativa' : 'Inativa';
  }

  void _showRegisterMachineDialog(BuildContext context) async {
    final inventoryViewmodel = Provider.of<InventoryViewmodel>(context, listen: false);
    String chapa = _searchController.text.trim();
    await inventoryViewmodel.searchChapa(chapa);
    final chapaExist = inventoryViewmodel.chapaExist;
    final maquina = inventoryViewmodel.machines; // ou .machines se houver getter

    final setores = await InventoryService().fetchSectors('outros');
    String descricao = chapaExist && maquina.isNotEmpty ? (maquina[0]['descri'] ?? '') : '';
    String? setorSelecionado;
    String frequencia = 'Diária';
    String intervalo = '';
    String dataCadastro = DateTime.now().toString().substring(0, 10);
    final descricaoController = TextEditingController(text: descricao);
    final intervaloController = TextEditingController();
    final dataCadastroController = TextEditingController(text: dataCadastro);

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Cadastrar Nova Máquina'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (chapaExist && maquina.isNotEmpty) ...[
                      const Text("Informações da Máquina:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Card(
                        color: Colors.grey[100],
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Chapa: ${maquina[0]['chapa']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                              Text('Codbem: ${maquina[0]['cbase'] ?? ''}'),
                              Text('Nome Máquina: ${maquina[0]['descri'] ?? ''}'),
                            ],
                          ),
                        ),
                      ),
                    ] else ...[
                      const Text('Não foi encontrada máquina com essa chapa no Ativo Fixo.', style: TextStyle(color: Colors.red)),
                    ],
                    const SizedBox(height: 8),
                    TextFormField(
                      initialValue: chapa,
                      enabled: false,
                      decoration: const InputDecoration(labelText: 'Chapa', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: descricaoController,
                      decoration: const InputDecoration(labelText: 'Descrição da máquina', border: OutlineInputBorder()),
                      onChanged: (v) => descricao = v,
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: setorSelecionado,
                      items: setores.map((s) => DropdownMenuItem(
                        value: s.chave,
                        child: Text(s.descri),
                      )).toList(),
                      onChanged: (v) => setState(() => setorSelecionado = v),
                      decoration: const InputDecoration(labelText: 'Setor', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: frequencia,
                      items: const [
                        DropdownMenuItem(value: 'Diária', child: Text('Diária')),
                        DropdownMenuItem(value: 'Mensal', child: Text('Mensal')),
                        DropdownMenuItem(value: 'Anual', child: Text('Anual')),
                      ],
                      onChanged: (v) => setState(() => frequencia = v!),
                      decoration: const InputDecoration(labelText: 'Frequência', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: intervaloController,
                      decoration: const InputDecoration(labelText: 'Intervalo de Preventiva', border: OutlineInputBorder()),
                      onChanged: (v) => intervalo = v,
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () async {
                        DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.tryParse(dataCadastro) ?? DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          setState(() {
                            dataCadastro = picked.toString().substring(0, 10);
                            dataCadastroController.text = dataCadastro;
                          });
                        }
                      },
                      child: AbsorbPointer(
                        child: TextField(
                          controller: dataCadastroController,
                          decoration: const InputDecoration(labelText: 'Data de Cadastro', border: OutlineInputBorder()),
                          readOnly: true,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (descricaoController.text.isEmpty || setorSelecionado == null || intervaloController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Preencha todos os campos obrigatórios.')));
                      return;
                    }
                    final machine = {
                      'chapa': chapa,
                      'descricao': descricaoController.text,
                      'linha': setorSelecionado,
                      'frequencia': frequencia,
                      'intervalo': intervaloController.text,
                      'datacad': dataCadastro,
                    };
                    try {
                      await InventoryService().updateNewMachineSector(machine);
                      if (mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Máquina cadastrada com sucesso!')));
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao cadastrar: $e')));
                    }
                  },
                  child: const Text('Salvar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Buscar Máquina', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22))),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: const InputDecoration(
                          labelText: 'Chapa da máquina',
                          border: OutlineInputBorder(),
                        ),
                        onSubmitted: (_) => _searchMachine(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _searchMachine,
                      style: ElevatedButton.styleFrom(
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(14),
                        backgroundColor: Colors.blueAccent,
                      ),
                      child: const Icon(Icons.search, size: 28),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),
            if (_isLoading) const Center(child: CircularProgressIndicator()),
            if (_error.isNotEmpty) ...[
              Card(
                color: Colors.red[50],
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(_error, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () => _showRegisterMachineDialog(context),
                        icon: const Icon(Icons.add),
                        label: const Text('Cadastrar nova máquina'),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            if (_machine != null) ...[
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            _getStatus(_machine!) == 'Ativa' ? Icons.check_circle : Icons.cancel,
                            color: _getStatus(_machine!) == 'Ativa' ? Colors.green : Colors.red,
                            size: 32,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Status: ${_getStatus(_machine!)}',
                            style: TextStyle(
                              color: _getStatus(_machine!) == 'Ativa' ? Colors.green : Colors.red,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text('Descrição: ${_machine!['descricao'] ?? ''}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text('Setor: ${_machine!['linha'] ?? ''}', style: const TextStyle(fontSize: 16)),
                      Text('Chapa: ${_machine!['chapa'] ?? ''}', style: const TextStyle(fontSize: 16)),
                      Text('Data Entrada: ${_machine!['data'] ?? ''}', style: const TextStyle(fontSize: 16)),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          ElevatedButton.icon(
                            onPressed: _isLoading ? null : _changeSector,
                            icon: const Icon(Icons.swap_horiz),
                            label: const Text('Alterar Setor'),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.orangeAccent),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton.icon(
                            onPressed: _isLoading ? null : _loadHistory,
                            icon: const Icon(Icons.history),
                            label: const Text('Histórico'),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
            if (_showHistory && _history.isNotEmpty) ...[
              const SizedBox(height: 16),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Histórico da Máquina:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 220,
                        child: ListView.builder(
                          itemCount: _history.length,
                          itemBuilder: (context, index) {
                            final h = _history[index];
                            return ListTile(
                              leading: const Icon(Icons.event_note, color: Colors.blueAccent),
                              title: Text(h['descricao'] ?? ''),
                              subtitle: Text('Data: ${h['data'] ?? ''} - Setor: ${h['linha'] ?? ''}'),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}