// Moteur de poses en pur Dart (aucune dépendance Flutter) : il sert à l'app,
// au générateur d'icône et à la planche de contrôle (tool/).
//
// Une pose est décrite par des angles « boussole » (0 = haut, 90 = droite,
// 180 = bas, 270 = gauche) et des points de contact (mains sur la barre,
// pieds au sol…). Un petit solveur Levenberg-Marquardt ajuste les angles au
// plus près de la forme demandée pour que les contacts tombent juste.
import 'dart:math' as m;

class V {
  const V(this.x, this.y);
  final double x, y;
  V operator +(V o) => V(x + o.x, y + o.y);
  V operator -(V o) => V(x - o.x, y - o.y);
  V operator *(double k) => V(x * k, y * k);
  double get len => m.sqrt(x * x + y * y);
  static V lerp(V a, V b, double t) => V(a.x + (b.x - a.x) * t, a.y + (b.y - a.y) * t);
}

const _rad = m.pi / 180;
V polar(double deg, [double len = 1]) => V(m.sin(deg * _rad) * len, -m.cos(deg * _rad) * len);

const kFloor = 104.0;
const lTorso = 28.0, lNeck = 9.0, lHead = 6.0;
const lUpper = 15.0, lFore = 14.0, lThigh = 21.0, lShin = 20.0, lFoot = 6.5;

enum J { hip, sh, head, elN, wrN, elF, wrF, knN, anN, knF, anF, toeN, toeF }

enum EqKind { floor, bar, hbar, lowbar, pbars, wall, pole, rings, box, parallettes, wheel, strap, pad }

class Eq {
  const Eq(this.kind, [this.a = const V(0, 0), this.b = const V(0, 0)]);
  final EqKind kind;
  final V a, b;
}

const flo = Eq(EqKind.floor);
Eq bar(double x, double y) => Eq(EqKind.bar, V(x, y));
Eq hbar(double x1, double x2, double y) => Eq(EqKind.hbar, V(x1, y), V(x2, y));
Eq lowbar(double x, double y) => Eq(EqKind.lowbar, V(x, y));
Eq pbars(double x1, double x2, double y) => Eq(EqKind.pbars, V(x1, y), V(x2, y));
Eq wall(double x) => Eq(EqKind.wall, V(x, 0));
Eq pole(double x) => Eq(EqKind.pole, V(x, 0));
Eq rings(double x, double y) => Eq(EqKind.rings, V(x, y));
Eq box(double x1, double x2, double top) => Eq(EqKind.box, V(x1, top), V(x2, kFloor));
Eq paral(double x) => Eq(EqKind.parallettes, V(x, kFloor - 9));
Eq wheel(double x, double y) => Eq(EqKind.wheel, V(x, y));
Eq strap(double x, double y1, double y2) => Eq(EqKind.strap, V(x, y1), V(x, y2));
Eq pad(double x) => Eq(EqKind.pad, V(x, kFloor - 5));

// Indices du vecteur de paramètres complet.
const _hx = 0, _hy = 1, _t = 2, _hd = 3, _aN0 = 4, _aN1 = 5, _aF0 = 6, _aF1 = 7;
const _lN0 = 8, _lN1 = 9, _lF0 = 10, _lF1 = 11, _ftN = 12, _ftF = 13;

class Skel {
  Skel(this.p, this.chest, this.eq) {
    final hip = V(p[_hx], p[_hy]);
    final sh = hip + polar(p[_t], lTorso);
    final head = sh + polar(p[_t] + p[_hd], lNeck);
    final elN = sh + polar(p[_aN0], lUpper), wrN = elN + polar(p[_aN1], lFore);
    final elF = sh + polar(p[_aF0], lUpper), wrF = elF + polar(p[_aF1], lFore);
    final knN = hip + polar(p[_lN0], lThigh), anN = knN + polar(p[_lN1], lShin);
    final knF = hip + polar(p[_lF0], lThigh), anF = knF + polar(p[_lF1], lShin);
    final toeN = anN + polar(p[_lN1] + p[_ftN], lFoot);
    final toeF = anF + polar(p[_lF1] + p[_ftF], lFoot);
    j = {
      J.hip: hip, J.sh: sh, J.head: head, J.elN: elN, J.wrN: wrN, J.elF: elF, J.wrF: wrF,
      J.knN: knN, J.anN: anN, J.knF: knF, J.anF: anF, J.toeN: toeN, J.toeF: toeF,
    };
    eye = head + polar(p[_t] + p[_hd] + 90.0 * chest, 2.6) + polar(p[_t] + p[_hd], 1.2);
  }

