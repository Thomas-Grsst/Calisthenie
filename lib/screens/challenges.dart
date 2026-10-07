import 'package:flutter/material.dart';

import '../data.dart';
import '../poses/library.dart';
import '../theme.dart';
import '../widgets/pose_view.dart';
import 'skills.dart';
import 'trophies.dart';

class ChallengesScreen extends StatefulWidget {
  const ChallengesScreen({super.key});

  @override
  State<ChallengesScreen> createState() => _ChallengesScreenState();
}

class _ChallengesScreenState extends State<ChallengesScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final active = s.activeChallenges;
    final discover = s.discoverChallenges;
    final done = s.doneChallenges;

    final List<Widget> content;
    switch (_tab) {
      case 0:
        content = [
          if (active.isEmpty)
            Panel(
              child: Text(
                'Aucun défi en cours. Choisis-en un ci-dessous, sans date limite.',
                style: body(14, color: C.muted),
              ),
            ),
          for (final c in active) ...[
            ActiveChallengeCard(def: c),
            const SizedBox(height: 12),
          ],
          if (discover.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text('À RELEVER', style: display(22, weight: FontWeight.w700)),
            const SizedBox(height: 10),
            for (final c in discover.take(3)) ...[
              _DiscoverItem(def: c),
              const SizedBox(height: 10),
            ],
          ],
        ];
      case 1:
        content = [
          if (discover.isEmpty)
            Panel(
              child: Text(
                'Tu as déjà lancé tous les défis.',
                style: body(14, color: C.muted),
              ),
            ),
          for (final c in discover) ...[
            _DiscoverItem(def: c),
            const SizedBox(height: 10),
          ],
        ];
      default:
        content = [
          if (done.isEmpty)
            Panel(
              child: Text(
                'Pas encore de défi terminé. Ça arrive.',
                style: body(14, color: C.muted),
              ),
            ),
          for (final c in done) ...[
            _DoneItem(def: c),
            const SizedBox(height: 10),
          ],
        ];
    }

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
        children: [
          Text('DÉFIS', style: display(40, height: 1)),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: C.surface,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                for (final (i, label) in [
                  'En cours',
                  'À découvrir',
                  'Terminés',
                ].indexed)
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
                        child: Text(
                          label,
                          style: body(
                            13,
                            color: _tab == i ? C.bg : C.muted,
                            weight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          ...content,
        ],
      ),
    );
  }
}

class ActiveChallengeCard extends StatelessWidget {
  const ActiveChallengeCard({super.key, required this.def});
  final ChallengeDef def;

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final p = s.challenges[def.id]!;
    final paliers = def.paliers;
    final nextIndex = paliers.indexWhere((v) => p.record < v);

