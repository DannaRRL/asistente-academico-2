
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../services/ocr_service.dart';
import '../services/horario_parser_service.dart';
import 'horario_detectado_screen.dart';

class ImportarHorarioScreen extends StatefulWidget {
  const ImportarHorarioScreen({super.key});

  @override
  State<ImportarHorarioScreen> createState() =>
      _ImportarHorarioScreenState();
}

class _ImportarHorarioScreenState
    extends State<ImportarHorarioScreen> {
  final ImagePicker _picker = ImagePicker();
  final OcrService _ocrService = OcrService();
  final HorarioParserService _parserService =
      HorarioParserService();

  XFile? _imagenSeleccionada;
  Uint8List? _imagenBytes;

  bool _escaneando = false;

  Future<void> _seleccionarImagen() async {
    try {
      final XFile? imagen = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 90,
      );

      if (imagen == null) return;

      final Uint8List bytes = await imagen.readAsBytes();

      if (!mounted) return;

      setState(() {
        _imagenSeleccionada = imagen;
        _imagenBytes = bytes;
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No se pudo seleccionar la imagen: $e'),
        ),
      );
    }
  }

  void _eliminarImagen() {
    setState(() {
      _imagenSeleccionada = null;
      _imagenBytes = null;
    });
  }

  Future<void> _escanearHorario() async {
    final imagen = _imagenSeleccionada;

    if (imagen == null || _escaneando) return;

    setState(() {
      _escaneando = true;
    });

    try {
      // 1. Reconocer el texto y sus posiciones X/Y.
      final resultadoOcr =
          await _ocrService.reconocerHorario(imagen.path);
          debugPrint('========== DIAGNÓSTICO OCR ==========');

debugPrint(
  'Cantidad de líneas: ${resultadoOcr.lineas.length}',
);

for (final linea in resultadoOcr.lineas) {
  debugPrint(
    'TEXTO: "${linea.texto}" '
    'X: ${linea.centroX.toStringAsFixed(1)} '
    'Y: ${linea.centroY.toStringAsFixed(1)}',
  );
}

debugPrint('========== FIN DIAGNÓSTICO ==========');

      if (!mounted) return;

      if (resultadoOcr.textoCompleto.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'No se detectó texto. Intenta con otra imagen.',
            ),
          ),
        );
        return;
      }

      // 2. Convertir el resultado en clases.
      final clases =
          _parserService.convertirAClases(resultadoOcr);

      if (!mounted) return;

      // 3. Abrir la pantalla de revisión.
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => HorarioDetectadoScreen(
            clases: clases,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ocurrió un error al escanear: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _escaneando = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _ocrService.cerrar();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool hayImagen = _imagenBytes != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7FB),
      appBar: AppBar(
        title: const Text(
          'Importar horario',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              'Importa tu horario',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Selecciona una imagen de tu horario. '
              'La aplicación intentará identificar las '
              'materias, los días y las horas.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 25),

            // Vista previa de la imagen.
            Container(
              width: double.infinity,
              height: 350,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFFE0E0E0),
                ),
              ),
              child: hayImagen
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.memory(
                        _imagenBytes!,
                        fit: BoxFit.contain,
                      ),
                    )
                  : const Column(
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.image_outlined,
                          size: 65,
                          color: Color(0xFF6750A4),
                        ),
                        SizedBox(height: 15),
                        Text(
                          'Aún no has seleccionado\nun horario',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
            ),

            const SizedBox(height: 20),

            // Seleccionar o cambiar imagen.
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton.icon(
                onPressed:
                    _escaneando ? null : _seleccionarImagen,
                icon: const Icon(
                  Icons.photo_library_outlined,
                ),
                label: Text(
                  hayImagen
                      ? 'Cambiar imagen'
                      : 'Seleccionar imagen',
                ),
              ),
            ),

            if (hayImagen) ...[
              const SizedBox(height: 10),

              // Escanear.
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton.icon(
                  onPressed:
                      _escaneando ? null : _escanearHorario,
                  icon: _escaneando
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(
                          Icons.document_scanner_outlined,
                        ),
                  label: Text(
                    _escaneando
                        ? 'Analizando horario...'
                        : 'Escanear horario',
                  ),
                ),
              ),

              const SizedBox(height: 10),

              TextButton.icon(
                onPressed:
                    _escaneando ? null : _eliminarImagen,
                icon: const Icon(
                  Icons.delete_outline,
                ),
                label: const Text('Quitar imagen'),
              ),
            ],

            const SizedBox(height: 25),

            // Explicación del proceso.
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Row(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Color(0xFF6750A4),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Después del escaneo podrás revisar, '
                      'editar, agregar o eliminar materias '
                      'antes de guardar tu horario.',
                      style: TextStyle(height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
