import 'package:flutter/material.dart';

import '../data.dart';
import '../poses/library.dart';
import '../theme.dart';
import '../widgets/pose_view.dart';
import 'trophies.dart';

void openMove(BuildContext context, String id) => Navigator.of(context)
    .push(MaterialPageRoute(builder: (_) => MoveScreen(move: moveById[id]!)));

class SkillsScreen extends StatefulWidget {
  const SkillsScreen({super.key});

  @override
  State<SkillsScreen> createState() => _SkillsScreenState();
}

class _SkillsScreenState extends State<SkillsScreen> {
  int _tab = 0;
  String _cat = moveCategories.first.id;
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final q = _query.trim().toLowerCase();
    final List<Move> list;
    if (q.isNotEmpty) {
      list = moves
          .where((m) => m.name.toLowerCase().contains(q) || (m.aka ?? '').toLowerCase().contains(q))
          .toList();
    } else {
      list = [for (final id in moveCategories.firstWhere((c) => c.id == _cat).ids) moveById[id]!];
    }

    return SafeArea(
      bottom: false,
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
            sliver: SliverList.list(children: [
              Text('TUTOS', style: display(40, height: 1)),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(color: C.surface, borderRadius: BorderRadius.circular(14)),
                child: Row(
                  children: [
                    for (final (i, label) in ['Skills', 'Bibliothèque'].indexed)
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _tab = i),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            height: 40,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: _tab == i ? C.text : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(label,
                                style: body(13, color: _tab == i ? C.bg : C.muted, weight: FontWeight.w700)),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ]),
          ),
          if (_tab == 0)
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              sliver: SliverList.separated(
                itemCount: skillCatalog.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (_, i) => _SkillCard(skill: skillCatalog[i], state: s),
              ),
            )
          else ...[
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverToBoxAdapter(
                child: TextField(
                  onChanged: (v) => setState(() => _query = v),
                  style: body(15),
                  decoration: InputDecoration(
                    hintText: 'Chercher un mouvement (${moves.length})',
                    hintStyle: body(15, color: C.muted2),
                    prefixIcon: const Icon(Icons.search, color: C.muted2),
                    filled: true,
                    fillColor: C.surface,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: C.border)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: s.accent)),
                  ),
                ),
              ),
            ),
            if (q.isEmpty)
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 56,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 6),
                    children: [
                      for (final c in moveCategories)
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(c.name),
                            selected: _cat == c.id,
                            onSelected: (_) => setState(() => _cat = c.id),
                            showCheckmark: false,
                            avatar: CircleAvatar(backgroundColor: Color(c.color), radius: 5),
                            labelStyle: body(13,
                                color: _cat == c.id ? C.bg : C.text, weight: FontWeight.w600),
                            selectedColor: C.text,
                            backgroundColor: C.surface,
                            side: const BorderSide(color: C.border),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
              sliver: list.isEmpty
                  ? SliverToBoxAdapter(
                      child: Text('Aucun mouvement ne correspond.', style: body(14, color: C.muted)))
                  : SliverList.separated(
                      itemCount: list.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (_, i) => _MoveTile(move: list[i], accent: s.accent),
                    ),
            ),
          ],
        ],
      ),
    );
  }
}

class _MoveTile extends StatelessWidget {
  const _MoveTile({required this.move, required this.accent});
  final Move move;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Panel(
      radius: 16,
      padding: const EdgeInsets.all(10),
      onTap: () => openMove(context, move.id),
      child: Row(
        children: [
          SizedBox(
            width: 92,
            child: MoveThumb(move: move, color: accent),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(move.name, style: body(15, weight: FontWeight.w700)),
                if (move.aka != null) ...[
                  const SizedBox(height: 2),
                  Text(move.aka!, style: body(12, color: C.muted2), maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
                const SizedBox(height: 4),
                Text('${move.level} · ${move.gear}', style: body(12, color: C.muted)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: C.muted2),
        ],
      ),
    );
  }
}

class Stars extends StatelessWidget {
  const Stars(this.n, {super.key, this.color = C.gold, this.size = 14});
  final int n;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < 5; i++)
            Icon(i < n ? Icons.star_rounded : Icons.star_outline_rounded,
                size: size, color: i < n ? color : C.off),
        ],
      );
}

class _SkillCard extends StatelessWidget {
  const _SkillCard({required this.skill, required this.state});
  final SkillDef skill;
  final AppState state;

