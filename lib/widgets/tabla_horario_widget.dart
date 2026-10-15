
import 'package:flutter/material.dart';

import '../models/clase.dart';

class TablaHorarioWidget extends StatelessWidget {
  final List<Clase> clases;
  final void Function(Clase clase)? onEditar;

  const TablaHorarioWidget({
    super.key,
    required this.clases,
    this.onEditar,
  });

  static const List<String> _dias = [
    'Lunes',
    'Martes',
    'Miércoles',
    'Jueves',
    'Viernes',
  ];

  static const List<Color> _colores = [
    Color(0xFFE9D5FF),
    Color(0xFFBFDBFE),
    Color(0xFFFBCFE8),
    Color(0xFFBBF7D0),
    Color(0xFFFDE68A),
    Color(0xFFFED7AA),
  ];

  int _minutos(String hora) {
    final partes = hora.split(':');

    if (partes.length != 2) return 0;

    final horas = int.tryParse(partes[0]) ?? 0;
    final minutos = int.tryParse(partes[1]) ?? 0;

    return horas * 60 + minutos;
  }

  Color _colorMateria(String materia) {
    final nombre = materia.trim().toUpperCase();

    // Mantiene un color consistente para cada materia.
    int suma = 0;

    for (final codigo in nombre.codeUnits) {
      suma += codigo;
    }

    return _colores[suma % _colores.length];
  }

  @override
  Widget build(BuildContext context) {
    if (clases.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Todavía no hay clases para mostrar.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final clasesValidas = clases.where((clase) {
      return _dias.contains(clase.dia) &&
          _minutos(clase.horaFin) >
              _minutos(clase.horaInicio);
    }).toList();

    if (clasesValidas.isEmpty) {
      return const Center(
        child: Text('No hay horarios válidos.'),
      );
    }

    final inicio = clasesValidas
        .map((clase) => _minutos(clase.horaInicio))
        .reduce((a, b) => a < b ? a : b);

    final fin = clasesValidas
        .map((clase) => _minutos(clase.horaFin))
        .reduce((a, b) => a > b ? a : b);

    // Cada minuto equivale a 1.15 píxeles.
    const double escala = 1.15;
    const double anchoHora = 66;
    const double anchoDia = 156;
    const double altoEncabezado = 48;

    final alturaHorario = (fin - inicio) * escala;
    final anchoTotal =
        anchoHora + (_dias.length * anchoDia);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: anchoTotal,
        child: Column(
          children: [
            SizedBox(
              height: altoEncabezado,
              child: Row(
                children: [
                  Container(
                    width: anchoHora,
                    alignment: Alignment.center,
                    color: const Color(0xFFEDE7F6),
                    child: const Text(
                      'Hora',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  for (final dia in _dias)
                    Container(
                      width: anchoDia,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: Color(0xFFEDE7F6),
                        border: Border(
                          left: BorderSide(
                            color: Color(0xFFD1C4E9),
                          ),
                        ),
                      ),
                      child: Text(
                        dia,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: SizedBox(
                  width: anchoTotal,
                  height: alturaHorario,
                  child: Stack(
                    children: [
                      // Líneas horizontales por cada hora.
                      for (int minuto = inicio;
                          minuto <= fin;
                          minuto += 60)
                        Positioned(
                          top: (minuto - inicio) * escala,
                          left: 0,
                          right: 0,
                          child: Container(
                            height: 1,
                            color: const Color(0xFFE0E0E0),
                          ),
                        ),

                      // Etiquetas de las horas.
                      for (int minuto = inicio;
                          minuto <= fin;
                          minuto += 60)
                        Positioned(
                          top: (minuto - inicio) * escala,
                          left: 4,
                          child: Text(
                            '${(minuto ~/ 60).toString().padLeft(2, '0')}:'
                            '${(minuto % 60).toString().padLeft(2, '0')}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.black54,
                            ),
                          ),
                        ),

                      // Líneas verticales.
                      for (int i = 0; i <= _dias.length; i++)
                        Positioned(
                          left: anchoHora + (i * anchoDia),
                          top: 0,
                          bottom: 0,
                          child: Container(
                            width: 1,
                            color: const Color(0xFFE0E0E0),
                          ),
                        ),

                      // Materias.
                      for (final clase in clasesValidas)
                        Positioned(
                          left: anchoHora +
                              (_dias.indexOf(clase.dia) *
                                  anchoDia) +
                              3,
                          top: (_minutos(clase.horaInicio) -
                                  inicio) *
                              escala +
                              2,
                          width: anchoDia - 6,
                          height: ((_minutos(clase.horaFin) -
                                      _minutos(clase.horaInicio)) *
                                  escala -
                              4)
                              .clamp(24.0, double.infinity)
                              .toDouble(),
                          child: Material(
                            color: _colorMateria(clase.materia),
                            borderRadius:
                                BorderRadius.circular(10),
                            child: InkWell(
                              borderRadius:
                                  BorderRadius.circular(10),
                              onTap: onEditar == null
                                  ? null
                                  : () => onEditar!(clase),
                              child: Padding(
                                padding: const EdgeInsets.all(7),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      clase.materia,
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      '${clase.horaInicio} - '
                                      '${clase.horaFin}',
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
