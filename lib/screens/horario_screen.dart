
import 'package:flutter/material.dart';

import '../models/clase.dart';
import '../services/horario_firestore_service.dart';
import '../widgets/tabla_horario_widget.dart';

class HorarioScreen extends StatefulWidget {
  const HorarioScreen({super.key});

  @override
  State<HorarioScreen> createState() =>
      _HorarioScreenState();
}

class _HorarioScreenState extends State<HorarioScreen> {
  final HorarioFirestoreService _servicio =
      HorarioFirestoreService();

  late final Stream<List<Clase>> _horarioStream;

  bool _vistaSemanal = true;

  static const List<String> _dias = [
    'Lunes',
    'Martes',
    'Miércoles',
    'Jueves',
    'Viernes',
    'Sábado',
    'Domingo',
  ];

  @override
  void initState() {
    super.initState();

    _horarioStream = _servicio.escucharHorario();
  }

  Widget _construirLista(List<Clase> clases) {
    final clasesOrdenadas = List<Clase>.from(clases);

    clasesOrdenadas.sort((a, b) {
      final diaA = _dias.indexOf(a.dia);
      final diaB = _dias.indexOf(b.dia);

      final comparacion = diaA.compareTo(diaB);

      if (comparacion != 0) {
        return comparacion;
      }

      return a.horaInicio.compareTo(b.horaInicio);
    });

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        for (final dia in _dias)
          if (clasesOrdenadas.any(
            (clase) => clase.dia == dia,
          )) ...[
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 12,
              ),
              child: Text(
                dia,
                style: const TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            for (final clase in clasesOrdenadas)
              if (clase.dia == dia)
                Card(
                  margin: const EdgeInsets.only(
                    bottom: 10,
                  ),
                  color: Colors.white,
                  elevation: 0,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          width: 5,
                          height: 60,
                          decoration: BoxDecoration(
                            color: const Color(0xFF9575CD),
                            borderRadius:
                                BorderRadius.circular(10),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                clase.materia,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.access_time,
                                    size: 16,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    '${clase.horaInicio} - '
                                    '${clase.horaFin}',
                                  ),
                                ],
                              ),
                              if (clase.salon != null &&
                                  clase.salon!.isNotEmpty)
                                Padding(
                                  padding:
                                      const EdgeInsets.only(
                                    top: 5,
                                  ),
                                  child: Text(
                                    'Salón: ${clase.salon}',
                                    style: const TextStyle(
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
          ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7FB),
      appBar: AppBar(
        title: const Text(
          'Mi horario',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
      ),
      body: StreamBuilder<List<Clase>>(
        stream: _horarioStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Colors.redAccent,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No pudimos cargar tu horario.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${snapshot.error}',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final clases = snapshot.data!;

          if (clases.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.calendar_month_outlined,
                      size: 72,
                      color: Color(0xFF9575CD),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Todavía no tienes un horario',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Importa una imagen de tu horario '
                      'y guarda las materias para verlas aquí.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          return Column(
            children: [
              Container(
                width: double.infinity,
                margin: const EdgeInsets.fromLTRB(
                  16, 16, 16, 12,
                ),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8DEFF),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '¡Este es tu horario! 💜',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Tienes ${clases.length} clases '
                      'guardadas en Firebase.',
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: ChoiceChip(
                        label: const Text('Vista semanal'),
                        avatar: const Icon(
                          Icons.calendar_view_week,
                          size: 18,
                        ),
                        selected: _vistaSemanal,
                        onSelected: (_) {
                          setState(() {
                            _vistaSemanal = true;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ChoiceChip(
                        label: const Text('Vista de lista'),
                        avatar: const Icon(
                          Icons.view_list,
                          size: 18,
                        ),
                        selected: !_vistaSemanal,
                        onSelected: (_) {
                          setState(() {
                            _vistaSemanal = false;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: _vistaSemanal
                    ? TablaHorarioWidget(
                        clases: clases,
                      )
                    : _construirLista(clases),
              ),
            ],
          );
        },
      ),
    );
  }
}
