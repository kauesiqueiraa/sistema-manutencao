import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sistema_manutencao/viewmodels/inventory_viewmodel.dart';
import 'package:sistema_manutencao/views/inventory/machine_list_view.dart';

class SectorListView extends StatefulWidget {
  const SectorListView({Key? key}) : super(key: key);

  @override
  State<SectorListView> createState() => _SectorListViewState();
}

class _SectorListViewState extends State<SectorListView> {
  bool _showSearch = false;
  String _searchText = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<InventoryViewmodel>(context, listen: false).loadSectors('outros');
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Expanded(child: Text('Setores', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22))),
            IconButton(
              icon: Icon(_showSearch ? Icons.close : Icons.search),
              onPressed: () {
                setState(() {
                  _showSearch = !_showSearch;
                  if (!_showSearch) {
                    _searchText = '';
                    _searchController.clear();
                  }
                });
              },
            ),
          ],
        ),
        toolbarHeight: _showSearch ? 110 : kToolbarHeight,
        bottom: _showSearch
            ? PreferredSize(
                preferredSize: const Size.fromHeight(60),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Material(
                    elevation: 2,
                    borderRadius: BorderRadius.circular(8),
                    child: TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.search),
                        hintText: 'Buscar setor pelo nome',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _searchText = value;
                        });
                      },
                    ),
                  ),
                ),
              )
            : null,
      ),
      body: SafeArea(
        child: Consumer<InventoryViewmodel>(
          builder: (context, viewModel, child) {
            if (viewModel.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (viewModel.error.isNotEmpty) {
              return Center(child: Text(viewModel.error));
            }
            // Filtra setores localmente pelo nome
            final setoresFiltrados = _searchText.isEmpty
                ? viewModel.sectors
                : viewModel.sectors.where((s) => s.descri.toLowerCase().contains(_searchText.toLowerCase())).toList();
            if (setoresFiltrados.isEmpty) {
              return const Center(child: Text('Nenhum setor encontrado.'));
            }
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: setoresFiltrados.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final setor = setoresFiltrados[index];
                return Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MachineListView(
                            setorKey: setor.chave,
                            setorDesc: setor.descri,
                          ),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                      child: Row(
                        children: [
                          const Icon(Icons.apartment, size: 32, color: Colors.blueAccent),
                          const SizedBox(width: 18),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(setor.descri, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 4),
                                Text('Chave: ${setor.chave}', style: TextStyle(color: Colors.grey[700], fontSize: 14)),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right, color: Colors.grey, size: 28),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}