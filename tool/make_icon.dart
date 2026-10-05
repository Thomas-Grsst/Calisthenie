// Génère l'icône de l'app à partir du moteur de poses (human flag sur poteau).
// dart run tool/make_icon.dart  puis  dart run flutter_launcher_icons
import 'dart:io';
import 'dart:math' as m;

import 'package:chalk/poses/library.dart';
import 'package:chalk/poses/skeleton.dart';
import 'package:image/image.dart' as img;

class _Shape {
  _Shape(this.a, this.b, this.r, this.color);
  final V a, b;
  final double r;
  final int color; // 0xRRGGBB
}

double _segDist(double px, double py, V a, V b) {
  final dx = b.x - a.x, dy = b.y - a.y;
  final l2 = dx * dx + dy * dy;
  var t = l2 == 0 ? 0.0 : ((px - a.x) * dx + (py - a.y) * dy) / l2;
  t = t.clamp(0.0, 1.0);
  final cx = a.x + t * dx - px, cy = a.y + t * dy - py;
  return m.sqrt(cx * cx + cy * cy);
}

img.Image _render(int size, {required bool withBackground, required double content}) {
  final s = moveById['humanflag']!.phases.last.pose.skel;
  const lime = 0xC8F03C, limeFar = 0x6E8424, pole = 0x8F8D86, dark = 0x121212;

  // Cadre monde → pixels, centré.
  final pts = [...s.points, const V(36, 22), const V(36, 86)];
  final x0 = pts.map((p) => p.x).reduce(m.min), x1 = pts.map((p) => p.x).reduce(m.max);
  final y0 = pts.map((p) => p.y).reduce(m.min), y1 = pts.map((p) => p.y).reduce(m.max);
  final k = size * content / m.max(x1 - x0, y1 - y0);
  final ox = size / 2 - (x0 + x1) / 2 * k, oy = size / 2 - (y0 + y1) / 2 * k;
  V tr(V v) => V(v.x * k + ox, v.y * k + oy);

  final shapes = <_Shape>[
    _Shape(tr(const V(36, 18)), tr(const V(36, 90)), 2.2 * k, pole),
    _Shape(tr(s[J.sh]), tr(s[J.elF]), 2.6 * k, limeFar),
    _Shape(tr(s[J.elF]), tr(s[J.wrF]), 2.6 * k, limeFar),
    _Shape(tr(s[J.hip]), tr(s[J.knF]), 3 * k, limeFar),
    _Shape(tr(s[J.knF]), tr(s[J.anF]), 2.8 * k, limeFar),
    _Shape(tr(s[J.hip]), tr(s[J.sh]), 4.6 * k, lime),
    _Shape(tr(s[J.sh]), tr(s[J.head]), 2.2 * k, lime),
    _Shape(tr(s[J.head]), tr(s[J.head]), lHead * 1.05 * k, lime),
    _Shape(tr(s[J.hip]), tr(s[J.knN]), 3.6 * k, lime),
    _Shape(tr(s[J.knN]), tr(s[J.anN]), 3.3 * k, lime),
    _Shape(tr(s[J.anN]), tr(s[J.toeN]), 2.6 * k, lime),
    _Shape(tr(s[J.sh]), tr(s[J.elN]), 2.6 * k, lime),
    _Shape(tr(s[J.elN]), tr(s[J.wrN]), 2.6 * k, lime),
  ];

  final im = img.Image(width: size, height: size, numChannels: 4);
  final radius = size * 0.22;
  for (var y = 0; y < size; y++) {
    for (var x = 0; x < size; x++) {
      final px = x + 0.5, py = y + 0.5;
      var r = 0.0, g = 0.0, b = 0.0, a = 0.0;
      void over(int c, double cov) {
        if (cov <= 0) return;
        final cr = ((c >> 16) & 255) / 255, cg = ((c >> 8) & 255) / 255, cb = (c & 255) / 255;
        r = cr * cov + r * (1 - cov);
        g = cg * cov + g * (1 - cov);
        b = cb * cov + b * (1 - cov);
        a = cov + a * (1 - cov);
      }

      if (withBackground) {
        // Carré arrondi.
        final qx = m.max((px - size / 2).abs() - (size / 2 - radius), 0.0);
        final qy = m.max((py - size / 2).abs() - (size / 2 - radius), 0.0);
        final d = m.sqrt(qx * qx + qy * qy) - radius;
        over(dark, (0.5 - d).clamp(0.0, 1.0));
      }
      for (final sh in shapes) {
        final d = _segDist(px, py, sh.a, sh.b) - sh.r;
        over(sh.color, (0.5 - d).clamp(0.0, 1.0));
      }
      if (a > 0) {
        im.setPixelRgba(x, y, (r / a * 255).round(), (g / a * 255).round(), (b / a * 255).round(), (a * 255).round());
      } else {
        im.setPixelRgba(x, y, 0, 0, 0, 0);
      }
    }
  }
  return im;
}

void main() {
  Directory('assets/icon').createSync(recursive: true);
  File('assets/icon/icon.png').writeAsBytesSync(img.encodePng(_render(1024, withBackground: true, content: 0.74)));
  File('assets/icon/foreground.png')
      .writeAsBytesSync(img.encodePng(_render(1024, withBackground: false, content: 0.56)));
  stdout.writeln('icônes écrites dans assets/icon/');
}
