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

  @override
  void paint(Canvas canvas, Size size) {
    final k = size.width / frame.width;
    canvas.save();
    canvas.clipRect(Offset.zero & size);
    canvas.scale(k);
    canvas.translate(-frame.left, -frame.top);

    Offset o(V v) => Offset(v.x, v.y);
    Paint stroke(Color c, double w) => Paint()
      ..color = c
      ..strokeWidth = w
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    void line(V a, V b, Paint p) => canvas.drawLine(o(a), o(b), p);

    const metal = Color(0xFF8F8D86), dim = Color(0xFF5C5A54), block = Color(0xFF2E2E2B);
    final top = frame.top, right = frame.left + frame.width;

    for (final e in skel.eq) {
      switch (e.kind) {
        case EqKind.floor:
          line(V(frame.left, kFloor + 1.5), V(right, kFloor + 1.5), stroke(const Color(0xFF44443F), 3));
        case EqKind.lowbar:
          line(e.a, V(e.a.x, kFloor), stroke(dim, 2));
        case EqKind.hbar:
          line(e.a, e.b, stroke(metal, 3));
        case EqKind.rings:
          line(V(e.a.x, top), V(e.a.x, e.a.y - 3), stroke(dim, 1.2));
        case EqKind.pbars:
          line(e.a, e.b, stroke(metal, 3));
          line(V(e.a.x + 3, e.a.y), V(e.a.x + 3, kFloor), stroke(dim, 2));
          line(V(e.b.x - 3, e.b.y), V(e.b.x - 3, kFloor), stroke(dim, 2));
        case EqKind.wall:
          canvas.drawRect(Rect.fromLTRB(e.a.x, top, e.a.x + 6, kFloor + 3), Paint()..color = block);
        case EqKind.pole:
          line(V(e.a.x, top), V(e.a.x, kFloor), stroke(metal, 3.5));
        case EqKind.box:
          final r = Rect.fromLTRB(e.a.x, e.a.y, e.b.x, e.b.y);
          canvas.drawRect(r, Paint()..color = block);
          canvas.drawRect(r, stroke(const Color(0xFF44443F), 1));
        case EqKind.parallettes:
          line(V(e.a.x - 6, e.a.y), V(e.a.x + 6, e.a.y), stroke(metal, 2.5));
          line(V(e.a.x - 5, e.a.y), V(e.a.x - 7, kFloor), stroke(dim, 2));
          line(V(e.a.x + 5, e.a.y), V(e.a.x + 7, kFloor), stroke(dim, 2));
        case EqKind.wheel:
          canvas.drawCircle(o(e.a), 5.5, stroke(metal, 2));
        case EqKind.strap:
          line(e.a, e.b, stroke(C.goldMuted, 1.5));
        case EqKind.pad:
          canvas.drawRRect(
              RRect.fromRectAndRadius(Rect.fromLTWH(e.a.x - 6, e.a.y, 12, 5), const Radius.circular(2)),
              Paint()..color = const Color(0xFF44443F));
        case EqKind.bar:
          break;
      }
    }

    final s = skel;
    final far = Color.lerp(color, C.surface, 0.55)!;
    line(s[J.sh], s[J.elF], stroke(far, 4.5));
    line(s[J.elF], s[J.wrF], stroke(far, 4.5));
    line(s[J.hip], s[J.knF], stroke(far, 5.5));
    line(s[J.knF], s[J.anF], stroke(far, 5));
    line(s[J.anF], s[J.toeF], stroke(far, 3.5));
    line(s[J.hip], s[J.sh], stroke(color, 8));
    line(s[J.sh], s[J.head], stroke(color, 4));
    canvas.drawCircle(o(s[J.head]), lHead, Paint()..color = color);
    if (s.chest != 0) canvas.drawCircle(o(s.eye), 1.1, Paint()..color = C.bg);
    line(s[J.hip], s[J.knN], stroke(color, 5.5));
    line(s[J.knN], s[J.anN], stroke(color, 5));
    line(s[J.anN], s[J.toeN], stroke(color, 3.5));
    line(s[J.sh], s[J.elN], stroke(color, 4.5));
    line(s[J.elN], s[J.wrN], stroke(color, 4.5));

    for (final e in s.eq) {
      if (e.kind == EqKind.bar || e.kind == EqKind.lowbar) {
        canvas.drawCircle(o(e.a), 2.6, Paint()..color = metal);
        canvas.drawCircle(o(e.a), 2.6, stroke(C.bg, 0.8));
      } else if (e.kind == EqKind.rings) {
        canvas.drawCircle(o(e.a), 3, stroke(metal, 1.5));
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
    final f = _thumbFrames.putIfAbsent(move.id, () => Frame.fit([move.phases.last.pose.skel]));
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
