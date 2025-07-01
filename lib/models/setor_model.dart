class SetorModel {
  final String chave;
  final String descri;

  SetorModel(
    this.chave,
    this.descri,
  );

  @override
  String toString() {
    return '$chave - $descri';
  }

  Map<String, dynamic> toJson() {
    return {
      'chave': chave,
      'descri': descri,
    };
  }

  factory SetorModel.fromJson(Map<String, dynamic> json) {
    return SetorModel(
      json['chave'] ?? '',
      json['descri'] ?? '',
    );
  }
}