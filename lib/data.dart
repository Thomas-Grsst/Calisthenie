import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'poses/library.dart';

const accentOptions = [Color(0xFFC8F03C), Color(0xFFFF7A3D), Color(0xFF5AA9FF)];
const accentNames = ['Craie', 'Orange', 'Bleu'];

class StepDef {
  const StepDef(this.move, this.goal, [this.name]);
  final String move;
  final String goal;
  final String? name;
}

class SkillDef {
  const SkillDef({
    required this.id,
    required this.name,
    required this.level,
    required this.wow,
    required this.equipment,
    required this.muscles,
    required this.trophyDesc,
    required this.steps,
  });
  final String id, name, level, equipment, muscles, trophyDesc;
  final int wow;
  final List<StepDef> steps;
}

class ChallengeDef {
  const ChallengeDef({
    required this.id,
    required this.name,
    required this.short,
    required this.category,
    required this.tag,
    required this.level,
    required this.target,
    required this.unit,
    required this.move,
  });
  final String id, name, short, category, tag, unit, move;
  final int level, target;

  bool get timed => unit == 's';
  List<int> get paliers => List.generate(6, (i) => (target * (i + 1) / 6).round());
  String fmt(int v) => timed ? '$v s' : '$v';
  String fmtUnit(int v) => timed ? '$v s' : '$v rep${v > 1 ? 's' : ''}';
}

