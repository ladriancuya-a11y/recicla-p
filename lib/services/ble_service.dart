// =============================================================================
// BLE SERVICE — RECICLA-P x ESP32-S3 Smart Bin
// Gestiona: escaneo → conexión → descubrimiento → suscripción → stream
// =============================================================================

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'ble_constants.dart';

// ---------------------------------------------------------------------------
// Enum de nivel del tacho
// ---------------------------------------------------------------------------
enum BinLevel {
  empty,  // Verde  — Tacho vacío
  half,   // Amarillo — Tacho medio lleno
  full,   // Rojo   — Tacho lleno / requiere vaciado
  unknown // Estado inicial o datos no reconocidos
}

// ---------------------------------------------------------------------------
// Enum de estado de la conexión BLE
// ---------------------------------------------------------------------------
enum BleConnectionState {
  idle,         // Sin actividad
  scanning,     // Escaneando dispositivos cercanos
  connecting,   // Conectando al ESP32
  discovering,  // Descubriendo servicios y características
  connected,    // Conectado y recibiendo datos
  disconnected, // Desconectado (puede reintentar)
  error,        // Error irrecuperable
}

// ---------------------------------------------------------------------------
// BleService: capa de acceso a datos BLE (independiente de la UI)
// ---------------------------------------------------------------------------
class BleService {
  // Singleton
  static final BleService _instance = BleService._internal();
  factory BleService() => _instance;
  BleService._internal();

  // --- Streams públicos ---
  final _binLevelController =
      StreamController<BinLevel>.broadcast();
  final _connectionStateController =
      StreamController<BleConnectionState>.broadcast();
  final _errorController =
      StreamController<String>.broadcast();

  Stream<BinLevel> get binLevelStream => _binLevelController.stream;
  Stream<BleConnectionState> get connectionStateStream =>
      _connectionStateController.stream;
  Stream<String> get errorStream => _errorController.stream;

  // --- Estado interno ---
  BluetoothDevice? _connectedDevice;
  BluetoothCharacteristic? _targetCharacteristic;
  StreamSubscription<List<ScanResult>>? _scanSubscription;
  // ignore: unused_field
  StreamSubscription<BluetoothConnectionState>? _connectionSubscription;
  StreamSubscription<List<int>>? _characteristicSubscription;
  bool _isScanning = false;

  BleConnectionState _state = BleConnectionState.idle;
  BinLevel _currentLevel = BinLevel.unknown;

  BleConnectionState get currentConnectionState => _state;
  BinLevel get currentBinLevel => _currentLevel;

  // --------------------------------------------------------------------------
  // 1. INICIAR ESCANEO — busca el ESP32_SmartBin por nombre o UUID de servicio
  // --------------------------------------------------------------------------
  Future<void> startScan() async {
    if (_isScanning) return;

    _emitState(BleConnectionState.scanning);

    // Verificar que el adaptador BLE esté disponible y encendido
    final adapterState = await FlutterBluePlus.adapterState.first;
    if (adapterState != BluetoothAdapterState.on) {
      _emitError('Bluetooth no está activado. Por favor actívalo e intenta de nuevo.');
      _emitState(BleConnectionState.error);
      return;
    }

    _isScanning = true;

    // Cancelar escaneo previo si existe
    await FlutterBluePlus.stopScan();

    try {
      await FlutterBluePlus.startScan(
        // Filtrar por UUID del servicio para mayor eficiencia
        withServices: [Guid(BleConstants.serviceUuid)],
        timeout: Duration(seconds: BleConstants.scanTimeoutSeconds),
        androidUsesFineLocation: false,
      );
    } catch (_) {
      // Si falla el filtro por servicio, escanear sin filtro
      await FlutterBluePlus.startScan(
        timeout: Duration(seconds: BleConstants.scanTimeoutSeconds),
        androidUsesFineLocation: false,
      );
    }

    _scanSubscription = FlutterBluePlus.scanResults.listen(
      (results) {
        for (final result in results) {
          final name = result.device.platformName;
          final advName = result.advertisementData.advName;

          final isTarget = name == BleConstants.deviceName ||
              advName == BleConstants.deviceName ||
              result.advertisementData.serviceUuids
                  .any((u) => u.str128.toLowerCase() ==
                      BleConstants.serviceUuid.toLowerCase());

          if (isTarget) {
            _stopScan();
            _connectToDevice(result.device);
            return;
          }
        }
      },
      onError: (e) {
        _emitError('Error durante el escaneo: $e');
        _emitState(BleConnectionState.error);
        _isScanning = false;
      },
    );

    // Timeout manual si el scan termina sin encontrar el dispositivo
    Future.delayed(Duration(seconds: BleConstants.scanTimeoutSeconds + 1), () {
      if (_isScanning) {
        _stopScan();
        _emitError(
            'No se encontró el dispositivo "${BleConstants.deviceName}". '
            'Asegúrate de que el ESP32 está encendido y en rango.');
        _emitState(BleConnectionState.disconnected);
      }
    });
  }

