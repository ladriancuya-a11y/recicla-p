import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ReciclaLogo extends StatelessWidget {
  final double size;
  final bool showText;
  final bool darkMode;

  const ReciclaLogo({
    super.key,
    this.size = 60,
    this.showText = true,
    this.darkMode = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = darkMode ? AppColors.white : AppColors.darkGreen;
    final bgColor = darkMode ? AppColors.darkGreen : AppColors.primaryGreen;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomPaint(
          size: Size(size, size),
          painter: _LogoPainter(color: color, bgColor: bgColor),
        ),
        if (showText) ...[
          SizedBox(width: size * 0.15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'RECICLA-P',
                style: TextStyle(
                  fontSize: size * 0.32,
                  fontWeight: FontWeight.w800,
                  color: color,
                  letterSpacing: 1.2,
                  height: 1.0,
                ),
              ),
              Text(
                'Gestión de residuos',
                style: TextStyle(
                  fontSize: size * 0.17,
                  fontWeight: FontWeight.w400,
                  color: color.withValues(alpha: 0.7),
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _LogoPainter extends CustomPainter {
  final Color color;
  final Color bgColor;

  _LogoPainter({required this.color, required this.bgColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..strokeCap = StrokeCap.round;

    final bgPaint = Paint()
      ..color = bgColor
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.45;

    // Fondo circular
    canvas.drawCircle(center, radius, bgPaint);

    // Dibujo del símbolo de reciclaje estilizado
    final s = size.width;

    // Barras verticales (3 barras del logo)
    final barWidth = s * 0.08;
    final barHeight = s * 0.35;
    final startY = s * 0.25;

    // Barra izquierda
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(s * 0.22, startY, barWidth, barHeight),
        Radius.circular(barWidth / 2),
      ),
      paint,
    );

    // Barra central
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(s * 0.34, startY, barWidth, barHeight),
        Radius.circular(barWidth / 2),
      ),
      paint,
    );

    // Barra derecha
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(s * 0.46, startY, barWidth, barHeight),
        Radius.circular(barWidth / 2),
      ),
      paint,
    );

    // Flecha derecha (triángulo)
    final arrowPath = Path();
    arrowPath.moveTo(s * 0.58, s * 0.38);
    arrowPath.lineTo(s * 0.72, s * 0.50);
    arrowPath.lineTo(s * 0.58, s * 0.62);
    arrowPath.close();
    canvas.drawPath(arrowPath, paint);

    // Línea inferior conectora
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(s * 0.22, s * 0.58, s * 0.38, barWidth),
        Radius.circular(barWidth / 2),
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Logo compacto solo ícono para AppBar
class ReciclaLogoIcon extends StatelessWidget {
  final double size;
  final bool onDark;

  const ReciclaLogoIcon({super.key, this.size = 32, this.onDark = false});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _LogoPainter(
        color: onDark ? AppColors.white : AppColors.darkGreen,
        bgColor: onDark ? AppColors.darkGreen : AppColors.primaryGreen,
      ),
    );
  }
}
