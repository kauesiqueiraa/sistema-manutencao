class PreventivoModel {
  final String numero;
  final String chapa;
  final String linha;
  final String status;
  final String? mecanico;
  final String? mecanico2;
  final String? dataInicio;
  final String? horaInicio;
  final String? dataFim;
  final String? horaFim;
  final String? observacaoMecanico;
  final String? pausa;

  PreventivoModel({
    required this.numero,
    required this.chapa,
    required this.linha,
    required this.status,
    this.mecanico,
    this.mecanico2,
    this.dataInicio,
    this.horaInicio,
    this.dataFim,
    this.horaFim,
    this.observacaoMecanico,
    this.pausa,
  });

  factory PreventivoModel.fromJson(Map<String, dynamic> json) {
    return PreventivoModel(
      numero: json['num'] ?? '',
      chapa: json['chapa'] ?? '',
      linha: json['linha'] ?? '',
      status: json['status'] ?? '',
      mecanico: json['mecan'],
      mecanico2: json['mecan2'],
      dataInicio: json['dtini'],
      horaInicio: json['hrini'],
      dataFim: json['dtfim'],
      horaFim: json['hrfim'],
      observacaoMecanico: json['obsmec'],
      pausa: json['pausa'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'num': numero,
      'chapa': chapa,
      'linha': linha,
      'status': status,
      'mecan': mecanico,
      'mecan2': mecanico2,
      'dtini': dataInicio,
      'hrini': horaInicio,
      'dtfim': dataFim,
      'hrfim': horaFim,
      'obsmec': observacaoMecanico,
      'pausa': pausa,
    };
  }
} 