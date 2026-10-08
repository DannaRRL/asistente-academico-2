import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class TextoDetectado {
  final String texto;
  final double izquierda;
  final double arriba;
  final double derecha;
  final double abajo;

  TextoDetectado({
    required this.texto,
    required this.izquierda,
    required this.arriba,
    required this.derecha,
    required this.abajo,
  });

  double get centroX => (izquierda + derecha) / 2;
  double get centroY => (arriba + abajo) / 2;
}

class ResultadoOcr {
  final String textoCompleto;
  final List<TextoDetectado> lineas;

  ResultadoOcr({
    required this.textoCompleto,
    required this.lineas,
  });
}

class OcrService {
  final TextRecognizer _textRecognizer = TextRecognizer(
    script: TextRecognitionScript.latin,
  );

  Future<ResultadoOcr> reconocerHorario(String rutaImagen) async {
    final InputImage inputImage = InputImage.fromFilePath(rutaImagen);

    final RecognizedText resultado =
        await _textRecognizer.processImage(inputImage);

    final List<TextoDetectado> lineas = [];

    for (final TextBlock bloque in resultado.blocks) {
      for (final TextLine linea in bloque.lines) {
        final rect = linea.boundingBox;

        lineas.add(
          TextoDetectado(
            texto: linea.text.trim(),
            izquierda: rect.left,
            arriba: rect.top,
            derecha: rect.right,
            abajo: rect.bottom,
          ),
        );
      }
    }

    // Ordenamos de arriba hacia abajo.
    lineas.sort(
      (a, b) => a.centroY.compareTo(b.centroY),
    );

    return ResultadoOcr(
      textoCompleto: resultado.text,
      lineas: lineas,
    );
  }

  Future<String> reconocerTexto(String rutaImagen) async {
    final ResultadoOcr resultado = await reconocerHorario(rutaImagen);

    return resultado.textoCompleto;
  }

  Future<void> cerrar() async {
    await _textRecognizer.close();
  }
}