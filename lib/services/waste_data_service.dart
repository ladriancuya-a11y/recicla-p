import '../models/models.dart';

class WasteDataService {
  static List<WasteCatalogItem> get catalog => [
    WasteCatalogItem(
      id: 'plastic_pet',
      name: 'Plástico PET',
      type: WasteType.recyclable,
      category: WasteCategory.plastic,
      description: 'Botellas de bebidas, envases de aceite, bandejas de alimentos.',
      howToProcess: 'Lavar el envase, retirar tapas y etiquetas, aplastar para reducir volumen y depositar en el contenedor amarillo o punto de reciclaje.',
      tips: 'Busca el símbolo ♻️ con el número 1 en la base del envase.',
      icon: '🍶',
      pointsPerKg: 20,
      examples: ['Botella de agua', 'Botella de gaseosa', 'Envase de aceite'],
    ),
    WasteCatalogItem(
      id: 'cardboard',
      name: 'Cartón y Papel',
      type: WasteType.recyclable,
      category: WasteCategory.paper,
      description: 'Cajas de cartón, periódicos, revistas, papel de oficina.',
      howToProcess: 'Aplanar las cajas, retirar grapas metálicas y cinta adhesiva. Mantener seco. Llevar al punto azul de reciclaje.',
      tips: 'El papel mojado no se puede reciclar. Mantén los materiales secos.',
      icon: '📦',
      pointsPerKg: 15,
      examples: ['Caja de cartón', 'Periódico', 'Cuaderno usado', 'Revista'],
    ),
    WasteCatalogItem(
      id: 'glass',
      name: 'Vidrio',
      type: WasteType.recyclable,
      category: WasteCategory.glass,
      description: 'Botellas de vidrio, frascos, tarros de conservas.',
      howToProcess: 'Lavar el envase, retirar tapas metálicas. Depositar en el contenedor verde o iglú de vidrio.',
      tips: 'El vidrio se puede reciclar infinitas veces sin perder calidad.',
      icon: '🍾',
      pointsPerKg: 10,
      examples: ['Botella de vino', 'Frasco de mermelada', 'Tarro de salsa'],
    ),
    WasteCatalogItem(
      id: 'metal',
      name: 'Metal y Aluminio',
      type: WasteType.recyclable,
      category: WasteCategory.metal,
      description: 'Latas de bebidas, latas de conservas, papel aluminio.',
      howToProcess: 'Lavar y aplastar las latas para reducir volumen. Llevar al punto amarillo.',
      tips: 'Reciclar aluminio ahorra el 95% de energía respecto a producirlo nuevo.',
      icon: '🥫',
      pointsPerKg: 25,
      examples: ['Lata de refresco', 'Lata de atún', 'Papel aluminio'],
    ),
    WasteCatalogItem(
      id: 'organic_food',
      name: 'Restos de Comida',
      type: WasteType.compostable,
      category: WasteCategory.organic,
      description: 'Cáscaras de frutas y verduras, restos de comida cocida, posos de café.',
      howToProcess: 'Separar en recipiente específico. Evitar carnes y lácteos en compost doméstico. Llevar al punto de compostaje o usar compostador casero.',
      tips: 'El compost resultante es un abono natural excelente para plantas.',
      icon: '🥗',
      pointsPerKg: 8,
      examples: ['Cáscaras de fruta', 'Posos de café', 'Restos de verdura'],
    ),
    WasteCatalogItem(
      id: 'garden_waste',
      name: 'Residuos de Jardín',
      type: WasteType.compostable,
      category: WasteCategory.organic,
      description: 'Hojas secas, ramas pequeñas, césped cortado, flores marchitas.',
      howToProcess: 'Triturar ramas grandes. Mezclar partes verdes (nitrógeno) con partes marrones (carbono) en el compostador.',
      tips: 'La mezcla ideal es 1 parte verde por 3 partes marrón.',
      icon: '🌿',
      pointsPerKg: 5,
      examples: ['Hojas secas', 'Césped', 'Flores marchitas', 'Ramas'],
    ),
    WasteCatalogItem(
      id: 'electronic',
      name: 'Residuos Electrónicos',
      type: WasteType.waste,
      category: WasteCategory.electronic,
      description: 'Móviles viejos, cables, pilas, baterías, electrodomésticos.',
      howToProcess: 'Llevar a puntos limpios o tiendas especializadas. Nunca tirar en basura normal. Buscar programas de recogida del fabricante.',
      tips: 'Los e-waste contienen metales preciosos recuperables y sustancias tóxicas.',
      icon: '📱',
      pointsPerKg: 30,
      examples: ['Móvil viejo', 'Pilas', 'Cables', 'Tableta'],
    ),
    WasteCatalogItem(
      id: 'hazardous',
      name: 'Residuos Peligrosos',
      type: WasteType.waste,
      category: WasteCategory.hazardous,
      description: 'Medicamentos caducados, pinturas, aceites de cocina usados, productos químicos.',
      howToProcess: 'Llevar al punto limpio más cercano. Nunca mezclar con basura normal ni verter por el desagüe.',
      tips: 'Los medicamentos caducados al punto SIGRE en farmacias.',
      icon: '⚠️',
      pointsPerKg: 35,
      examples: ['Medicamentos', 'Aceite usado', 'Pintura', 'Pilas'],
    ),
    WasteCatalogItem(
      id: 'general_waste',
      name: 'Resto / Desecho',
      type: WasteType.waste,
      category: WasteCategory.general,
      description: 'Residuos no reciclables ni compostables: servilletas usadas, colillas, pañales.',
      howToProcess: 'Depositar en el contenedor gris o de resto. Intentar reducir su generación comprando productos con menos embalaje.',
      tips: 'Antes de tirar algo al resto, pregúntate: ¿puede reciclarse? ¿puede reutilizarse?',
      icon: '🗑️',
      pointsPerKg: 2,
      examples: ['Servilletas usadas', 'Pañales', 'Colillas', 'Chicle'],
    ),
  ];

