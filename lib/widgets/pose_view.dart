import 'dart:math' as m;

import 'package:flutter/material.dart';

import '../poses/library.dart';
import '../poses/photos.dart';
import '../poses/skeleton.dart';
import '../theme.dart';

final Map<String, Frame> _frames = {};

Frame frameOf(Move m) =>
    _frames.putIfAbsent(m.id, () => Frame.fit([for (final p in m.phases) p.pose.skel]));

class PosePainter extends CustomPainter {
  PosePainter(this.skel, this.frame, this.color);
  final Skel skel;
  final Frame frame;
  final Color color;

  static const _skin = Color(0xFFD9A47E);
  static const _hair = Color(0xFF2E2118);
  static const _shorts = Color(0xFF2A2A2E);
  static const _shoe = Color(0xFFEDEBE4);
  static const _metal = Color(0xFFA9A8A2);

  Offset _o(V v) => Offset(v.x, v.y);

  /// Segment effilé façon membre, avec une bande d'ombre et une bande de lumière.
  void _limb(Canvas canvas, V a, V b, double ra, double rb, Color c) {
    final d = b - a;
    final l = d.len;
    final fill = Paint()..color = c;
    if (l < 1e-6) {
      canvas.drawCircle(_o(a), ra, fill);
      return;
    }
    final n = V(-d.y / l, d.x / l);
    Path band(double o1, double o2) {
      return Path()
        ..moveTo((a + n * (ra * o1)).x, (a + n * (ra * o1)).y)
        ..lineTo((b + n * (rb * o1)).x, (b + n * (rb * o1)).y)
        ..lineTo((b + n * (rb * o2)).x, (b + n * (rb * o2)).y)
        ..lineTo((a + n * (ra * o2)).x, (a + n * (ra * o2)).y)
        ..close();
    }

    final body = Path()
      ..addPath(band(-1, 1), Offset.zero)
      ..addOval(Rect.fromCircle(center: _o(a), radius: ra))
      ..addOval(Rect.fromCircle(center: _o(b), radius: rb));
    canvas.drawPath(body, fill);
    // La lumière vient du haut : la bande basse est dans l'ombre.
    final down = n.y >= 0 ? 1.0 : -1.0;
    canvas.save();
    canvas.clipPath(body);
    canvas.drawPath(band(0.25 * down, 1.1 * down), Paint()..color = const Color(0x38000000));
    canvas.drawPath(band(-0.2 * down, -0.7 * down), Paint()..color = const Color(0x1FFFFFFF));
    canvas.restore();
  }

  Color _dim(Color c, double k) => Color.lerp(c, const Color(0xFF000000), k)!;

