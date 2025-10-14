String stripAccents(String input) {
  const withA = 'áéíóúÁÉÍÓÚñÑüÜ', noA = 'aeiouAEIOUnNuU';
  var out = input;
  for (var i = 0; i < withA.length; i++) {
    out = out.replaceAll(withA[i], noA[i]);
  }
  return out;
}

String norm(String s) => stripAccents(s.trim().toLowerCase());
