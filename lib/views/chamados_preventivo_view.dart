import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:sistema_manutencao/models/user_model.dart';
import 'package:sistema_manutencao/viewmodels/auth_viewmodel.dart';
import 'package:sistema_manutencao/views/selecao_produtos_view.dart';
import '../viewmodels/chamado_preventivo_viewmodel.dart';
import '../models/chamado_preventivo_model.dart';

class ChamadosPreventivoView extends StatefulWidget {
  const ChamadosPreventivoView({super.key});

  @override
  State<ChamadosPreventivoView> createState() => _ChamadosPreventivoViewState();
}

class _ChamadosPreventivoViewState extends State<ChamadosPreventivoView> {
  final RefreshController _refreshController = RefreshController(initialRefresh: false);
  
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final viewModel = context.read<ChamadoPreventivoViewModel>();
      viewModel.carregarChamados();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chamados Preventivos', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontFamily: 'Inter'),),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white,),
          onPressed: () => context.goNamed('home'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.white,),
            onPressed: () => _showFiltrosDialog(context),
          ),
        ],
        backgroundColor: Colors.lightGreen,
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
              Expanded(
                child: SmartRefresher(
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
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildChamadoCard(
    ChamadoPreventivoModel chamado, 
    ChamadoPreventivoViewModel viewModel,
    UserModel? user,
  ) {
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
        title: Text('Chamado #${chamado.num}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Linha: ${chamado.linha}'),
            Text('Máquina: ${chamado.chapa}'),
            Text('Status: ${chamado.statusText}'),
          ],
        ),
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
                if (chamado.status == '3') ...[
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SelecaoProdutosView(
                            onProdutosSelecionados: (produtosSelecionados) {
                              chamado.produtos = produtosSelecionados;
                              // viewModel.adicionarProdutos(chamado.numero, produtosSelecionados);
                              setState(() {});
                            },
                          ),
                        ),
                      );
                    },
                    child: const Text('Produtos'),
                  ),
                ],
                const SizedBox(height: 16),
                _buildActionButtons(chamado, viewModel, user),
                const SizedBox(height: 16),
                // só que tem que mostrar os produtos do chamado referente ao qual ele foi setado
                if (chamado.produtos.isNotEmpty) 
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Produtos utilizados:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      ...chamado.produtos.map(
                        (produto) => Text(
                        '${produto.descricao} \nQtd: ${produto.quantidade} \nObservação: ${produto.observacao}\n',
                      )),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(
    ChamadoPreventivoModel chamado, 
    ChamadoPreventivoViewModel viewModel,
    UserModel? user,
  ) {
    final userMatricula = user?.matricula;

    switch (chamado.status) {
      case '1': // Aberto
        return ElevatedButton(
          onPressed: () => _showUpdateStatusDialog(
            context, 
            chamado, 
            viewModel,
            user,
             '3'
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
          child: const Text('Iniciar Atendimento', style: TextStyle(color: Colors.white),),
        );
      case '2': // Pausado
        return ElevatedButton(
          onPressed: () => _showUpdateStatusDialog(
            context, 
            chamado, 
            viewModel,
            user, 
            '3'
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
          ),
          child: const Text('Retomar Atendimento', style: TextStyle(color: Colors.white),),
        );
      case '3': // Em Atendimento
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: () async {
                if (userMatricula != chamado.mecanico) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Esse chamado está sendo atendido por outro Mecânico!', style: TextStyle(color: Colors.white),), backgroundColor: Colors.red, ),
                  );
                  return;
                }
                await _showUpdateStatusDialog(
                  context, 
                  chamado, 
                  viewModel,
                  user,
                  '2'
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text('Pausar', style: TextStyle(color: Colors.white),),
            ),
            ElevatedButton(
              onPressed: () async {
                if (userMatricula != chamado.mecanico) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Esse chamado está sendo atendido por outro Mecânico!', style: TextStyle(color: Colors.white),), backgroundColor: Colors.red),
                  );
                  return;
                }

                await viewModel.finalizarChamado(chamado.num, chamado.produtos, chamado.chapa);
                await _showUpdateStatusDialog(
                  context, 
                  chamado, 
                  viewModel, 
                  user,
                  '4'
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              child: const Text('Finalizar', style: TextStyle(color: Colors.white),),
            ),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
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
    ChamadoPreventivoModel chamado,
    ChamadoPreventivoViewModel viewModel,
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
      dataInicio: chamado.dataInicio,
      horaInicio: novoStatus == '3' ? horaAtual : null,
      dataFim: novoStatus == '4' ? dataAtual : null,
      horaFim: novoStatus == '4' ? horaAtual : null,   
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