  @override
  void paint(Canvas canvas, Size size) {
    final k = size.width / frame.width;
    final s = skel;
    final top = frame.top, right = frame.left + frame.width, bottom = frame.top + frame.height;
    canvas.save();
    canvas.clipRect(Offset.zero & size);

    // Fond : léger dégradé, comme une salle ou un parc de nuit.
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF31312D), Color(0xFF1F1F1D)],
        ).createShader(Offset.zero & size),
    );
    canvas.scale(k);
    canvas.translate(-frame.left, -frame.top);

    Paint stroke(Color c, double w) => Paint()
      ..color = c
      ..strokeWidth = w
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    void line(V a, V b, Paint p) => canvas.drawLine(_o(a), _o(b), p);

    const dim = Color(0xFF55534E), block = Color(0xFF34342F);

    // Décor derrière le corps.
    for (final e in s.eq) {
      switch (e.kind) {
        case EqKind.floor:
          canvas.drawRect(
            Rect.fromLTRB(frame.left, kFloor + 1, right, bottom + 2),
            Paint()
              ..shader = const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF3D3D38), Color(0xFF262624)],
              ).createShader(Rect.fromLTRB(frame.left, kFloor, right, bottom + 2)),
          );
          line(V(frame.left, kFloor + 1), V(right, kFloor + 1), stroke(const Color(0xFF55554F), 0.8));
        case EqKind.lowbar:
          line(e.a, V(e.a.x, kFloor), stroke(dim, 2.2));
        case EqKind.hbar:
          line(e.a, e.b, stroke(_metal, 3));
          line(e.a, e.b, stroke(const Color(0x40FFFFFF), 0.9));
        case EqKind.bar:
          // Montant du rack, vu de profil, qui monte de la barre.
          line(V(e.a.x, top), e.a, stroke(dim, 2.6));
        case EqKind.rings:
          line(V(e.a.x, top), V(e.a.x, e.a.y - 3), stroke(dim, 1.2));
        case EqKind.pbars:
          line(V(e.a.x + 3, e.a.y), V(e.a.x + 3, kFloor), stroke(dim, 2.2));
          line(V(e.b.x - 3, e.b.y), V(e.b.x - 3, kFloor), stroke(dim, 2.2));
          line(e.a, e.b, stroke(_metal, 3.2));
          line(e.a, e.b, stroke(const Color(0x40FFFFFF), 0.9));
        case EqKind.wall:
          canvas.drawRect(Rect.fromLTRB(e.a.x, top, e.a.x + 8, kFloor + 3), Paint()..color = block);
          for (var y = top + 8; y < kFloor; y += 14) {
            line(V(e.a.x, y), V(e.a.x + 8, y), stroke(const Color(0xFF2A2A26), 0.8));
          }
        case EqKind.pole:
          line(V(e.a.x, top), V(e.a.x, kFloor), stroke(_metal, 3.6));
          line(V(e.a.x - 0.8, top), V(e.a.x - 0.8, kFloor), stroke(const Color(0x40FFFFFF), 0.8));
        case EqKind.box:
          final r = Rect.fromLTRB(e.a.x, e.a.y, e.b.x, e.b.y);
          canvas.drawRect(r, Paint()..color = block);
          canvas.drawRect(Rect.fromLTRB(r.left, r.top, r.right, r.top + 2.2), Paint()..color = const Color(0xFF4A4A44));
          canvas.drawRect(r, stroke(const Color(0xFF4A4A44), 0.8));
        case EqKind.parallettes:
          line(V(e.a.x - 5, e.a.y), V(e.a.x - 7, kFloor), stroke(dim, 2.2));
          line(V(e.a.x + 5, e.a.y), V(e.a.x + 7, kFloor), stroke(dim, 2.2));
          line(V(e.a.x - 6.5, e.a.y), V(e.a.x + 6.5, e.a.y), stroke(const Color(0xFFC9B27A), 2.8));
        case EqKind.wheel:
          canvas.drawCircle(_o(e.a), 5.5, Paint()..color = const Color(0xFF3A3A36));
          canvas.drawCircle(_o(e.a), 5.5, stroke(_metal, 1.6));
          canvas.drawCircle(_o(e.a), 1.4, Paint()..color = _metal);
        case EqKind.strap:
          line(e.a, e.b, stroke(C.goldMuted, 1.6));
        case EqKind.pad:
          canvas.drawRRect(
              RRect.fromRectAndRadius(Rect.fromLTWH(e.a.x - 7, e.a.y, 14, 5), const Radius.circular(2.5)),
              Paint()..color = const Color(0xFF4A4A44));
      }
    }

    // Ombres de contact au sol.
    if (s.eq.any((e) => e.kind == EqKind.floor)) {
      final shadow = Paint()..color = const Color(0x55000000);
      for (final j in [J.wrN, J.wrF, J.anN, J.anF, J.toeN, J.toeF, J.knN, J.knF, J.hip, J.head]) {
        final p = s[j];
        if (p.y > kFloor - 6 && p.y < kFloor + 4) {
          canvas.drawOval(Rect.fromCenter(center: Offset(p.x, kFloor + 1.4), width: 12, height: 2.6), shadow);
        }
      }
    }

    final front = s.chest == 0;
    final shirt = color;
    final farShirt = _dim(shirt, 0.42), farSkin = _dim(_skin, 0.32), farShorts = _dim(_shorts, 0.3);
    final farShoe = _dim(_shoe, 0.38);

    void arm(J el, J wr, bool near) {
      final sk = near ? _skin : farSkin;
      final sh = near ? shirt : farShirt;
      final shoulder = s[J.sh];
      _limb(canvas, shoulder, s[el], 3.5, 3.0, sk);
      _limb(canvas, s[el], s[wr], 2.9, 2.3, sk);
      _limb(canvas, shoulder, V.lerp(shoulder, s[el], 0.55), 4.0, 3.7, sh); // manche
      canvas.drawCircle(_o(s[wr]), 2.5, Paint()..color = sk); // main
    }

    void leg(J kn, J an, J toe, bool near) {
      final sk = near ? _skin : farSkin;
      final sht = near ? _shorts : farShorts;
      final shoe = near ? _shoe : farShoe;
      final hip = s[J.hip];
      _limb(canvas, hip, s[kn], 4.9, 3.8, sk);
      _limb(canvas, s[kn], s[an], 3.7, 2.6, sk);
      _limb(canvas, hip, V.lerp(hip, s[kn], 0.55), 5.3, 4.6, sht); // short
      _limb(canvas, s[an], s[toe], 2.7, 1.9, shoe); // chaussure
    }

    // Côté éloigné d'abord.
    arm(J.elF, J.wrF, false);
    leg(J.knF, J.anF, J.toeF, false);

    // Tronc : plus large vu de face.
    final tw = front ? 8.2 : 6.0;
    _limb(canvas, s[J.hip], s[J.sh], tw, tw + (front ? 1.0 : 0.8), shirt);
    final hipDir = (s[J.sh] - s[J.hip]);
    final hl = hipDir.len == 0 ? 1.0 : hipDir.len;
    final pelvisEnd = s[J.hip] + hipDir * (6.5 / hl);
    _limb(canvas, s[J.hip], pelvisEnd, tw + 0.3, tw, _shorts);

    // Cou et tête.
    _limb(canvas, s[J.sh], s[J.head], 2.5, 2.3, _skin);
    final hc = _o(s[J.head]);
    canvas.drawCircle(hc, lHead, Paint()..color = _skin);
    final toHead = s[J.head] - s[J.sh];
    final up = m.atan2(toHead.y, toHead.x);
    final faceDir = front ? up : m.atan2(s.eye.y - s[J.head].y, s.eye.x - s[J.head].x);
    final hairCenter = front ? up : faceDir + m.pi; // la nuque, ou le dessus vu de face
    canvas.drawArc(Rect.fromCircle(center: hc, radius: lHead), hairCenter - (front ? 1.7 : 1.1),
        front ? 3.4 : 2.2, true, Paint()..color = _hair);
    if (!front) {
      canvas.drawCircle(_o(s.eye), 0.9, Paint()..color = const Color(0xFF1A1410));
    }

    // Côté proche.
    leg(J.knN, J.anN, J.toeN, true);
    arm(J.elN, J.wrN, true);

    // Barres et anneaux par-dessus les mains.
    for (final e in s.eq) {
      switch (e.kind) {
        case EqKind.bar:
        case EqKind.lowbar:
          canvas.drawCircle(_o(e.a), 2.8, Paint()..color = _metal);
          canvas.drawCircle(_o(e.a), 2.8, stroke(const Color(0xFF3A3A36), 0.7));
          canvas.drawCircle(Offset(e.a.x - 0.7, e.a.y - 0.8), 0.9, Paint()..color = const Color(0x66FFFFFF));
        case EqKind.rings:
          canvas.drawCircle(_o(e.a), 3.2, stroke(const Color(0xFFC9B27A), 1.7));
        default:
          break;
      }
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(PosePainter old) => old.skel != skel || old.color != color || old.frame != frame;
}

