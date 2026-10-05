import 'package:flutter/material.dart';

import '../data.dart';
import '../theme.dart';
import 'trophies.dart';

class SkillsScreen extends StatelessWidget {
  const SkillsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
        children: [
          Text('TUTOS', style: display(40, height: 1)),
          const SizedBox(height: 4),
          Text('Chaque figure se débloque en 5 étapes.', style: body(14, color: C.muted)),
          const SizedBox(height: 18),
          for (final k in skillCatalog) ...[
            _SkillCard(skill: k, state: s),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
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
    return Panel(
      radius: 20,
      color: done ? C.goldBg : C.surface,
      borderColor: done ? C.goldBorder : C.border,
      padding: const EdgeInsets.all(16),
      onTap: () => Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => SkillScreen(skillId: skill.id))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(skill.name.toUpperCase(), style: display(28, height: 1))),
              if (done)
                const Icon(Icons.emoji_events_outlined, color: C.gold)
              else
                Text('$step/$total', style: display(22, color: C.muted)),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(spacing: 6, runSpacing: 6, children: [Chip2(skill.level), Chip2(skill.equipment)]),
          const SizedBox(height: 12),
          Bar(value: step / total, color: done ? C.gold : state.accent, height: 6),
          const SizedBox(height: 8),
          Text(
            done ? 'Maîtrisé' : 'Étape ${step + 1} : ${skill.steps[step].name}',
            style: body(13, color: done ? C.goldMuted : C.muted, weight: FontWeight.w600),
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

    return Scaffold(
      body: Column(
        children: [
          Container(
            color: C.surface2,
            width: double.infinity,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Material(
                      color: C.bg.withValues(alpha: 0.7),
                      shape: const CircleBorder(),
                      child: IconButton(
                        tooltip: 'Retour',
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back, color: C.text, size: 20),
                      ),
                    ),
                    const SizedBox(height: 28),
                    Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(done ? 'FIGURE MAÎTRISÉE' : 'ÉTAPE ${step + 1} / $total',
                              style: eyebrow(done ? C.gold : accent)),
                          const SizedBox(height: 6),
                          Text(
                            (done ? skill.steps.last.name : skill.steps[step].name).toUpperCase(),
                            style: display(32, height: 1),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            done ? skill.trophyDesc : 'Objectif : ${skill.steps[step].goal}',
                            style: body(14, color: C.muted),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              children: [
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
                for (var i = 0; i < total; i++) _StepRow(skill: skill, index: i, current: step, accent: accent),
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
                        child: Icon(Icons.undo, color: step == 0 ? C.off : C.text, semanticLabel: 'Annuler une étape'),
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
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      color: st == 'done' ? accent : C.border,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16, top: 3),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(step.name,
                      style: body(15, weight: FontWeight.w700, color: st == 'next' ? C.muted : C.text)),
                  const SizedBox(height: 2),
                  Text(meta, style: body(12, color: C.muted)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