const skillCatalog = [
  SkillDef(
    id: 'muscleup',
    name: 'Muscle-up',
    level: 'Intermédiaire',
    wow: 5,
    equipment: 'Barre fixe',
    muscles: 'Dos · Triceps',
    trophyDesc: 'Ton tout premier, strict, à la barre fixe.',
    steps: [
      StepDef('pullup', '3 × 10 tractions'),
      StepDef('dips', '3 × 15 dips'),
      StepDef('kippingmu', '3 × 2 avec élan'),
      StepDef('falsegripmu', '3 × 2 en false grip'),
      StepDef('strictmu', '1 muscle-up strict'),
    ],
  ),
  SkillDef(
    id: 'handstand',
    name: 'Handstand',
    level: 'Intermédiaire',
    wow: 4,
    equipment: 'Sol · Mur',
    muscles: 'Épaules · Gainage',
    trophyDesc: 'Trente secondes en équilibre, sans le mur.',
    steps: [
      StepDef('wallhs', '3 × 45 s au mur'),
      StepDef('hsshouldertaps', '3 × 10 touches'),
      StepDef('handstand', 'Kick-up + 5 s'),
      StepDef('freehs', 'Tenir 15 s'),
      StepDef('freehs', 'Tenir 30 s', 'Handstand libre 30 s'),
    ],
  ),
  SkillDef(
    id: 'hspu',
    name: 'Handstand push-up',
    level: 'Avancé',
    wow: 5,
    equipment: 'Sol · Mur · Box',
    muscles: 'Épaules · Triceps',
    trophyDesc: 'Une pompe complète tête en bas.',
    steps: [
      StepDef('pikepushup', '3 × 12'),
      StepDef('pikehspu', '3 × 8 pieds sur la box'),
      StepDef('wallhs', '3 × 60 s au mur'),
      StepDef('hspu', '3 × 3 au mur', 'HSPU au mur'),
      StepDef('hspu', '5 répétitions', 'HSPU complet'),
    ],
  ),
  SkillDef(
    id: 'frontlever',
    name: 'Front lever',
    level: 'Avancé',
    wow: 5,
    equipment: 'Barre fixe',
    muscles: 'Dos · Abdos',
    trophyDesc: 'Le corps à l’horizontale, bras tendus, face au ciel.',
    steps: [
      StepDef('tuckfl', '3 × 10 s'),
      StepDef('advtuckfl', '3 × 10 s'),
      StepDef('onelegfl', '3 × 8 s'),
      StepDef('straddlefl', '3 × 5 s'),
      StepDef('fullfl', 'Tenir 5 s'),
    ],
  ),
  SkillDef(
    id: 'humanflag',
    name: 'Human flag',
    level: 'Avancé',
    wow: 5,
    equipment: 'Poteau · Espalier',
    muscles: 'Obliques · Épaules',
    trophyDesc: 'Le drapeau humain, à l’horizontale sur le poteau.',
    steps: [
      StepDef('sideplank', '3 × 60 s par côté'),
      StepDef('tuckflag', '3 × 5 s'),
      StepDef('straddleflag', '3 × 4 s'),
      StepDef('flagraises', '3 × 3 montées'),
      StepDef('humanflag', 'Tenir 5 s'),
    ],
  ),
  SkillDef(
    id: 'backlever',
    name: 'Back lever',
    level: 'Intermédiaire / avancé',
    wow: 4,
    equipment: 'Barre · Anneaux',
    muscles: 'Épaules · Dos · Biceps',
    trophyDesc: 'Horizontal, face au sol, bras tendus derrière toi.',
    steps: [
      StepDef('skinthecat', '3 × 3 lents'),
      StepDef('tuckbl', '3 × 10 s'),
      StepDef('advtuckbl', '3 × 10 s'),
      StepDef('straddlebl', '3 × 6 s'),
      StepDef('fullbl', 'Tenir 5 s'),
    ],
  ),
  SkillDef(
    id: 'lsit',
    name: 'L-sit',
    level: 'Débutant / intermédiaire',
    wow: 3,
    equipment: 'Parallettes · Sol',
    muscles: 'Abdos · Fléchisseurs · Triceps',
    trophyDesc: 'L’équerre parfaite, jambes tendues.',
    steps: [
      StepDef('hollow', '3 × 30 s'),
      StepDef('compression', '3 × 10 s'),
      StepDef('tucklsit', '3 × 15 s'),
      StepDef('lsit', 'Tenir 10 s', 'L-sit 10 s'),
      StepDef('lsit', 'Tenir 20 s', 'L-sit 20 s'),
    ],
  ),
  SkillDef(
    id: 'vsit',
    name: 'V-sit',
    level: 'Avancé',
    wow: 4,
    equipment: 'Sol · Parallettes',
    muscles: 'Compression · Épaules',
    trophyDesc: 'Les jambes au-dessus de l’horizontale, en V.',
    steps: [
      StepDef('lsit', 'Tenir 30 s', 'L-sit 30 s'),
      StepDef('compression', '3 × 15 s'),
      StepDef('pancake', '3 × 60 s de mobilité'),
      StepDef('vsit', 'Tenir 3 s', 'V-sit 3 s'),
      StepDef('vsit', 'Tenir 10 s', 'V-sit 10 s'),
    ],
  ),
  SkillDef(
    id: 'planche',
    name: 'Planche',
    level: 'Très avancé',
    wow: 5,
    equipment: 'Sol · Parallettes',
    muscles: 'Épaules · Gainage',
    trophyDesc: 'Le corps à l’horizontale, en appui sur les mains.',
    steps: [
      StepDef('planchelean', '3 × 30 s'),
      StepDef('tuckpl', '3 × 10 s'),
      StepDef('advtuckpl', '3 × 8 s'),
      StepDef('straddlepl', '3 × 4 s'),
      StepDef('fullpl', 'Tenir 3 s'),
    ],
  ),
  SkillDef(
    id: 'oap',
    name: 'One-arm pull-up',
    level: 'Très avancé',
    wow: 5,
    equipment: 'Barre fixe · Sangle',
    muscles: 'Dos · Biceps · Avant-bras',
    trophyDesc: 'Le menton au-dessus de la barre, un seul bras.',
    steps: [
      StepDef('pullup', '3 × 15 tractions'),
      StepDef('archerpullup', '3 × 5 par côté'),
      StepDef('assistedoap', '3 × 3 par côté'),
      StepDef('oachinup', '1 par côté'),
      StepDef('oap', '1 par côté'),
    ],
  ),
];