  final List<double> p;
  final int chest;
  final List<Eq> eq;
  late final Map<J, V> j;
  late final V eye;

  V operator [](J k) => j[k]!;

  /// Interpolation sur les angles (les membres gardent leur longueur).
  static Skel lerp(Skel a, Skel b, double t) {
    final p = List<double>.generate(a.p.length, (i) {
      if (i <= _hy) return a.p[i] + (b.p[i] - a.p[i]) * t;
      var d = (b.p[i] - a.p[i]) % 360;
      if (d > 180) d -= 360;
      return a.p[i] + d * t;
    });
    return Skel(p, t < 0.5 ? a.chest : b.chest, t < 0.5 ? a.eq : b.eq);
  }

  Iterable<V> get points sync* {
    yield* j.values;
    final h = j[J.head]!;
    yield h + const V(lHead, lHead);
    yield h - const V(lHead, lHead);
  }
}

class Pose {
  Pose({
    double hx = 60,
    double hy = 55,
    double t = 0,
    double hd = 0,
    List<double> a = const [180, 180],
    List<double>? af,
    List<double> l = const [180, 180],
    List<double>? lf,
    double ft = -90,
    double? ftf,
    this.pin = const {},
    this.eq = const [flo],
    this.chest = 1,
  })  : _init = [
          hx, hy, t, hd, a[0], a[1], (af ?? a)[0], (af ?? a)[1],
          l[0], l[1], (lf ?? l)[0], (lf ?? l)[1], ft, ftf ?? ft,
        ],
        _shareArm = af == null,
        _shareLeg = lf == null;

  final List<double> _init;
  final bool _shareArm, _shareLeg;
  final Map<J, V> pin;
  final List<Eq> eq;
  final int chest;

  late final Skel skel = _solve();

  bool get _hasFloor => eq.any((e) => e.kind == EqKind.floor);

  // Indices optimisés : hanche, tronc, bras/jambes proches, puis lointains si libres.
  List<int> get _free => [
        _hx, _hy, _t, _aN0, _aN1, _lN0, _lN1,
        if (!_shareArm) ...[_aF0, _aF1],
        if (!_shareLeg) ...[_lF0, _lF1],
      ];

  List<double> _expand(List<double> q) {
    final p = List<double>.of(q);
    if (_shareArm) {
      p[_aF0] = p[_aN0];
      p[_aF1] = p[_aN1];
    }
    if (_shareLeg) {
      p[_lF0] = p[_lN0];
      p[_lF1] = p[_lN1];
    }
    return p;
  }

  List<double> _residuals(List<double> q) {
    final s = Skel(_expand(q), chest, eq);
    final r = <double>[];
    const wPin = 14.0, wAng = 3.2, wHip = 0.05, wFloor = 14.0;
    pin.forEach((k, v) {
      final d = s[k] - v;
      r..add(wPin * d.x)..add(wPin * d.y);
    });
    for (final i in _free) {
      if (i == _hx || i == _hy) {
        r.add(wHip * (q[i] - _init[i]));
      } else {
        var d = (q[i] - _init[i]) % 360;
        if (d > 180) d -= 360;
        r.add(wAng * d * _rad);
      }
    }
    if (_hasFloor) {
      for (final k in J.values) {
        final y = s[k].y + (k == J.head ? lHead : 0);
        r.add(y > kFloor + 0.5 ? wFloor * (y - kFloor - 0.5) : 0);
      }
    }
    return r;
  }

