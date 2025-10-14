import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class JsonStore {
  final String fileName;
  JsonStore(this.fileName);

  Future<File> _file() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$fileName');
  }

  Future<Map<String, dynamic>> read() async {
    try {
      final f = await _file();
      if (!await f.exists()) return {};
      final txt = await f.readAsString();
      return txt.isEmpty ? {} : jsonDecode(txt) as Map<String, dynamic>;
    } catch (_) {
      return {};
    }
  }

  Future<void> write(Map<String, dynamic> data) async {
    final f = await _file();
    await f.writeAsString(jsonEncode(data));
  }
}
