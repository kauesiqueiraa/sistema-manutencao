class MecanicoModel {
  final String matricula;
  final String iduser;
  final String nome;
  final String status;
  final String setmanu;

  MecanicoModel({
    required this.matricula,
    required this.iduser,
    required this.nome,
    required this.status,
    required this.setmanu,
  });

  factory MecanicoModel.fromJson(Map<String, dynamic> json) {
    return MecanicoModel(
      matricula: json['matricula']?.toString() ?? '',
      iduser: json['iduser']?.toString() ?? '',
      nome: json['nome']?.toString().trim() ?? '',
      status: json['status']?.toString() ?? '',
      setmanu: json['setmanu']?.toString() ?? '',
    );
  }

  bool get isDisponivel => status.contains('D=Disponivel');
  bool get isEmAtendimento => status.contains('A=Atendimento');
  bool get isIndustrial => setmanu.contains('I=Industrial');
  bool get isPredial => setmanu.contains('P=Predial');
} 