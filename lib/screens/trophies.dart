import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../data.dart';
import '../poses/library.dart';
import '../theme.dart';
import '../widgets/pose_view.dart';
import 'skills.dart';

class TrophiesScreen extends StatelessWidget {
  const TrophiesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final defs = s.trophyDefs;
    final unlocked = s.unlockedSorted;
    final ordered = [
      for (final t in unlocked) defs.firstWhere((d) => d.id == t.id),
      ...defs.where((d) => !s.trophies.containsKey(d.id)),
    ];

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(child: Text('TROPHÉES', style: display(40, height: 1))),
              Text.rich(TextSpan(children: [
                TextSpan(text: '${unlocked.length}', style: display(22, color: C.gold, weight: FontWeight.w700)),
                TextSpan(text: ' / ${defs.length}', style: display(22, color: C.muted2, weight: FontWeight.w700)),
              ])),
            ],
          ),
          const SizedBox(height: 18),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 0.78,
            children: [for (final d in ordered) _Badge(def: d)],
          ),
          const SizedBox(height: 22),
          Text('HISTORIQUE', style: display(22, weight: FontWeight.w700)),
          const SizedBox(height: 10),
          if (unlocked.isEmpty)
            Panel(
              radius: 14,
              child: Text('Ton premier trophée t’attend. Lance un défi ou un tuto.',
                  style: body(14, color: C.muted)),
            ),
          for (final t in unlocked) ...[
            Panel(
              radius: 14,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              onTap: () => Navigator.of(context)
                  .push(MaterialPageRoute(builder: (_) => TrophyScreen(trophyId: t.id))),
              child: Row(
                children: [
                  SizedBox(
                    width: 46,
                    child: Column(
                      children: [
                        Text(t.unlockedAt.day.toString().padLeft(2, '0'), style: display(24, height: 1)),
                        Text(monthShort(t.unlockedAt).toUpperCase(),
                            style: body(11, color: C.muted, weight: FontWeight.w700)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(s.trophyDef(t.id).name, style: body(14, weight: FontWeight.w700)),
                        const SizedBox(height: 2),
                        Text(
                          t.note.isNotEmpty ? '« ${t.note} »' : (t.place.isNotEmpty ? t.place : t.path),
                          style: body(12, color: C.muted),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.def});
  final TrophyDef def;

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final t = s.trophies[def.id];
    final on = t != null;
    return Material(
      color: on ? C.goldBg : C.nav,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: on ? C.goldBorder : C.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          if (on) {
            Navigator.of(context).push(MaterialPageRoute(builder: (_) => TrophyScreen(trophyId: def.id)));
          } else if (def.isSkill) {
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => SkillScreen(skillId: def.sourceId)));
          } else {
            s.goTab(1);
          }
        },
        child: Padding(
          padding: const EdgeInsets.fromLTRB(6, 14, 6, 10),
          child: Column(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(shape: BoxShape.circle, color: on ? C.gold : C.surface2),
                child: Icon(on ? Icons.emoji_events_outlined : Icons.lock_outline,
                    color: on ? C.goldInk : const Color(0xFF6E6C66), size: on ? 26 : 22),
              ),
              const SizedBox(height: 6),
              Expanded(
                child: Text(def.name,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: body(13, weight: FontWeight.w700, height: 1.15, color: on ? C.text : C.muted2)),
              ),
              Text(
                on
                    ? '${t.unlockedAt.day.toString().padLeft(2, '0')}/${t.unlockedAt.month.toString().padLeft(2, '0')}/${t.unlockedAt.year}'
                    : 'Verrouillé',
                style: body(11, color: C.muted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TrophyScreen extends StatefulWidget {
  const TrophyScreen({super.key, required this.trophyId, this.isNew = false});
  final String trophyId;
  final bool isNew;

  @override
  State<TrophyScreen> createState() => _TrophyScreenState();
}

class _TrophyScreenState extends State<TrophyScreen> {
  late final TextEditingController _note;

  @override
  void initState() {
    super.initState();
    _note = TextEditingController(text: AppScope.read(context).trophies[widget.trophyId]?.note ?? '');
  }

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  Future<void> _editPlace(AppState s, Trophy t) async {
    final ctrl = TextEditingController(text: t.place);
    final res = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Ton spot', style: display(26)),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(hintText: 'Ex. : parc de la Villette'),
          onSubmitted: (v) => Navigator.pop(ctx, v),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
          TextButton(onPressed: () => Navigator.pop(ctx, ctrl.text), child: const Text('Enregistrer')),
        ],
      ),
    );
    ctrl.dispose();
    if (res != null) s.updateTrophy(t.id, place: res);
  }

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final t = s.trophies[widget.trophyId];
    final def = s.trophyDef(widget.trophyId);

    if (t == null) {
      return Scaffold(
        backgroundColor: C.trophyBg,
        appBar: AppBar(backgroundColor: C.trophyBg),
        body: Center(child: Text('Ce trophée est verrouillé.', style: body(15, color: C.muted))),
      );
    }

    Widget cell(String label, String value, {VoidCallback? onTap, bool right = false, bool bottom = false}) {
      return InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            border: Border(
              right: right ? const BorderSide(color: Color(0xFF3A3220)) : BorderSide.none,
              bottom: bottom ? const BorderSide(color: Color(0xFF3A3220)) : BorderSide.none,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label.toUpperCase(),
                  style: body(11, color: const Color(0xFFB9A77A), weight: FontWeight.w700, letterSpacing: 1)),
              const SizedBox(height: 3),
              Row(
                children: [
                  Flexible(
                    child: Text(value,
                        style: body(15, weight: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis),
                  ),
                  if (onTap != null) ...[
                    const SizedBox(width: 4),
                    const Icon(Icons.edit_outlined, size: 14, color: Color(0xFFB9A77A)),
                  ],
                ],
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: C.trophyBg,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: Material(
                color: C.surface,
                shape: const CircleBorder(),
                child: IconButton(
                  tooltip: 'Fermer',
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: C.text, size: 18),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(widget.isNew ? 'PREMIÈRE FOIS' : 'TROPHÉE',
                  style: body(12, color: C.gold, weight: FontWeight.w700, letterSpacing: 3)),
            ),
            const SizedBox(height: 22),
            Center(
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: widget.isNew ? 0.6 : 1, end: 1),
                duration: const Duration(milliseconds: 600),
                curve: Curves.elasticOut,
                builder: (_, v, child) => Transform.scale(scale: v, child: child),
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: C.goldBorder, width: 2),
                  ),
                  alignment: Alignment.center,
                  child: Container(
                    width: 164,
                    height: 164,
                    decoration: const BoxDecoration(shape: BoxShape.circle, color: C.gold),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.emoji_events_outlined, size: 64, color: C.goldInk),
                        Text('N° ${s.trophyNumber(t.id).toString().padLeft(2, '0')}',
                            style: display(15, color: C.goldInk).copyWith(letterSpacing: 1.5)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 22),
            Text(def.name.toUpperCase(), textAlign: TextAlign.center, style: display(58, height: 0.9)),
            const SizedBox(height: 6),
            Text(def.desc, textAlign: TextAlign.center, style: body(15, color: const Color(0xFFC9C6BD))),
            const SizedBox(height: 18),
            GestureDetector(
              onTap: () => openMove(context, s.trophyMove(t.id)),
              child: Center(child: SizedBox(height: 190, child: MoveThumb(move: moveById[s.trophyMove(t.id)]!, color: C.gold, radius: 16))),
            ),
            const SizedBox(height: 22),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1A1813),
                border: Border.all(color: const Color(0xFF3A3220)),
                borderRadius: BorderRadius.circular(18),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  Row(children: [
                    Expanded(child: cell('Date', shortDate(t.unlockedAt), right: true, bottom: true)),
                    Expanded(child: cell('Heure', hourLabel(t.unlockedAt), bottom: true)),
                  ]),
                  Row(children: [
                    Expanded(
                      child: cell('Lieu', t.place.isEmpty ? 'Ajouter' : t.place,
                          right: true, onTap: () => _editPlace(s, t)),
                    ),
                    Expanded(child: cell('Parcours', t.path)),
                  ]),
                ],
              ),
            ),
            const SizedBox(height: 22),
            Text('Un mot pour ce moment', style: body(12, color: C.muted, weight: FontWeight.w600)),
            const SizedBox(height: 6),
            TextField(
              controller: _note,
              onChanged: (v) => s.updateTrophy(t.id, note: v),
              textCapitalization: TextCapitalization.sentences,
              style: body(14),
              decoration: InputDecoration(
                hintText: 'Ex. : enfin passé au-dessus de la barre !',
                hintStyle: body(14, color: C.muted2),
                filled: true,
                fillColor: const Color(0xFF161614),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: C.border)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: C.gold)),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: BigButton(
                    label: 'Fermer',
                    color: C.surface,
                    ink: C.text,
                    height: 54,
                    borderColor: C.border,
                    onTap: () => Navigator.pop(context),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: BigButton(
                    label: 'Partager',
                    color: C.gold,
                    ink: C.goldInk,
                    height: 54,
                    onTap: () {
                      final note = t.note.isNotEmpty ? '\n« ${t.note} »' : '';
                      final place = t.place.isNotEmpty ? ' à ${t.place}' : '';
                      SharePlus.instance.share(ShareParams(
                        text: 'Trophée débloqué sur Chalk : ${def.name} !\n'
                            '${def.desc}\nLe ${fullDate(t.unlockedAt)}$place · ${t.path}$note',
                      ));
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