  static List<RecyclingCenter> get nearbycenters => [
    RecyclingCenter(
      id: '1',
      name: 'Centro Verde Bogotá Norte',
      address: 'Cra 7 #120-30, Bogotá',
      lat: 4.7110,
      lng: -74.0721,
      acceptedMaterials: ['Plástico', 'Cartón', 'Vidrio', 'Metal'],
      phone: '+57 1 234-5678',
      schedule: 'Lun-Vie 8am-5pm',
      rating: 4.5,
      distanceKm: 0.8,
    ),
    RecyclingCenter(
      id: '2',
      name: 'EcoRec Chapinero',
      address: 'Calle 60 #10-20, Bogotá',
      lat: 4.6486,
      lng: -74.0621,
      acceptedMaterials: ['Electrónicos', 'Pilas', 'Metal'],
      phone: '+57 1 345-6789',
      schedule: 'Lun-Sab 9am-6pm',
      rating: 4.2,
      distanceKm: 1.4,
    ),
    RecyclingCenter(
      id: '3',
      name: 'Punto Limpio La Candelaria',
      address: 'Calle 10 #4-50, Bogotá',
      lat: 4.5981,
      lng: -74.0761,
      acceptedMaterials: ['Plástico', 'Papel', 'Vidrio', 'Orgánico'],
      phone: '+57 1 456-7890',
      schedule: 'Mar-Dom 7am-4pm',
      rating: 4.8,
      distanceKm: 2.1,
    ),
    RecyclingCenter(
      id: '4',
      name: 'ReciclaPlus Usaquén',
      address: 'Cra 11 #93-10, Bogotá',
      lat: 4.6763,
      lng: -74.0487,
      acceptedMaterials: ['Todo tipo de reciclables'],
      phone: '+57 1 567-8901',
      schedule: 'Lun-Dom 8am-7pm',
      rating: 4.6,
      distanceKm: 3.2,
    ),
    RecyclingCenter(
      id: '5',
      name: 'EcoSoluciones Suba',
      address: 'Av. Suba #115-20, Bogotá',
      lat: 4.7420,
      lng: -74.0834,
      acceptedMaterials: ['Cartón', 'Papel', 'Plástico'],
      phone: '+57 1 678-9012',
      schedule: 'Lun-Vie 9am-5pm',
      rating: 4.1,
      distanceKm: 4.5,
    ),
  ];

  static int calculatePoints(WasteType type, double weightKg) {
    switch (type) {
      case WasteType.recyclable:
        return (weightKg * 20).round() + 5;
      case WasteType.compostable:
        return (weightKg * 10).round() + 3;
      case WasteType.waste:
        return 1;
    }
  }

  static WasteCatalogItem? findByName(String name) {
    final lower = name.toLowerCase();
    return catalog.firstWhere(
      (item) =>
          item.name.toLowerCase().contains(lower) ||
          item.examples.any((e) => e.toLowerCase().contains(lower)),
      orElse: () => catalog.last,
    );
  }

  static List<WasteCatalogItem> getByType(WasteType type) {
    return catalog.where((item) => item.type == type).toList();
  }
}
