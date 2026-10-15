import 'package:flutter/material.dart';
import '../models/clase.dart';
import '../widgets/tabla_horario_widget.dart';
import '../services/horario_firestore_service.dart';
import 'horario_screen.dart';
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
  bool _vistaTabla = true;
  static const List<String> _dias = [
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
    _ordenarYAgrupar();
  }
  String _normalizarMateria(String texto) {
    return texto
        .trim()
        .toUpperCase()
        .replaceAll(RegExp(r'\s+'), ' ');
  }
  void _ordenarYAgrupar() {
    _clases.sort((a, b) {
      final diaA = _dias.indexOf(a.dia);
      final diaB = _dias.indexOf(b.dia);
      final comparacion = diaA.compareTo(diaB);
      if (comparacion != 0) return comparacion;
      return a.horaInicio.compareTo(b.horaInicio);
    });
    final agrupadas = <Clase>[];
    for (final clase in _clases) {
      if (agrupadas.isNotEmpty) {
        final anterior = agrupadas.last;
        final mismaMateria =
            _normalizarMateria(anterior.materia) ==
            _normalizarMateria(clase.materia);
        final mismoDia = anterior.dia == clase.dia;
        final consecutivas =
            anterior.horaFin == clase.horaInicio;
        if (mismaMateria && mismoDia && consecutivas) {
          agrupadas[agrupadas.length - 1] = Clase(
            materia: anterior.materia,
            dia: anterior.dia,
            horaInicio: anterior.horaInicio,
            horaFin: clase.horaFin,
            salon: anterior.salon,
          );
          continue;
        }
      }
      agrupadas.add(clase);
    }
    _clases = agrupadas;
  }
  Future<Clase?> _mostrarEditor(Clase clase) async {
    final materiaController =
        TextEditingController(text: clase.materia);
    final inicioController =
        TextEditingController(text: clase.horaInicio);
    final finController =
        TextEditingController(text: clase.horaFin);
    final salonController =
        TextEditingController(text: clase.salon ?? '');
    String diaSeleccionado =
        _dias.contains(clase.dia) ? clase.dia : 'Lunes';
    final resultado = await showDialog<Clase>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, actualizarDialogo) {
            return AlertDialog(
              title: const Text('Editar materia'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: materiaController,
                      decoration: const InputDecoration(
                        labelText: 'Materia',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: diaSeleccionado,
                      decoration: const InputDecoration(
                        labelText: 'Día',
                        border: OutlineInputBorder(),
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
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.datetime,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: finController,
                      decoration: const InputDecoration(
                        labelText: 'Hora fin (HH:mm)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.datetime,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: salonController,
                      decoration: const InputDecoration(
                        labelText: 'Salón (opcional)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                  },
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
                      ScaffoldMessenger.of(dialogContext)
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
    return resultado;
  }
  Future<void> _editarClase(Clase clase) async {
    final resultado = await _mostrarEditor(clase);
    if (resultado == null || !mounted) return;
    final indice = _clases.indexOf(clase);
    if (indice < 0) return;
    setState(() {
      _clases[indice] = resultado;
      _ordenarYAgrupar();
    });
  }
  Future<void> _agregarClase() async {
    const nuevaClase = Clase(
      materia: '',
      dia: 'Lunes',
      horaInicio: '08:00',
      horaFin: '08:50',
    );
    final resultado = await _mostrarEditor(nuevaClase);
    if (resultado == null || !mounted) return;
    setState(() {
      _clases.add(resultado);
      _ordenarYAgrupar();
    });
  }
  void _eliminarClase(Clase clase) {
    setState(() {
      _clases.remove(clase);
    });
  }
  Widget _construirLista() {
    if (_clases.isEmpty) {
      return const Center(
        child: Text(
          'No se detectaron clases.\n'
          'Puedes agregarlas manualmente.',
          textAlign: TextAlign.center,
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      itemCount: _clases.length,
      itemBuilder: (context, indice) {
        final clase = _clases[indice];
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: Padding(
            padding: const EdgeInsets.all(12),
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
                          fontWeight: FontWeight.bold,
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
                        Text('Salón: ${clase.salon}'),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Editar',
                  onPressed: () => _editarClase(clase),
                  icon: const Icon(Icons.edit_outlined),
                ),
                IconButton(
                  tooltip: 'Eliminar',
                  onPressed: () => _eliminarClase(clase),
                  icon: const Icon(Icons.delete_outline),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  Widget _construirTabla() {
    return TablaHorarioWidget(
      clases: _clases,
      onEditar: _editarClase,
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7FB),
      appBar: AppBar(
        title: const Text('Horario detectado'),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
      ),
      body: SafeArea(
        child: Column(
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
                    '¡Escaneo terminado!',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Encontramos ${_clases.length} clases. '
                    'Revisa que los días, las materias '
                    'y los horarios sean correctos.',
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
                      selected: _vistaTabla,
                      onSelected: (_) {
                        setState(() {
                          _vistaTabla = true;
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
                      selected: !_vistaTabla,
                      onSelected: (_) {
                        setState(() {
                          _vistaTabla = false;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: _vistaTabla
                  ? _construirTabla()
                  : _construirLista(),
            ),
            Container(
              color: Colors.white,
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.stretch,
                    children: [
                      OutlinedButton.icon(
                        onPressed: _agregarClase,
                        icon: const Icon(Icons.add),
                        label: const Text(
                          'Agregar materia',
                        ),
                      ),
                      const SizedBox(height: 10),
                     FilledButton.icon(
  onPressed: _guardando ? null : _guardarHorario,
  icon: _guardando
      ? const SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(
            strokeWidth: 2,
          ),
        )
      : const Icon(Icons.save_outlined),
  label: Text(
    _guardando ? 'Guardando...' : 'Guardar horario',
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
  bool _guardando = false;
  Future<void> _guardarHorario() async {
    if (_guardando) return;
    if (_clases.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Agrega al menos una materia.')),
      );
      return;
    }
    setState(() => _guardando = true);
    try {
      await HorarioFirestoreService().guardarHorario(_clases);
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HorarioScreen()),
        (route) => route.isFirst,
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al guardar: $error'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }
}