const challengeCatalog = [
  ChallengeDef(id: 'tractions15', name: '15 tractions d’affilée', short: '15 tractions', category: 'Barre fixe', tag: '15', level: 2, target: 15, unit: 'reps', move: 'pullup'),
  ChallengeDef(id: 'gainage60', name: 'Tenir 1 min en gainage', short: 'Gainage 1 min', category: 'Gainage', tag: '1:00', level: 1, target: 60, unit: 's', move: 'plank'),
  ChallengeDef(id: 'lsit20', name: 'Tenir 20 s en L-sit', short: 'L-sit 20 s', category: 'Barres parallèles', tag: 'L-sit', level: 2, target: 20, unit: 's', move: 'lsit'),
  ChallengeDef(id: 'pompes50', name: '50 pompes d’affilée', short: '50 pompes', category: 'Sol', tag: '50', level: 1, target: 50, unit: 'reps', move: 'pushup'),
  ChallengeDef(id: 'dips20', name: '20 dips d’affilée', short: 'Dips 20 reps', category: 'Barres parallèles', tag: 'DIP', level: 2, target: 20, unit: 'reps', move: 'dips'),
  ChallengeDef(id: 'hollow60', name: 'Hollow hold 1 min', short: 'Hollow 1 min', category: 'Gainage', tag: 'HOL', level: 1, target: 60, unit: 's', move: 'hollow'),
  ChallengeDef(id: 'wallhs60', name: 'Handstand au mur 1 min', short: 'Mur 1 min', category: 'Équilibre', tag: 'HS', level: 2, target: 60, unit: 's', move: 'wallhs'),
  ChallengeDef(id: 'pistol10', name: '10 pistol squats par jambe', short: '10 pistols', category: 'Jambes', tag: 'PIS', level: 3, target: 10, unit: 'reps', move: 'pistol'),
];

class ChallengeProgress {
  ChallengeProgress({required this.startedAt, this.record = 0, this.attempts = 0, this.doneAt});
  DateTime startedAt;
  int record;
  int attempts;
  DateTime? doneAt;
  bool get done => doneAt != null;

  Map<String, dynamic> toJson() => {
        'startedAt': startedAt.toIso8601String(),
        'record': record,
        'attempts': attempts,
        'doneAt': doneAt?.toIso8601String(),
      };

  factory ChallengeProgress.fromJson(Map<String, dynamic> j) => ChallengeProgress(
        startedAt: DateTime.parse(j['startedAt'] as String),
        record: j['record'] as int? ?? 0,
        attempts: j['attempts'] as int? ?? 0,
        doneAt: j['doneAt'] == null ? null : DateTime.parse(j['doneAt'] as String),
      );
}

class Trophy {
  Trophy({required this.id, required this.unlockedAt, required this.path, this.note = '', this.place = ''});
  final String id;
  final DateTime unlockedAt;
  final String path;
  String note;
  String place;

  Map<String, dynamic> toJson() =>
      {'id': id, 'unlockedAt': unlockedAt.toIso8601String(), 'path': path, 'note': note, 'place': place};

  factory Trophy.fromJson(Map<String, dynamic> j) => Trophy(
        id: j['id'] as String,
        unlockedAt: DateTime.parse(j['unlockedAt'] as String),
        path: j['path'] as String? ?? '',
        note: j['note'] as String? ?? '',
        place: j['place'] as String? ?? '',
      );
}

class TrophyDef {
  const TrophyDef(this.id, this.name, this.desc, this.isSkill, this.sourceId);
  final String id, name, desc, sourceId;
  final bool isSkill;
}

class AttemptResult {
  const AttemptResult(this.improved, this.trophy);
  final bool improved;
  final Trophy? trophy;
}

