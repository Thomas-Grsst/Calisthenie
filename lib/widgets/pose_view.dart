import 'package:flutter/material.dart';

import '../poses/library.dart';
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
