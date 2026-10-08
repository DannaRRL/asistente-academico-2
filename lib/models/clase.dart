class Clase {
  final String materia;
  final String dia;
  final String horaInicio;
  final String horaFin;
  final String? salon;

  const Clase({
    required this.materia,
    required this.dia,
    required this.horaInicio,
    required this.horaFin,
    this.salon,
  });

  Clase copyWith({
    String? materia,
    String? dia,
    String? horaInicio,
    String? horaFin,
    String? salon,
  }) {
    return Clase(
      materia: materia ?? this.materia,
      dia: dia ?? this.dia,
      horaInicio: horaInicio ?? this.horaInicio,
      horaFin: horaFin ?? this.horaFin,
      salon: salon ?? this.salon,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'materia': materia,
      'dia': dia,
      'horaInicio': horaInicio,
      'horaFin': horaFin,
      'salon': salon,
    };
  }

  factory Clase.fromMap(Map<String, dynamic> map) {
    return Clase(
      materia: map['materia'] ?? '',
      dia: map['dia'] ?? '',
      horaInicio: map['horaInicio'] ?? '',
      horaFin: map['horaFin'] ?? '',
      salon: map['salon'],
    );
  }
}