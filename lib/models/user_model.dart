class UserModel {
  final String id;
  final String nome;
  final String email;
  final String setmanu; // Setor do mecânico
  final String matricula; // Matrícula do mecânico

  UserModel({
    required this.id,
    required this.nome,
    required this.email,
    this.setmanu = '',
    this.matricula = '',
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      nome: json['nome']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      setmanu: json['setmanu']?.toString() ?? '',
      matricula: json['matricula']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'email': email,
      'setmanu': setmanu,
      'matricula': matricula,
    };
  }
} 