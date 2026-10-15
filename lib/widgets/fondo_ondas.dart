
import 'package:flutter/material.dart';

class FondoOndas extends StatelessWidget {
  final Widget child;

  const FondoOndas({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned.fill(
          child: ColoredBox(
            color: Color(0xFFF9F7FF),
          ),
        ),

        // Ondas superiores
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SizedBox(
            height: 290,
            child: CustomPaint(
              painter: OndasSuperiores(),
            ),
          ),
        ),

        // Ondas inferiores
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: SizedBox(
            height: 230,
            child: CustomPaint(
              painter: OndasInferiores(),
            ),
          ),
        ),

        // Contenido de la pantalla
        Positioned.fill(
          child: child,
        ),
      ],
    );
  }
}

class OndasSuperiores extends CustomPainter {
  const OndasSuperiores();

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    final pintura = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF6945D9),
          Color(0xFF9C7AF5),
          Color(0xFFC5AEFF),
        ],
      ).createShader(rect);

    final onda = Path()
      ..lineTo(0, size.height * 0.73)
      ..cubicTo(
        size.width * 0.20,
        size.height * 0.95,
        size.width * 0.65,
        size.height * 0.48,
        size.width,
        size.height * 0.75,
      )
      ..lineTo(size.width, 0)
      ..close();

    canvas.drawPath(onda, pintura);

    final segunda = Path()
      ..moveTo(0, size.height * 0.77)
      ..cubicTo(
        size.width * 0.35,
        size.height * 1.10,
        size.width * 0.70,
        size.height * 0.60,
        size.width,
        size.height * 0.82,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(
      segunda,
      Paint()
        ..color = const Color(0xFFCDBBFF)
            .withValues(alpha: 0.22),
    );

    canvas.drawCircle(
      Offset(size.width * 0.85, size.height * 0.20),
      85,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.09),
    );

    canvas.drawCircle(
      Offset(size.width * 0.12, size.height * 0.30),
      48,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.10),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

class OndasInferiores extends CustomPainter {
  const OndasInferiores();

  @override
  void paint(Canvas canvas, Size size) {
    final onda = Path()
      ..moveTo(0, size.height * 0.58)
      ..cubicTo(
        size.width * 0.30,
        size.height * 0.20,
        size.width * 0.70,
        size.height * 0.85,
        size.width,
        size.height * 0.38,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(
      onda,
      Paint()
        ..color = const Color(0xFFECE4FF)
            .withValues(alpha: 0.65),
    );

    final onda2 = Path()
      ..moveTo(0, size.height * 0.80)
      ..cubicTo(
        size.width * 0.30,
        size.height * 0.50,
        size.width * 0.75,
        size.height * 0.98,
        size.width,
        size.height * 0.65,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(
      onda2,
      Paint()
        ..color = const Color(0xFFDCCEFF)
            .withValues(alpha: 0.45),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