  @override
  Widget build(BuildContext context) {
    final step = state.stepOf(skill.id);
    final done = state.skillDone(skill.id);
    final total = skill.steps.length;
    final finalMove = moveById[skill.steps.last.move]!;
    return Panel(
      radius: 20,
      color: done ? C.goldBg : C.surface,
      borderColor: done ? C.goldBorder : C.border,
      padding: const EdgeInsets.all(14),
      onTap: () => Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => SkillScreen(skillId: skill.id))),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 96,
            child: MoveThumb(move: finalMove, color: done ? C.gold : state.accent, radius: 12),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: Text(skill.name.toUpperCase(), style: display(24, height: 1))),
                    if (done)
                      const Icon(Icons.emoji_events_outlined, color: C.gold, size: 20)
                    else
                      Text('$step/$total', style: display(20, color: C.muted)),
                  ],
                ),
                const SizedBox(height: 4),
                Row(children: [
                  Stars(skill.wow),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(skill.level,
                        style: body(12, color: C.muted, weight: FontWeight.w600), overflow: TextOverflow.ellipsis),
                  ),
                ]),
                const SizedBox(height: 10),
                Bar(value: step / total, color: done ? C.gold : state.accent, height: 6),
                const SizedBox(height: 6),
                Text(
                  done ? 'Maîtrisé' : 'Étape ${step + 1} : ${stepName(skill.steps[step])}',
                  style: body(12, color: done ? C.goldMuted : C.muted, weight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SkillScreen extends StatelessWidget {
  const SkillScreen({super.key, required this.skillId});
  final String skillId;

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final skill = s.skillDef(skillId);
    final step = s.stepOf(skillId);
    final total = skill.steps.length;
    final done = step >= total;
    final accent = s.accent;
    final current = skill.steps[done ? total - 1 : step];

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                children: [
                  Row(
                    children: [
                      IconButton(
                        tooltip: 'Retour',
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back, color: C.text),
                      ),
                      const Spacer(),
                      Stars(skill.wow, size: 18),
                      const SizedBox(width: 8),
                    ],
                  ),
                  const SizedBox(height: 4),
                  MoveViewer(key: ValueKey(current.move), move: moveById[current.move]!, color: done ? C.gold : accent),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(done ? 'FIGURE MAÎTRISÉE' : 'ÉTAPE ${step + 1} / $total · ${current.goal.toUpperCase()}',
                            style: eyebrow(done ? C.gold : accent)),
                        const SizedBox(height: 6),
                        Text(skill.name.toUpperCase(), style: display(44, height: 0.95)),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [Chip2(skill.level), Chip2(skill.equipment), Chip2(skill.muscles)],
                        ),
                        const SizedBox(height: 18),
                        Text('PROGRESSION · ${step.clamp(0, total)} / $total',
                            style: display(20, color: C.muted, weight: FontWeight.w700)),
                        const SizedBox(height: 12),
                        for (var i = 0; i < total; i++)
                          _StepRow(skill: skill, index: i, current: step, accent: accent),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              decoration: const BoxDecoration(
                color: C.bg,
                border: Border(top: BorderSide(color: C.navBorder)),
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 56,
                        height: 56,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.zero,
                            backgroundColor: C.surface,
                            side: const BorderSide(color: C.border),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          onPressed: step == 0
                              ? null
                              : () {
                                  s.undoStep(skillId);
                                  toast(context, 'Dernière étape annulée');
                                },
                          child: Icon(Icons.undo,
                              color: step == 0 ? C.off : C.text, semanticLabel: 'Annuler une étape'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: done
                            ? BigButton(
                                label: 'Voir le trophée',
                                color: C.gold,
                                ink: C.goldInk,
                                displayFont: true,
                                onTap: () => Navigator.of(context).push(
                                    MaterialPageRoute(builder: (_) => TrophyScreen(trophyId: 's:$skillId'))),
                              )
                            : BigButton(
                                label: 'J’ai réussi !',
                                color: accent,
                                displayFont: true,
                                onTap: () {
                                  final trophy = s.validateStep(skillId);
                                  if (trophy != null) {
                                    Navigator.of(context).push(MaterialPageRoute(
                                        builder: (_) => TrophyScreen(trophyId: trophy.id, isNew: true)));
                                  } else {
                                    toast(context, 'Étape validée ! Place à la suivante.');
                                  }
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  const _StepRow({required this.skill, required this.index, required this.current, required this.accent});
  final SkillDef skill;
  final int index;
  final int current;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final st = index < current ? 'done' : (index == current ? 'now' : 'next');
    final last = index == skill.steps.length - 1;
    final step = skill.steps[index];
    final move = moveById[step.move]!;
    final meta = switch (st) {
      'done' => 'Validé · ${step.goal}',
      'now' => 'En cours · ${step.goal}',
      _ => last ? 'Le trophée t’attend · ${step.goal}' : 'À venir · ${step.goal}',
    };

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 28,
            child: Column(
              children: [
                const SizedBox(height: 14),
                Container(
                  width: 28,
                  height: 28,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: st == 'done' ? accent : null,
                    border: st == 'done'
                        ? null
                        : Border.all(color: st == 'now' ? accent : C.dash, width: st == 'now' ? 2 : 1.5),
                  ),
                  child: st == 'done'
                      ? const Icon(Icons.check, size: 16, color: C.bg)
                      : Text('${index + 1}',
                          style: body(13, weight: FontWeight.w800, color: st == 'now' ? accent : C.muted2)),
                ),
                if (!last)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.only(top: 4),
                      color: st == 'done' ? accent : C.border,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Panel(
                radius: 14,
                padding: const EdgeInsets.all(8),
                color: st == 'now' ? C.surface : C.nav,
                borderColor: st == 'now' ? accent.withValues(alpha: 0.5) : C.border,
                onTap: () => openMove(context, step.move),
                child: Row(
                  children: [
                    SizedBox(
                      width: 72,
                      child: MoveThumb(move: move, color: st == 'next' ? C.muted2 : accent, radius: 8),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(stepName(step),
                              style: body(14, weight: FontWeight.w700, color: st == 'next' ? C.muted : C.text)),
                          const SizedBox(height: 2),
                          Text(meta, style: body(12, color: C.muted)),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: C.muted2, size: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MoveScreen extends StatelessWidget {
  const MoveScreen({super.key, required this.move});
  final Move move;

  @override
  Widget build(BuildContext context) {
    final accent = AppScope.of(context).accent;
    final cats = moveCategories.where((c) => c.ids.contains(move.id)).toList();
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                tooltip: 'Retour',
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back, color: C.text),
              ),
            ),
            const SizedBox(height: 4),
            MoveViewer(move: move, color: accent),
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(move.name.toUpperCase(), style: display(40, height: 0.95)),
                  if (move.aka != null) ...[
                    const SizedBox(height: 4),
                    Text(move.aka!, style: body(13, color: C.muted2)),
                  ],
                  const SizedBox(height: 10),
                  Wrap(spacing: 6, runSpacing: 6, children: [
                    Chip2(move.level),
                    Chip2(move.gear),
                    for (final c in cats) Chip2(c.name),
                  ]),
                  const SizedBox(height: 12),
                  Text(move.desc, style: body(15, color: const Color(0xFFC9C6BD), height: 1.4)),
                  const SizedBox(height: 20),
                  Text('POSITIONS CLÉS', style: display(22, weight: FontWeight.w700)),
                  const SizedBox(height: 10),
                ],
              ),
            ),
            for (var i = 0; i < move.phases.length; i++) ...[
              Panel(
                radius: 18,
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PhaseImage(move: move, phase: i, color: accent),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 26,
                            height: 26,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
                            child: Text('${i + 1}', style: body(13, color: C.bg, weight: FontWeight.w800)),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(move.phases[i].label.toUpperCase(), style: eyebrow(accent)),
                                const SizedBox(height: 3),
                                Text(move.phases[i].cue, style: body(14, height: 1.35)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                  ],
                ),
              ),
              const SizedBox(height: 10),
            ],
          ],
        ),
      ),
    );
  }
}

/// Visionneuse : photos réelles quand elles existent (avec bascule vers le schéma animé).
class MoveViewer extends StatefulWidget {
  const MoveViewer({super.key, required this.move, required this.color});
  final Move move;
  final Color color;

  @override
  State<MoveViewer> createState() => _MoveViewerState();
}

class _MoveViewerState extends State<MoveViewer> {
  late bool _photo = hasPhotos(widget.move.id);

  @override
  Widget build(BuildContext context) {
    final photos = hasPhotos(widget.move.id);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _photo
            ? PhotoLoop(move: widget.move, color: widget.color)
            : MoveAnimation(move: widget.move, color: widget.color),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: Text(
                _photo ? 'Photo réelle' : 'Touche l’animation pour la mettre en pause',
                style: body(11, color: C.muted2),
              ),
            ),
            if (photos)
              TextButton.icon(
                onPressed: () => setState(() => _photo = !_photo),
                icon: Icon(_photo ? Icons.gesture : Icons.photo_outlined, size: 16, color: widget.color),
                label: Text(_photo ? 'Voir le schéma' : 'Voir les photos',
                    style: body(12, color: widget.color, weight: FontWeight.w700)),
              ),
          ],
        ),
      ],
    );
  }
}