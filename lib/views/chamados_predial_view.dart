import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:sistema_manutencao/models/user_model.dart';
import 'package:sistema_manutencao/viewmodels/auth_viewmodel.dart';
import '../viewmodels/chamado_predial_viewmodel.dart';
import '../models/chamado_predial_model.dart';

class ChamadosPredialView extends StatefulWidget {
  const ChamadosPredialView({super.key});

  @override
  State<ChamadosPredialView> createState() => _ChamadosPredialViewState();
}

class _ChamadosPredialViewState extends State<ChamadosPredialView> {
  final Map<String, String> _mecanic2Selected = {};
  final RefreshController _refreshController = RefreshController(initialRefresh: false);

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final viewModel = context.read<ChamadoPredialViewModel>();
      viewModel.carregarChamados();
      viewModel.carregarMecanicos();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chamados Predial', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontFamily: 'Inter'),),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white,),
          onPressed: () => context.goNamed('home'),
        ),
        // actions: [
        //   IconButton(
        //     onPressed: () {
        //       context.goNamed('home');
        //     },
        //     icon: const Icon(Icons.arrow_back_ios, color: Colors.white,),
        //   ),
        // ],
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          _buildStatusFilter(),
          Expanded(
            child: Consumer<ChamadoPredialViewModel>(
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

                if (viewModel.chamadosFiltrados.isEmpty) {
                  return const Center(
                    child: Text('Nenhum chamado encontrado'),
                  );
                }

                return SmartRefresher(
                  controller: _refreshController,
                  enablePullDown: true,
                  onRefresh: () async {
                    await viewModel.carregarChamados();
                    _refreshController.refreshCompleted();
                  },
                  child: ListView.builder(
                    itemCount: viewModel.chamadosFiltrados.length,
                    itemBuilder: (context, index) {
                      final chamado = viewModel.chamadosFiltrados[index];
                      final user = context.read<AuthViewModel>().user;
                      return _buildChamadoCard(chamado, viewModel, user);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusFilter() {
    return Consumer<ChamadoPredialViewModel>(
      builder: (context, viewModel, child) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('Todos', '', viewModel),
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
          ),
        );
      },
    );
  }

  Widget _buildFilterChip(
    String label,
    String value,
    ChamadoPredialViewModel viewModel,
  ) {
    final isSelected = viewModel.statusFiltro == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        viewModel.alterarFiltroStatus(selected ? value : '');
      },
      backgroundColor: Colors.white,
      selectedColor: Colors.blue,
      checkmarkColor: Colors.white,
    );
  }

  Widget _buildChamadoCard(ChamadoPredialModel chamado, ChamadoPredialViewModel viewModel, UserModel? user) {
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
            Text('Setor: ${chamado.setor}'),
            Text('Solicitante: ${chamado.solict}'),
            Text('Status: ${chamado.statusText}'),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Objetivo: ${chamado.objetivo}'),
                const SizedBox(height: 8),
                Text('Mecânico: ${chamado.mecanico}'),
                const SizedBox(height: 8),
                if (chamado.status == '3') ...[
                  if (chamado.mecanico2.isEmpty) ...[
                    DropdownButtonFormField<String>(
                      value: _mecanic2Selected[chamado.mecanico2],
                      decoration: const InputDecoration(
                        labelText: 'Adicionar Segundo Mecânico',
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
                  ] else ...[
                    Text('Mecânico 2: ${chamado.mecanico2}'),
                  ],
                ],
                const SizedBox(height: 8),
                Text('Data Solicitação: ${chamado.dataSolicitacao}'),
                const SizedBox(height: 8),
                Text('Hora Solicitação: ${chamado.horaSolicitacao}'),
                if (chamado.dataInicio.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text('Início: ${chamado.dataInicio} ${chamado.horaInicio}'),
                ],
                if (chamado.dataFim.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text('Fim: ${chamado.dataFim} ${chamado.horaFim}'),
                ],
                if (chamado.observacaoMecanico.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text('Observação: ${chamado.observacaoMecanico}'),
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
    ChamadoPredialModel chamado,
    ChamadoPredialViewModel viewModel,
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
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            child: const Text('Iniciar Atendimento', style: TextStyle(color: Colors.white),),
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
              backgroundColor: Colors.red,
            ),
            child: const Text('Pausar', style: TextStyle(color: Colors.white),),
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
                backgroundColor: Colors.green,
              ),
              child: const Text('Finalizar', style: TextStyle(color: Colors.white),),
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
              backgroundColor: Colors.blue,
            ),
            child: const Text('Retomar', style: TextStyle(color: Colors.white),),
          ),
      ],
    );
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case '1':
        return Icons.assignment;
      case '2':
        return Icons.pause;
      case '3':
        return Icons.build;
      case '4':
        return Icons.check_circle;
      default:
        return Icons.help;
    }
  }

  Future<void> _showUpdateStatusDialog(
    BuildContext context,
    ChamadoPredialModel chamado,
    ChamadoPredialViewModel viewModel,
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
      dataInicioPausa: novoStatus == '2' ? dataAtual : null,
      dataFim: novoStatus == '4' ? dataAtual : null,
      horaFim: novoStatus == '4' ? horaAtual : null,
    );
  }

} 