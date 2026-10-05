import 'package:flutter/material.dart';

import '../data.dart';
import '../poses/library.dart';
import '../theme.dart';
import '../widgets/pose_view.dart';
import 'skills.dart';
import 'trophies.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final now = DateTime.now();
    final active = s.activeChallenges;
    final next = s.nextSkills;
    final latest = s.unlockedSorted.firstOrNull;

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(longDate(now), style: body(13, color: C.muted)),
                    const SizedBox(height: 2),
                    Text(
                      s.name.isEmpty ? 'SALUT !' : 'SALUT ${s.name.toUpperCase()}',
                      style: display(34),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Material(
                color: C.surface,
                shape: const CircleBorder(side: BorderSide(color: C.border)),
                child: IconButton(
                  tooltip: 'Mes trophées',
                  onPressed: () => s.goTab(3),
                  icon: const Icon(Icons.emoji_events_outlined, color: C.gold, size: 22),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const _WeekCard(),
          const SizedBox(height: 20),
          if (active.isEmpty)
            _NoChallengeCard(onTap: () => s.goTab(1))
          else
            _CurrentChallengeCard(def: active.first),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: Text('TES PROCHAINES FIGURES', style: display(22, weight: FontWeight.w700))),
              TextButton(
                onPressed: () => s.goTab(2),
                child: Text('Tout voir', style: body(13, color: C.muted)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          if (next.isEmpty)
            Panel(child: Text('Toutes les figures sont maîtrisées. Respect.', style: body(14)))
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var i = 0; i < next.length; i++) ...[
                  if (i > 0) const SizedBox(width: 10),
                  Expanded(child: _SkillMini(skill: next[i])),
                ],
              ],
            ),
          if (latest != null) ...[
            const SizedBox(height: 20),
            Panel(
              color: C.goldBg,
              borderColor: C.goldBorder,
              radius: 16,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              onTap: () => Navigator.of(context)
                  .push(MaterialPageRoute(builder: (_) => TrophyScreen(trophyId: latest.id))),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(color: C.gold, shape: BoxShape.circle),
                    child: const Icon(Icons.emoji_events_outlined, color: C.bg, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Dernier trophée : ${s.trophyDef(latest.id).name}',
                            style: body(14, weight: FontWeight.w700)),
                        const SizedBox(height: 2),
                        Text('Débloqué le ${fullDate(latest.unlockedAt)}',
                            style: body(12, color: C.goldMuted)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _WeekCard extends StatelessWidget {
  const _WeekCard();

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final monday = today.subtract(Duration(days: today.weekday - 1));
    final days = List.generate(7, (i) => monday.add(Duration(days: i)));
    final count = days.where(s.hasSession).length;
    const labels = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];
    final doneToday = s.hasSession(today);

    return Panel(
      onTap: () {
        s.toggleSession(today);
        toast(context, doneToday ? 'Séance du jour retirée' : 'Séance du jour notée. Bien joué !');
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Expanded(
                child: Text.rich(TextSpan(children: [
                  TextSpan(text: '$count SÉANCE${count > 1 ? 'S' : ''} ', style: display(26)),
                  TextSpan(
                      text: 'NOTÉE${count > 1 ? 'S' : ''}',
                      style: display(26, color: C.muted, weight: FontWeight.w600)),
                ])),
              ),
              Text('Cette semaine', style: body(12, color: C.muted)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              for (var i = 0; i < 7; i++)
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: s.hasSession(days[i]) ? s.accent : null,
                          border: s.hasSession(days[i])
                              ? null
                              : Border.all(
                                  color: days[i] == today ? s.accent : C.dash,
                                  width: 1.5,
                                ),
                        ),
                        child: s.hasSession(days[i])
                            ? const Icon(Icons.check, size: 16, color: C.bg)
                            : null,
                      ),
                      const SizedBox(height: 6),
                      Text(labels[i],
                          style: body(11,
                              color: days[i] == today ? C.text : C.muted, weight: FontWeight.w600)),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(doneToday ? 'Touche pour retirer la séance du jour' : 'Touche pour noter ta séance du jour',
              style: body(12, color: C.muted2)),
        ],
      ),
    );
  }
}

class _CurrentChallengeCard extends StatelessWidget {
  const _CurrentChallengeCard({required this.def});
  final ChallengeDef def;

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final p = s.challenges[def.id]!;
    return Panel(
      color: s.accent,
      borderColor: null,
      radius: 22,
      padding: const EdgeInsets.all(18),
      onTap: () => s.goTab(1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text('TON DÉFI EN COURS', style: eyebrow(C.bg))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: C.bg, borderRadius: BorderRadius.circular(999)),
                child: Text('À ton rythme', style: body(12, color: s.accent, weight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(child: Text(def.name.toUpperCase(), style: display(40, color: C.bg, height: 0.95))),
              const SizedBox(width: 10),
              SizedBox(width: 110, child: MoveThumb(move: moveById[def.move]!, color: s.accent, radius: 12)),
            ],
          ),
          const SizedBox(height: 12),
          Bar(
            value: p.record / def.target,
            color: C.bg,
            track: C.bg.withValues(alpha: 0.18),
            height: 10,
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: Text('Record : ${def.fmt(p.record)} / ${def.fmt(def.target)}',
                    style: body(13, color: C.bg, weight: FontWeight.w700)),
              ),
              Text('Voir le défi →', style: body(13, color: C.bg, weight: FontWeight.w700)),
            ],
          ),
        ],
      ),
    );
  }
}

class _NoChallengeCard extends StatelessWidget {
  const _NoChallengeCard({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final accent = AppScope.of(context).accent;
    return Panel(
      color: accent,
      borderColor: null,
      radius: 22,
      padding: const EdgeInsets.all(18),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('AUCUN DÉFI EN COURS', style: eyebrow(C.bg)),
          const SizedBox(height: 12),
          Text('CHOISIS TON\nPROCHAIN DÉFI', style: display(40, color: C.bg, height: 0.95)),
          const SizedBox(height: 12),
          Text('Voir les défis →', style: body(13, color: C.bg, weight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _SkillMini extends StatelessWidget {
  const _SkillMini({required this.skill});
  final SkillDef skill;

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final pct = (s.skillProgress(skill.id) * 100).round();
    return Panel(
      radius: 16,
      padding: const EdgeInsets.all(12),
      onTap: () => Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => SkillScreen(skillId: skill.id))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MoveThumb(move: moveById[skill.steps[s.stepOf(skill.id)].move]!, color: s.accent, radius: 10),
          const SizedBox(height: 10),
          Text('$pct%', style: display(30)),
          const SizedBox(height: 8),
          Bar(value: pct / 100, color: s.accent),
          const SizedBox(height: 10),
          Text(skill.name, style: body(13, weight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}
