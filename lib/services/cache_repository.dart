import '../models/region_lite.dart';
import '../models/comuna_lite.dart';
import 'json_store.dart';

class CacheRepository {
  final _regions = JsonStore('regions.json');
  final _comunas = JsonStore('comunas.json');

  Future<void> saveRegions(List<RegionLite> list) async {
    await _regions.write({'items': list.map((e) => e.toJson()).toList()});
  }

  Future<void> saveComunas(List<ComunaLite> list) async {
    await _comunas.write({'items': list.map((e) => e.toJson()).toList()});
  }

  Future<List<RegionLite>> loadRegions() async {
    final m = await _regions.read();
    final raw = (m['items'] as List?) ?? const [];
    return raw
        .map((e) => RegionLite.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<List<ComunaLite>> loadComunas() async {
    final m = await _comunas.read();
    final raw = (m['items'] as List?) ?? const [];
    return raw
        .map((e) => ComunaLite.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }
}
