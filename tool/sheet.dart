// Planche de contrÃ´le : dessine toutes les poses en SVG dans build/sheet.html.
// dart run tool/sheet.dart
import 'dart:io';

import 'package:chalk/poses/library.dart';
import 'package:chalk/poses/skeleton.dart';

String svgFor(Skel s, Frame fr, {double w = 200}) {
  final h = w * fr.height / fr.width;
  final b = StringBuffer(
      '<svg xmlns="http://www.w3.org/2000/svg" width="$w" height="${h.toStringAsFixed(0)}" viewBox="${fr.left} ${fr.top} ${fr.width} ${fr.height}" style="background:#1D1D1B">');
  String line(V a, V c, String col, double sw) =>
      '<line x1="${a.x}" y1="${a.y}" x2="${c.x}" y2="${c.y}" stroke="$col" stroke-width="$sw" stroke-linecap="round"/>';
  for (final e in s.eq) {
    switch (e.kind) {
      case EqKind.floor:
        b.write(line(V(fr.left, kFloor + 1.5), V(fr.left + fr.width, kFloor + 1.5), '#44443F', 3));
      case EqKind.bar || EqKind.lowbar:
        if (e.kind == EqKind.lowbar) b.write(line(e.a, V(e.a.x, kFloor), '#5C5A54', 2));
        b.write('<circle cx="${e.a.x}" cy="${e.a.y}" r="2.6" fill="#8F8D86"/>');
      case EqKind.hbar:
        b.write(line(e.a, e.b, '#8F8D86', 3));
      case EqKind.rings:
        b.write(line(V(e.a.x, fr.top), V(e.a.x, e.a.y - 3), '#5C5A54', 1.2));
        b.write('<circle cx="${e.a.x}" cy="${e.a.y}" r="3" fill="none" stroke="#8F8D86" stroke-width="1.5"/>');
      case EqKind.pbars:
        b.write(line(e.a, e.b, '#8F8D86', 3));
        b.write(line(V(e.a.x + 3, e.a.y), V(e.a.x + 3, kFloor), '#5C5A54', 2));
        b.write(line(V(e.b.x - 3, e.b.y), V(e.b.x - 3, kFloor), '#5C5A54', 2));
      case EqKind.wall:
        b.write('<rect x="${e.a.x}" y="${fr.top}" width="6" height="${kFloor - fr.top + 3}" fill="#2E2E2B"/>');
      case EqKind.pole:
        b.write(line(V(e.a.x, fr.top), V(e.a.x, kFloor), '#8F8D86', 3.5));
      case EqKind.box:
        b.write('<rect x="${e.a.x}" y="${e.a.y}" width="${e.b.x - e.a.x}" height="${e.b.y - e.a.y}" fill="#2E2E2B" stroke="#44443F"/>');
      case EqKind.parallettes:
        b.write(line(V(e.a.x - 6, e.a.y), V(e.a.x + 6, e.a.y), '#8F8D86', 2.5));
        b.write(line(V(e.a.x - 5, e.a.y), V(e.a.x - 7, kFloor), '#5C5A54', 2));
        b.write(line(V(e.a.x + 5, e.a.y), V(e.a.x + 7, kFloor), '#5C5A54', 2));
      case EqKind.wheel:
        b.write('<circle cx="${e.a.x}" cy="${e.a.y}" r="5.5" fill="none" stroke="#8F8D86" stroke-width="2"/>');
      case EqKind.strap:
        b.write(line(e.a, e.b, '#C9B27A', 1.5));
      case EqKind.pad:
        b.write('<rect x="${e.a.x - 6}" y="${e.a.y}" width="12" height="5" rx="2" fill="#44443F"/>');
    }
  }
  const near = '#C8F03C', far = '#6B7A35';
  b.write(line(s[J.sh], s[J.elF], far, 4.5));
  b.write(line(s[J.elF], s[J.wrF], far, 4.5));
  b.write(line(s[J.hip], s[J.knF], far, 5.5));
  b.write(line(s[J.knF], s[J.anF], far, 5));
  b.write(line(s[J.anF], s[J.toeF], far, 3.5));
  b.write(line(s[J.hip], s[J.sh], near, 8));
  b.write(line(s[J.sh], s[J.head], near, 4));
  b.write('<circle cx="${s[J.head].x}" cy="${s[J.head].y}" r="$lHead" fill="$near"/>');
  if (s.chest != 0) b.write('<circle cx="${s.eye.x}" cy="${s.eye.y}" r="1.1" fill="#121212"/>');
  b.write(line(s[J.hip], s[J.knN], near, 5.5));
  b.write(line(s[J.knN], s[J.anN], near, 5));
  b.write(line(s[J.anN], s[J.toeN], near, 3.5));
  b.write(line(s[J.sh], s[J.elN], near, 4.5));
  b.write(line(s[J.elN], s[J.wrN], near, 4.5));
  for (final e in s.eq) {
    if (e.kind == EqKind.bar || e.kind == EqKind.lowbar) {
      b.write('<circle cx="${e.a.x}" cy="${e.a.y}" r="2.6" fill="#8F8D86" stroke="#121212" stroke-width="0.8"/>');
    } else if (e.kind == EqKind.rings) {
      b.write('<circle cx="${e.a.x}" cy="${e.a.y}" r="3" fill="none" stroke="#8F8D86" stroke-width="1.5"/>');
    }
  }
  b.write('</svg>');
  return b.toString();
}

void main(List<String> args) {
  final filter = args.isEmpty || args.first == 'all' ? null : args.first;
  final w = args.length > 1 ? double.parse(args[1]) : 170.0;
  final sw = Stopwatch()..start();
  final out = StringBuffer('<html><body style="background:#121212;color:#eee;font:12px sans-serif">');
  for (final mv in moves) {
    if (filter != null && !filter.split(',').contains(mv.id)) continue;
    final skels = [for (final p in mv.phases) p.pose.skel];
    final fr = Frame.fit(skels);
    out.write('<div style="display:inline-block;margin:6px;vertical-align:top"><b>${mv.id}</b><br>');
    for (var i = 0; i < skels.length; i++) {
      out.write('<span style="display:inline-block;margin-right:3px">${mv.phases[i].label}<br>${svgFor(skels[i], fr, w: w)}</span>');
    }
    out.write('</div>');
  }
  out.write('</body></html>');
  Directory('build').createSync(recursive: true);
  File('build/sheet.html').writeAsStringSync(out.toString());
  stdout.writeln('ok ${moves.length} mouvements en ${sw.elapsedMilliseconds} ms');
}