  // --------------------------------------------------------------------------
  // 2. DETENER ESCANEO
  // --------------------------------------------------------------------------
  Future<void> _stopScan() async {
    _isScanning = false;
    await _scanSubscription?.cancel();
    _scanSubscription = null;
    await FlutterBluePlus.stopScan();
  }

  // --------------------------------------------------------------------------
  // 3. CONECTAR AL DISPOSITIVO ESP32
  // --------------------------------------------------------------------------
  Future<void> _connectToDevice(BluetoothDevice device) async {
    _emitState(BleConnectionState.connecting);
    _connectedDevice = device;

    // Escuchar cambios de estado de la conexión física
    _connectionSubscription =
        device.connectionState.listen((state) async {
      if (state == BluetoothConnectionState.disconnected) {
        await _characteristicSubscription?.cancel();
        _characteristicSubscription = null;
        _targetCharacteristic = null;
        _currentLevel = BinLevel.unknown;
        _emitState(BleConnectionState.disconnected);
        debugPrint('[BLE] Dispositivo desconectado.');
      }
    });

    try {
      await device.connect(
        autoConnect: false,
        timeout: const Duration(seconds: 12),
      );
    } catch (e) {
      _emitError('Error al conectar: $e');
      _emitState(BleConnectionState.error);
      return;
    }

    await _discoverServicesAndSubscribe(device);
  }

  // --------------------------------------------------------------------------
  // 4. DESCUBRIR SERVICIOS Y SUSCRIBIRSE A LA CARACTERÍSTICA
  // --------------------------------------------------------------------------
  Future<void> _discoverServicesAndSubscribe(BluetoothDevice device) async {
    _emitState(BleConnectionState.discovering);

    List<BluetoothService> services;
    try {
      services = await device.discoverServices();
    } catch (e) {
      _emitError('Error al descubrir servicios: $e');
      _emitState(BleConnectionState.error);
      return;
    }

    BluetoothCharacteristic? characteristic;

    for (final service in services) {
      if (service.serviceUuid.str128.toLowerCase() ==
          BleConstants.serviceUuid.toLowerCase()) {
        for (final c in service.characteristics) {
          if (c.characteristicUuid.str128.toLowerCase() ==
              BleConstants.characteristicUuid.toLowerCase()) {
            characteristic = c;
            break;
          }
        }
      }
    }

    if (characteristic == null) {
      _emitError(
          'Servicio/característica no encontrada en el ESP32. '
          'Verifica que los UUIDs del firmware coincidan con BleConstants.');
      _emitState(BleConnectionState.error);
      return;
    }

    _targetCharacteristic = characteristic;

    // Habilitar notificaciones (NOTIFY) si la característica lo soporta
    if (characteristic.properties.notify) {
      try {
        await characteristic.setNotifyValue(true);
      } catch (e) {
        debugPrint('[BLE] No se pudo habilitar notify: $e — usando polling.');
      }

      _characteristicSubscription =
          characteristic.onValueReceived.listen(_processRawBytes);
    }

    // Lectura inicial para mostrar el estado actual sin esperar la primera notificación
    if (characteristic.properties.read) {
      try {
        final initialValue = await characteristic.read();
        _processRawBytes(initialValue);
      } catch (e) {
        debugPrint('[BLE] Lectura inicial fallida: $e');
      }
    }

    _emitState(BleConnectionState.connected);
    debugPrint('[BLE] ✅ Conectado y suscrito al ESP32 SmartBin.');
  }

