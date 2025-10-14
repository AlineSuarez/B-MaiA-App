class ComunaLite {
  final int id;
  final String name;
  final int regionId;

  ComunaLite({required this.id, required this.name, required this.regionId});

  factory ComunaLite.fromJson(Map<String, dynamic> json) {
    final ridRaw = json['region_id'] ?? json['regionId'];
    return ComunaLite(
      id: json['id'] is String
          ? int.tryParse(json['id']) ?? -1
          : (json['id'] ?? -1) as int,
      name: (json['name'] ?? json['nombre'] ?? '').toString(),
      regionId: ridRaw is String
          ? int.tryParse(ridRaw) ?? -1
          : (ridRaw ?? -1) as int,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'region_id': regionId,
  };
}
