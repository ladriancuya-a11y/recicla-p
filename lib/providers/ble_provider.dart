// =============================================================================
// BLE PROVIDER — RECICLA-P
// Puente entre BleService (lógica) y los widgets de la UI (Consumer/watch).
// Gestiona: solicitud de permisos, ciclo de vida, estado reactivo.
// =============================================================================

import 'dart:async';
import 'dart:ui' show Color;
import 'package:flutter/foundation.dart';
import '../services/ble_service.dart';

class BleProvider extends ChangeNotifier {
  final BleService _service = BleService();

  // --- Estado observable ---
  BleConnectionState _connectionState = BleConnectionState.idle;
  BinLevel _binLevel = BinLevel.unknown;
  String? _lastError;
  bool _isDemoMode = false;

  BleConnectionState get connectionState => _connectionState;
  BinLevel get binLevel => _binLevel;
  String? get lastError => _lastError;
  bool get isDemoMode => _isDemoMode;

  // --- Getters de conveniencia para la UI ---
  bool get isConnected => _connectionState == BleConnectionState.connected;
  bool get isScanning => _connectionState == BleConnectionState.scanning;
  bool get isConnecting =>
      _connectionState == BleConnectionState.connecting ||
      _connectionState == BleConnectionState.discovering;

  String get statusLabel {
    switch (_connectionState) {
      case BleConnectionState.idle:
        return 'Sin conectar';
      case BleConnectionState.scanning:
        return 'Buscando ESP32...';
      case BleConnectionState.connecting:
        return 'Conectando...';
      case BleConnectionState.discovering:
        return 'Configurando...';
      case BleConnectionState.connected:
        return _isDemoMode ? 'Demo activo' : 'Conectado';
      case BleConnectionState.disconnected:
        return 'Desconectado';
      case BleConnectionState.error:
        return 'Error de conexión';
    }
  }

  // Subscripciones internas a los streams del servicio
  StreamSubscription<BleConnectionState>? _connStateSub;
  StreamSubscription<BinLevel>? _binLevelSub;
  StreamSubscription<String>? _errorSub;

  BleProvider() {
    _subscribeToService();
  }

  // --------------------------------------------------------------------------
  // Subscripción a los streams del BleService
  // --------------------------------------------------------------------------
  void _subscribeToService() {
    _connStateSub = _service.connectionStateStream.listen((state) {
      _connectionState = state;
      if (state != BleConnectionState.error) {
        _lastError = null;
      }
      notifyListeners();
    });

    _binLevelSub = _service.binLevelStream.listen((level) {
      _binLevel = level;
      notifyListeners();
    });

    _errorSub = _service.errorStream.listen((error) {
      _lastError = error;
      notifyListeners();
    });
  }

  // --------------------------------------------------------------------------
  // Iniciar escaneo BLE real (dispositivo físico)
  // --------------------------------------------------------------------------
  Future<void> connect() async {
    _lastError = null;
    _isDemoMode = false;
    notifyListeners();

    // En web no hay BLE nativo — forzar demo
    if (kIsWeb) {
      _startDemo();
      return;
    }

    await _service.startScan();
  }

  // --------------------------------------------------------------------------
  // Reconectar (desde botón en la UI)
  // --------------------------------------------------------------------------
  Future<void> reconnect() async {
    _lastError = null;
    if (_isDemoMode) {
      _isDemoMode = false;
      _service.stopDemoMode();
    }
    notifyListeners();

    if (kIsWeb) {
      _startDemo();
      return;
    }

    await _service.reconnect();
  }

  // --------------------------------------------------------------------------
  // Desconectar
  // --------------------------------------------------------------------------
  Future<void> disconnect() async {
    if (_isDemoMode) {
      _isDemoMode = false;
      _service.stopDemoMode();
    }
    await _service.disconnect();
  }

  // --------------------------------------------------------------------------
  // Modo demo — para preview web y pruebas sin hardware
  // --------------------------------------------------------------------------
  void _startDemo() {
    _isDemoMode = true;
    _service.startDemoMode();
    notifyListeners();
  }

  void toggleDemo() {
    if (_isDemoMode) {
      _isDemoMode = false;
      _service.stopDemoMode();
      _connectionState = BleConnectionState.idle;
      _binLevel = BinLevel.unknown;
    } else {
      _startDemo();
    }
    notifyListeners();
  }

  // --------------------------------------------------------------------------
  // Datos del nivel del tacho para la UI
  // --------------------------------------------------------------------------
  BinLevelData get binLevelData {
    switch (_binLevel) {
      case BinLevel.empty:
        return BinLevelData(
          level: BinLevel.empty,
          label: 'Tacho vacío',
          sublabel: 'Listo para recibir residuos',
          percentage: 0.05,
          fillSegments: 0,
          primaryColor: const Color(0xFF14C38E),   // verde principal
          accentColor: const Color(0xFF0B3D2E),    // verde oscuro
          backgroundColor: const Color(0xFFE8F8F2),
          icon: '🗑️',
          alertMessage: null,
          showAlert: false,
        );
      case BinLevel.half:
        return BinLevelData(
          level: BinLevel.half,
          label: 'Tacho medio lleno',
          sublabel: 'Capacidad al 50 %',
          percentage: 0.50,
          fillSegments: 1,
          primaryColor: const Color(0xFFF5A623),   // ámbar armonioso
          accentColor: const Color(0xFF8A5700),
          backgroundColor: const Color(0xFFFFF8ED),
          icon: '⚠️',
          alertMessage: 'Considera vaciarlo pronto',
          showAlert: false,
        );
      case BinLevel.full:
        return BinLevelData(
          level: BinLevel.full,
          label: 'Tacho lleno',
          sublabel: 'Capacidad al 100 %',
          percentage: 1.0,
          fillSegments: 2,
          primaryColor: const Color(0xFFE53935),   // rojo alerta
          accentColor: const Color(0xFF7F0000),
          backgroundColor: const Color(0xFFFFEBEE),
          icon: '🚨',
          alertMessage: '¡El tacho requiere vaciado!',
          showAlert: true,
        );
      case BinLevel.unknown:
        return BinLevelData(
          level: BinLevel.unknown,
          label: 'Sin datos',
          sublabel: 'Conecta el sensor para ver el nivel',
          percentage: 0.0,
          fillSegments: -1,
          primaryColor: const Color(0xFF9E9E9E),
          accentColor: const Color(0xFF424242),
          backgroundColor: const Color(0xFFF5F5F5),
          icon: '📡',
          alertMessage: null,
          showAlert: false,
        );
    }
  }

  // --------------------------------------------------------------------------
  // Dispose limpio
  // --------------------------------------------------------------------------
  @override
  void dispose() {
    _connStateSub?.cancel();
    _binLevelSub?.cancel();
    _errorSub?.cancel();
    _service.dispose();
    super.dispose();
  }
}

// ---------------------------------------------------------------------------
// Data class con toda la información visual para un nivel dado
// ---------------------------------------------------------------------------
class BinLevelData {
  final BinLevel level;
  final String label;
  final String sublabel;
  final double percentage;        // 0.0 → 1.0
  final int fillSegments;         // 0, 1, 2  (segmentos de la barra gráfica)
  final Color primaryColor;
  final Color accentColor;
  final Color backgroundColor;
  final String icon;
  final String? alertMessage;
  final bool showAlert;

  const BinLevelData({
    required this.level,
    required this.label,
    required this.sublabel,
    required this.percentage,
    required this.fillSegments,
    required this.primaryColor,
    required this.accentColor,
    required this.backgroundColor,
    required this.icon,
    required this.alertMessage,
    required this.showAlert,
  });
}


