
import 'package:flutter/material.dart';

import '../models/clase.dart';

class HorarioDetectadoScreen extends StatefulWidget {
  final List<Clase> clases;

  const HorarioDetectadoScreen({
    super.key,
    required this.clases,
  });

  @override
  State<HorarioDetectadoScreen> createState() =>
      _HorarioDetectadoScreenState();
}

class _HorarioDetectadoScreenState
    extends State<HorarioDetectadoScreen> {
  late List<Clase> _clases;

  final List<String> _dias = const [
    'Lunes',
    'Martes',
    'Miércoles',
    'Jueves',
    'Viernes',
  ];

  @override
  void initState() {
    super.initState();
    _clases = List<Clase>.from(widget.clases);
    _ordenarClases();
  }

  void _ordenarClases() {
    _clases.sort((a, b) {
      final diaA = _dias.indexOf(a.dia);
      final diaB = _dias.indexOf(b.dia);

      final comparacionDia = diaA.compareTo(diaB);

      if (comparacionDia != 0) {
        return comparacionDia;
      }

      return a.horaInicio.compareTo(b.horaInicio);
    });
  }

  Future<void> _editarClase(int indice) async {
    final clase = _clases[indice];

    final materiaController =
        TextEditingController(text: clase.materia);

    final inicioController =
        TextEditingController(text: clase.horaInicio);

    final finController =
        TextEditingController(text: clase.horaFin);

    final salonController =
        TextEditingController(text: clase.salon ?? '');

    String diaSeleccionado = clase.dia;

    final resultado = await showDialog<Clase>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, actualizarDialogo) {
            return AlertDialog(
              title: const Text('Editar clase'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: materiaController,
                      decoration: const InputDecoration(
                        labelText: 'Materia',
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: diaSeleccionado,
                      decoration: const InputDecoration(
                        labelText: 'Día',
                      ),
                      items: _dias.map((dia) {
                        return DropdownMenuItem(
                          value: dia,
                          child: Text(dia),
                        );
                      }).toList(),
                      onChanged: (valor) {
                        if (valor != null) {
                          actualizarDialogo(() {
                            diaSeleccionado = valor;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: inicioController,
                      decoration: const InputDecoration(
                        labelText: 'Hora inicio (HH:mm)',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: finController,
                      decoration: const InputDecoration(
                        labelText: 'Hora fin (HH:mm)',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: salonController,
                      decoration: const InputDecoration(
                        labelText: 'Salón (opcional)',
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () =>
                      Navigator.pop(dialogContext),
                  child: const Text('Cancelar'),
                ),
                FilledButton(
                  onPressed: () {
                    final materia =
                        materiaController.text.trim();
                    final inicio =
                        inicioController.text.trim();
                    final fin =
                        finController.text.trim();

                    final formatoHora = RegExp(
                      r'^([01]\d|2[0-3]):[0-5]\d$',
                    );

                    if (materia.isEmpty ||
                        !formatoHora.hasMatch(inicio) ||
                        !formatoHora.hasMatch(fin) ||
                        inicio.compareTo(fin) >= 0) {
                      ScaffoldMessenger.of(context)
                          .showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Revisa la materia y las horas.',
                          ),
                        ),
                      );
                      return;
                    }

                    Navigator.pop(
                      dialogContext,
                      Clase(
                        materia: materia,
                        dia: diaSeleccionado,
                        horaInicio: inicio,
                        horaFin: fin,
                        salon: salonController.text.trim(),
                      ),
                    );
                  },
                  child: const Text('Aplicar'),
                ),
              ],
            );
          },
        );
      },
    );

    materiaController.dispose();
    inicioController.dispose();
    finController.dispose();
    salonController.dispose();

    if (resultado != null && mounted) {
      setState(() {
        _clases[indice] = resultado;
        _ordenarClases();
      });
    }
  }

  void _eliminarClase(int indice) {
    setState(() {
      _clases.removeAt(indice);
    });
  }

  Future<void> _agregarClase() async {
    setState(() {
      _clases.add(
        const Clase(
          materia: 'Nueva materia',
          dia: 'Lunes',
          horaInicio: '08:00',
          horaFin: '08:50',
        ),
      );
      _ordenarClases();
    });

    final indice = _clases.indexWhere(
      (clase) => clase.materia == 'Nueva materia',
    );

    if (indice >= 0) {
      await _editarClase(indice);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Horario detectado'),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context)
                  .colorScheme
                  .primaryContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Text(
                  '¡Escaneo terminado!',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Encontramos ${_clases.length} registros. '
                  'Revisa los días, horarios y materias '
                  'antes de guardar.',
                ),
              ],
            ),
          ),
          Expanded(
            child: _clases.isEmpty
                ? const Center(
                    child: Text(
                      'No se detectaron clases.\n'
                      'Puedes agregarlas manualmente.',
                      textAlign: TextAlign.center,
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                    ),
                    itemCount: _clases.length,
                    itemBuilder: (context, indice) {
                      final clase = _clases[indice];

                      return Card(
                        margin: const EdgeInsets.only(
                          bottom: 10,
                        ),
                        child: Padding(
                          padding:
                              const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      clase.materia,
                                      style: const TextStyle(
                                        fontWeight:
                                            FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      '${clase.dia} • '
                                      '${clase.horaInicio} - '
                                      '${clase.horaFin}',
                                    ),
                                    if (clase.salon != null &&
                                        clase.salon!.isNotEmpty)
                                      Text(
                                        'Salón: ${clase.salon}',
                                      ),
                                  ],
                                ),
                              ),
                              IconButton(
                                tooltip: 'Editar',
                                icon: const Icon(
                                  Icons.edit_outlined,
                                ),
                                onPressed: () =>
                                    _editarClase(indice),
                              ),
                              IconButton(
                                tooltip: 'Eliminar',
                                icon: const Icon(
                                  Icons.delete_outline,
                                ),
                                onPressed: () =>
                                    _eliminarClase(indice),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.stretch,
                children: [
                  OutlinedButton.icon(
                    onPressed: _agregarClase,
                    icon: const Icon(Icons.add),
                    label: const Text('Agregar materia'),
                  ),
                  const SizedBox(height: 10),
                  FilledButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context)
                          .showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Próximo paso: guardar en Firebase.',
                          ),
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.save_outlined,
                    ),
                    label: const Text('Guardar horario'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