    return Panel(
      radius: 22,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'DÉFI EN COURS · SANS DATE LIMITE',
                      style: eyebrow(s.accent),
                    ),
                    const SizedBox(height: 4),
                    Text(def.name.toUpperCase(), style: display(30, height: 1)),
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: () => openMove(context, def.move),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 120,
                            child: MoveThumb(
                              move: moveById[def.move]!,
                              color: s.accent,
                              radius: 12,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Voir le mouvement →',
                            style: body(
                              13,
                              color: C.muted,
                              weight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(text: '${p.record}', style: display(28)),
                    TextSpan(
                      text: '/${def.target}',
                      style: display(28, color: C.muted2),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'Paliers franchis${def.timed ? ' (secondes)' : ''}',
            style: body(12, color: C.muted, weight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              for (var i = 0; i < paliers.length; i++) ...[
                if (i > 0) const SizedBox(width: 6),
                Expanded(
                  child: Container(
                    height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: p.record >= paliers[i]
                          ? s.accent
                          : (i == nextIndex ? null : C.navBorder),
                      border: i == nextIndex
                          ? Border.all(color: s.accent, width: 1.5)
                          : null,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${paliers[i]}',
                      style: display(
                        18,
                        color: p.record >= paliers[i]
                            ? C.bg
                            : (i == nextIndex ? s.accent : C.muted2),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 14),
          BigButton(
            label: 'Noter une tentative',
            color: s.accent,
            height: 48,
            onTap: () => logAttemptFlow(context, def),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                '${p.attempts} tentative${p.attempts > 1 ? 's' : ''} · depuis le ${fullDate(p.startedAt)}',
                style: body(12, color: C.muted2),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => _confirmAbandon(context, s),
                child: Text('Abandonner', style: body(12, color: C.muted2)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _confirmAbandon(BuildContext context, AppState s) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Abandonner ce défi ?', style: display(26)),
        content: Text(
          'Ton record et tes tentatives seront effacés.',
          style: body(14, color: C.muted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Garder'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Abandonner'),
          ),
        ],
      ),
    );
    if (ok == true) s.abandonChallenge(def.id);
  }
}

Future<void> logAttemptFlow(BuildContext context, ChallengeDef def) async {
  final s = AppScope.read(context);
  final p = s.challenges[def.id];
  final start = (p == null || p.record == 0) ? def.paliers.first : p.record;
  final value = await showModalBottomSheet<int>(
    context: context,
    backgroundColor: C.surface,
    showDragHandle: true,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => _AttemptSheet(def: def, initial: start, accent: s.accent),
  );
  if (value == null || !context.mounted) return;
  final res = s.logAttempt(def.id, value);
  if (res.trophy != null) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TrophyScreen(trophyId: res.trophy!.id, isNew: true),
      ),
    );
  } else {
    toast(
      context,
      res.improved
          ? 'Nouveau record : ${def.fmtUnit(value)} !'
          : 'Tentative notée. Continue !',
    );
  }
}

class _AttemptSheet extends StatefulWidget {
  const _AttemptSheet({
    required this.def,
    required this.initial,
    required this.accent,
  });
  final ChallengeDef def;
  final int initial;
  final Color accent;

  @override
  State<_AttemptSheet> createState() => _AttemptSheetState();
}

class _AttemptSheetState extends State<_AttemptSheet> {
  late int _v = widget.initial;

  void _add(int d) => setState(() => _v = (_v + d).clamp(0, 9999));

  Widget _step(int d) => SizedBox(
    width: 56,
    height: 56,
    child: OutlinedButton(
      style: OutlinedButton.styleFrom(
        padding: EdgeInsets.zero,
        side: const BorderSide(color: C.border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      onPressed: () => _add(d),
      child: Text(d > 0 ? '+$d' : '$d', style: display(20)),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final def = widget.def;
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('NOTER UNE TENTATIVE', style: eyebrow(widget.accent)),
              const SizedBox(height: 4),
              Text(def.name.toUpperCase(), style: display(28, height: 1)),
              const SizedBox(height: 20),
              Row(
                children: [
                  _step(-5),
                  const SizedBox(width: 8),
                  _step(-1),
                  Expanded(
                    child: Column(
                      children: [
                        Text('$_v', style: display(64, height: 1)),
                        Text(
                          def.timed ? 'secondes' : 'répétitions',
                          style: body(12, color: C.muted),
                        ),
                      ],
                    ),
                  ),
                  _step(1),
                  const SizedBox(width: 8),
                  _step(5),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Objectif : ${def.fmtUnit(def.target)}',
                textAlign: TextAlign.center,
                style: body(13, color: C.muted),
              ),
              const SizedBox(height: 20),
              BigButton(
                label: 'Enregistrer',
                color: widget.accent,
                onTap: _v > 0 ? () => Navigator.pop(context, _v) : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DiscoverItem extends StatelessWidget {
  const _DiscoverItem({required this.def});
  final ChallengeDef def;

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    return Panel(
      radius: 16,
      padding: const EdgeInsets.all(14),
      onTap: () => _openDetails(context, s),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: MoveThumb(
              move: moveById[def.move]!,
              color: s.accent,
              radius: 10,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(def.name, style: body(15, weight: FontWeight.w700)),
                const SizedBox(height: 3),
                Text(
                  '${def.category} · objectif ${def.fmtUnit(def.target)}',
                  style: body(12, color: C.muted),
                ),
              ],
            ),
          ),
          LevelBars(level: def.level, color: s.accent),
        ],
      ),
    );
  }

  Future<void> _openDetails(BuildContext context, AppState s) async {
    final start = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: C.surface,
      showDragHandle: true,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        def.category.toUpperCase(),
                        style: eyebrow(s.accent),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        def.name.toUpperCase(),
                        style: display(34, height: 1),
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        height: 170,
                        child: Center(
                          child: hasPhotos(def.move)
                              ? PhotoLoop(
                                  move: moveById[def.move]!,
                                  color: s.accent,
                                )
                              : MoveAnimation(
                                  move: moveById[def.move]!,
                                  color: s.accent,
                                ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'Six paliers jusqu’à ${def.fmtUnit(def.target)} : ${def.paliers.join(' · ')}. '
                        'Note chaque tentative, à ton rythme, sans date limite. '
                        'Atteins l’objectif pour débloquer le trophée.',
                        style: body(14, color: C.muted, height: 1.4),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
              BigButton(
                label: 'Commencer le défi',
                color: s.accent,
                onTap: () => Navigator.pop(ctx, true),
              ),
            ],
          ),
        ),
      ),
    );
    if (start == true) {
      s.startChallenge(def.id);
      if (context.mounted) toast(context, 'Défi lancé : ${def.name}');
    }
  }
}

class _DoneItem extends StatelessWidget {
  const _DoneItem({required this.def});
  final ChallengeDef def;

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final p = s.challenges[def.id]!;
    return Panel(
      color: C.goldBg,
      borderColor: C.goldBorder,
      radius: 16,
      padding: const EdgeInsets.all(14),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => TrophyScreen(trophyId: 'c:${def.id}'),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: C.gold,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.emoji_events_outlined, color: C.goldInk),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 72,
            child: MoveThumb(
              move: moveById[def.move]!,
              color: C.gold,
              radius: 10,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(def.name, style: body(15, weight: FontWeight.w700)),
                const SizedBox(height: 3),
                Text(
                  'Relevé le ${fullDate(p.doneAt!)} · record ${def.fmtUnit(p.record)}',
                  style: body(12, color: C.goldMuted),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            tooltip: 'Noter une tentative',
            onPressed: () => logAttemptFlow(context, def),
            icon: const Icon(Icons.add, color: C.goldMuted),
          ),
        ],
      ),
    );
  }
}