  Skel _solve() {
    final q = List<double>.of(_init);
    if (pin.isNotEmpty) {
      final s = Skel(_expand(q), chest, eq);
      final e = pin.entries.first;
      final d = e.value - s[e.key];
      q[_hx] += d.x;
      q[_hy] += d.y;
    }
    final free = _free;
    double cost(List<double> r) => r.fold(0.0, (s, x) => s + x * x);
    var r = _residuals(q);
    var c = cost(r);
    var mu = 1e-2;
    for (var it = 0; it < 80 && c > 1e-6; it++) {
      // Jacobien numérique.
      final jac = List.generate(r.length, (_) => List<double>.filled(free.length, 0));
      for (var k = 0; k < free.length; k++) {
        final i = free[k];
        final h = (i == _hx || i == _hy) ? 1e-3 : 1e-3;
        final old = q[i];
        q[i] = old + h;
        final r2 = _residuals(q);
        q[i] = old;
        for (var n = 0; n < r.length; n++) {
          jac[n][k] = (r2[n] - r[n]) / h;
        }
      }
      final n = free.length;
      final a = List.generate(n, (_) => List<double>.filled(n + 1, 0));
      for (var x = 0; x < n; x++) {
        for (var y = 0; y < n; y++) {
          var s = 0.0;
          for (var k = 0; k < r.length; k++) {
            s += jac[k][x] * jac[k][y];
          }
          a[x][y] = s;
        }
        var g = 0.0;
        for (var k = 0; k < r.length; k++) {
          g += jac[k][x] * r[k];
        }
        a[x][n] = -g;
      }
      var improved = false;
      for (var tries = 0; tries < 8 && !improved; tries++) {
        final mat = [for (final row in a) List<double>.of(row)];
        for (var x = 0; x < n; x++) {
          mat[x][x] += mu * (mat[x][x] + 1e-3);
        }
        final delta = _gauss(mat, n);
        if (delta == null) {
          mu *= 4;
          continue;
        }
        final q2 = List<double>.of(q);
        for (var k = 0; k < n; k++) {
          q2[free[k]] += delta[k];
        }
        final r2 = _residuals(q2);
        final c2 = cost(r2);
        if (c2 < c) {
          q.setAll(0, q2);
          r = r2;
          final gain = c - c2;
          c = c2;
          mu = m.max(mu / 3, 1e-7);
          improved = true;
          if (gain < 1e-9) it = 1000;
        } else {
          mu *= 4;
        }
      }
      if (!improved) break;
    }
    return Skel(_expand(q), chest, eq);
  }

  static List<double>? _gauss(List<List<double>> a, int n) {
    for (var c = 0; c < n; c++) {
      var piv = c;
      for (var r = c + 1; r < n; r++) {
        if (a[r][c].abs() > a[piv][c].abs()) piv = r;
      }
      if (a[piv][c].abs() < 1e-12) return null;
      final tmp = a[c];
      a[c] = a[piv];
      a[piv] = tmp;
      for (var r = 0; r < n; r++) {
        if (r == c) continue;
        final f = a[r][c] / a[c][c];
        for (var k = c; k <= n; k++) {
          a[r][k] -= f * a[c][k];
        }
      }
    }
    return [for (var i = 0; i < n; i++) a[i][n] / a[i][i]];
  }
}

Map<J, V> hands(double x, double y) => {J.wrN: V(x, y), J.wrF: V(x, y)};
Map<J, V> feet(double x, double y) => {J.anN: V(x, y), J.anF: V(x, y)};
Map<J, V> toes(double x, double y) => {J.toeN: V(x, y), J.toeF: V(x, y)};

/// Cadre commun (en coordonnées monde) pour toutes les poses d'un mouvement.
class Frame {
  const Frame(this.left, this.top, this.width, this.height);
  final double left, top, width, height;

  factory Frame.fit(List<Skel> skels, {double aspect = 1.25}) {
    var x0 = double.infinity, y0 = double.infinity, x1 = -double.infinity, y1 = -double.infinity;
    void add(V v) {
      x0 = m.min(x0, v.x);
      y0 = m.min(y0, v.y);
      x1 = m.max(x1, v.x);
      y1 = m.max(y1, v.y);
    }

    var hasFloor = false;
    for (final s in skels) {
      s.points.forEach(add);
      for (final e in s.eq) {
        switch (e.kind) {
          case EqKind.floor:
            hasFloor = true;
          case EqKind.bar || EqKind.rings || EqKind.wheel:
            add(e.a - const V(5, 5));
            add(e.a + const V(5, 5));
          case EqKind.box || EqKind.pbars || EqKind.strap || EqKind.hbar:
            add(e.a);
            add(e.b);
          case EqKind.parallettes || EqKind.lowbar || EqKind.pad:
            add(e.a);
            add(V(e.a.x, kFloor));
          case EqKind.wall || EqKind.pole:
            add(V(e.a.x, y0.isFinite ? y0 : 50));
        }
      }
    }
    if (hasFloor) add(V(x0, kFloor + 3));
    var w = x1 - x0, h = y1 - y0;
    final pad = m.max(w, h) * 0.1 + 4;
    w += pad * 2;
    h += pad * 2;
    var cx = (x0 + x1) / 2, cy = (y0 + y1) / 2;
    if (w / h > aspect) {
      h = w / aspect;
    } else {
      w = h * aspect;
    }
    if (hasFloor) {
      // Le sol reste près du bas du cadre.
      final bottom = kFloor + 6;
      cy = bottom - h / 2;
      if (cy - h / 2 > y0 - 2) cy = y0 - 2 + h / 2;
    }
    return Frame(cx - w / 2, cy - h / 2, w, h);
  }
}