  // --------------------------------------------------------------------------
  // 5. PARSEO DE DATOS RAW → BinLevel
  //    El ESP32 envía 1 byte. Se aceptan valores numéricos y ASCII.
  // --------------------------------------------------------------------------
  void _processRawBytes(List<int> bytes) {
    if (bytes.isEmpty) return;

    final byte = bytes[0];
    BinLevel newLevel;

    switch (byte) {
      case BleConstants.byteEmpty:   // 0x00
      case BleConstants.asciiEmpty:  // 'E' = 0x45
        newLevel = BinLevel.empty;
        break;
      case BleConstants.byteHalf:    // 0x01
      case BleConstants.asciiHalf:   // 'M' = 0x4D
        newLevel = BinLevel.half;
        break;
      case BleConstants.byteFull:    // 0x02
      case BleConstants.asciiFulll:  // 'F' = 0x46
        newLevel = BinLevel.full;
        break;
      default:
        debugPrint('[BLE] Byte no reconocido: 0x${byte.toRadixString(16)}');
        newLevel = BinLevel.unknown;
    }

    if (newLevel != _currentLevel) {
      _currentLevel = newLevel;
      _binLevelController.add(newLevel);
      debugPrint('[BLE] Nivel del tacho actualizado: $newLevel');
    }
  }

  // --------------------------------------------------------------------------
  // 6. RECONECTAR — llamado desde la UI al presionar "Reconectar"
  // --------------------------------------------------------------------------
  Future<void> reconnect() async {
    await disconnect();
    await Future.delayed(
        Duration(seconds: BleConstants.reconnectDelaySeconds));
    await startScan();
  }

  // --------------------------------------------------------------------------
  // 7. DESCONECTAR LIMPIAMENTE
  // --------------------------------------------------------------------------
  Future<void> disconnect() async {
    await _stopScan();
    await _characteristicSubscription?.cancel();
    _characteristicSubscription = null;

    if (_connectedDevice != null) {
      try {
        if (_targetCharacteristic != null &&
            _targetCharacteristic!.properties.notify) {
          await _targetCharacteristic!.setNotifyValue(false);
        }
        await _connectedDevice!.disconnect();
      } catch (_) {}
      _connectedDevice = null;
    }

    _targetCharacteristic = null;
    _currentLevel = BinLevel.unknown;
    _emitState(BleConnectionState.idle);
  }

  // --------------------------------------------------------------------------
  // 8. SIMULACIÓN PARA WEB / DEMO (sin hardware real)
  //    Cicla los 3 estados cada 4 segundos para demostrar la UI.
  // --------------------------------------------------------------------------
  Timer? _demoTimer;
  int _demoIndex = 0;
  final _demoLevels = [BinLevel.empty, BinLevel.half, BinLevel.full];

  void startDemoMode() {
    _emitState(BleConnectionState.connected);
    _demoIndex = 0;
    _demoTimer?.cancel();
    _processRawBytes([BleConstants.byteEmpty]);

    _demoTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      _demoIndex = (_demoIndex + 1) % _demoLevels.length;
      final level = _demoLevels[_demoIndex];
      _currentLevel = level;
      _binLevelController.add(level);
    });
  }

  void stopDemoMode() {
    _demoTimer?.cancel();
    _demoTimer = null;
  }

  // --------------------------------------------------------------------------
  // Helpers internos
  // --------------------------------------------------------------------------
  void _emitState(BleConnectionState state) {
    _state = state;
    _connectionStateController.add(state);
  }

  void _emitError(String message) {
    _errorController.add(message);
    debugPrint('[BLE ERROR] $message');
  }

  // --------------------------------------------------------------------------
  // Liberar recursos (llamar en dispose del Provider)
  // --------------------------------------------------------------------------
  Future<void> dispose() async {
    stopDemoMode();
    await disconnect();
    await _binLevelController.close();
    await _connectionStateController.close();
    await _errorController.close();
  }
}
