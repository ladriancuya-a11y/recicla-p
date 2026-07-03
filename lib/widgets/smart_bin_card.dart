// =============================================================================
// SMART BIN CARD — RECICLA-P
// Widget visual que muestra el estado del tacho inteligente ESP32 vía BLE.
// Utiliza AnimatedContainer + AnimatedSwitcher para transiciones suaves.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/ble_provider.dart';
import '../services/ble_service.dart';
import '../theme/app_theme.dart';

class SmartBinCard extends StatelessWidget {
  const SmartBinCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<BleProvider>(
      builder: (context, ble, _) {
        final data = ble.binLevelData;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título de sección
            Row(
              children: [
                const Text(
                  'Tacho inteligente',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkGreen,
                  ),
                ),
                const Spacer(),
                _BleStatusBadge(ble: ble),
              ],
            ),
            const SizedBox(height: 10),
            // Card principal animada
            AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
              decoration: BoxDecoration(
                color: data.backgroundColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: data.primaryColor.withValues(alpha: 0.35),
                  width: 1.5,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 450),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  transitionBuilder: (child, animation) => FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.06),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  ),
                  child: _BinCardContent(
                    key: ValueKey(ble.binLevel),
                    data: data,
                    ble: ble,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Contenido interno de la tarjeta (cambia según el estado)
// ---------------------------------------------------------------------------
class _BinCardContent extends StatelessWidget {
  final BinLevelData data;
  final BleProvider ble;

  const _BinCardContent({super.key, required this.data, required this.ble});

  @override
  Widget build(BuildContext context) {
    // Si no está conectado ni en demo, mostrar el panel de conexión
    if (!ble.isConnected && ble.binLevel == BinLevel.unknown) {
      return _DisconnectedPanel(ble: ble);
    }

    return Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Fila superior: icono + label + porcentaje
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _AnimatedBinIcon(data: data),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.label,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: data.accentColor,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      data.sublabel,
                      style: TextStyle(
                        fontSize: 12,
                        color: data.accentColor.withValues(alpha: 0.65),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              // Porcentaje animado
              _PercentageBadge(data: data),
            ],
          ),

          const SizedBox(height: 16),

          // Barra de nivel visual (3 segmentos tipo celdas)
          _BinLevelBar(data: data),

          const SizedBox(height: 14),

          // Alerta roja si está lleno
          if (data.showAlert && data.alertMessage != null)
            _AlertBanner(message: data.alertMessage!, color: data.primaryColor),

          // Consejo si no está lleno
          if (!data.showAlert && data.level != BinLevel.unknown)
            _TipRow(data: data),

          const SizedBox(height: 6),

          // Fila inferior: modo demo + botón reconectar
          _BottomRow(ble: ble, data: data),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Panel mostrado cuando no hay conexión activa
// ---------------------------------------------------------------------------
class _DisconnectedPanel extends StatelessWidget {
  final BleProvider ble;
  const _DisconnectedPanel({required this.ble});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.lightGreen,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(Icons.bluetooth_searching_rounded,
                  color: AppColors.primaryGreen, size: 32),
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Tacho inteligente',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.darkGreen,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            ble.lastError ??
                'Conecta tu ESP32 SmartBin vía Bluetooth para ver el nivel del tacho en tiempo real.',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.mediumGray,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _ConnectButton(ble: ble),
              const SizedBox(width: 10),
              // Botón demo siempre disponible
              OutlinedButton.icon(
                onPressed: ble.toggleDemo,
                icon: const Icon(Icons.play_circle_outline_rounded, size: 16),
                label: const Text('Demo'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.darkGreen,
                  side: const BorderSide(color: AppColors.darkGreen),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  textStyle: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Ícono animado del tacho (gráfico vectorial con CustomPainter)
// ---------------------------------------------------------------------------
class _AnimatedBinIcon extends StatelessWidget {
  final BinLevelData data;
  const _AnimatedBinIcon({required this.data});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        color: data.primaryColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: data.primaryColor.withValues(alpha: 0.4),
          width: 1.5,
        ),
      ),
      child: Center(
        child: CustomPaint(
          size: const Size(36, 36),
          painter: _BinIconPainter(
            fillColor: data.primaryColor,
            percentage: data.percentage,
          ),
        ),
      ),
    );
  }
}

// Pintor del icono del tacho con relleno proporcional
class _BinIconPainter extends CustomPainter {
  final Color fillColor;
  final double percentage;

  _BinIconPainter({required this.fillColor, required this.percentage});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final outlinePaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..color = fillColor.withValues(alpha: 0.25)
      ..style = PaintingStyle.fill;

    final fillSolidPaint = Paint()
      ..color = fillColor.withValues(alpha: 0.7)
      ..style = PaintingStyle.fill;

    // Cuerpo del tacho (trapezoide redondeado)
    final bodyTop = h * 0.2;
    final bodyBottom = h * 0.95;
    final bodyTopW = w * 0.68;
    final bodyBottomW = w * 0.80;
    final centerX = w / 2;

    final bodyPath = Path()
      ..moveTo(centerX - bodyTopW / 2, bodyTop)
      ..lineTo(centerX + bodyTopW / 2, bodyTop)
      ..lineTo(centerX + bodyBottomW / 2, bodyBottom)
      ..lineTo(centerX - bodyBottomW / 2, bodyBottom)
      ..close();

    // Relleno de fondo
    canvas.drawPath(bodyPath, fillPaint);

    // Relleno proporcional (desde abajo hacia arriba)
    if (percentage > 0) {
      final fillH = (bodyBottom - bodyTop) * percentage;
      final fillTop = bodyBottom - fillH;
      // Interpolación del ancho en fillTop
      final t = (fillTop - bodyTop) / (bodyBottom - bodyTop);
      final fillTopW = bodyTopW + (bodyBottomW - bodyTopW) * t;

      final fillPath = Path()
        ..moveTo(centerX - fillTopW / 2, fillTop)
        ..lineTo(centerX + fillTopW / 2, fillTop)
        ..lineTo(centerX + bodyBottomW / 2, bodyBottom)
        ..lineTo(centerX - bodyBottomW / 2, bodyBottom)
        ..close();

      canvas.save();
      canvas.clipPath(bodyPath);
      canvas.drawPath(fillPath, fillSolidPaint);
      canvas.restore();
    }

    // Contorno del cuerpo
    canvas.drawPath(bodyPath, outlinePaint);

    // Tapa del tacho
    final lidPath = Path()
      ..moveTo(centerX - w * 0.44, bodyTop)
      ..lineTo(centerX + w * 0.44, bodyTop)
      ..lineTo(centerX + w * 0.36, h * 0.12)
      ..lineTo(centerX - w * 0.36, h * 0.12)
      ..close();
    canvas.drawPath(lidPath, fillPaint);
    canvas.drawPath(lidPath, outlinePaint);

    // Asa de la tapa
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(centerX, h * 0.07), width: w * 0.25, height: h * 0.09),
        const Radius.circular(3),
      ),
      outlinePaint,
    );

    // Líneas de ventilación internas
    if (percentage < 1.0) {
      final linePaint = Paint()
        ..color = fillColor.withValues(alpha: 0.4)
        ..strokeWidth = 1.2
        ..strokeCap = StrokeCap.round;
      for (int i = 0; i < 3; i++) {
        final lx = centerX - w * 0.14 + i * w * 0.14;
        canvas.drawLine(
          Offset(lx, bodyTop + h * 0.12),
          Offset(lx, bodyBottom - h * 0.06),
          linePaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _BinIconPainter old) =>
      old.percentage != percentage || old.fillColor != fillColor;
}

// ---------------------------------------------------------------------------
// Badge de porcentaje
// ---------------------------------------------------------------------------
class _PercentageBadge extends StatelessWidget {
  final BinLevelData data;
  const _PercentageBadge({required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.level == BinLevel.unknown) return const SizedBox.shrink();
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: data.primaryColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: data.primaryColor.withValues(alpha: 0.4)),
      ),
      child: Text(
        '${(data.percentage * 100).round()}%',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w800,
          color: data.accentColor,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Barra de nivel con 3 segmentos
// ---------------------------------------------------------------------------
class _BinLevelBar extends StatelessWidget {
  final BinLevelData data;
  const _BinLevelBar({required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.level == BinLevel.unknown) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Nivel de llenado',
              style: TextStyle(
                fontSize: 11,
                color: data.accentColor.withValues(alpha: 0.65),
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            Text(
              data.label,
              style: TextStyle(
                fontSize: 11,
                color: data.primaryColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        // 3 segmentos tipo "batería"
        Row(
          children: List.generate(3, (i) {
            final filled = i <= data.fillSegments;
            return Expanded(
              child: AnimatedContainer(
                duration: Duration(milliseconds: 300 + i * 80),
                curve: Curves.easeOut,
                height: 10,
                margin: EdgeInsets.only(right: i < 2 ? 5 : 0),
                decoration: BoxDecoration(
                  color: filled
                      ? data.primaryColor
                      : data.primaryColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Vacío',
                style: TextStyle(
                    fontSize: 10,
                    color: data.accentColor.withValues(alpha: 0.5))),
            Text('Lleno',
                style: TextStyle(
                    fontSize: 10,
                    color: data.accentColor.withValues(alpha: 0.5))),
          ],
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Banner de alerta (tacho lleno)
// ---------------------------------------------------------------------------
class _AlertBanner extends StatelessWidget {
  final String message;
  final Color color;
  const _AlertBanner({required this.message, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: color, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Fila de consejo (cuando no está lleno)
// ---------------------------------------------------------------------------
class _TipRow extends StatelessWidget {
  final BinLevelData data;
  const _TipRow({required this.data});

  @override
  Widget build(BuildContext context) {
    final tips = {
      BinLevel.empty: '♻️  Recuerda separar los residuos antes de depositarlos.',
      BinLevel.half: '🕒  Programa el vaciado próximamente.',
    };
    final tip = tips[data.level];
    if (tip == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.divider),
      ),
      child: Text(
        tip,
        style: const TextStyle(
          fontSize: 12,
          color: AppColors.darkGray,
          height: 1.4,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Fila inferior: info de demo + botón reconectar
// ---------------------------------------------------------------------------
class _BottomRow extends StatelessWidget {
  final BleProvider ble;
  final BinLevelData data;
  const _BottomRow({required this.ble, required this.data});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (ble.isDemoMode)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.darkGreen.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.science_outlined,
                    size: 12, color: AppColors.darkGreen),
                SizedBox(width: 4),
                Text(
                  'Modo demo',
                  style: TextStyle(
                      fontSize: 10,
                      color: AppColors.darkGreen,
                      fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        const Spacer(),
        _ReconnectButton(ble: ble),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Botón de reconexión
// ---------------------------------------------------------------------------
class _ReconnectButton extends StatelessWidget {
  final BleProvider ble;
  const _ReconnectButton({required this.ble});

  @override
  Widget build(BuildContext context) {
    final isActive = ble.isScanning || ble.isConnecting;

    return GestureDetector(
      onTap: isActive ? null : ble.reconnect,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color:
              isActive ? AppColors.lightGray : AppColors.darkGreen.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isActive ? AppColors.divider : AppColors.darkGreen.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isActive)
              const SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primaryGreen,
                ),
              )
            else
              const Icon(Icons.bluetooth_searching_rounded,
                  size: 13, color: AppColors.darkGreen),
            const SizedBox(width: 6),
            Text(
              isActive ? ble.statusLabel : 'Reconectar',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color:
                    isActive ? AppColors.mediumGray : AppColors.darkGreen,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Botón de conexión inicial
// ---------------------------------------------------------------------------
class _ConnectButton extends StatelessWidget {
  final BleProvider ble;
  const _ConnectButton({required this.ble});

  @override
  Widget build(BuildContext context) {
    final isActive = ble.isScanning || ble.isConnecting;

    return ElevatedButton.icon(
      onPressed: isActive ? null : ble.connect,
      icon: isActive
          ? const SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.white,
              ),
            )
          : const Icon(Icons.bluetooth_rounded, size: 16),
      label: Text(isActive ? ble.statusLabel : 'Conectar ESP32'),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.darkGreen,
        foregroundColor: AppColors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        textStyle:
            const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Badge de estado BLE en la barra superior de la tarjeta
// ---------------------------------------------------------------------------
class _BleStatusBadge extends StatelessWidget {
  final BleProvider ble;
  const _BleStatusBadge({required this.ble});

  @override
  Widget build(BuildContext context) {
    Color dotColor;
    String label;

    switch (ble.connectionState) {
      case BleConnectionState.connected:
        dotColor = AppColors.primaryGreen;
        label = ble.isDemoMode ? 'Demo' : 'Conectado';
        break;
      case BleConnectionState.scanning:
      case BleConnectionState.connecting:
      case BleConnectionState.discovering:
        dotColor = const Color(0xFFF5A623);
        label = 'Buscando...';
        break;
      case BleConnectionState.error:
        dotColor = const Color(0xFFE53935);
        label = 'Error';
        break;
      default:
        dotColor = AppColors.mediumGray;
        label = 'Desconectado';
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: dotColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: dotColor.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _PulsingDot(color: dotColor,
              pulse: ble.isScanning || ble.isConnecting),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: dotColor,
            ),
          ),
        ],
      ),
    );
  }
}

// Punto animado con efecto de pulso
class _PulsingDot extends StatefulWidget {
  final Color color;
  final bool pulse;
  const _PulsingDot({required this.color, required this.pulse});

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _scale = Tween<double>(begin: 0.7, end: 1.3).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.pulse) {
      return Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color: widget.color,
          shape: BoxShape.circle,
        ),
      );
    }
    return AnimatedBuilder(
      animation: _scale,
      builder: (_, __) => Transform.scale(
        scale: _scale.value,
        child: Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: widget.color,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}