/// Une position figée d'un mouvement.
class PoseImage extends StatelessWidget {
  const PoseImage({super.key, required this.move, required this.phase, required this.color, this.radius = 14});
  final Move move;
  final int phase;
  final Color color;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final f = frameOf(move);
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: ColoredBox(
        color: C.surface,
        child: AspectRatio(
          aspectRatio: f.width / f.height,
          child: CustomPaint(painter: PosePainter(move.phases[phase].pose.skel, f, color)),
        ),
      ),
    );
  }
}

/// Animation en boucle entre les positions clés d'un mouvement.
class MoveAnimation extends StatefulWidget {
  const MoveAnimation({super.key, required this.move, required this.color, this.radius = 18});
  final Move move;
  final Color color;
  final double radius;

  @override
  State<MoveAnimation> createState() => _MoveAnimationState();
}

class _MoveAnimationState extends State<MoveAnimation> with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  bool _playing = true;

  int get _n => widget.move.phases.length;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: Duration(milliseconds: 1500 * _n))..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _playing = !_playing);
    _playing ? _c.repeat() : _c.stop();
  }

  @override
  Widget build(BuildContext context) {
    final f = frameOf(widget.move);
    final skels = [for (final p in widget.move.phases) p.pose.skel];
    return GestureDetector(
      onTap: _toggle,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(widget.radius),
        child: ColoredBox(
          color: C.surface,
          child: AspectRatio(
            aspectRatio: f.width / f.height,
            child: AnimatedBuilder(
              animation: _c,
              builder: (context, _) {
                final pos = _c.value * _n;
                final i = pos.floor() % _n;
                final local = pos - pos.floor();
                // Tenue sur la position, puis transition douce vers la suivante.
                final t = local < 0.45 ? 0.0 : Curves.easeInOut.transform((local - 0.45) / 0.55);
                final skel = Skel.lerp(skels[i], skels[(i + 1) % _n], t);
                final label = widget.move.phases[t < 0.5 ? i : (i + 1) % _n].label;
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    CustomPaint(painter: PosePainter(skel, f, widget.color)),
                    Positioned(
                      left: 12,
                      top: 10,
                      child: Text(label.toUpperCase(), style: eyebrow(widget.color)),
                    ),
                    Positioned(
                      right: 10,
                      top: 6,
                      child: Icon(_playing ? Icons.pause_circle_outline : Icons.play_circle_outline,
                          color: C.muted2, size: 22),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

// ───────────── Photos réelles (free-exercise-db, Wikimedia Commons) ─────────────

String _photoId(String id) => photoAlias[id] ?? id;

bool hasPhotos(String id) => photoSets.containsKey(_photoId(id));

/// Chemin de la photo de départ (0) ou de fin (1), si elle existe.
String? photoKey(String id, int which) {
  final pid = _photoId(id);
  return (photoSets[pid]?.contains(which) ?? false) ? '${pid}_$which' : null;
}

String photoPath(String key) => 'assets/photos/$key.jpg';

/// La photo la plus représentative : la fin, sinon le départ.
String? bestPhoto(String id) => photoKey(id, 1) ?? photoKey(id, 0);

class _Photo extends StatelessWidget {
  const _Photo(this.keyName, {this.radius = 14});
  final String keyName;
  final double radius;

  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: AspectRatio(
          aspectRatio: 1.5,
          child: Stack(fit: StackFit.expand, children: [
            Image.asset(photoPath(keyName), fit: BoxFit.cover, cacheWidth: 900),
            Positioned(right: 6, bottom: 4, child: _Credit(keyName)),
          ]),
        ),
      );
}

class _Credit extends StatelessWidget {
  const _Credit(this.keyName);
  final String keyName;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
        decoration: BoxDecoration(color: C.bg.withValues(alpha: 0.6), borderRadius: BorderRadius.circular(4)),
        child: Text(creditOf(keyName), style: body(8.5, color: Colors.white70)),
      );
}

/// Vignette d'un mouvement : photo si elle existe, sinon le dessin cadré sur la position finale.
class MoveThumb extends StatelessWidget {
  const MoveThumb({super.key, required this.move, required this.color, this.radius = 10});
  final Move move;
  final Color color;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final photo = bestPhoto(move.id);
    if (photo != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: AspectRatio(
          aspectRatio: 1.25,
          child: Image.asset(photoPath(photo), fit: BoxFit.cover, cacheWidth: 300),
        ),
      );
    }
    final f = _thumbFrames.putIfAbsent(move.id, () => Frame.fit([move.phases.last.pose.skel], aspect: 1.25));
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: ColoredBox(
        color: C.surface2,
        child: AspectRatio(
          aspectRatio: 1.25,
          child: CustomPaint(painter: PosePainter(move.phases.last.pose.skel, f, color)),
        ),
      ),
    );
  }
}

final Map<String, Frame> _thumbFrames = {};

/// Image d'une position clé : photo pour le départ et la fin quand on en a, dessin sinon.
class PhaseImage extends StatelessWidget {
  const PhaseImage({super.key, required this.move, required this.phase, required this.color});
  final Move move;
  final int phase;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final last = move.phases.length - 1;
    final key = phase == 0 ? photoKey(move.id, 0) : (phase == last ? photoKey(move.id, 1) : null);
    if (key != null) return _Photo(key, radius: 12);
    return PoseImage(move: move, phase: phase, color: color, radius: 12);
  }
}

/// Photo(s) réelle(s) : fondu départ ↔ fin quand les deux existent, sinon la photo de fin.
class PhotoLoop extends StatefulWidget {
  const PhotoLoop({super.key, required this.move, required this.color});
  final Move move;
  final Color color;

  @override
  State<PhotoLoop> createState() => _PhotoLoopState();
}

class _PhotoLoopState extends State<PhotoLoop> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 3200));
  bool _playing = true;

  String? get _a => photoKey(widget.move.id, 0);
  String? get _b => photoKey(widget.move.id, 1);
  bool get _loop => _a != null && _b != null;

  @override
  void initState() {
    super.initState();
    if (_loop) _c.repeat();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    for (final k in [_a, _b]) {
      if (k != null) precacheImage(AssetImage(photoPath(k)), context);
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  Widget _tag(String label) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(color: C.bg.withValues(alpha: 0.75), borderRadius: BorderRadius.circular(8)),
        child: Text(label.toUpperCase(), style: eyebrow(widget.color)),
      );

  @override
  Widget build(BuildContext context) {
    final phases = widget.move.phases;
    if (!_loop) {
      final k = (_b ?? _a)!;
      return ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: AspectRatio(
          aspectRatio: 1.5,
          child: Stack(fit: StackFit.expand, children: [
            Image.asset(photoPath(k), fit: BoxFit.cover, cacheWidth: 900),
            Positioned(left: 10, top: 10, child: _tag(_b != null ? phases.last.label : phases.first.label)),
            Positioned(right: 8, bottom: 6, child: _Credit(k)),
          ]),
        ),
      );
    }
    return GestureDetector(
      onTap: () {
        setState(() => _playing = !_playing);
        _playing ? _c.repeat() : _c.stop();
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: AspectRatio(
          aspectRatio: 1.5,
          child: AnimatedBuilder(
            animation: _c,
            builder: (context, _) {
              // 0–0.4 départ, 0.4–0.5 fondu, 0.5–0.9 fin, 0.9–1 fondu retour.
              final v = _c.value;
              final double t = v < 0.4
                  ? 0
                  : v < 0.5
                      ? (v - 0.4) / 0.1
                      : v < 0.9
                          ? 1
                          : 1 - (v - 0.9) / 0.1;
              return Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(photoPath(_a!), fit: BoxFit.cover, cacheWidth: 900),
                  Opacity(
                    opacity: Curves.easeInOut.transform(t),
                    child: Image.asset(photoPath(_b!), fit: BoxFit.cover, cacheWidth: 900),
                  ),
                  Positioned(left: 10, top: 10, child: _tag(t < 0.5 ? phases.first.label : phases.last.label)),
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Icon(_playing ? Icons.pause_circle_filled : Icons.play_circle_filled,
                        color: Colors.white70, size: 24),
                  ),
                  Positioned(right: 8, bottom: 6, child: _Credit(t < 0.5 ? _a! : _b!)),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
