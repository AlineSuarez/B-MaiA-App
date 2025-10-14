class RegionLite {
  final int id;
  final String name;

  RegionLite({required this.id, required this.name});

  factory RegionLite.fromJson(Map<String, dynamic> json) {
    return RegionLite(
      id: json['id'] is String
          ? int.tryParse(json['id']) ?? -1
          : (json['id'] ?? -1) as int,
      name: (json['name'] ?? json['nombre'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name};
}
