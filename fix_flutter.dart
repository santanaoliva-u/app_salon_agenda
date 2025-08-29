import 'dart:io';

void main() {
  final dir = Directory('lib');

  final dartFiles = dir
      .listSync(recursive: true)
      .where((f) => f is File && f.path.endsWith('.dart'))
      .map((f) => f as File);

  for (final file in dartFiles) {
    String content = file.readAsStringSync();

    // 1️⃣ Eliminar todas las líneas con print()
    content = content.replaceAll(
        RegExp(r'^\s*print\(.*\);\s*$', multiLine: true), '');

    // 2️⃣ Reemplazar withOpacity(x) por withAlpha((x*255).toInt())
    content = content.replaceAllMapped(
        RegExp(r'(\w+)\.withOpacity\(([\d.]+)\)'),
        (m) => '${m[1]}.withAlpha((${m[2]}*255).toInt())');

    file.writeAsStringSync(content);
  }
}
