import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../viewmodels/mecanico_viewmodel.dart';
import '../models/mecanico_model.dart';

class MecanicosView extends StatefulWidget {
  const MecanicosView({super.key});

  @override
  State<MecanicosView> createState() => _MecanicosViewState();
}

class _MecanicosViewState extends State<MecanicosView> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => context.read<MecanicoViewModel>().carregarMecanicos(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mecânicos'),
        actions: [
          IconButton(
            onPressed: () {
              context.goNamed('home');
            },
            icon: const Icon(Icons.arrow_back_ios), 
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSetorSelector(),
          Expanded(
            child: Consumer<MecanicoViewModel>(
              builder: (context, viewModel, child) {
                if (viewModel.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (viewModel.error.isNotEmpty) {
                  return Center(
                    child: Text(
                      'Erro: ${viewModel.error}',
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }

                if (viewModel.mecanicos.isEmpty) {
                  return const Center(
                    child: Text('Nenhum mecânico encontrado'),
                  );
                }

                return ListView.builder(
                  itemCount: viewModel.mecanicos.length,
                  itemBuilder: (context, index) {
                    final mecanico = viewModel.mecanicos[index];
                    return _buildMecanicoCard(mecanico);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSetorSelector() {
    return Consumer<MecanicoViewModel>(
      builder: (context, viewModel, child) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: _buildSetorButton(
                  'Mecânicos Industrial',
                  'I',
                  viewModel.setorSelecionado == 'I',
                  () => viewModel.alterarSetor('I'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSetorButton(
                  'Mecânicos Predial',
                  'P',
                  viewModel.setorSelecionado == 'P',
                  () => viewModel.alterarSetor('P'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSetorButton(
    String label,
    String value,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return Material(
      color: isSelected ? Theme.of(context).primaryColor : Colors.grey[200],
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black87,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMecanicoCard(MecanicoModel mecanico) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: mecanico.isDisponivel
              ? Colors.green
              : Theme.of(context).primaryColor,
          child: Icon(
            mecanico.isDisponivel ? Icons.check : Icons.build,
            color: Colors.white,
          ),
        ),
        title: Text(
          mecanico.nome,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('Matrícula: ${mecanico.matricula}'),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: mecanico.isDisponivel ? Colors.green : Colors.orange,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            mecanico.isDisponivel ? 'Disponível' : 'Em Atendimento',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        onTap: () {
          // TODO: Implementar navegação para detalhes do mecânico
        },
      ),
    );
  }
} 