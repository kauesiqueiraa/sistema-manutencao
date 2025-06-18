class ProdutoModel {
  final String codigo;
  final String descricao;

  ProdutoModel({
    required this.codigo,
    required this.descricao,
  });

  factory ProdutoModel.fromJson(Map<String, dynamic> json) {
    return ProdutoModel(
      codigo: json['cod']?.toString().trim() ?? '',
      descricao: json['descri']?.toString().trim() ?? '',
    );
  }
} 