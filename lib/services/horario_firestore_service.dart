
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/clase.dart';

class HorarioFirestoreService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final FirebaseAuth _auth =
      FirebaseAuth.instance;

  static const List<String> _dias = [
    'Lunes',
    'Martes',
    'Miércoles',
    'Jueves',
    'Viernes',
    'Sábado',
    'Domingo',
  ];

  CollectionReference<Map<String, dynamic>>
      _coleccionHorario() {
    final usuario = _auth.currentUser;

    if (usuario == null) {
      throw Exception(
        'No hay una sesión de Firebase activa.',
      );
    }

    return _firestore
        .collection('usuarios')
        .doc(usuario.uid)
        .collection('horarios');
  }

  int _numeroDia(String dia) {
    final indice = _dias.indexOf(dia);

    if (indice == -1) {
      throw Exception('Día no válido: $dia');
    }

    return indice + 1;
  }

  String _nombreDia(int numero) {
    if (numero < 1 || numero > 7) {
      return 'Lunes';
    }

    return _dias[numero - 1];
  }

  String _colorMateria(String materia) {
    const colores = [
      '#E9D5FF',
      '#BFDBFE',
      '#FBCFE8',
      '#BBF7D0',
      '#FDE68A',
      '#FED7AA',
    ];

    int suma = 0;

    for (final codigo
        in materia.trim().toUpperCase().codeUnits) {
      suma += codigo;
    }

    return colores[suma % colores.length];
  }

  Future<void> guardarHorario(
    List<Clase> clases,
  ) async {
    if (clases.isEmpty) {
      throw Exception(
        'No hay clases para guardar.',
      );
    }

    final coleccion = _coleccionHorario();

    // Primero comprobamos que todas las clases
    // tengan datos válidos.
    for (final clase in clases) {
      _numeroDia(clase.dia);

      if (clase.materia.trim().isEmpty ||
          clase.materia.trim().length > 100 ||
          clase.horaInicio.compareTo(
                clase.horaFin,
              ) >=
              0) {
        throw Exception(
          'Revisa los datos de ${clase.materia}.',
        );
      }
    }

    final existentes = await coleccion.get();
    final batch = _firestore.batch();

    // Reemplazamos el horario anterior.
    for (final documento in existentes.docs) {
      batch.delete(documento.reference);
    }

    final ahora = Timestamp.now();

    for (final clase in clases) {
      final documento = coleccion.doc();

      batch.set(documento, {
        'materia': clase.materia.trim(),
        'dia': _numeroDia(clase.dia),
        'horaInicio': clase.horaInicio,
        'horaFin': clase.horaFin,
        'color': _colorMateria(clase.materia),
        'origen': 'ocr',
        'creadoEn': ahora,
        'actualizadoEn': ahora,
      });
    }

    await batch.commit();
  }

  Stream<List<Clase>> escucharHorario() {
    return _coleccionHorario()
        .snapshots()
        .map((snapshot) {
      final clases = snapshot.docs.map((documento) {
        final datos = documento.data();

        return Clase(
          materia: datos['materia'] as String,
          dia: _nombreDia(datos['dia'] as int),
          horaInicio:
              datos['horaInicio'] as String,
          horaFin: datos['horaFin'] as String,
        );
      }).toList();

      clases.sort((a, b) {
        final diaA = _numeroDia(a.dia);
        final diaB = _numeroDia(b.dia);

        final comparacion = diaA.compareTo(diaB);

        if (comparacion != 0) {
          return comparacion;
        }

        return a.horaInicio.compareTo(
          b.horaInicio,
        );
      });

      return clases;
    });
  }
}
