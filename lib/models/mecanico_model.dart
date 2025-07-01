class MecanicoModel {
  final String matricula;
  final String iduser;
  final String nome;
  final String status;
  final String setmanu;
  final String setor;
  final String empresaAtendimento;

  MecanicoModel({
    required this.matricula,
    required this.iduser,
    required this.nome,
    required this.status,
    required this.setmanu,
    required this.setor,
    required this.empresaAtendimento,
  });

  factory MecanicoModel.fromJson(Map<String, dynamic> json) {
    return MecanicoModel(
      matricula: json['matricula']?.toString() ?? '',
      iduser: json['iduser']?.toString() ?? '',
      nome: json['nome']?.toString().trim() ?? '',
      status: json['status']?.toString() ?? '',
      setmanu: json['setmanu']?.toString() ?? '',
      setor: json['setor']?.toString() ?? '',
      empresaAtendimento: json['empatendi']?.toString() ?? '',
    );
  }

  bool get isDisponivel => status.contains('D=Disponivel');
  bool get isEmAtendimento => status.contains('A=Atendimento');
  bool get isIndustrial => setmanu.contains('I=Industrial');
  bool get isPredial => setmanu.contains('P=Predial');

  bool get empAtendTresPontas => empresaAtendimento.contains('0401');
  bool get empAtendVarginha => empresaAtendimento.contains('0902');
  bool get empAtendMonsenhorPaulo => empresaAtendimento.contains('0903');

  String get nomeEmpresaAtendimento {
    if (empAtendTresPontas) return 'Três Pontas';
    if (empAtendVarginha) return 'Varginha';
    if (empAtendMonsenhorPaulo) return 'Monsenhor Paulo';
    return 'Empresa Desconhecida';
  }

  Map<String, dynamic> toJson() {
    return {
      'matricula': matricula,
      'iduser': iduser,
      'nome': nome,
      'status': status,
      'setmanu': setmanu,
      'setor': setor,
      'empresaAtendimento': nomeEmpresaAtendimento,
    };
  }
} 