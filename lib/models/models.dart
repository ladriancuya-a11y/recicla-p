enum WasteType { recyclable, compostable, waste }
enum WasteCategory {
  paper,
  plastic,
  glass,
  metal,
  organic,
  electronic,
  hazardous,
  general,
}

class WasteItem {
  final String id;
  final String name;
  final WasteType type;
  final WasteCategory category;
  final String description;
  final String howToRecycle;
  final String icon;
  final double weight;
  final DateTime date;
  final int pointsEarned;

  WasteItem({
    required this.id,
    required this.name,
    required this.type,
    required this.category,
    required this.description,
    required this.howToRecycle,
    required this.icon,
    required this.weight,
    required this.date,
    required this.pointsEarned,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type.index,
      'category': category.index,
      'description': description,
      'howToRecycle': howToRecycle,
      'icon': icon,
      'weight': weight,
      'date': date.toIso8601String(),
      'pointsEarned': pointsEarned,
    };
  }

  factory WasteItem.fromMap(Map<String, dynamic> map) {
    return WasteItem(
      id: map['id'],
      name: map['name'],
      type: WasteType.values[map['type']],
      category: WasteCategory.values[map['category']],
      description: map['description'],
      howToRecycle: map['howToRecycle'],
      icon: map['icon'],
      weight: map['weight'],
      date: DateTime.parse(map['date']),
      pointsEarned: map['pointsEarned'],
    );
  }
}

class RecyclingCenter {
  final String id;
  final String name;
  final String address;
  final double lat;
  final double lng;
  final List<String> acceptedMaterials;
  final String phone;
  final String schedule;
  final double rating;
  final double distanceKm;

  RecyclingCenter({
    required this.id,
    required this.name,
    required this.address,
    required this.lat,
    required this.lng,
    required this.acceptedMaterials,
    required this.phone,
    required this.schedule,
    required this.rating,
    required this.distanceKm,
  });
}

class UserStats {
  final int totalPoints;
  final double totalWeightKg;
  final int totalItems;
  final int streakDays;
  final String level;
  final int levelProgress;
  final Map<WasteType, double> weightByType;

  UserStats({
    required this.totalPoints,
    required this.totalWeightKg,
    required this.totalItems,
    required this.streakDays,
    required this.level,
    required this.levelProgress,
    required this.weightByType,
  });
}

class WasteCatalogItem {
  final String id;
  final String name;
  final WasteType type;
  final WasteCategory category;
  final String description;
  final String howToProcess;
  final String tips;
  final String icon;
  final int pointsPerKg;
  final List<String> examples;

  WasteCatalogItem({
    required this.id,
    required this.name,
    required this.type,
    required this.category,
    required this.description,
    required this.howToProcess,
    required this.tips,
    required this.icon,
    required this.pointsPerKg,
    required this.examples,
  });
}
