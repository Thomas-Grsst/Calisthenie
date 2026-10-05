// Régénère lib/poses/photos.dart à partir de assets/photos/ et tool/photo_credits.json.
// dart run tool/gen_photos.dart
import 'dart:convert';
import 'dart:io';

void main() {
  final sets = <String, Set<int>>{};
  for (final f in Directory('assets/photos').listSync().whereType<File>()) {
    final name = f.uri.pathSegments.last;
    final m = RegExp(r'^(.+)_(\d)\.jpg$').firstMatch(name);
    if (m == null) continue;
    sets.putIfAbsent(m[1]!, () => {}).add(int.parse(m[2]!));
  }

  final credits = <String, String>{};
  final cf = File('tool/photo_credits.json');
  if (cf.existsSync()) {
    var raw = cf.readAsStringSync();
    if (raw.startsWith('﻿')) raw = raw.substring(1);
    for (final c in (jsonDecode(raw) as List).cast<Map<String, dynamic>>()) {
      credits[c['key'] as String] = '${c['author']} · ${c['license']} · Wikimedia Commons';
    }
  }

  final ids = sets.keys.toList()..sort();
  final keys = credits.keys.toList()..sort();
  String q(String s) => "'${s.replaceAll("'", '’')}'";
  final b = StringBuffer()
    ..writeln('// Généré par tool/gen_photos.dart : positions disponibles (0 = départ, 1 = fin) et crédits.')
    ..writeln('const photoSets = <String, List<int>>{');
  for (final id in ids) {
    b.writeln("  '$id': [${(sets[id]!.toList()..sort()).join(', ')}],");
  }
  b
    ..writeln('};')
    ..writeln()
    ..writeln('/// Mouvements qui réutilisent les photos d’un autre.')
    ..writeln("const photoAlias = {'strictmu': 'muscleup', 'barmu': 'muscleup', 'freehs': 'handstand'};")
    ..writeln()
    ..writeln("const _freeDb = 'free-exercise-db · domaine public';")
    ..writeln()
    ..writeln('const photoCredits = <String, String>{');
  for (final k in keys) {
    b.writeln('  ${q(k)}: ${q(credits[k]!)},');
  }
  b
    ..writeln('};')
    ..writeln()
    ..writeln('String creditOf(String key) => photoCredits[key] ?? _freeDb;');
  File('lib/poses/photos.dart').writeAsStringSync(b.toString());
  stdout.writeln('${ids.length} mouvements avec photo, ${keys.length} crédits');
}
