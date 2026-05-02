import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import 'main_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _fadeController;

  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _textOpacity;
  late Animation<Offset> _textSlide;
  late Animation<double> _screenFade;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    _logoController = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    );
    _textController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _logoScale = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: const Interval(0.0, 0.5)),
    );
    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeOut),
    );
    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _textController, curve: Curves.easeOut));
    _screenFade = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );

    _startAnimation();
  }

  Future<void> _startAnimation() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _logoController.forward();
    await Future.delayed(const Duration(milliseconds: 500));
    _textController.forward();
    await Future.delayed(const Duration(milliseconds: 1800));
    _fadeController.forward();
    await Future.delayed(const Duration(milliseconds: 600));
    if (mounted) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainScreen()),
      );
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _screenFade,
      child: Scaffold(
        backgroundColor: AppColors.primaryGreen,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedBuilder(
                animation: _logoController,
                builder: (context, child) {
                  return Opacity(
                    opacity: _logoOpacity.value,
                    child: Transform.scale(
                      scale: _logoScale.value,
                      child: child,
                    ),
                  );
                },
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppColors.darkGreen,
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.darkGreen.withValues(alpha: 0.3),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Center(
                    child: CustomPaint(
                      size: const Size(70, 70),
                      painter: _SplashLogoPainter(),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 28),
              FadeTransition(
                opacity: _textOpacity,
                child: SlideTransition(
                  position: _textSlide,
                  child: Column(
                    children: [
                      const Text(
                        'RECICLA-P',
                        style: TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.w800,
                          color: AppColors.darkGreen,
                          letterSpacing: 3,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Gestión inteligente de residuos',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: AppColors.darkGreen.withValues(alpha: 0.75),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 80),
              FadeTransition(
                opacity: _textOpacity,
                child: Column(
                  children: [
                    SizedBox(
                      width: 32,
                      height: 32,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: AppColors.darkGreen.withValues(alpha: 0.6),
                        backgroundColor: AppColors.darkGreen.withValues(alpha: 0.15),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Cargando...',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.darkGreen.withValues(alpha: 0.6),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SplashLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primaryGreen
      ..style = PaintingStyle.fill
      ..strokeCap = StrokeCap.round;

    final s = size.width;
    final barW = s * 0.10;
    final barH = s * 0.42;
    final startY = s * 0.18;
    final radius = Radius.circular(barW / 2);

    // 3 barras verticales
    for (int i = 0; i < 3; i++) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(s * (0.18 + i * 0.16), startY, barW, barH),
          radius,
        ),
        paint,
      );
    }

    // Flecha derecha
    final path = Path();
    path.moveTo(s * 0.66, s * 0.32);
    path.lineTo(s * 0.82, s * 0.50);
    path.lineTo(s * 0.66, s * 0.68);
    path.close();
    canvas.drawPath(path, paint);

    // Barra inferior
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(s * 0.18, s * 0.58, s * 0.42, barW),
        radius,
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
