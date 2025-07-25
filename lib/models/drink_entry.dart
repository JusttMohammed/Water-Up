class DrinkEntry {
  final String id;
  final int volumeMl;
  final String drinkType;
  final double effectiveVolumeMl;
  final DateTime timestamp;
  final String? deviceId;
  final Map<String, dynamic> metadata;

  DrinkEntry({
    required this.id,
    required this.volumeMl,
    required this.drinkType,
    required this.effectiveVolumeMl,
    required this.timestamp,
    this.deviceId,
    this.metadata = const {},
  });

  factory DrinkEntry.fromJson(Map<String, dynamic> json) {
    return DrinkEntry(
      id: json['id'] ?? '',
      volumeMl: json['volume_ml'] ?? 0,
      drinkType: json['drink_type'] ?? 'water',
      effectiveVolumeMl: (json['effective_volume_ml'] ?? 0).toDouble(),
      timestamp: DateTime.parse(json['timestamp']),
      deviceId: json['device_id'],
      metadata: json['metadata'] ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'volume_ml': volumeMl,
      'drink_type': drinkType,
      'effective_volume_ml': effectiveVolumeMl,
      'timestamp': timestamp.toIso8601String(),
      'device_id': deviceId,
      'metadata': metadata,
    };
  }

  DrinkEntry copyWith({
    String? id,
    int? volumeMl,
    String? drinkType,
    double? effectiveVolumeMl,
    DateTime? timestamp,
    String? deviceId,
    Map<String, dynamic>? metadata,
  }) {
    return DrinkEntry(
      id: id ?? this.id,
      volumeMl: volumeMl ?? this.volumeMl,
      drinkType: drinkType ?? this.drinkType,
      effectiveVolumeMl: effectiveVolumeMl ?? this.effectiveVolumeMl,
      timestamp: timestamp ?? this.timestamp,
      deviceId: deviceId ?? this.deviceId,
      metadata: metadata ?? this.metadata,
    );
  }
} 