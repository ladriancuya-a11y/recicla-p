// =============================================================================
// BLE CONSTANTS — RECICLA-P x ESP32-S3 Smart Bin
// =============================================================================
//
// Instrucciones para el firmware del ESP32-S3:
// ---------------------------------------------
// 1. Usa el mismo SERVICE_UUID y CHARACTERISTIC_UUID en el servidor BLE del ESP32.
// 2. La característica debe tener las propiedades: READ + NOTIFY.
// 3. El ESP32 debe enviar 1 byte con los valores:
//      0x00  → Tacho vacío      (EMPTY)
//      0x01  → Tacho medio      (HALF)
//      0x02  → Tacho lleno      (FULL)
//    También se aceptan los bytes ASCII: 'E' (0x45), 'M' (0x4D), 'F' (0x46)
// 4. Código de ejemplo para Arduino/ESP32-IDF:
//    pCharacteristic->setValue(&binLevel, 1);
//    pCharacteristic->notify();
// =============================================================================

class BleConstants {
  BleConstants._(); // prevenir instanciación

  /// UUID del servicio BLE que expone el ESP32-S3.
  /// ⚠️ Debe coincidir exactamente con el ESP32 firmware.
  static const String serviceUuid =
      '4fafc201-1fb5-459e-8fcc-c5c9c331914b';

  /// UUID de la característica que contiene el nivel del tacho.
  /// Propiedades requeridas en el ESP32: READ + NOTIFY
  static const String characteristicUuid =
      'beb5483e-36e1-4688-b7f5-ea07361b26a8';

  /// Nombre del dispositivo BLE anunciado por el ESP32.
  /// Usado para filtrar el escaneo y encontrar el dispositivo correcto.
  static const String deviceName = 'ESP32_SmartBin';

  /// Tiempo máximo de escaneo antes de rendirse (segundos).
  static const int scanTimeoutSeconds = 10;

  /// Tiempo de espera para reconexión automática (segundos).
  static const int reconnectDelaySeconds = 3;

  /// Bytes que el ESP32 puede enviar para cada estado:
  static const int byteEmpty = 0x00; // Vacío  (también acepta 'E' = 0x45)
  static const int byteHalf  = 0x01; // Medio  (también acepta 'M' = 0x4D)
  static const int byteFull  = 0x02; // Lleno  (también acepta 'F' = 0x46)

  // Códigos ASCII alternativos
  static const int asciiEmpty = 0x45; // 'E'
  static const int asciiHalf  = 0x4D; // 'M'
  static const int asciiFulll = 0x46; // 'F'
}
