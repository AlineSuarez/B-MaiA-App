import 'package:flutter/foundation.dart';
import '../../services/text_norm.dart';

class ApiarioSlots {
  String? nombre;
  String? region;
  String? comuna;
  int? numColmenas;
  String tipoApiario = 'fijo'; // todos fijos
  // puedes agregar: tipo_manejo, objetivo_produccion, registro_sag…

  Map<String, dynamic> toJsonResolved({
    required int regionId,
    required int comunaId,
  }) => {
    'nombre': nombre,
    'tipo_apiario': tipoApiario,
    'num_colmenas': numColmenas,
    'region_id': regionId,
    'comuna_id': comunaId,
    'activo': true,
  };
}

enum DialogStep {
  saludo,
  askNombre,
  askRegion,
  askComuna,
  askNum,
  confirm,
  done,
}

class ApiarioDialog with ChangeNotifier {
  final ApiarioSlots slots = ApiarioSlots();
  DialogStep step = DialogStep.saludo;

  String promptForStep() {
    switch (step) {
      case DialogStep.saludo:
        return '¿Quieres crear un apiario? Dime el nombre.';
      case DialogStep.askNombre:
        return '¿Cuál será el nombre del apiario?';
      case DialogStep.askRegion:
        return '¿En qué región estará?';
      case DialogStep.askComuna:
        return '¿Y la comuna?';
      case DialogStep.askNum:
        return '¿Cuántas colmenas tendrá? Puedes decir un número aproximado.';
      case DialogStep.confirm:
        return '¿Confirmo la creación? Di “sí” para guardar o “no” para corregir.';
      case DialogStep.done:
        return 'Listo.';
    }
  }

  /// Alimenta el diálogo con lo que dijo el usuario; devuelve texto breve para hablar.
  String feedUserUtterance(String text) {
    final t = norm(text);

    switch (step) {
      case DialogStep.saludo:
        if (t.contains('si') || t.contains('sí') || t.contains('crear')) {
          step = DialogStep.askNombre;
          return promptForStep();
        }
        // Si ya vino todo junto: “crear apiario Las Palmas en región Maule, comuna Talca con 20 colmenas”
        final nameMatch = RegExp(
          r'apiario\s+(llamado\s+)?(.+?)(\s+en\s+region|\s+en\s+región|,|$)',
        ).firstMatch(t);
        if (nameMatch != null) {
          slots.nombre = _title(nameMatch.group(2)!);
          step = DialogStep.askRegion;
          return 'Entendido. Nombre: ${slots.nombre}. ${promptForStep()}';
        }
        return 'Di “crear apiario” para comenzar o dime directamente el nombre.';

      case DialogStep.askNombre:
        slots.nombre = _title(text.trim());
        step = DialogStep.askRegion;
        return 'Nombre: ${slots.nombre}. ${promptForStep()}';

      case DialogStep.askRegion:
        slots.region = _title(text.trim());
        step = DialogStep.askComuna;
        return 'Región: ${slots.region}. ${promptForStep()}';

      case DialogStep.askComuna:
        slots.comuna = _title(text.trim());
        step = DialogStep.askNum;
        return 'Comuna: ${slots.comuna}. ${promptForStep()}';

      case DialogStep.askNum:
        final n = int.tryParse(
          RegExp(r'(\d{1,4})').firstMatch(t)?.group(1) ?? '',
        );
        slots.numColmenas = n ?? 0;
        step = DialogStep.confirm;
        return _confirmString();

      case DialogStep.confirm:
        if (t.contains('si') || t.contains('sí')) {
          step = DialogStep.done;
          return 'Perfecto, guardando.';
        }
        if (t.contains('no')) {
          // vuelve a pedir lo que quieras; aquí devuelvo al nombre
          step = DialogStep.askNombre;
          return 'De acuerdo, dime nuevamente el nombre.';
        }
        return '¿Digo que sí para guardar, o no para corregir?';

      case DialogStep.done:
        return 'Listo.';
    }
  }

  bool isCompleteBasic() =>
      (slots.nombre ?? '').isNotEmpty &&
      (slots.region ?? '').isNotEmpty &&
      (slots.comuna ?? '').isNotEmpty &&
      (slots.numColmenas ?? 0) > 0 &&
      step == DialogStep.done;

  String _title(String s) => s
      .split(' ')
      .map((w) => w.isEmpty ? '' : '${w[0].toUpperCase()}${w.substring(1)}')
      .join(' ');

  String _confirmString() {
    final n = slots.numColmenas == null ? 'sin número' : '${slots.numColmenas}';
    return 'Confirmo: nombre ${slots.nombre}, región ${slots.region}, comuna ${slots.comuna}, $n colmenas. ¿Confirmo?';
  }
}
