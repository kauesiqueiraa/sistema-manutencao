import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../viewmodels/chamado_preventivo_viewmodel.dart';
import '../models/chamado_preventivo_model.dart';

class ChamadosPreventivoView extends StatefulWidget {
  const ChamadosPreventivoView({super.key});

  @override
  State<ChamadosPreventivoView> createState() => _ChamadosPreventivoViewState();
}

class _ChamadosPreventivoViewState extends State<ChamadosPreventivoView> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<ChamadoPreventivoViewModel>().carregarChamados();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chamados Preventivos'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFiltrosDialog(context),
          ),
        ],
      ),
      body: Consumer<ChamadoPreventivoViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.error.isNotEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Erro ao carregar chamados: ${viewModel.error}',
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => viewModel.carregarChamados(),
                    child: const Text('Tentar novamente'),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // _buildFiltros(context, viewModel),
              Expanded(
                child: ListView.builder(
                  itemCount: viewModel.chamadosFiltrados.length,
                  itemBuilder: (context, index) {
                    final chamado = viewModel.chamadosFiltrados[index];
                    return _buildChamadoCard(context, chamado, viewModel);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFiltros(BuildContext context, ChamadoPreventivoViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatusFilter(context, viewModel),
          const SizedBox(height: 16),
          _buildPeriodoFilter(context, viewModel),
          const SizedBox(height: 16),
          _buildChapaLinhaFilter(context, viewModel),
        ],
      ),
    );
  }

  Widget _buildStatusFilter(BuildContext context, ChamadoPreventivoViewModel viewModel) {
    return Wrap(
      spacing: 8,
      children: [
        FilterChip(
          label: const Text('Todos'),
          selected: viewModel.statusFiltro.isEmpty,
          onSelected: (selected) {
            viewModel.alterarFiltroStatus(selected ? '' : '123');
          },
        ),
        FilterChip(
          label: const Text('Abertos'),
          selected: viewModel.statusFiltro == '1',
          onSelected: (selected) {
            viewModel.alterarFiltroStatus(selected ? '1' : '123');
          },
        ),
        FilterChip(
          label: const Text('Pausados'),
          selected: viewModel.statusFiltro == '2',
          onSelected: (selected) {
            viewModel.alterarFiltroStatus(selected ? '2' : '123');
          },
        ),
        FilterChip(
          label: const Text('Em Atendimento'),
          selected: viewModel.statusFiltro == '3',
          onSelected: (selected) {
            viewModel.alterarFiltroStatus(selected ? '3' : '123');
          },
        ),
        FilterChip(
          label: const Text('Finalizados'),
          selected: viewModel.statusFiltro == '4',
          onSelected: (selected) {
            viewModel.alterarFiltroStatus(selected ? '4' : '123');
          },
        ),
      ],
    );
  }

  Widget _buildPeriodoFilter(BuildContext context, ChamadoPreventivoViewModel viewModel) {
    return Row(
      children: [
        Expanded(
          child: TextButton.icon(
            icon: const Icon(Icons.calendar_today),
            label: Text(viewModel.dataInicio != null
                ? '${viewModel.dataInicio!.day}/${viewModel.dataInicio!.month}/${viewModel.dataInicio!.year}'
                : 'Data Inicial'),
            onPressed: () async {
              final data = await showDatePicker(
                context: context,
                initialDate: viewModel.dataInicio ?? DateTime.now(),
                firstDate: DateTime(2020),
                lastDate: DateTime(2025),
              );
              if (data != null) {
                viewModel.alterarPeriodo(data, viewModel.dataFim);
              }
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: TextButton.icon(
            icon: const Icon(Icons.calendar_today),
            label: Text(viewModel.dataFim != null
                ? '${viewModel.dataFim!.day}/${viewModel.dataFim!.month}/${viewModel.dataFim!.year}'
                : 'Data Final'),
            onPressed: () async {
              final data = await showDatePicker(
                context: context,
                initialDate: viewModel.dataFim ?? DateTime.now(),
                firstDate: DateTime(2020),
                lastDate: DateTime(2025),
              );
              if (data != null) {
                viewModel.alterarPeriodo(viewModel.dataInicio, data);
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildChapaLinhaFilter(BuildContext context, ChamadoPreventivoViewModel viewModel) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            decoration: const InputDecoration(
              labelText: 'Chapa',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) => viewModel.alterarFiltroChapa(value),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: TextField(
            decoration: const InputDecoration(
              labelText: 'Linha',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) => viewModel.alterarFiltroLinha(value),
          ),
        ),
      ],
    );
  }

  Widget _buildChamadoCard(BuildContext context, ChamadoPreventivoModel chamado, ChamadoPreventivoViewModel viewModel) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ExpansionTile(
        leading: _getStatusIcon(chamado.status),
        title: Text('Chamado #${chamado.num}'),
        subtitle: Text('${chamado.linha} - ${chamado.chapa}'),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Defeito: ${chamado.defeito}'),
                if (chamado.descricaoDefeito.isNotEmpty)
                  Text('Descrição: ${chamado.descricaoDefeito}'),
                Text('Solicitante: ${chamado.setor}'),
                if (chamado.mecanico.isNotEmpty)
                  Text('Mecânico: ${chamado.mecanico}'),
                Text('Data Solicitação: ${chamado.dataSolicitacaoFormatada}'),
                if (chamado.dataInicio.isNotEmpty)
                  Text('Início: ${chamado.dataInicioFormatada}'),
                if (chamado.dataFim.isNotEmpty)
                  Text('Fim: ${chamado.dataFimFormatada}'),
                if (chamado.observacao.isNotEmpty)
                  Text('Observação: ${chamado.observacao}'),
                const SizedBox(height: 16),
                _buildActionButtons(context, chamado, viewModel),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, ChamadoPreventivoModel chamado, ChamadoPreventivoViewModel viewModel) {
    switch (chamado.status) {
      case '1': // Aberto
        return ElevatedButton(
          onPressed: () => _showUpdateStatusDialog(context, chamado, viewModel, '3'),
          child: const Text('Iniciar Atendimento'),
        );
      case '2': // Pausado
        return ElevatedButton(
          onPressed: () => _showUpdateStatusDialog(context, chamado, viewModel, '3'),
          child: const Text('Retomar Atendimento'),
        );
      case '3': // Em Atendimento
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: () => _showUpdateStatusDialog(context, chamado, viewModel, '2'),
              child: const Text('Pausar'),
            ),
            ElevatedButton(
              onPressed: () => _showUpdateStatusDialog(context, chamado, viewModel, '4'),
              child: const Text('Finalizar'),
            ),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Icon _getStatusIcon(String status) {
    switch (status) {
      case '1':
        return const Icon(Icons.error_outline, color: Colors.orange);
      case '2':
        return const Icon(Icons.pause_circle_outline, color: Colors.blue);
      case '3':
        return const Icon(Icons.play_circle_outline, color: Colors.green);
      case '4':
        return const Icon(Icons.check_circle_outline, color: Colors.grey);
      default:
        return const Icon(Icons.help_outline, color: Colors.grey);
    }
  }

  Future<void> _showUpdateStatusDialog(
    BuildContext context,
    ChamadoPreventivoModel chamado,
    ChamadoPreventivoViewModel viewModel,
    String novoStatus,
  ) async {
    final mecanicoController = TextEditingController();
    final observacaoController = TextEditingController();

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(novoStatus == '3' ? 'Iniciar Atendimento' : 'Atualizar Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: mecanicoController,
              decoration: const InputDecoration(
                labelText: 'Mecânico',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: observacaoController,
              decoration: const InputDecoration(
                labelText: 'Observação',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (mecanicoController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Informe o mecânico')),
                );
                return;
              }

              await viewModel.atualizarStatus(
                numero: chamado.num,
                status: novoStatus,
                mecanico: mecanicoController.text,
                observacaoMecanico: observacaoController.text.isNotEmpty ? observacaoController.text : null,
              );
              if (mounted) Navigator.pop(context);
            },
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }

  Future<void> _showFiltrosDialog(BuildContext context) async {
    final viewModel = context.read<ChamadoPreventivoViewModel>();
    String tempStatusFiltro = viewModel.statusFiltro;
    DateTime? tempDataInicio = viewModel.dataInicio;
    DateTime? tempDataFim = viewModel.dataFim;
    final chapaController = TextEditingController(text: viewModel.chapaFiltro);
    final linhaController = TextEditingController(text: viewModel.linhaFiltro);

    return showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Filtros'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Status:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    FilterChip(
                      label: const Text('Todos'),
                      selected: tempStatusFiltro.isEmpty,
                      onSelected: (selected) {
                        setState(() {
                          tempStatusFiltro = selected ? '' : '123';
                        });
                      },
                    ),
                    FilterChip(
                      label: const Text('Abertos'),
                      selected: tempStatusFiltro == '1',
                      onSelected: (selected) {
                        setState(() {
                          tempStatusFiltro = selected ? '1' : '123';
                        });
                      },
                    ),
                    FilterChip(
                      label: const Text('Pausados'),
                      selected: tempStatusFiltro == '2',
                      onSelected: (selected) {
                        setState(() {
                          tempStatusFiltro = selected ? '2' : '123';
                        });
                      },
                    ),
                    FilterChip(
                      label: const Text('Em Atendimento'),
                      selected: tempStatusFiltro == '3',
                      onSelected: (selected) {
                        setState(() {
                          tempStatusFiltro = selected ? '3' : '123';
                        });
                      },
                    ),
                    FilterChip(
                      label: const Text('Finalizados'),
                      selected: tempStatusFiltro == '4',
                      onSelected: (selected) {
                        setState(() {
                          tempStatusFiltro = selected ? '4' : '123';
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text('Período:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextButton.icon(
                        icon: const Icon(Icons.calendar_today),
                        label: Text(tempDataInicio != null
                            ? '${tempDataInicio!.day}/${tempDataInicio!.month}/${tempDataInicio!.year}'
                            : 'Data Inicial'),
                        onPressed: () async {
                          final data = await showDatePicker(
                            context: context,
                            initialDate: tempDataInicio ?? DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2025),
                          );
                          if (data != null) {
                            setState(() {
                              tempDataInicio = data;
                            });
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextButton.icon(
                        icon: const Icon(Icons.calendar_today),
                        label: Text(tempDataFim != null
                            ? '${tempDataFim!.day}/${tempDataFim!.month}/${tempDataFim!.year}'
                            : 'Data Final'),
                        onPressed: () async {
                          final data = await showDatePicker(
                            context: context,
                            initialDate: tempDataFim ?? DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2025),
                          );
                          if (data != null) {
                            setState(() {
                              tempDataFim = data;
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text('Chapa e Linha:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                TextField(
                  controller: chapaController,
                  decoration: const InputDecoration(
                    labelText: 'Chapa',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: linhaController,
                  decoration: const InputDecoration(
                    labelText: 'Linha',
                    border: OutlineInputBorder(),
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
              onPressed: () {
                viewModel.alterarFiltroStatus(tempStatusFiltro);
                viewModel.alterarPeriodo(tempDataInicio, tempDataFim);
                viewModel.alterarFiltroChapa(chapaController.text);
                viewModel.alterarFiltroLinha(linhaController.text);
                viewModel.carregarChamados();
                Navigator.pop(context);
              },
              child: const Text('Aplicar'),
            ),
          ],
        ),
      ),
    );
  }
} 