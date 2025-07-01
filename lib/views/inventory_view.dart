import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sistema_manutencao/views/inventory/machine_view.dart';
import 'package:sistema_manutencao/views/inventory/sector_list_view.dart';

class InventoryView extends StatefulWidget {
const InventoryView({ Key? key }) : super(key: key);

  @override
  State<InventoryView> createState() => _InventoryViewState();
}

class _InventoryViewState extends State<InventoryView> {
  int _currentIndex = 0;

  final List<Widget> _children = const [
    SectorListView(),
    MachineView(),
  ];

  @override
  Widget build(BuildContext context){
    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(33, 58, 98, 1),
        elevation: 3,
        leading: Row(
          children: [
            IconButton(
              onPressed: () {
                context.goNamed('home');
              },
              icon: const Icon(Icons.arrow_back, color: Colors.white),
            ),
          ],
        ),
        title: const Text(
          'Inventário de Máquinas',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
            fontFamily: 'Inter',
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            tooltip: 'Atualizar',
            onPressed: () {
              setState(() {}); // Pode ser substituído por lógica de refresh global
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _children[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        elevation: 12,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey[600],
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 14),
        iconSize: 30,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Lista de Sectores',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Pesquisar Máquina',
          ),
        ],
      ),
    );
  }
}