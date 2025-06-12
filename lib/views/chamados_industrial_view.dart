import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:sistema_manutencao/models/user_model.dart';
import 'package:sistema_manutencao/viewmodels/auth_viewmodel.dart';
import 'package:sistema_manutencao/widgets/error_page.dart';
import '../viewmodels/chamado_industrial_viewmodel.dart';
import '../models/chamado_industrial_model.dart';

class ChamadosIndustrialView extends StatefulWidget {
  const ChamadosIndustrialView({super.key});

  @override
  State<ChamadosIndustrialView> createState() => _ChamadosIndustrialViewState();
}

class _ChamadosIndustrialViewState extends State<ChamadosIndustrialView> {
  final Map<String, String> _mecanic2Selected = {};
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () {
        final viewModel = context.read<ChamadoIndustrialViewModel>();
        viewModel.carregarChamados();
        viewModel.carregarMecanicos();
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chamados Industrial'),
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
          _buildFiltros(),
          Expanded(
            child: Consumer<ChamadoIndustrialViewModel>(
              builder: (context, viewModel, child) {
                if (viewModel.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                // if (viewModel.error.isNotEmpty) {
                //   return ErrorPage(
                //     message: viewModel.error,
                //     onRetry: () {
                //       viewModel.carregarChamados();
                //       viewModel.carregarMecanicos();
                //     },
                //   );
                // }

                if (viewModel.error.isNotEmpty) {
                 return const Center(
                    child: Text('Nenhum chamado encontrado'),
                  );
                }

                if (viewModel.chamadosFiltrados.isEmpty) {
                  return const Center(
                    child: Text('Nenhum chamado encontrado'),
                  );
                }

                return ListView.builder(
                  itemCount: viewModel.chamadosFiltrados.length,
                  itemBuilder: (context, index) {
                    final chamado = viewModel.chamadosFiltrados[index];
                    final user = context.read<AuthViewModel>().user;
                    return _buildChamadoCard(chamado, viewModel, user);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltros() {
    return Consumer<ChamadoIndustrialViewModel>(
      builder: (context, viewModel, child) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildStatusFilter(viewModel),
              const SizedBox(height: 16),
              // _buildPeriodoFilter(viewModel),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusFilter(ChamadoIndustrialViewModel viewModel) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildFilterChip('Todos', '123', viewModel),
          const SizedBox(width: 8),
          _buildFilterChip('Abertos', '1', viewModel),
          const SizedBox(width: 8),
          _buildFilterChip('Pausados', '2', viewModel),
          const SizedBox(width: 8),
          _buildFilterChip('Em Atendimento', '3', viewModel),
          const SizedBox(width: 8),
          _buildFilterChip('Finalizados', '4', viewModel),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    String label,
    String value,
    ChamadoIndustrialViewModel viewModel,
  ) {
    final isSelected = viewModel.statusFiltro == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        viewModel.alterarFiltroStatus(selected ? value : '123');
        viewModel.carregarChamados();
      },
    );
  }

  Widget _buildPeriodoFilter(ChamadoIndustrialViewModel viewModel) {
    return Row(
      children: [
        Expanded(
          child: TextButton.icon(
            onPressed: () async {
              final data = await showDateRangePicker(
                context: context,
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
                initialDateRange: viewModel.dataInicio != null && viewModel.dataFim != null
                    ? DateTimeRange(
                        start: viewModel.dataInicio!,
                        end: viewModel.dataFim!,
                      )
                    : null,
              );
              if (data != null) {
                viewModel.alterarPeriodo(data.start, data.end);
                viewModel.carregarChamados();
              }
            },
            icon: const Icon(Icons.calendar_today),
            label: Text(
              viewModel.dataInicio != null && viewModel.dataFim != null
                  ? '${viewModel.dataInicio!.day}/${viewModel.dataInicio!.month}/${viewModel.dataInicio!.year} - ${viewModel.dataFim!.day}/${viewModel.dataFim!.month}/${viewModel.dataFim!.year}'
                  : 'Selecionar Período',
            ),
          ),
        ),
        if (viewModel.dataInicio != null && viewModel.dataFim != null)
          IconButton(
            onPressed: () {
              viewModel.alterarPeriodo(null, null);
              viewModel.carregarChamados();
            },
            icon: const Icon(Icons.clear),
          ),
      ],
    );
  }

  Widget _buildChamadoCard(
    ChamadoIndustrialModel chamado,
    ChamadoIndustrialViewModel viewModel,
    UserModel? user,
  ) {
    final observacaoController = TextEditingController();
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: chamado.statusColor,
          child: Icon(
            _getStatusIcon(chamado.status),
            color: Colors.white,
          ),
        ),
        title: Text(
          'Chamado #${chamado.num}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Linha: ${chamado.linha}'),
            Text('Máquina: ${chamado.maq}'),
            Text('Status: ${chamado.statusText}'),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Defeito: ${chamado.descricaoDefeito}'),
                const SizedBox(height: 8),
                Text('Solicitante: ${chamado.solict}'),
                if (chamado.mecanico.isNotEmpty)
                  Text('Mecânico: ${chamado.mecanico}'),
                if (chamado.status == '3') ...[
                  if (chamado.mecanico2.isEmpty) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: DropdownButtonFormField<String>(
                        value: _mecanic2Selected[chamado.mecanico2],
                        decoration: const InputDecoration(
                          labelText: 'Adicionar Mecânico',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                        ),
                        items: viewModel.mecanicos.map((mecanico) {
                          return DropdownMenuItem<String>(
                            value: mecanico['matricula'],
                            child: Text(mecanico['nome']!),
                          );
                        }).toList(),
                        onChanged: (String? matricula) {
                          setState(() {
                            _mecanic2Selected[chamado.mecanico2] = matricula ?? '';
                          });
                        },
                      ),
                    ),
                  ] else ...[
                    Text('Mecânico 2: ${chamado.mecanico2}'),
                  ],
                ],
                const SizedBox(height: 8),
                Text('Data Solicitação: ${chamado.dataSolicitacaoFormatada}'),
                Text('Hora Solicitação: ${chamado.horaSolicitacao}'),
                if (chamado.dataInicio.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text('Início: ${chamado.dataInicio} ${chamado.horaInicio}'),
                ],
                if (chamado.dataFim.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text('Fim: ${chamado.dataFim} ${chamado.horaFim}'),
                ],
                if (chamado.observacao.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text('Observação: ${chamado.observacao}'),
                ],
                if (chamado.status == '3') ...[
                  const SizedBox(height: 16),
                  TextField(
                    controller: observacaoController,
                    decoration: const InputDecoration(
                      labelText: 'Observação',
                      border: OutlineInputBorder(),
                      hintText: 'Digite a observação para finalizar o chamado',
                    ),
                    maxLines: 3,
                  ),
                ],
                const SizedBox(height: 16),
                _buildActionButtons(chamado, viewModel, observacaoController, user),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(
    ChamadoIndustrialModel chamado,
    ChamadoIndustrialViewModel viewModel,
    TextEditingController observacaoController,
    UserModel? user,
  ) {
    // final userMatricula = user?.matricula;
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (chamado.status == '1') // Aberto
          ElevatedButton(
            onPressed: () => _showUpdateStatusDialog(
              context,
              chamado,
              viewModel,
              user,
              '3', // Em Atendimento
            ),
            child: const Text('Iniciar Atendimento'),
          ),
        if (chamado.status == '3') ...[
          // Em Atendimento
          ElevatedButton(
            onPressed: () => _showUpdateStatusDialog(
              context,
              chamado,
              viewModel,
              user,
              '2', // Pausado
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.pink,
            ),
            child: const Text('Pausar'),
          ),
          const SizedBox(width: 8),
          // if (userMatricula == chamado.mecanico || userMatricula == chamado.mecanico2)
            ElevatedButton(
              onPressed: () async {
                if (observacaoController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Informe uma observação para finalizar o chamado')),
                  );
                  return;
                }
                await viewModel.atualizarStatus(
                  numero: chamado.num,
                  status: '4',
                  observacaoMecanico: observacaoController.text,
                  mecanico2: _mecanic2Selected[chamado.mecanico2],
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.yellow,
              ),
              child: const Text('Finalizar'),
            ),
        ],
        if (chamado.status == '2') // Pausado
          ElevatedButton(
            onPressed: () => _showUpdateStatusDialog(
              context,
              chamado,
              viewModel,
              user,
              '3', // Em Atendimento
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            child: const Text('Retomar'),
          ),
      ],
    );
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case '1':
        return Icons.add_circle;
      case '2':
        return Icons.pause_circle;
      case '3':
        return Icons.play_arrow;
      case '4':
        return Icons.check_circle;
      default:
        return Icons.help;
    }
  }

  Future<void> _showUpdateStatusDialog(
    BuildContext context,
    ChamadoIndustrialModel chamado,
    ChamadoIndustrialViewModel viewModel,
    UserModel? user,
    String novoStatus,
  ) async {
      final now = DateTime.now();
      final dataAtual = '${now.year}/${now.month.toString().padLeft(2, '0')}/${now.day.toString().padLeft(2, '0')}';
      final horaAtual = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';
    await viewModel.atualizarStatus(
      numero: chamado.num,
      status: novoStatus,
      mecanico: novoStatus == '3' ? user?.matricula : chamado.mecanico,
      mecanico2: chamado.mecanico2,
      dataInicio: chamado.dataInicio,
      horaInicio: novoStatus == '3' ? horaAtual : null,
      dataFim: novoStatus == '4' ? dataAtual : null,
      horaFim: novoStatus == '4' ? horaAtual : null,   
    );
  }

  // Future<void> statusMecanico() async {
  //   final mecanicoDisponivel = await viewModel.mecanicoDiponivel(userMatricula!);

  //   if (!mecanicoDisponivel) {
  //     showDialog(
  //       context: context,
  //       builder: (context) => AlertDialog(
  //         title: const Text('Mecânico ocupado'),
  //         content: const Text('Você já está atendendo outro chamado. Finalize-o antes de iniciar outro.'),
  //         actions: [
  //           TextButton(
  //             onPressed: () => Navigator.of(context).pop(),
  //             child: const Text('OK'),
  //           ),
  //         ],
  //       ),
  //     );
  //   }
  // }
} 