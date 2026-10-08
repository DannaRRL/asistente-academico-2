
import '../models/clase.dart';
import 'ocr_service.dart';

class HorarioParserService {
  static const List<String> _dias = [
    'Lunes',
    'Martes',
    'Miércoles',
    'Jueves',
    'Viernes',
  ];

  List<Clase> convertirAClases(ResultadoOcr resultado) {
    final lineas = resultado.lineas;

    if (lineas.isEmpty) return [];

    // 1. Encontrar los encabezados de los días.
    // La tabla verdadera tiene varios días alineados
    // horizontalmente.
    final candidatos = <_EncabezadoDia>[];

    for (final linea in lineas) {
      final texto = _normalizar(linea.texto);

      for (final dia in _dias) {
        if (texto == _normalizar(dia)) {
          candidatos.add(
            _EncabezadoDia(
              dia: dia,
              x: linea.centroX,
              y: linea.centroY,
            ),
          );
        }
      }
    }

    if (candidatos.isEmpty) return [];

    // Elegir la fila que contiene más encabezados
    // de días, evitando otras secciones del documento.
    List<_EncabezadoDia> mejorFila = [];

    for (final candidato in candidatos) {
      final fila = candidatos.where((otro) {
        return (otro.y - candidato.y).abs() < 25;
      }).toList();

      if (fila.length > mejorFila.length) {
        mejorFila = fila;
      }
    }

    if (mejorFila.length < 2) return [];

    mejorFila.sort((a, b) => a.x.compareTo(b.x));

    final encabezados = <String, double>{
      for (final dia in mejorFila) dia.dia: dia.x,
    };

    final encabezadoY =
        mejorFila.map((e) => e.y).reduce((a, b) => a + b) /
        mejorFila.length;

    // 2. Detectar los horarios debajo del encabezado.
    final horarios = <_FilaHorario>[];

    for (final linea in lineas) {
      if (linea.centroY <= encabezadoY) continue;

      final intervalo = _extraerHorario(linea.texto);

      if (intervalo == null) continue;

      horarios.add(
        _FilaHorario(
          inicio: intervalo.$1,
          fin: intervalo.$2,
          y: linea.centroY,
          x: linea.centroX,
        ),
      );
    }

    if (horarios.isEmpty) return [];

    // La columna de horas debe estar a la izquierda
    // de las materias.
    final primerDiaX =
        encabezados.values.reduce((a, b) => a < b ? a : b);

    horarios.removeWhere(
      (hora) => hora.x >= primerDiaX,
    );

    if (horarios.isEmpty) return [];

    horarios.sort((a, b) => a.y.compareTo(b.y));

    // Eliminar filas horarias duplicadas.
    final filasUnicas = <_FilaHorario>[];

    for (final fila in horarios) {
      final repetida = filasUnicas.any(
        (otra) => (otra.y - fila.y).abs() < 8,
      );

      if (!repetida) filasUnicas.add(fila);
    }

    // 3. Definir los límites de las columnas.
    final columnas = mejorFila;

    final celdas = <String, List<String>>{};

    for (final linea in lineas) {
      if (linea.centroY <= encabezadoY) continue;

      if (_extraerHorario(linea.texto) != null) continue;

      final texto = linea.texto.trim();

      if (_ignorarTexto(texto)) continue;

      // Buscar la columna de día correspondiente.
      int indiceDia = -1;

      for (int i = 0; i < columnas.length; i++) {
        final limiteIzquierdo = i == 0
            ? columnas[i].x -
                (columnas.length > 1
                    ? (columnas[i + 1].x - columnas[i].x) / 2
                    : 50)
            : (columnas[i - 1].x + columnas[i].x) / 2;

        final limiteDerecho = i == columnas.length - 1
            ? columnas[i].x +
                (columnas.length > 1
                    ? (columnas[i].x - columnas[i - 1].x) / 2
                    : 50)
            : (columnas[i].x + columnas[i + 1].x) / 2;

        if (linea.centroX >= limiteIzquierdo &&
            linea.centroX < limiteDerecho) {
          indiceDia = i;
          break;
        }
      }

      if (indiceDia == -1) continue;

      // Encontrar la fila horaria más cercana.
      int indiceHora = -1;
      double distanciaMinima = double.infinity;

      for (int i = 0; i < filasUnicas.length; i++) {
        final distancia =
            (linea.centroY - filasUnicas[i].y).abs();

        if (distancia < distanciaMinima) {
          distanciaMinima = distancia;
          indiceHora = i;
        }
      }

      if (indiceHora == -1) continue;

      // Evitar capturar textos muy alejados de las filas.
      final separacionPromedio = filasUnicas.length > 1
          ? (filasUnicas.last.y - filasUnicas.first.y) /
              (filasUnicas.length - 1)
          : 35.0;

      if (distanciaMinima > separacionPromedio * 0.7) {
        continue;
      }

      final dia = columnas[indiceDia].dia;
      final clave = '$dia|$indiceHora';

      celdas.putIfAbsent(clave, () => []);
      celdas[clave]!.add(texto);
    }

    // 4. Construir las clases.
    final clases = <Clase>[];

    for (final entrada in celdas.entries) {
      final partes = entrada.key.split('|');

      final dia = partes[0];
      final indiceHora = int.parse(partes[1]);

      final materia = entrada.value.join(' ').trim();

      if (materia.isEmpty) continue;

      final horario = filasUnicas[indiceHora];

      clases.add(
        Clase(
          materia: materia,
          dia: dia,
          horaInicio: horario.inicio,
          horaFin: horario.fin,
        ),
      );
    }

    // 5. Ordenar y unir materias consecutivas.
    clases.sort((a, b) {
      final diaA = _dias.indexOf(a.dia);
      final diaB = _dias.indexOf(b.dia);

      final comparacion = diaA.compareTo(diaB);

      if (comparacion != 0) return comparacion;

      return a.horaInicio.compareTo(b.horaInicio);
    });

    final agrupadas = <Clase>[];

    for (final clase in clases) {
      if (agrupadas.isNotEmpty) {
        final anterior = agrupadas.last;

        if (anterior.dia == clase.dia &&
            _normalizar(anterior.materia) ==
                _normalizar(clase.materia) &&
            anterior.horaFin == clase.horaInicio) {
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

    return agrupadas;
  }

  // Convierte horarios reconocidos con distintos
  // separadores a HH:mm - HH:mm.
  (String, String)? _extraerHorario(String texto) {
    final limpio = texto
        .replaceAll(' ', '')
        .replaceAll('–', '-')
        .replaceAll('—', '-')
        .replaceAll('.', ':');

    final partes = limpio.split('-');

    if (partes.length != 2) return null;

    final inicio = _normalizarHora(partes[0]);
    final fin = _normalizarHora(partes[1]);

    if (inicio == null || fin == null) return null;

    if (inicio.compareTo(fin) >= 0) return null;

    return (inicio, fin);
  }

  String? _normalizarHora(String texto) {
    final limpio = texto.replaceAll(':', '');

    if (!RegExp(r'^\d{3,4}$').hasMatch(limpio)) {
      return null;
    }

    final horas = int.tryParse(
      limpio.substring(0, limpio.length - 2),
    );

    final minutos = int.tryParse(
      limpio.substring(limpio.length - 2),
    );

    if (horas == null || minutos == null) return null;

    if (horas > 23 || minutos > 59) return null;

    return '${horas.toString().padLeft(2, '0')}:'
        '${minutos.toString().padLeft(2, '0')}';
  }

  String _normalizar(String texto) {
    return texto
        .toUpperCase()
        .replaceAll('Á', 'A')
        .replaceAll('É', 'E')
        .replaceAll('Í', 'I')
        .replaceAll('Ó', 'O')
        .replaceAll('Ú', 'U')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  bool _ignorarTexto(String texto) {
    final normalizado = _normalizar(texto);

    if (normalizado.isEmpty) return true;

    final ignorados = [
      'COORDINADOR',
      'SECRETARIA ACADEMICA',
      'DATOS DEL GRUPO',
      'CUATRIMESTRE',
      'CODIGO DE GRUPO',
      'RESUMEN DE MATERIAS',
      'DOCENTE',
      'HORARIO DE CLASES',
      'GRUPO:',
      'AREA:',
      'UNIVERSIDAD',
    ];

    if (ignorados.any(
      (palabra) => normalizado.contains(palabra),
    )) {
      return true;
    }

    if (_dias.any(
      (dia) => normalizado == _normalizar(dia),
    )) {
      return true;
    }

    return false;
  }
}

class _EncabezadoDia {
  final String dia;
  final double x;
  final double y;

  _EncabezadoDia({
    required this.dia,
    required this.x,
    required this.y,
  });
}

class _FilaHorario {
  final String inicio;
  final String fin;
  final double x;
  final double y;

  _FilaHorario({
    required this.inicio,
    required this.fin,
    required this.x,
    required this.y,
  });
}
