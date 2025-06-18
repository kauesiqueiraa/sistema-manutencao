import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/produto_model.dart';
import '../models/produto_selecionado_model.dart';
import '../viewmodels/produto_viewmodel.dart';

class SelecaoProdutosView extends StatefulWidget {
  final Function(List<ProdutoSelecionadoModel> produtos) onProdutosSelecionados;

  const SelecaoProdutosView({
    super.key,
    required this.onProdutosSelecionados,
  });

  @override
  State<SelecaoProdutosView> createState() => _SelecaoProdutosViewState();
}

class _SelecaoProdutosViewState extends State<SelecaoProdutosView> {
  final TextEditingController _searchController = TextEditingController();
  final List<ProdutoSelecionadoModel> _produtosSelecionados = [];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Selecionar Produtos'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          if (_produtosSelecionados.isNotEmpty)
            TextButton.icon(
              onPressed: () async {
                await widget.onProdutosSelecionados(_produtosSelecionados);
                if (context.mounted) {
                  Navigator.pop(context);
                }
              },
              icon: const Icon(Icons.check, color: Colors.white),
              label: const Text(
                'Confirmar',
                style: TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Pesquisar Produto',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    if (_searchController.text.isNotEmpty) {
                      context.read<ProdutoViewModel>().buscarProdutos(_searchController.text.toUpperCase());
                    }
                  },
                ),
                border: const OutlineInputBorder(),
              ),
              onSubmitted: (value) {
                if (value.isNotEmpty) {
                  context.read<ProdutoViewModel>().buscarProdutos(value.toUpperCase());
                }
              },
            ),
          ),
          if (_produtosSelecionados.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(8.0),
              color: Colors.grey[200],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Produtos Selecionados:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 150,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _produtosSelecionados.length,
                      itemBuilder: (context, index) {
                        final produto = _produtosSelecionados[index];
                        return Card(
                          margin: const EdgeInsets.only(right: 8),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  produto.descricao,
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text('Qtd: ${produto.quantidade}'),
                                if (produto.observacao.isNotEmpty)
                                  Text(
                                    'Obs: ${produto.observacao}',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                IconButton(
                                  icon: const Icon(Icons.delete, size: 20),
                                  onPressed: () {
                                    setState(() {
                                      _produtosSelecionados.removeAt(index);
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: Consumer<ProdutoViewModel>(
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

                if (viewModel.produtos.isEmpty) {
                  return const Center(
                    child: Text('Digite algo para pesquisar produtos'),
                  );
                }

                return ListView.builder(
                  itemCount: viewModel.produtos.length,
                  itemBuilder: (context, index) {
                    final produto = viewModel.produtos[index];
                    final isSelected = _produtosSelecionados.any((p) => p.codigo == produto.codigo);

                    return ListTile(
                      title: Text(produto.descricao),
                      subtitle: Text('Código: ${produto.codigo}'),
                      trailing: isSelected
                          ? const Icon(Icons.check_circle, color: Colors.green)
                          : const Icon(Icons.add_circle_outline),
                      onTap: () {
                        if (!isSelected) {
                          _showDialogQuantidade(context, produto);
                        }
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showDialogQuantidade(BuildContext context, ProdutoModel produto) {
    final quantidadeController = TextEditingController();
    final observacaoController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Informações do Produto'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: quantidadeController,
              decoration: const InputDecoration(
                labelText: 'Quantidade',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
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
            onPressed: () {
              if (quantidadeController.text.isNotEmpty) {
                setState(() {
                  _produtosSelecionados.add(
                    ProdutoSelecionadoModel(
                      codigo: produto.codigo,
                      descricao: produto.descricao,
                      quantidade: quantidadeController.text,
                      observacao: observacaoController.text,
                    ),
                  );
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Adicionar'),
          ),
        ],
      ),
    );
  }
} 