String dayKey(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

String stepName(StepDef s) => s.name ?? moveById[s.move]!.name;

int _daysSince(DateTime start) => DateTime.now().difference(start).inDays + 1;

class AppState extends ChangeNotifier {
  static const _key = 'chalk_state_v1';
  SharedPreferences? _prefs;

  String name = '';
  int accentIndex = 0;
  final Map<String, int> skillStep = {};
  final Map<String, DateTime> skillStarted = {};
  final Map<String, ChallengeProgress> challenges = {};
  final Map<String, Trophy> trophies = {};
  final Set<String> sessionDays = {};
  int tab = 0;

  Color get accent => accentOptions[accentIndex];

  Future<void> load() async {
    _prefs = await SharedPreferences.getInstance();
    final raw = _prefs!.getString(_key);
    if (raw == null) return;
    try {
      final j = jsonDecode(raw) as Map<String, dynamic>;
      name = j['name'] as String? ?? '';
      accentIndex = (j['accent'] as int? ?? 0).clamp(0, accentOptions.length - 1);
      (j['skillStep'] as Map<String, dynamic>? ?? {}).forEach((k, v) => skillStep[k] = v as int);
      (j['skillStarted'] as Map<String, dynamic>? ?? {})
          .forEach((k, v) => skillStarted[k] = DateTime.parse(v as String));
      (j['challenges'] as Map<String, dynamic>? ?? {})
          .forEach((k, v) => challenges[k] = ChallengeProgress.fromJson(v as Map<String, dynamic>));
      for (final t in (j['trophies'] as List? ?? [])) {
        final trophy = Trophy.fromJson(t as Map<String, dynamic>);
        trophies[trophy.id] = trophy;
      }
      sessionDays.addAll((j['sessions'] as List? ?? []).cast<String>());
      // Nettoie ce qui ne correspond plus au catalogue (anciennes versions).
      bool skill(String k) => skillCatalog.any((s) => s.id == k);
      skillStep.removeWhere((k, _) => !skill(k));
      skillStarted.removeWhere((k, _) => !skill(k));
      challenges.removeWhere((k, _) => !challengeCatalog.any((c) => c.id == k));
      final known = trophyDefs.map((t) => t.id).toSet();
      trophies.removeWhere((k, _) => !known.contains(k));
    } catch (_) {
      // Données corrompues : on repart de zéro plutôt que de planter.
    }
  }

  void _commit() {
    _prefs?.setString(
      _key,
      jsonEncode({
        'name': name,
        'accent': accentIndex,
        'skillStep': skillStep,
        'skillStarted': skillStarted.map((k, v) => MapEntry(k, v.toIso8601String())),
        'challenges': challenges.map((k, v) => MapEntry(k, v.toJson())),
        'trophies': trophies.values.map((t) => t.toJson()).toList(),
        'sessions': sessionDays.toList(),
      }),
    );
    notifyListeners();
  }

  void goTab(int i) {
    tab = i;
    notifyListeners();
  }

  void setName(String v) {
    name = v.trim();
    _commit();
  }

  void setAccent(int i) {
    accentIndex = i;
    _commit();
  }

  // Séances
  bool hasSession(DateTime d) => sessionDays.contains(dayKey(d));

  void toggleSession(DateTime d) {
    final k = dayKey(d);
    if (!sessionDays.remove(k)) sessionDays.add(k);
    _commit();
  }

  void _markToday() => sessionDays.add(dayKey(DateTime.now()));

  // Défis
  ChallengeDef challengeDef(String id) => challengeCatalog.firstWhere((c) => c.id == id);

  List<ChallengeDef> get activeChallenges => challengeCatalog.where((c) {
        final p = challenges[c.id];
        return p != null && !p.done;
      }).toList()
        ..sort((a, b) => challenges[a.id]!.startedAt.compareTo(challenges[b.id]!.startedAt));

  List<ChallengeDef> get discoverChallenges =>
      challengeCatalog.where((c) => challenges[c.id] == null).toList();

  List<ChallengeDef> get doneChallenges =>
      challengeCatalog.where((c) => challenges[c.id]?.done ?? false).toList();

  void startChallenge(String id) {
    challenges[id] = ChallengeProgress(startedAt: DateTime.now());
    _commit();
  }

  void abandonChallenge(String id) {
    challenges.remove(id);
    _commit();
  }

  AttemptResult logAttempt(String id, int value) {
    final def = challengeDef(id);
    final p = challenges.putIfAbsent(id, () => ChallengeProgress(startedAt: DateTime.now()));
    p.attempts++;
    final improved = value > p.record;
    if (improved) p.record = value;
    _markToday();
    Trophy? trophy;
    if (!p.done && p.record >= def.target) {
      p.doneAt = DateTime.now();
      trophy = _unlock('c:$id',
          '${p.attempts} tentative${p.attempts > 1 ? 's' : ''} · ${_daysSince(p.startedAt)} j');
    }
    _commit();
    return AttemptResult(improved, trophy);
  }

  // Figures
  SkillDef skillDef(String id) => skillCatalog.firstWhere((s) => s.id == id);
  int stepOf(String id) => skillStep[id] ?? 0;
  bool skillDone(String id) => stepOf(id) >= skillDef(id).steps.length;
  double skillProgress(String id) => stepOf(id) / skillDef(id).steps.length;

  List<SkillDef> get nextSkills {
    final list = skillCatalog.where((s) => !skillDone(s.id)).toList()
      ..sort((a, b) => stepOf(b.id).compareTo(stepOf(a.id)));
    return list.take(3).toList();
  }

  int get masteredSkills => skillCatalog.where((s) => skillDone(s.id)).length;

  Trophy? validateStep(String id) {
    final def = skillDef(id);
    final step = stepOf(id);
    if (step >= def.steps.length) return null;
    if (step == 0 || !skillStarted.containsKey(id)) skillStarted[id] = DateTime.now();
    skillStep[id] = step + 1;
    _markToday();
    Trophy? trophy;
    if (step + 1 == def.steps.length) {
      trophy = _unlock('s:$id', '${def.steps.length} étapes · ${_daysSince(skillStarted[id]!)} j');
    }
    _commit();
    return trophy;
  }

  void undoStep(String id) {
    final step = stepOf(id);
    if (step == 0) return;
    if (step == skillDef(id).steps.length) trophies.remove('s:$id');
    skillStep[id] = step - 1;
    _commit();
  }

  // Trophées
  List<TrophyDef> get trophyDefs => [
        for (final s in skillCatalog) TrophyDef('s:${s.id}', s.name, s.trophyDesc, true, s.id),
        for (final c in challengeCatalog)
          TrophyDef('c:${c.id}', c.short, 'Défi « ${c.name} » relevé.', false, c.id),
      ];

  String trophyMove(String id) {
    final d = trophyDef(id);
    return d.isSkill ? skillDef(d.sourceId).steps.last.move : challengeDef(d.sourceId).move;
  }

  TrophyDef trophyDef(String id) => trophyDefs.firstWhere((t) => t.id == id);

  List<Trophy> get unlockedSorted =>
      trophies.values.toList()..sort((a, b) => b.unlockedAt.compareTo(a.unlockedAt));

  int trophyNumber(String id) {
    final asc = unlockedSorted.reversed.toList();
    return asc.indexWhere((t) => t.id == id) + 1;
  }

  void updateTrophy(String id, {String? note, String? place}) {
    final t = trophies[id];
    if (t == null) return;
    if (note != null) t.note = note;
    if (place != null) t.place = place.trim();
    _commit();
  }

  Trophy _unlock(String id, String path) {
    final t = Trophy(id: id, unlockedAt: DateTime.now(), path: path);
    trophies[id] = t;
    return t;
  }

  void resetAll() {
    name = '';
    skillStep.clear();
    skillStarted.clear();
    challenges.clear();
    trophies.clear();
    sessionDays.clear();
    _commit();
  }
}

class AppScope extends InheritedNotifier<AppState> {
  const AppScope({super.key, required AppState super.notifier, required super.child});

  static AppState of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppScope>()!.notifier!;

  static AppState read(BuildContext context) =>
      context.getInheritedWidgetOfExactType<AppScope>()!.notifier!;
}

// Dates en français, sans dépendre de l'initialisation d'intl.
const _days = ['lundi', 'mardi', 'mercredi', 'jeudi', 'vendredi', 'samedi', 'dimanche'];
const _daysShort = ['Lun.', 'Mar.', 'Mer.', 'Jeu.', 'Ven.', 'Sam.', 'Dim.'];
const _months = [
  'janvier', 'février', 'mars', 'avril', 'mai', 'juin',
  'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre',
];
const _monthsShort = [
  'janv.', 'févr.', 'mars', 'avr.', 'mai', 'juin',
  'juil.', 'août', 'sept.', 'oct.', 'nov.', 'déc.',
];

String longDate(DateTime d) {
  final day = _days[d.weekday - 1];
  return '${day[0].toUpperCase()}${day.substring(1)} ${d.day} ${_months[d.month - 1]}';
}

String shortDate(DateTime d) => '${_daysShort[d.weekday - 1]} ${d.day} ${_monthsShort[d.month - 1]} ${d.year}';
String fullDate(DateTime d) => '${d.day} ${_months[d.month - 1]} ${d.year}';
String hourLabel(DateTime d) => '${d.hour} h ${d.minute.toString().padLeft(2, '0')}';
String monthShort(DateTime d) => _monthsShort[d.month - 1];
