import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/models.dart';

class ReciclaProvider extends ChangeNotifier {
  List<WasteItem> _history = [];
  int _totalPoints = 0;
  int _streakDays = 0;
  String _userName = 'Reciclador';
  int _selectedTabIndex = 0;

  List<WasteItem> get history => _history;
  int get totalPoints => _totalPoints;
  int get streakDays => _streakDays;
  String get userName => _userName;
  int get selectedTabIndex => _selectedTabIndex;

  double get totalWeightKg =>
      _history.fold(0.0, (sum, item) => sum + item.weight);

  int get totalItems => _history.length;

  String get userLevel {
    if (_totalPoints < 100) return 'Principiante';
    if (_totalPoints < 300) return 'Aprendiz Verde';
    if (_totalPoints < 600) return 'Reciclador';
    if (_totalPoints < 1000) return 'Eco Guardián';
    return 'Maestro Verde';
  }

  String get userLevelIcon {
    if (_totalPoints < 100) return '🌱';
    if (_totalPoints < 300) return '🌿';
    if (_totalPoints < 600) return '♻️';
    if (_totalPoints < 1000) return '🌳';
    return '🏆';
  }

  int get levelProgress {
    if (_totalPoints < 100) return ((_totalPoints / 100) * 100).round();
    if (_totalPoints < 300) return (((_totalPoints - 100) / 200) * 100).round();
    if (_totalPoints < 600) return (((_totalPoints - 300) / 300) * 100).round();
    if (_totalPoints < 1000) return (((_totalPoints - 600) / 400) * 100).round();
    return 100;
  }

  int get nextLevelPoints {
    if (_totalPoints < 100) return 100;
    if (_totalPoints < 300) return 300;
    if (_totalPoints < 600) return 600;
    if (_totalPoints < 1000) return 1000;
    return 1000;
  }

  Map<WasteType, double> get weightByType {
    final map = <WasteType, double>{};
    for (final item in _history) {
      map[item.type] = (map[item.type] ?? 0) + item.weight;
    }
    return map;
  }

  Map<WasteType, int> get countByType {
    final map = <WasteType, int>{};
    for (final item in _history) {
      map[item.type] = (map[item.type] ?? 0) + 1;
    }
    return map;
  }

  List<WasteItem> get recentHistory => _history.take(10).toList();

  void setSelectedTab(int index) {
    _selectedTabIndex = index;
    notifyListeners();
  }

  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();
    _totalPoints = prefs.getInt('totalPoints') ?? 0;
    _streakDays = prefs.getInt('streakDays') ?? 0;
    _userName = prefs.getString('userName') ?? 'Reciclador';

    final historyJson = prefs.getStringList('history') ?? [];
    _history = historyJson
        .map((e) => WasteItem.fromMap(json.decode(e)))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    notifyListeners();
  }

  Future<void> addWasteItem(WasteItem item) async {
    _history.insert(0, item);
    _totalPoints += item.pointsEarned;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('totalPoints', _totalPoints);
    final historyJson = _history.map((e) => json.encode(e.toMap())).toList();
    await prefs.setStringList('history', historyJson);

    notifyListeners();
  }

  Future<void> setUserName(String name) async {
    _userName = name;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userName', name);
    notifyListeners();
  }

  Future<void> clearHistory() async {
    _history.clear();
    _totalPoints = 0;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('history');
    await prefs.setInt('totalPoints', 0);
    notifyListeners();
  }

  // Demo data para mostrar en primera carga
  Future<void> loadDemoData() async {
    final prefs = await SharedPreferences.getInstance();
    final hasData = prefs.getBool('hasLoadedDemo') ?? false;
    if (hasData) return;

    final demoItems = [
      WasteItem(
        id: '1',
        name: 'Botella PET',
        type: WasteType.recyclable,
        category: WasteCategory.plastic,
        description: 'Botella de plástico PET',
        howToRecycle: 'Lavar y depositar en contenedor amarillo',
        icon: '🍶',
        weight: 0.05,
        date: DateTime.now().subtract(const Duration(days: 1)),
        pointsEarned: 10,
      ),
      WasteItem(
        id: '2',
        name: 'Cáscara de naranja',
        type: WasteType.compostable,
        category: WasteCategory.organic,
        description: 'Residuo orgánico compostable',
        howToRecycle: 'Depositar en compostador',
        icon: '🍊',
        weight: 0.1,
        date: DateTime.now().subtract(const Duration(days: 2)),
        pointsEarned: 8,
      ),
      WasteItem(
        id: '3',
        name: 'Cartón',
        type: WasteType.recyclable,
        category: WasteCategory.paper,
        description: 'Caja de cartón',
        howToRecycle: 'Aplanar y llevar al punto azul',
        icon: '📦',
        weight: 0.3,
        date: DateTime.now().subtract(const Duration(days: 3)),
        pointsEarned: 15,
      ),
      WasteItem(
        id: '4',
        name: 'Lata aluminio',
        type: WasteType.recyclable,
        category: WasteCategory.metal,
        description: 'Lata de bebida',
        howToRecycle: 'Aplastar y depositar en punto amarillo',
        icon: '🥫',
        weight: 0.015,
        date: DateTime.now().subtract(const Duration(days: 4)),
        pointsEarned: 12,
      ),
      WasteItem(
        id: '5',
        name: 'Restos de comida',
        type: WasteType.compostable,
        category: WasteCategory.organic,
        description: 'Residuos de cocina',
        howToRecycle: 'Separar y compostar',
        icon: '🥗',
        weight: 0.4,
        date: DateTime.now().subtract(const Duration(days: 5)),
        pointsEarned: 20,
      ),
    ];

    for (final item in demoItems) {
      _history.add(item);
      _totalPoints += item.pointsEarned;
    }
    _streakDays = 5;

    final historyJson = _history.map((e) => json.encode(e.toMap())).toList();
    await prefs.setStringList('history', historyJson);
    await prefs.setInt('totalPoints', _totalPoints);
    await prefs.setInt('streakDays', _streakDays);
    await prefs.setBool('hasLoadedDemo', true);

    notifyListeners();
  }
}
