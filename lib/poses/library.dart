// Bibliothèque des mouvements : chaque mouvement a ses positions clés
// (départ, milieu éventuel, fin), dessinées par le moteur de poses.
import 'skeleton.dart';

class Phase {
  const Phase(this.label, this.pose, this.cue);
  final String label;
  final Pose pose;
  final String cue;
}

class Move {
  const Move(this.id, this.name, this.level, this.gear, this.desc, this.phases, {this.aka});
  final String id, name, level, gear, desc;
  final String? aka;
  final List<Phase> phases;
}

class MoveCategory {
  const MoveCategory(this.id, this.name, this.color, this.ids);
  final String id, name;
  final int color;
  final List<String> ids;
}

Phase _d(Pose p, String cue) => Phase('Départ', p, cue);
Phase _m(Pose p, String cue, [String label = 'Milieu']) => Phase(label, p, cue);
Phase _f(Pose p, String cue) => Phase('Fin', p, cue);

const F = kFloor;
const _deb = 'Débutant', _int = 'Intermédiaire', _av = 'Avancé', _tav = 'Très avancé', _eli = 'Élite';

// ───────────────────────── Familles de poses ─────────────────────────

Pose _stand({
  double x = 60,
  double y = F,
  double t = 0,
  double hd = 0,
  List<double> a = const [180, 180],
  List<double>? af,
  List<double> l = const [180, 180],
  List<double>? lf,
  double ft = -90,
  List<Eq> eq = const [flo],
  Map<J, V> extra = const {},
  int chest = 1,
}) =>
    Pose(
      hx: x,
      hy: y - 41,
      t: t,
      hd: hd,
      a: a,
      af: af,
      l: l,
      lf: lf,
      ft: ft,
      eq: eq,
      chest: chest,
      pin: {J.anN: V(x, y), if (lf == null) J.anF: V(x, y), ...extra},
    );

Pose _plank({
  required V hand,
  required V toe,
  double t = 66,
  List<double> a = const [180, 180],
  List<double>? af,
  List<double>? l,
  List<Eq> eq = const [flo],
  Map<J, V> extra = const {},
  double? hy,
  double ft = -90,
}) {
  final hip = V.lerp(toe, hand, 0.5);
  return Pose(
    hx: hip.x,
    hy: hy ?? hip.y - 8,
    t: t,
    a: a,
    af: af,
    l: l ?? [t + 180, t + 180],
    ft: ft,
    eq: eq,
    pin: {J.toeN: toe, J.toeF: toe, J.wrN: hand, if (af == null) J.wrF: hand, ...extra},
  );
}

Pose _hang({
  double bx = 65,
  double by = 10,
  double t = 0,
  double hd = 0,
  List<double> a = const [12, 8],
  List<double>? af,
  List<double> l = const [180, 180],
  List<double>? lf,
  double ft = -90,
  double? hx,
  double? hy,
  int chest = 1,
  bool pinF = true,
  List<Eq>? eq,
  Map<J, V> extra = const {},
}) =>
    Pose(
      hx: hx ?? bx,
      hy: hy ?? by + 57,
      t: t,
      hd: hd,
      a: a,
      af: af,
      l: l,
      lf: lf,
      ft: ft,
      chest: chest,
      eq: eq ?? [bar(bx, by)],
      pin: {J.wrN: V(bx, by), if (pinF) J.wrF: V(bx, by), ...extra},
    );

Pose _hs({
  double x = 65,
  double y = F,
  double t = 180,
  double hd = 0,
  List<double> a = const [180, 180],
  List<double>? af,
  List<double> l = const [0, 0],
  List<double>? lf,
  double ft = 0,
  List<Eq> eq = const [flo],
  int chest = -1,
  bool pinF = true,
  Map<J, V> extra = const {},
  double? hx,
  double? hy,
}) =>
    Pose(
      hx: hx ?? x,
      hy: hy ?? y - 57,
      t: t,
      hd: hd,
      a: a,
      af: af,
      l: l,
      lf: lf,
      ft: ft,
      chest: chest,
      eq: eq,
      pin: {J.wrN: V(x, y), if (pinF) J.wrF: V(x, y), ...extra},
    );

Pose _pl({
  double x = 70,
  double y = F,
  List<double> a = const [205, 205],
  List<double> l = const [270, 270],
  List<double>? lf,
  double t = 90,
  double? hy,
  List<Eq> eq = const [flo],
  Map<J, V> extra = const {},
}) =>
    Pose(
      hx: x - 30,
      hy: hy ?? y - 27,
      t: t,
      a: a,
      l: l,
      lf: lf,
      ft: 0,
      eq: eq,
      pin: {...hands(x, y), ...extra},
    );

// Front lever / back lever : barre en (55, 38), corps horizontal vers la droite.
Pose _lever({
  required int chest,
  List<double> l = const [90, 90],
  List<double>? lf,
  List<double> a = const [5, 5],
  List<double>? af,
  bool pinF = true,
  double bx = 55,
  double by = 38,
  double? hy,
  List<Eq>? eq,
}) =>
    Pose(
      hx: bx + 26,
      hy: hy ?? by + 29,
      t: 270,
      a: a,
      af: af,
      l: l,
      lf: lf,
      ft: 0,
      chest: chest,
      eq: eq ?? [bar(bx, by)],
      pin: {J.wrN: V(bx, by), if (pinF) J.wrF: V(bx, by)},
    );

Pose _invHang({double bx = 55, double by = 38, List<double> l = const [0, 0], int chest = -1, List<Eq>? eq}) =>
    Pose(
      hx: bx + 4,
      hy: by + 1,
      t: 180,
      a: const [0, 0],
      l: l,
      ft: 0,
      chest: chest,
      eq: eq ?? [bar(bx, by)],
      pin: hands(bx, by),
    );

// Appui au-dessus d'une barre (muscle-up, dips).
Pose _support({double bx = 65, double by = 30, List<double> l = const [185, 185], List<Eq>? eq, double t = 0}) =>
    Pose(
      hx: bx - 2,
      hy: by - 1,
      t: t,
      a: const [180, 180],
      l: l,
      eq: eq ?? [bar(bx, by)],
      pin: hands(bx, by),
    );

Pose _flag({
  List<double> l = const [90, 90],
  List<double>? lf,
  double t = 270,
  List<double> a = const [335, 335],
  List<double> af = const [215, 215],
  double hy = 55,
}) =>
    Pose(
      hx: 72,
      hy: hy,
      t: t,
      a: a,
      af: af,
      l: l,
      lf: lf,
      ft: 0,
      chest: 0,
      eq: [pole(35), flo],
      pin: {J.wrN: const V(36, 38), J.wrF: const V(36, 70)},
    );

// ───────────────────────── Poses partagées ─────────────────────────

final _pushTop = _plank(hand: const V(90, F), toe: const V(28, F), t: 66);
final _pushBot = _plank(hand: const V(90, F), toe: const V(28, F), t: 82, a: const [295, 150]);
final _pushBotAir = Pose(hx: 60, hy: 70, t: 82, a: const [180, 180], l: const [262, 262], ft: -60, eq: const [flo]);

final _hangP = _hang();
final _pullMid = _hang(a: const [95, 5], hx: 52, hy: 52);
final _pullTop = _hang(a: const [148, 22], hx: 60, hy: 38, l: const [185, 185]);

final _squatBot = Pose(hx: 50, hy: 80, t: 40, a: const [95, 95], l: const [110, 205], pin: feet(62, F));
final _standP = _stand();

final _dipTop = Pose(hx: 63, hy: 57, t: 0, a: const [180, 180], l: const [175, 235], pin: hands(65, 58), eq: [pbars(40, 92, 58), flo]);
final _dipBot = Pose(hx: 62, hy: 76, t: 25, a: const [285, 155], l: const [170, 230], pin: hands(65, 58), eq: [pbars(40, 92, 58), flo]);

final _hsP = _hs();
final _kickUp = _hs(t: 195, l: const [25, 25], lf: const [215, 200], hy: 62);
final _lunge = Pose(hx: 50, hy: 70, t: 12, a: const [10, 10], l: const [120, 180], lf: const [215, 225], pin: {J.anN: const V(70, F), J.anF: const V(28, F)});
final _hspuBot = _hs(a: const [235, 140], extra: {J.head: const V(74, 97)}, hy: 70);

final _plLean = _plank(hand: const V(82, F), toe: const V(22, F), t: 74, a: const [208, 208]);
final _tuckPl = _pl(l: const [140, 268]);
final _advTuckPl = _pl(l: const [180, 270]);
final _straddlePl = _pl(l: const [266, 266]);
final _fullPl = _pl(l: const [270, 270]);
final _plBot = Pose(hx: 50, hy: 90, t: 90, a: const [275, 175], l: const [270, 270], ft: 0, pin: hands(72, F));
final _maltese = Pose(hx: 52, hy: 93, t: 90, a: const [240, 240], l: const [270, 270], ft: 0, pin: hands(62, F));

final _tuckFl = _lever(chest: 1, l: const [300, 100]);
final _advTuckFl = _lever(chest: 1, l: const [5, 92]);
final _fullFl = _lever(chest: 1);
final _hangFl = _hang(bx: 55, by: 38);
final _invFl = _invHang();
final _flPulled = Pose(hx: 76, hy: 46, t: 270, a: const [150, 20], l: const [90, 90], ft: 0, chest: 1, eq: [bar(55, 38)], pin: hands(55, 38));

final _tuckBl = _lever(chest: -1, l: const [235, 88], a: const [355, 355]);
final _advTuckBl = _lever(chest: -1, l: const [178, 90], a: const [355, 355]);
final _fullBl = _lever(chest: -1, a: const [355, 355]);
final _germanHang = Pose(hx: 70, hy: 90, t: 15, a: const [340, 340], l: const [185, 185], chest: 1, eq: [bar(55, 38)], pin: hands(55, 38));

final _muHang = _hang(by: 30);
final _muPull = _hang(by: 30, a: const [165, 25], hx: 60, hy: 58, l: const [195, 195]);
final _muTrans = Pose(hx: 58, hy: 48, t: 20, a: const [235, 95], l: const [190, 190], pin: hands(65, 30), eq: [bar(65, 30)]);
final _muSup = _support();

final _flagP = _flag();

// ───────────────────────── Mouvements ─────────────────────────

final List<Move> moves = [
  // ---------- Fondamentaux ----------
  Move('pushup', 'Pompes', _deb, 'Sol', 'Le mouvement de poussée de base : corps gainé, de la tête aux talons.', [
    _d(_pushTop, 'Bras tendus, mains sous les épaules, corps aligné.'),
    _f(_pushBot, 'Descends la poitrine près du sol, coudes vers l’arrière, puis repousse.'),
  ], aka: 'Push-up'),
  Move('diamondpushup', 'Pompes diamant', _deb, 'Sol', 'Mains rapprochées en losange sous la poitrine : cible les triceps.', [
    _d(_pushTop, 'Pouces et index se touchent en forme de diamant sous le sternum.'),
    _f(_pushBot, 'Descends en gardant les coudes collés au corps.'),
  ], aka: 'Diamond push-up'),
  Move('widepushup', 'Pompes mains larges', _deb, 'Sol', 'Mains plus larges que les épaules : plus de pectoraux.', [
    _d(_pushTop, 'Mains écartées une fois et demie la largeur d’épaules.'),
    _f(_pushBot, 'Descends poitrine entre les mains, coudes ouverts à 45°.'),
  ], aka: 'Wide push-up'),
  Move('archerpushup', 'Pompes archer', _int, 'Sol', 'Une main travaille, l’autre bras reste tendu sur le côté : vers la pompe à un bras.', [
    _d(_plank(hand: const V(90, F), toe: const V(28, F), t: 66, af: const [150, 150], extra: {J.wrF: const V(112, F)}), 'Mains très écartées, bras tendus.'),
    _f(_plank(hand: const V(90, F), toe: const V(28, F), t: 82, a: const [295, 150], af: const [110, 110], extra: {J.wrF: const V(118, F)}), 'Descends vers une main, l’autre bras reste tendu comme une corde d’arc.'),
  ], aka: 'Archer push-up'),
  Move('declinepushup', 'Pompes déclinées', _int, 'Sol · Banc', 'Pieds surélevés : plus de charge sur les épaules et le haut des pectoraux.', [
    _d(_plank(hand: const V(92, F), toe: const V(30, 78), t: 58, eq: [flo, box(4, 32, 78)]), 'Pieds sur le banc, corps gainé, bras tendus.'),
    _f(_plank(hand: const V(92, F), toe: const V(30, 78), t: 72, a: const [300, 150], eq: [flo, box(4, 32, 78)]), 'Descends le front vers le sol devant les mains.'),
  ], aka: 'Decline push-up'),
  Move('pikepushup', 'Pompes piquées', _deb, 'Sol', 'Hanches hautes, corps en V inversé : la porte d’entrée du handstand push-up.', [
    _d(Pose(hx: 56, hy: 62, t: 140, a: const [172, 172], l: const [215, 215], pin: {...hands(86, F), ...toes(34, F)}), 'Hanches hautes, bras et jambes tendus, tête entre les bras.'),
    _f(Pose(hx: 58, hy: 66, t: 158, a: const [235, 125], l: const [212, 212], pin: {...hands(86, F), ...toes(34, F)}), 'Plie les coudes et descends le sommet du crâne devant les mains.'),
  ], aka: 'Pike push-up'),
  Move('hindupushup', 'Pompes hindoues', _int, 'Sol', 'Un mouvement fluide en vague, du chien tête en bas au chien tête en haut.', [
    _d(Pose(hx: 56, hy: 62, t: 140, a: const [172, 172], l: const [215, 215], pin: {...hands(86, F), ...toes(34, F)}), 'Chien tête en bas : hanches hautes, bras tendus.'),
    _m(Pose(hx: 58, hy: 86, t: 84, a: const [295, 150], l: const [250, 250], pin: {...hands(86, F), ...toes(34, F)}), 'Plonge : la poitrine rase le sol vers l’avant.'),
    _f(Pose(hx: 55, hy: 95, t: 42, a: const [180, 180], l: const [262, 262], hd: -20, pin: {...hands(80, F), ...toes(22, F)}), 'Chien tête en haut : bras tendus, poitrine ouverte, hanches basses.'),
  ], aka: 'Hindu push-up'),
  Move('pseudoplanchepushup', 'Pompes pseudo-planche', _int, 'Sol', 'Mains au niveau de la taille, épaules projetées en avant : prépare la planche.', [
    _d(_plank(hand: const V(80, F), toe: const V(22, F), t: 72, a: const [205, 205]), 'Mains tournées vers l’extérieur, épaules devant les mains.'),
    _f(_plank(hand: const V(80, F), toe: const V(22, F), t: 84, a: const [285, 150]), 'Descends en gardant les épaules en avant des mains.'),
  ], aka: 'Pseudo planche push-up'),
  Move('pullup', 'Tractions', _deb, 'Barre fixe', 'Le tirage roi : mains en pronation, menton au-dessus de la barre.', [
    _d(_hangP, 'Suspendu bras tendus, mains en pronation, épaules engagées.'),
    _m(_pullMid, 'Tire les coudes vers les hanches.'),
    _f(_pullTop, 'Menton au-dessus de la barre, puis redescends contrôlé.'),
  ], aka: 'Pull-up'),
  Move('chinup', 'Tractions supination', _deb, 'Barre fixe', 'Paumes vers soi : plus de biceps, souvent plus facile que la traction.', [
    _d(_hangP, 'Paumes tournées vers toi, largeur d’épaules.'),
    _m(_pullMid, 'Tire en gardant les coudes devant toi.'),
    _f(_pullTop, 'Menton au-dessus de la barre, poitrine vers la barre.'),
  ], aka: 'Chin-up'),
  Move('neutralpullup', 'Tractions prise neutre', _deb, 'Barre parallèle', 'Paumes face à face : la prise la plus douce pour les épaules.', [
    _d(_hangP, 'Paumes face à face, bras tendus.'),
    _f(_pullTop, 'Tire jusqu’au menton au-dessus des poignées.'),
  ], aka: 'Neutral-grip pull-up'),
  Move('widepullup', 'Tractions prise large', _int, 'Barre fixe', 'Mains très écartées : accent sur le grand dorsal.', [
    _d(_hangP, 'Mains à une fois et demie la largeur d’épaules.'),
    _f(_pullTop, 'Tire la poitrine vers la barre, coudes vers le bas et l’extérieur.'),
  ], aka: 'Wide pull-up'),
  Move('closepullup', 'Tractions prise serrée', _int, 'Barre fixe', 'Mains collées : plus de bras, amplitude plus longue.', [
    _d(_hangP, 'Mains presque collées au centre.'),
    _f(_pullTop, 'Monte jusqu’à ce que la barre touche le haut de la poitrine.'),
  ], aka: 'Close-grip pull-up'),
  Move('archerpullup', 'Tractions archer', _av, 'Barre fixe', 'Tu tires vers une main pendant que l’autre bras reste tendu.', [
    _d(_hang(a: const [330, 330], af: const [30, 30], pinF: true, chest: 0, eq: [hbar(30, 100, 10)], extra: {J.wrN: const V(48, 10), J.wrF: const V(82, 10)}), 'Vue de face : prise très large, bras tendus.'),
    _f(Pose(hx: 50, hy: 48, t: 0, a: const [220, 340], af: const [60, 60], chest: 0, eq: [hbar(30, 100, 10)], pin: {J.wrN: const V(48, 10), J.wrF: const V(82, 10)}), 'Monte vers une main ; l’autre bras reste tendu le long de la barre.'),
  ], aka: 'Archer pull-up'),
  Move('australianpullup', 'Tractions australiennes', _deb, 'Barre basse', 'Rowing au poids du corps, pieds au sol : idéal pour débuter le tirage.', [
    _d(Pose(hx: 57, hy: 87, t: 65, a: const [335, 335], l: const [245, 245], ft: 90, chest: -1, pin: {...hands(70, 49), ...feet(20, F)}, eq: [flo, lowbar(70, 49)]), 'Sous la barre, bras tendus, corps gainé, talons au sol.'),
    _f(Pose(hx: 52, hy: 80, t: 48, a: const [235, 45], l: const [228, 228], ft: 90, chest: -1, pin: {...hands(70, 49), ...feet(20, F)}, eq: [flo, lowbar(70, 49)]), 'Tire la poitrine jusqu’à la barre, omoplates serrées.'),
  ], aka: 'Australian pull-up'),
  Move('dips', 'Dips', _deb, 'Barres parallèles', 'La poussée verticale : triceps, pectoraux, épaules.', [
    _d(_dipTop, 'En appui bras tendus, épaules basses.'),
    _f(_dipBot, 'Descends jusqu’à 90° aux coudes en penchant le buste, puis repousse.'),
  ]),
  Move('benchdips', 'Dips sur banc', _deb, 'Banc', 'Version accessible des dips, mains derrière toi sur un banc.', [
    _d(Pose(hx: 52, hy: 66, t: 0, a: const [200, 180], l: const [110, 110], pin: {...hands(44, 80), ...feet(98, F)}, eq: [flo, box(14, 44, 80)]), 'Mains sur le bord du banc, bras tendus, jambes allongées.'),
    _f(Pose(hx: 52, hy: 88, t: 0, a: const [310, 190], l: const [100, 110], pin: {...hands(44, 80), ...feet(98, F)}, eq: [flo, box(14, 44, 80)]), 'Plie les coudes vers l’arrière et descends les hanches près du sol.'),
  ], aka: 'Bench dips'),
  Move('squat', 'Squat', _deb, 'Sol', 'La base des jambes : hanches en arrière, genoux dans l’axe des pieds.', [
    _d(_standP, 'Debout, pieds largeur d’épaules.'),
    _f(_squatBot, 'Hanches sous les genoux, dos droit, bras devant pour l’équilibre.'),
  ], aka: 'Bodyweight squat'),
  Move('bulgarian', 'Squat bulgare', _int, 'Sol · Banc', 'Fente avec le pied arrière surélevé : chaque jambe travaille seule.', [
    _d(Pose(hx: 58, hy: 63, t: 0, l: const [172, 182], lf: const [205, 262], pin: {J.anN: const V(70, F), J.toeF: const V(32, 80)}, eq: [flo, box(8, 36, 80)]), 'Pied arrière posé sur le banc, buste droit.'),
    _f(Pose(hx: 54, hy: 82, t: 8, l: const [105, 190], lf: const [190, 262], pin: {J.anN: const V(70, F), J.toeF: const V(32, 80)}, eq: [flo, box(8, 36, 80)]), 'Descends jusqu’à ce que la cuisse avant soit parallèle au sol.'),
  ], aka: 'Bulgarian split squat'),
  Move('pistol', 'Pistol squat', _av, 'Sol', 'Squat complet sur une jambe, l’autre tendue devant.', [
    _d(_stand(lf: const [150, 160], a: const [90, 90]), 'Sur une jambe, l’autre légèrement décollée devant.'),
    _f(Pose(hx: 50, hy: 88, t: 28, a: const [90, 90], l: const [112, 208], lf: const [92, 92], ft: -90, pin: {J.anN: const V(60, F)}), 'Descends tout en bas, jambe libre tendue, puis remonte sans élan.'),
  ], aka: 'Pistol squat'),
  Move('lunges', 'Fentes', _deb, 'Sol', 'Un grand pas en avant, le genou arrière frôle le sol.', [
    _d(_standP, 'Debout, buste droit.'),
    _f(Pose(hx: 58, hy: 78, t: 0, l: const [115, 180], lf: const [195, 262], pin: {J.anN: const V(76, F), J.knF: const V(46, 100)}), 'Grand pas, les deux genoux à 90°, genou arrière près du sol.'),
  ], aka: 'Lunges'),
  Move('cossack', 'Squat cosaque', _int, 'Sol', 'Squat latéral profond : force et mobilité des adducteurs.', [
    _d(Pose(hx: 62, hy: 66, t: 0, a: const [165, 165], af: const [195, 195], l: const [212, 182], lf: const [148, 178], chest: 0, pin: {J.anN: const V(38, F), J.anF: const V(88, F)}), 'Vue de face : grand écart des pieds, pointes légèrement ouvertes.'),
    _f(Pose(hx: 44, hy: 90, t: 8, a: const [150, 150], l: const [250, 190], lf: const [104, 104], ft: -90, ftf: -180, chest: 0, pin: {J.anN: const V(38, F), J.anF: const V(95, F)}), 'Descends sur une jambe, l’autre reste tendue, pointe vers le ciel.'),
  ], aka: 'Cossack squat'),
  Move('nordic', 'Nordic curl', _av, 'Sol · Appui chevilles', 'Descente lente en bloquant les chevilles : ischios en béton.', [
    _d(Pose(hx: 60, hy: 80, t: 0, l: const [180, 270], pin: {J.knN: const V(60, 101), J.knF: const V(60, 101), J.anN: const V(40, 101), J.anF: const V(40, 101)}, eq: [flo, pad(40)]), 'À genoux, chevilles bloquées, corps droit des genoux à la tête.'),
    _m(Pose(hx: 72, hy: 84, t: 42, a: const [160, 160], l: const [222, 270], pin: {J.knN: const V(60, 101), J.knF: const V(60, 101), J.anN: const V(40, 101), J.anF: const V(40, 101)}, eq: [flo, pad(40)]), 'Bascule vers l’avant le plus lentement possible.'),
    _f(Pose(hx: 80, hy: 94, t: 76, a: const [170, 170], l: const [256, 270], pin: {J.knN: const V(60, 101), J.knF: const V(60, 101), J.anN: const V(40, 101), J.anF: const V(40, 101)}, eq: [flo, pad(40)]), 'Rattrape-toi avec les mains, puis remonte avec les ischios.'),
  ], aka: 'Nordic curl'),
  Move('glutebridge', 'Pont fessier', _deb, 'Sol', 'Hanches vers le ciel en serrant les fessiers.', [
    _d(Pose(hx: 54, hy: 99, t: 270, a: const [95, 95], l: const [55, 160], ft: -70, pin: {J.sh: const V(27, 98), ...feet(70, F)}), 'Allongé sur le dos, genoux pliés, pieds à plat.'),
    _f(Pose(hx: 52, hy: 84, t: 240, a: const [100, 100], l: const [80, 175], ft: -85, pin: {J.sh: const V(28, 98), ...feet(70, F)}), 'Pousse dans les talons, hanches alignées avec genoux et épaules.'),
  ], aka: 'Glute bridge'),
  Move('calfraise', 'Mollets debout', _deb, 'Sol', 'Montées sur la pointe des pieds.', [
    _d(_stand(x: 56), 'Debout, pieds à plat.'),
    _f(Pose(hx: 57, hy: 56, l: const [180, 180], ft: -38, pin: toes(62, F)), 'Monte le plus haut possible sur les orteils, tiens une seconde.'),
  ], aka: 'Calf raises'),

  // ---------- Core ----------
  Move('plank', 'Gainage planche', _deb, 'Sol', 'Sur les avant-bras, le corps en une seule ligne.', [
    _d(Pose(hx: 55, hy: 92, t: 70, a: const [180, 90], l: const [232, 292], pin: {J.elN: const V(80, 101), J.elF: const V(80, 101), J.knN: const V(46, 101), J.knF: const V(46, 101)}), 'Sur les genoux et avant-bras pour se placer.'),
    _f(Pose(hx: 58, hy: 90, t: 76, a: const [180, 90], l: const [256, 256], pin: {J.elN: const V(82, 101), J.elF: const V(82, 101), ...toes(22, F)}), 'Décolle les genoux : talons, hanches et épaules alignés.'),
  ], aka: 'Plank'),
  Move('sideplank', 'Gainage latéral', _deb, 'Sol', 'En appui sur un avant-bras, de profil : les obliques.', [
    _d(Pose(hx: 55, hy: 98, t: 72, a: const [180, 90], af: const [90, 90], l: const [255, 255], ft: -90, chest: 0, pin: {J.elN: const V(82, 101), J.anN: const V(22, 101), J.anF: const V(22, 101)}), 'Vue de face : sur le côté, coude sous l’épaule.'),
    _f(Pose(hx: 55, hy: 88, t: 68, a: const [180, 90], af: const [10, 10], l: const [252, 252], ft: -90, chest: 0, pin: {J.elN: const V(82, 101), J.anN: const V(22, 101), J.anF: const V(22, 101)}), 'Monte les hanches, bras libre vers le ciel.'),
  ], aka: 'Side plank'),
  Move('hollow', 'Hollow body', _deb, 'Sol', 'Position « banane » sur le dos : la base de tous les skills.', [
    _d(Pose(hx: 60, hy: 100, t: 270, a: const [270, 270], l: const [90, 90], ft: 0, pin: {J.hip: const V(60, 100)}), 'Allongé sur le dos, bras au-dessus de la tête.'),
    _f(Pose(hx: 60, hy: 100, t: 284, a: const [290, 290], l: const [78, 78], ft: 0, pin: {J.hip: const V(60, 100)}), 'Bas du dos plaqué, décolle épaules et jambes.'),
  ], aka: 'Hollow body hold'),
  Move('archhold', 'Superman', _deb, 'Sol', 'L’inverse du hollow : à plat ventre, tout le dos se contracte.', [
    _d(Pose(hx: 60, hy: 100, t: 270, a: const [270, 270], l: const [90, 90], ft: 0, chest: -1, pin: {J.hip: const V(60, 100)}), 'À plat ventre, bras devant.'),
    _f(Pose(hx: 60, hy: 100, t: 290, a: const [296, 296], l: const [72, 72], ft: 0, chest: -1, pin: {J.hip: const V(60, 100)}), 'Décolle bras, poitrine et jambes, regard vers le sol.'),
  ], aka: 'Arch body hold'),
  Move('lsit', 'L-sit', _int, 'Parallettes · Sol', 'Corps en équerre, jambes tendues à l’horizontale.', [
    _d(Pose(hx: 55, hy: 99, t: 0, a: const [200, 160], l: const [90, 90], ft: 0, pin: {...hands(55, 95), J.hip: const V(55, 99)}, eq: [flo, paral(55)]), 'Assis, mains sur les parallettes à côté des hanches.'),
    _f(Pose(hx: 55, hy: 93, t: 0, a: const [180, 180], l: const [90, 90], ft: 0, pin: hands(55, 95), eq: [flo, paral(55)]), 'Pousse : fesses et jambes décollent, jambes tendues à l’horizontale.'),
  ], aka: 'L-sit'),
  Move('tucklsit', 'L-sit groupé', _deb, 'Parallettes · Sol', 'Le L-sit genoux pliés : la première étape.', [
    _d(Pose(hx: 55, hy: 99, t: 0, a: const [200, 160], l: const [40, 175], pin: {...hands(55, 95), J.hip: const V(55, 99)}, eq: [flo, paral(55)]), 'Assis, genoux pliés, mains sur les parallettes.'),
    _f(Pose(hx: 55, hy: 93, t: 0, a: const [180, 180], l: const [40, 180], pin: hands(55, 95), eq: [flo, paral(55)]), 'Pousse et remonte les genoux vers la poitrine.'),
  ], aka: 'Tuck L-sit'),
  Move('vsit', 'V-sit', _av, 'Sol', 'Au-delà du L-sit : jambes au-dessus de l’horizontale, en V.', [
    _d(Pose(hx: 55, hy: 93, t: 0, a: const [180, 180], l: const [90, 90], ft: 0, pin: hands(55, 95), eq: [flo, paral(55)]), 'Pars d’un L-sit solide.'),
    _f(Pose(hx: 58, hy: 82, t: 340, a: const [195, 195], l: const [28, 28], ft: 0, pin: hands(50, 95), eq: [flo, paral(50)]), 'Pousse les épaules en arrière et monte les jambes vers le ciel.'),
  ], aka: 'V-sit'),
  Move('compression', 'Compression', _int, 'Sol', 'Assis jambes tendues, tu décolles les jambes par la seule force des fléchisseurs.', [
    _d(Pose(hx: 50, hy: 99, t: 48, a: const [150, 150], l: const [90, 90], ft: 0, pin: {J.hip: const V(50, 99), ...hands(70, F)}), 'Assis en pike, mains au sol à côté des genoux.'),
    _f(Pose(hx: 50, hy: 99, t: 42, a: const [150, 150], l: const [78, 78], ft: 0, pin: {J.hip: const V(50, 99), ...hands(68, F)}), 'Décolle les talons du sol, jambes tendues, et tiens.'),
  ], aka: 'Compression hold'),
  Move('hangkneeraise', 'Relevés de genoux', _deb, 'Barre fixe', 'Suspendu, les genoux montent vers la poitrine.', [
    _d(_hangP, 'Suspendu bras tendus, épaules engagées.'),
    _f(_hang(t: 352, l: const [85, 180]), 'Monte les genoux au-dessus des hanches sans balancer.'),
  ], aka: 'Hanging knee raise'),
  Move('hanglegraise', 'Relevés de jambes', _int, 'Barre fixe', 'Jambes tendues jusqu’à l’horizontale ou plus.', [
    _d(_hangP, 'Suspendu, jambes serrées.'),
    _f(_hang(t: 345, l: const [88, 88], ft: 0), 'Monte les jambes tendues jusqu’à l’horizontale.'),
  ], aka: 'Hanging leg raise'),
  Move('toestobar', 'Toes-to-bar', _int, 'Barre fixe', 'Les pointes de pieds viennent toucher la barre.', [
    _d(_hangP, 'Suspendu, gainé.'),
    _f(_hang(t: 318, l: const [22, 22], ft: 0, extra: toes(70, 13), hy: 45, hx: 50), 'Enroule le bassin et touche la barre avec les orteils.'),
  ], aka: 'Toes-to-bar'),
  Move('windshield', 'Essuie-glaces', _av, 'Barre fixe', 'Jambes à la barre, tu les balaies d’un côté à l’autre.', [
    _d(_hang(t: 318, l: const [22, 22], ft: 0, extra: toes(70, 13), hy: 45, hx: 50), 'Monte les pieds à la barre.'),
    _m(_hang(t: 20, l: const [300, 300], ft: 0, chest: 0, hx: 70, hy: 40), 'Vue de face : bascule les jambes d’un côté.', 'Côté 1'),
    _f(_hang(t: 340, l: const [60, 60], ft: 0, chest: 0, hx: 60, hy: 40), 'Puis de l’autre, en contrôlant.'),
  ], aka: 'Windshield wipers'),
  Move('dragonflag', 'Dragon flag', _av, 'Banc', 'Corps gainé et rigide, seul le haut du dos touche le banc.', [
    _d(Pose(hx: 62, hy: 85, t: 270, a: const [300, 300], l: const [90, 90], ft: 0, pin: {...hands(18, 86)}, eq: [flo, box(16, 104, 88)]), 'Allongé, mains agrippées au banc derrière la tête.'),
    _f(Pose(hx: 52, hy: 66, t: 232, a: const [260, 260], l: const [52, 52], ft: 0, pin: {...hands(18, 86), J.sh: const V(31, 84)}, eq: [flo, box(16, 104, 88)]), 'Monte en planche droite et redescends lentement sans plier les hanches.'),
  ], aka: 'Dragon flag'),
  Move('abwheel', 'Roue abdominale', _int, 'Roue', 'Tu déroules le corps vers l’avant en gardant le bassin en rétroversion.', [
    _d(Pose(hx: 50, hy: 82, t: 50, a: const [175, 175], l: const [205, 272], pin: {...hands(70, 97), J.knN: const V(46, 101), J.knF: const V(46, 101)}, eq: [flo, wheel(70, 98)]), 'À genoux, mains sur la roue sous les épaules.'),
    _f(Pose(hx: 70, hy: 90, t: 82, a: const [95, 95], l: const [250, 272], pin: {...hands(108, 97), J.knN: const V(46, 101), J.knF: const V(46, 101)}, eq: [flo, wheel(108, 98)]), 'Roule le plus loin possible sans creuser, puis reviens.'),
  ], aka: 'Ab wheel'),
  Move('flraises', 'Front lever raises', _av, 'Barre fixe', 'De la suspension renversée au front lever, bras tendus.', [
    _d(_invFl, 'Suspension renversée, corps à la verticale.'),
    _f(_fullFl, 'Descends le corps gainé jusqu’à l’horizontale, puis remonte.'),
  ], aka: 'Front lever raises'),

  // ---------- Handstand ----------
  Move('handstand', 'Équilibre (handstand)', _int, 'Sol', 'L’équilibre sur les mains, corps aligné et gainé.', [
    _d(_lunge, 'Fente avant, bras tendus au-dessus de la tête.'),
    _m(_kickUp, 'Pose les mains et lance la jambe arrière.', 'Kick-up'),
    _f(_hsP, 'Corps aligné, épaules poussées vers le sol, pointes tendues.'),
  ], aka: 'Handstand'),
  Move('wallhs', 'Handstand au mur', _deb, 'Mur', 'L’équilibre avec le mur comme filet de sécurité.', [
    _d(_hs(x: 76, t: 195, l: const [25, 25], lf: const [215, 200], hy: 62, eq: [flo, wall(90)]), 'Dos au mur, mains à une main du mur, kick-up.'),
    _f(_hs(x: 76, l: const [8, 8], eq: [flo, wall(90)], extra: toes(89, 4)), 'Talons contre le mur, corps gainé, regard entre les mains.'),
  ], aka: 'Wall handstand'),
  Move('freehs', 'Handstand libre', _int, 'Sol', 'Sans mur : tout se joue dans les doigts.', [
    _d(_kickUp, 'Kick-up contrôlé, sans élan excessif.'),
    _f(_hsP, 'Trouve l’équilibre en jouant des doigts et des paumes.'),
  ], aka: 'Freestanding handstand'),
  Move('hsshouldertaps', 'Handstand shoulder taps', _int, 'Mur · Sol', 'En équilibre, une main vient toucher l’épaule opposée.', [
    _d(_hs(x: 76, l: const [8, 8], eq: [flo, wall(90)], extra: toes(89, 4)), 'Handstand, idéalement face ou dos au mur.'),
    _f(_hs(x: 76, af: const [20, 200], pinF: false, l: const [8, 8], eq: [flo, wall(90)], extra: toes(89, 4)), 'Transfère le poids sur une main et touche l’épaule.'),
  ], aka: 'Handstand shoulder taps'),
  Move('hspu', 'Pompes en équilibre', _av, 'Sol · Mur', 'Le développé militaire au poids du corps.', [
    _d(_hsP, 'En équilibre, bras tendus.'),
    _f(_hspuBot, 'Descends la tête entre les mains (triangle tête-mains), puis repousse.'),
  ], aka: 'Handstand push-up · HSPU'),
  Move('pikehspu', 'Pike HSPU pieds surélevés', _int, 'Box', 'Pieds sur une box, hanches à 90° : charge proche du HSPU.', [
    _d(Pose(hx: 74, hy: 50, t: 180, a: const [180, 180], l: const [270, 270], ft: 0, chest: -1, pin: {...hands(74, F), ...toes(36, 46)}, eq: [flo, box(8, 38, 48)]), 'Mains au sol, pieds sur la box, hanches au-dessus des épaules.'),
    _f(Pose(hx: 76, hy: 66, t: 175, a: const [235, 140], l: const [265, 265], ft: 0, chest: -1, pin: {...hands(74, F), ...toes(36, 46), J.head: const V(82, 97)}, eq: [flo, box(8, 38, 48)]), 'Descends la tête devant les mains, puis repousse.'),
  ], aka: 'Pike handstand push-up'),
  Move('pushup90', 'Pompes à 90°', _eli, 'Sol', 'Du handstand, on descend jusqu’à une planche bras pliés à 90°, puis on remonte.', [
    _d(_hs(x: 85), 'Handstand solide.'),
    _f(Pose(hx: 58, hy: 88, t: 90, a: const [270, 180], l: const [270, 270], ft: 0, pin: hands(85, F)), 'Bascule et plie jusqu’à la planche à 90°, puis repousse en équilibre.'),
  ], aka: '90° push-up · 90° handstand push-up'),
  Move('hspress', 'Press to handstand', _tav, 'Sol', 'Monter en équilibre sans élan, par la force et la compression.', [
    _d(Pose(hx: 58, hy: 63, t: 150, a: const [180, 180], l: const [192, 192], pin: {...hands(76, F), ...feet(54, F)}), 'Mains au sol devant les pieds, jambes tendues, hanches hautes.'),
    _m(_hs(x: 76, l: const [100, 100], hy: 46, t: 186), 'Épaules en avant, hanches au-dessus des épaules, jambes décollent.'),
    _f(_hs(x: 76), 'Déplie les hanches jusqu’à l’équilibre.'),
  ], aka: 'Handstand press · Press handstand'),
  Move('oahs', 'Handstand à un bras', _eli, 'Sol', 'Le Graal de l’équilibre : tout le poids sur une main.', [
    _d(_hs(x: 60, af: const [150, 150], chest: 0, extra: {J.wrF: const V(76, F)}, l: const [340, 340], lf: const [20, 20]), 'Vue de face : handstand jambes écartées, mains rapprochées.'),
    _f(_hs(x: 64, af: const [80, 80], pinF: false, chest: 0, l: const [330, 330], lf: const [25, 25], t: 175), 'Transfère le poids sur une main, l’autre bras s’écarte.'),
  ], aka: 'One-arm handstand'),
  Move('hswalk', 'Marche sur les mains', _int, 'Sol', 'Avancer en équilibre, une main après l’autre.', [
    _d(_hs(x: 60), 'Handstand, corps légèrement penché vers l’avant.'),
    _m(_hs(x: 60, af: const [140, 150], pinF: false, t: 172, l: const [350, 350]), 'Lève une main et avance-la.', 'Pas'),
    _f(_hs(x: 60, af: const [160, 160], t: 168, l: const [345, 345], extra: {J.wrF: const V(72, F)}), 'Pose-la devant et enchaîne avec l’autre.'),
  ], aka: 'Handstand walking'),
  Move('hstohspu', 'Handstand → HSPU', _av, 'Sol', 'Tenir l’équilibre puis enchaîner une pompe en équilibre libre.', [
    _d(_hsP, 'Handstand libre stable.'),
    _m(_hspuBot, 'Descends contrôlé, tête vers le sol.', 'Descente'),
    _f(_hsP, 'Repousse sans perdre l’équilibre.'),
  ], aka: 'Handstand to handstand push-up'),

  // ---------- Planche ----------
  Move('planchelean', 'Planche lean', _int, 'Sol', 'Pompe haute avec les épaules projetées loin devant les mains.', [
    _d(_pushTop, 'Position de pompe, bras tendus.'),
    _f(_plLean, 'Avance les épaules au-delà des mains, bras verrouillés.'),
  ], aka: 'Planche lean'),
  Move('tuckpl', 'Tuck planche', _av, 'Sol · Parallettes', 'Genoux groupés sous la poitrine, pieds décollés.', [
    _d(Pose(hx: 52, hy: 84, t: 72, a: const [190, 190], l: const [140, 225], ft: -60, pin: {...hands(72, F), ...toes(60, F)}), 'Accroupi, mains au sol, épaules au-dessus des mains.'),
    _f(_tuckPl, 'Penche les épaules en avant jusqu’à décoller les pieds.'),
  ], aka: 'Tuck planche'),
  Move('advtuckpl', 'Advanced tuck planche', _av, 'Sol · Parallettes', 'Dos plat, hanches ouvertes à 90°.', [
    _d(_tuckPl, 'Pars de la tuck planche.'),
    _f(_advTuckPl, 'Ouvre les hanches : dos plat, genoux sous les hanches.'),
  ], aka: 'Advanced tuck planche'),
  Move('straddlepl', 'Straddle planche', _tav, 'Sol · Parallettes', 'Jambes tendues et écartées : bras de levier raccourci.', [
    _d(_advTuckPl, 'Advanced tuck solide.'),
    _f(_straddlePl, 'Tends les jambes en les écartant largement.'),
  ], aka: 'Straddle planche'),
  Move('fullpl', 'Full planche', _eli, 'Sol · Parallettes', 'Le corps entier à l’horizontale, en appui sur les mains.', [
    _d(_plLean, 'Planche lean profonde.'),
    _f(_fullPl, 'Jambes serrées, corps horizontal, bras verrouillés.'),
  ], aka: 'Full planche'),
  Move('onelegpl', 'Planche une jambe', _tav, 'Sol · Parallettes', 'Une jambe tendue, l’autre en advanced tuck.', [
    _d(_advTuckPl, 'Advanced tuck.'),
    _f(_pl(l: const [270, 270], lf: const [180, 270]), 'Tends une jambe à l’arrière, l’autre reste groupée.'),
  ], aka: 'One-leg planche'),
  Move('maltese', 'Maltese', _eli, 'Sol · Anneaux', 'Planche extrême, corps au ras du sol et bras écartés.', [
    _d(_fullPl, 'Full planche.'),
    _f(_maltese, 'Écarte les mains au niveau des hanches et descends le corps près du sol.'),
  ], aka: 'Maltese'),
  Move('tuckplpushup', 'Pompes en tuck planche', _av, 'Sol · Parallettes', 'Pompe complète sans que les pieds touchent le sol.', [
    _d(_tuckPl, 'Tuck planche bras tendus.'),
    _f(Pose(hx: 52, hy: 88, t: 90, a: const [275, 175], l: const [112, 265], ft: 0, pin: hands(72, F)), 'Plie les coudes en gardant l’horizontale, puis repousse.'),
  ], aka: 'Tuck planche push-up'),
  Move('straddleplpushup', 'Pompes en straddle planche', _tav, 'Sol · Parallettes', 'La pompe en straddle planche.', [
    _d(_straddlePl, 'Straddle planche.'),
    _f(Pose(hx: 50, hy: 90, t: 90, a: const [275, 175], l: const [266, 266], ft: 0, pin: hands(72, F)), 'Descends en gardant le corps rigide et horizontal.'),
  ], aka: 'Straddle planche push-up'),
  Move('fullplpushup', 'Pompes en full planche', _eli, 'Sol · Parallettes', 'La pompe la plus dure qui soit, jambes serrées.', [
    _d(_fullPl, 'Full planche.'),
    _f(_plBot, 'Descends la poitrine près du sol, puis repousse sans casser la ligne.'),
  ], aka: 'Planche push-up · Full planche push-up'),

  // ---------- Front lever ----------
  Move('tuckfl', 'Tuck front lever', _int, 'Barre fixe', 'Dos horizontal, genoux groupés contre la poitrine.', [
    _d(_hangFl, 'Suspendu, épaules engagées vers le bas.'),
    _f(_tuckFl, 'Bras tendus, monte le dos à l’horizontale, genoux à la poitrine.'),
  ], aka: 'Tuck front lever'),
  Move('advtuckfl', 'Advanced tuck front lever', _av, 'Barre fixe', 'Dos plat, hanches ouvertes à 90°.', [
    _d(_tuckFl, 'Tuck front lever.'),
    _f(_advTuckFl, 'Éloigne les genoux : dos plat, cuisses verticales.'),
  ], aka: 'Advanced tuck front lever'),
  Move('onelegfl', 'Front lever une jambe', _av, 'Barre fixe', 'Une jambe tendue, l’autre en advanced tuck.', [
    _d(_advTuckFl, 'Advanced tuck.'),
    _f(_lever(chest: 1, lf: const [5, 92]), 'Tends une jambe dans le prolongement du corps.'),
  ], aka: 'One-leg front lever'),
  Move('straddlefl', 'Straddle front lever', _tav, 'Barre fixe', 'Jambes tendues écartées, corps horizontal.', [
    _d(_advTuckFl, 'Advanced tuck.'),
    _f(_fullFl, 'Jambes tendues et écartées, hanches dans l’alignement.'),
  ], aka: 'Straddle front lever'),
  Move('fullfl', 'Full front lever', _tav, 'Barre fixe', 'Tout le corps à l’horizontale sous la barre, face au ciel.', [
    _d(_hangFl, 'Suspendu, bras tendus.'),
    _f(_fullFl, 'Corps rigide à l’horizontale, jambes serrées, bras tendus.'),
  ], aka: 'Front lever hold'),
  Move('flpulls', 'Front lever pulls', _tav, 'Barre fixe', 'En front lever, tu tires le corps horizontal vers la barre.', [
    _d(_fullFl, 'Front lever bras tendus.'),
    _f(_flPulled, 'Tire la barre vers les hanches en restant horizontal.'),
  ], aka: 'Front lever pulls'),
  Move('flrows', 'Front lever rows', _av, 'Barre fixe', 'Rowing en tuck front lever : le corps reste horizontal pendant le tirage.', [
    _d(_advTuckFl, 'Advanced tuck front lever.'),
    _f(Pose(hx: 76, hy: 46, t: 270, a: const [150, 20], l: const [5, 92], ft: 0, chest: 1, eq: [bar(55, 38)], pin: hands(55, 38)), 'Tire la poitrine vers la barre, coudes le long du corps.'),
  ], aka: 'Front lever rows'),
  Move('flpullup', 'Front lever pull-up', _eli, 'Barre fixe', 'Du front lever à la traction complète, sans casser la ligne.', [
    _d(_fullFl, 'Front lever.'),
    _m(_flPulled, 'Tire en gardant le corps horizontal.', 'Tirage'),
    _f(_hang(bx: 55, by: 38, a: const [168, 20], hx: 50, hy: 66, l: const [185, 185]), 'Laisse descendre les jambes et finis menton au-dessus de la barre.'),
  ], aka: 'Front lever pull-up'),
  Move('fltomu', 'Front lever → muscle-up', _eli, 'Barre fixe', 'Enchaînement : front lever, tirage, puis passage au-dessus de la barre.', [
    _d(_fullFl, 'Front lever.'),
    _m(_flPulled, 'Tire la barre vers les hanches.', 'Tirage'),
    _f(_support(bx: 55, by: 38), 'Bascule les poignets et termine en appui au-dessus de la barre.'),
  ], aka: 'Front lever to muscle-up'),

  // ---------- Back lever ----------
  Move('skinthecat', 'Skin the cat', _int, 'Barre · Anneaux', 'Rotation complète des épaules : de la suspension à la German hang.', [
    _d(_hangFl, 'Suspendu, bras tendus.'),
    _m(Pose(hx: 58, hy: 52, t: 180, a: const [0, 0], l: const [130, 40], chest: -1, eq: [bar(55, 38)], pin: hands(55, 38)), 'Remonte les genoux et passe à l’envers entre les bras.', 'Renversé'),
    _f(_germanHang, 'Continue la rotation jusqu’à la German hang, puis reviens.'),
  ], aka: 'Skin the cat'),
  Move('tuckbl', 'Tuck back lever', _int, 'Barre · Anneaux', 'Face au sol, dos horizontal, genoux groupés.', [
    _d(_invFl, 'Suspension renversée.'),
    _f(_tuckBl, 'Bascule vers l’arrière jusqu’à l’horizontale, genoux à la poitrine.'),
  ], aka: 'Tuck back lever'),
  Move('advtuckbl', 'Advanced tuck back lever', _av, 'Barre · Anneaux', 'Dos plat et hanches ouvertes à 90°.', [
    _d(_tuckBl, 'Tuck back lever.'),
    _f(_advTuckBl, 'Ouvre les hanches, dos plat.'),
  ], aka: 'Advanced tuck back lever'),
  Move('onelegbl', 'Back lever une jambe', _av, 'Barre · Anneaux', 'Une jambe tendue, l’autre groupée.', [
    _d(_advTuckBl, 'Advanced tuck back lever.'),
    _f(_lever(chest: -1, a: const [355, 355], lf: const [178, 90]), 'Tends une jambe dans l’alignement du corps.'),
  ], aka: 'One-leg back lever'),
  Move('straddlebl', 'Straddle back lever', _av, 'Barre · Anneaux', 'Jambes tendues et écartées.', [
    _d(_advTuckBl, 'Advanced tuck back lever.'),
    _f(_fullBl, 'Tends et écarte les jambes, hanches alignées.'),
  ], aka: 'Straddle back lever'),
  Move('fullbl', 'Full back lever', _av, 'Barre · Anneaux', 'Corps horizontal face au sol, bras derrière toi.', [
    _d(_invFl, 'Suspension renversée.'),
    _f(_fullBl, 'Descends le corps rigide jusqu’à l’horizontale, face au sol.'),
  ], aka: 'Full back lever'),
  Move('blraises', 'Back lever raises', _av, 'Barre · Anneaux', 'Allers-retours entre la suspension renversée et le back lever.', [
    _d(_invFl, 'Suspension renversée, corps vertical.'),
    _f(_fullBl, 'Descends en back lever, puis remonte bras tendus.'),
  ], aka: 'Back lever raises'),

  // ---------- Muscle-up ----------
  Move('muscleup', 'Muscle-up', _int, 'Barre fixe', 'Traction explosive enchaînée avec un dips au-dessus de la barre.', [
    _d(_muHang, 'Suspendu, prise légèrement plus large que les épaules.'),
    _m(_muPull, 'Traction explosive jusqu’au bas de la poitrine.', 'Tirage'),
    _m(_muTrans, 'Bascule les poignets et passe les épaules au-dessus de la barre.', 'Transition'),
    _f(_muSup, 'Repousse en dips jusqu’à l’appui bras tendus.'),
  ], aka: 'Muscle-up'),
  Move('kippingmu', 'Muscle-up avec élan', _int, 'Barre fixe', 'On utilise le balancier et le kip des hanches pour passer.', [
    _d(_hang(by: 30, t: 10, l: const [200, 200], hx: 60), 'Balancier : poitrine en avant, jambes derrière.'),
    _m(_hang(by: 30, t: 340, l: const [55, 55], ft: 0, hx: 70, hy: 60), 'Kip : jambes devant, hanches qui montent.', 'Kip'),
    _m(_muTrans, 'Utilise l’élan pour passer la barre.', 'Transition'),
    _f(_muSup, 'Termine en appui bras tendus.'),
  ], aka: 'Kipping muscle-up'),
  Move('strictmu', 'Muscle-up strict', _av, 'Barre fixe', 'Sans balancier ni kip : force pure.', [
    _d(_muHang, 'Suspension immobile, corps gainé.'),
    _m(_muPull, 'Tirage haut sans élan.', 'Tirage'),
    _m(_muTrans, 'Transition lente et contrôlée.', 'Transition'),
    _f(_muSup, 'Appui bras tendus.'),
  ], aka: 'Strict muscle-up'),
  Move('barmu', 'Bar muscle-up', _int, 'Barre fixe', 'Le muscle-up sur barre fixe (par opposition aux anneaux).', [
    _d(_muHang, 'Suspendu à la barre.'),
    _m(_muPull, 'Tire la barre vers les hanches.', 'Tirage'),
    _f(_muSup, 'Passe au-dessus et verrouille les bras.'),
  ], aka: 'Bar muscle-up'),
  Move('ringmu', 'Muscle-up aux anneaux', _av, 'Anneaux', 'Plus technique : les anneaux bougent, prise en false grip.', [
    _d(_hang(by: 30, eq: [rings(65, 30)]), 'Suspendu aux anneaux en false grip.'),
    _m(_hang(by: 30, a: const [165, 25], hx: 60, hy: 58, l: const [195, 195], eq: [rings(65, 30)]), 'Tire les anneaux vers la poitrine.', 'Tirage'),
    _m(Pose(hx: 58, hy: 48, t: 20, a: const [235, 95], l: const [190, 190], pin: hands(65, 30), eq: [rings(65, 30)]), 'Passe les épaules au-dessus des mains.', 'Transition'),
    _f(_support(eq: [rings(65, 30)]), 'Repousse en appui, anneaux près des hanches.'),
  ], aka: 'Ring muscle-up'),
  Move('chesttobarmu', 'Muscle-up poitrine-barre', _av, 'Barre fixe', 'Un tirage si haut que la barre touche la poitrine avant de passer.', [
    _d(_muHang, 'Suspendu, gainé.'),
    _m(_hang(by: 30, a: const [175, 30], hx: 58, hy: 52, l: const [190, 190]), 'Tire jusqu’à ce que la barre touche le bas de la poitrine.', 'Tirage'),
    _f(_muSup, 'Passe directement en appui.'),
  ], aka: 'Chest-to-bar muscle-up'),
  Move('falsegripmu', 'Muscle-up en false grip', _av, 'Anneaux · Barre', 'Poignet au-dessus de la barre dès le départ : transition facilitée.', [
    _d(_hang(by: 30, eq: [rings(65, 30)]), 'Suspendu, poignets cassés par-dessus (false grip).'),
    _m(Pose(hx: 58, hy: 48, t: 20, a: const [235, 95], l: const [190, 190], pin: hands(65, 30), eq: [rings(65, 30)]), 'Tire et garde le false grip pendant la transition.', 'Transition'),
    _f(_support(eq: [rings(65, 30)]), 'Appui bras tendus.'),
  ], aka: 'False-grip muscle-up'),
  Move('slowmu', 'Muscle-up lent', _tav, 'Barre fixe', 'Chaque phase prend 3 à 5 secondes : contrôle total.', [
    _d(_muHang, 'Suspension immobile.'),
    _m(_muPull, 'Monte lentement jusqu’au haut de la traction.', 'Tirage'),
    _m(_muTrans, 'Transition au ralenti, coudes qui passent derrière.', 'Transition'),
    _f(_muSup, 'Pousse lentement jusqu’à l’appui.'),
  ], aka: 'Slow muscle-up'),
  Move('oamu', 'Muscle-up à un bras', _eli, 'Barre fixe', 'Un seul bras pour tirer et pousser.', [
    _d(_hang(by: 30, af: const [180, 180], pinF: false), 'Suspendu à un bras, l’autre le long du corps.'),
    _m(_hang(by: 30, a: const [165, 25], af: const [170, 170], pinF: false, hx: 60, hy: 58, l: const [195, 195]), 'Tirage explosif à un bras.', 'Tirage'),
    _f(Pose(hx: 62, hy: 29, t: 0, a: const [180, 180], af: const [120, 120], l: const [185, 185], eq: [bar(65, 30)], pin: {J.wrN: const V(65, 30)}), 'Passe et verrouille en appui sur un bras.'),
  ], aka: 'One-arm muscle-up'),
  Move('mu360', 'Muscle-up 360', _eli, 'Barre fixe', 'Lâcher de barre après le tirage, rotation complète, rattrapage en appui.', [
    _d(_muPull, 'Tirage explosif très haut.'),
    _m(Pose(hx: 65, hy: 22, t: 0, a: const [150, 20], l: const [180, 180], chest: 0, eq: [bar(65, 30)]), 'Lâche la barre et tourne sur toi-même, bras serrés.', 'Rotation'),
    _f(_muSup, 'Rattrape la barre en appui.'),
  ], aka: '360 muscle-up'),
  Move('mu540', 'Muscle-up 540', _eli, 'Barre fixe', 'Un tour et demi en l’air avant de rattraper la barre.', [
    _d(_muPull, 'Tirage maximal et lâcher.'),
    _m(Pose(hx: 65, hy: 18, t: 0, a: const [150, 20], l: const [180, 180], chest: 0, eq: [bar(65, 30)]), 'Un tour et demi, gainage total.', 'Rotation'),
    _f(_muSup, 'Rattrape la barre face à l’autre côté.'),
  ], aka: '540 muscle-up'),
  Move('mutohs', 'Muscle-up → handstand', _eli, 'Barre fixe', 'Après le muscle-up, monter en équilibre sur la barre.', [
    _d(_muSup, 'Appui au-dessus de la barre.'),
    _m(Pose(hx: 66, hy: 0, t: 185, a: const [180, 180], l: const [95, 95], ft: 0, chest: -1, pin: hands(65, 30), eq: [bar(65, 30)]), 'Bascule les épaules en avant et monte les hanches.', 'Press'),
    _f(Pose(hx: 65, hy: -27, t: 180, a: const [180, 180], l: const [0, 0], ft: 0, chest: -1, pin: hands(65, 30), eq: [bar(65, 30)]), 'Équilibre sur la barre, corps aligné.'),
  ], aka: 'Muscle-up to handstand'),

  // ---------- Drapeaux ----------
  Move('humanflag', 'Human flag', _tav, 'Poteau · Espalier', 'Le drapeau humain : corps horizontal, bras sur un poteau vertical.', [
    _d(Pose(hx: 50, hy: 63, t: 340, a: const [330, 330], af: const [230, 230], l: const [175, 175], chest: 0, eq: [pole(35), flo], pin: {J.wrN: const V(36, 38), J.wrF: const V(36, 70), ...feet(56, F)}), 'Main du haut tire, main du bas pousse, bras tendus.'),
    _f(_flagP, 'Lance les jambes et tiens le corps à l’horizontale.'),
  ], aka: 'Full human flag'),
  Move('tuckflag', 'Human flag groupé', _av, 'Poteau', 'Le drapeau genoux groupés.', [
    _d(Pose(hx: 50, hy: 63, t: 340, a: const [330, 330], af: const [230, 230], l: const [175, 175], chest: 0, eq: [pole(35), flo], pin: {J.wrN: const V(36, 38), J.wrF: const V(36, 70), ...feet(56, F)}), 'Prise sur le poteau, bras tendus.'),
    _f(_flag(l: const [45, 150]), 'Décolle les pieds et groupe les genoux, hanches à l’horizontale.'),
  ], aka: 'Tuck human flag'),
  Move('straddleflag', 'Human flag écarté', _tav, 'Poteau', 'Jambes tendues et écartées.', [
    _d(_flag(l: const [45, 150]), 'Human flag groupé.'),
    _f(_flag(l: const [62, 62], lf: const [118, 118]), 'Tends les jambes en les écartant.'),
  ], aka: 'Straddle human flag'),
  Move('flagpullup', 'Tractions en human flag', _eli, 'Poteau', 'En drapeau, le bras du haut tire le corps vers le haut.', [
    _d(_flagP, 'Human flag.'),
    _f(_flag(a: const [300, 30], hy: 45), 'Plie le bras du haut et monte le corps en restant horizontal.'),
  ], aka: 'Human flag pull-up'),
  Move('flagraises', 'Human flag raises', _tav, 'Poteau', 'Monter du drapeau incliné au drapeau horizontal.', [
    _d(_flag(t: 330, l: const [150, 150], hy: 62), 'Drapeau jambes basses, en diagonale.'),
    _f(_flagP, 'Monte les jambes jusqu’à l’horizontale, puis redescends.'),
  ], aka: 'Human flag raises'),
  Move('sidelever', 'Side lever', _tav, 'Barre · Poteau', 'Un levier horizontal, le corps sur le côté.', [
    _d(_hangFl, 'Suspendu, mains rapprochées.'),
    _f(_lever(chest: 0), 'Pivote sur le côté et monte le corps à l’horizontale.'),
  ], aka: 'Side lever'),

  // ---------- Force avancée ----------
  Move('oapushup', 'Pompes à un bras', _av, 'Sol', 'Pieds écartés, une main dans le dos.', [
    _d(_plank(hand: const V(90, F), toe: const V(28, F), t: 66, af: const [235, 85]), 'Pieds larges, main sous l’épaule, l’autre dans le dos.'),
    _f(_plank(hand: const V(90, F), toe: const V(28, F), t: 80, a: const [295, 150], af: const [250, 80]), 'Descends sans tourner les hanches, puis repousse.'),
  ], aka: 'One-arm push-up'),
  Move('oap', 'Traction à un bras', _eli, 'Barre fixe', 'Monter le menton au-dessus de la barre avec un seul bras.', [
    _d(_hang(af: const [180, 180], pinF: false), 'Suspendu à un bras, épaule engagée.'),
    _f(_hang(a: const [168, 20], af: const [175, 175], pinF: false, hx: 60, hy: 38, l: const [185, 185]), 'Tire jusqu’au menton au-dessus de la barre, sans rotation.'),
  ], aka: 'One-arm pull-up'),
  Move('oachinup', 'Traction supination à un bras', _tav, 'Barre fixe', 'Un bras, paume vers soi : un peu plus accessible.', [
    _d(_hang(af: const [180, 180], pinF: false), 'Suspendu à un bras, paume vers toi.'),
    _f(_hang(a: const [168, 20], af: const [175, 175], pinF: false, hx: 60, hy: 38, l: const [185, 185]), 'Monte le menton au-dessus de la barre.'),
  ], aka: 'One-arm chin-up'),
  Move('assistedoap', 'Traction un bras assistée', _av, 'Barre · Sangle', 'L’autre main tient une sangle plus bas pour aider.', [
    _d(_hang(af: const [10, 10], extra: {J.wrF: const V(73, 34)}, eq: [bar(65, 10), strap(73, 10, 36)]), 'Une main à la barre, l’autre sur la sangle.'),
    _f(_hang(a: const [168, 20], af: const [100, 20], hx: 60, hy: 38, l: const [185, 185], extra: {J.wrF: const V(73, 34)}, eq: [bar(65, 10), strap(73, 10, 36)]), 'Tire surtout avec le bras du haut.'),
  ], aka: 'Assisted one-arm pull-up'),
  Move('tigerbend', 'Tiger bend', _eli, 'Sol', 'Du poirier sur les avant-bras au handstand, en poussant.', [
    _d(_hs(x: 76, a: const [180, 90], extra: {J.elN: const V(62, 101), J.elF: const V(62, 101)}, y: 101, hy: 46), 'Poirier sur les avant-bras, corps aligné.'),
    _f(_hs(x: 76), 'Pousse pour décoller les coudes jusqu’au handstand.'),
  ], aka: 'Tiger bend'),
  Move('supermanpushup', 'Pompes Superman', _tav, 'Sol', 'Poussée si explosive que le corps décolle, bras tendus devant.', [
    _d(_pushBot, 'Bas de la pompe, prêt à exploser.'),
    _m(Pose(hx: 50, hy: 72, t: 90, a: const [90, 90], l: const [270, 270], ft: 0), 'En l’air : bras tendus devant, corps horizontal.', 'Envol'),
    _f(_pushBot, 'Ramène les mains et amortis la réception.'),
  ], aka: 'Superman push-up'),
  Move('aztecpushup', 'Pompes aztèques', _tav, 'Sol', 'En l’air, tu te plies en deux pour toucher tes pieds.', [
    _d(_pushBot, 'Bas de la pompe.'),
    _m(Pose(hx: 58, hy: 66, t: 140, a: const [105, 105], l: const [100, 100], ft: 0), 'Explose et plie-toi en pike pour toucher les orteils.', 'Envol'),
    _f(_pushBot, 'Rouvre et réceptionne-toi en pompe.'),
  ], aka: 'Aztec push-up'),
  Move('deficithspu', 'HSPU en déficit', _tav, 'Parallettes', 'Mains surélevées : la tête descend sous le niveau des mains.', [
    _d(_hs(y: 95, eq: [flo, paral(65)]), 'Handstand sur les parallettes.'),
    _f(_hs(y: 95, a: const [235, 140], extra: {J.head: const V(73, 97)}, hy: 64, eq: [flo, paral(65)]), 'Descends la tête plus bas que les mains, puis repousse.'),
  ], aka: 'Deficit HSPU'),
  Move('maltesepushup', 'Pompes en maltese', _eli, 'Sol · Anneaux', 'Pompe en position maltese, mains au niveau des hanches.', [
    _d(_maltese, 'Maltese bras tendus.'),
    _f(Pose(hx: 52, hy: 97, t: 90, a: const [275, 205], l: const [270, 270], ft: 0, pin: hands(62, F)), 'Plie les coudes au ras du sol, puis repousse.'),
  ], aka: 'Maltese push-up'),

  // ---------- Freestyle ----------
  Move('clappushup', 'Pompes claquées', _int, 'Sol', 'Explose, frappe dans les mains, réceptionne.', [
    _d(_pushBot, 'Bas de la pompe.'),
    _m(_pushBotAir, 'Explose : les mains décollent et claquent sous la poitrine.', 'Envol'),
    _f(_pushTop, 'Réceptionne bras légèrement fléchis.'),
  ], aka: 'Clap push-up'),
  Move('doubleclap', 'Pompes double claquement', _av, 'Sol', 'Deux claquements avant de toucher le sol.', [
    _d(_pushBot, 'Bas de la pompe.'),
    _m(Pose(hx: 60, hy: 64, t: 78, a: const [175, 175], l: const [258, 258], ft: -60), 'Poussée maximale : deux claquements rapides.', 'Envol'),
    _f(_pushTop, 'Réception souple.'),
  ], aka: 'Double clap push-up'),
  Move('pushup360', 'Pompes 360', _eli, 'Sol', 'Le corps entier décolle et fait un tour complet.', [
    _d(_pushBot, 'Bas de la pompe, très gainé.'),
    _m(Pose(hx: 58, hy: 66, t: 90, a: const [120, 220], l: const [270, 270], ft: 0, chest: 0), 'En l’air, rotation complète du corps.', 'Rotation'),
    _f(_pushBot, 'Réception en pompe.'),
  ], aka: '360 push-up'),
  Move('behindbackclap', 'Claquement dans le dos', _tav, 'Sol', 'Les mains claquent derrière le dos en plein vol.', [
    _d(_pushBot, 'Bas de la pompe.'),
    _m(Pose(hx: 58, hy: 66, t: 80, a: const [250, 280], l: const [260, 260], ft: 0), 'Explose et frappe dans les mains dans le dos.', 'Envol'),
    _f(_pushBot, 'Ramène vite les mains pour la réception.'),
  ], aka: 'Behind-the-back clap push-up'),
  Move('pushup180', 'Pompes 180', _av, 'Sol', 'Demi-tour en l’air pour atterrir dans l’autre sens.', [
    _d(_pushBot, 'Bas de la pompe.'),
    _m(Pose(hx: 60, hy: 72, t: 82, a: const [170, 170], l: const [262, 262], ft: 0, chest: 0), 'Explose et pivote d’un demi-tour.', 'Rotation'),
    _f(_plank(hand: const V(28, F), toe: const V(90, F), t: 294, a: const [180, 180], ft: 90), 'Réceptionne dans l’autre sens.'),
  ], aka: '180 push-up'),
  Move('barspin', 'Bar spin', _eli, 'Barre fixe', 'Lâcher de barre avec une rotation du corps, puis rattrapage.', [
    _d(_hang(t: 345, l: const [160, 160], hx: 72), 'Balancier vers l’avant.'),
    _m(Pose(hx: 65, hy: 66, t: 0, a: const [150, 30], l: const [182, 182], chest: 0, eq: [bar(65, 10)]), 'Lâche et tourne sur l’axe vertical, bras serrés.', 'Rotation'),
    _f(_hangP, 'Rattrape la barre.'),
  ], aka: 'Bar spin'),
  Move('pullup360', 'Traction 360', _eli, 'Barre fixe', 'Traction explosive, lâcher, tour complet, rattrapage.', [
    _d(_pullTop, 'Traction explosive au-dessus de la barre.'),
    _m(Pose(hx: 65, hy: 44, t: 0, a: const [150, 30], l: const [180, 180], chest: 0, eq: [bar(65, 10)]), 'Lâche la barre et fais un tour complet.', 'Rotation'),
    _f(_hangP, 'Rattrape la barre bras tendus.'),
  ], aka: '360 pull-up'),
  Move('frontflipdismount', 'Sortie salto avant', _eli, 'Barre fixe', 'Quitter la barre en salto avant.', [
    _d(_support(bx: 40, by: 40, l: const [195, 195]), 'Appui sur la barre, prêt à basculer.'),
    _m(Pose(hx: 76, hy: 52, t: 210, a: const [120, 120], l: const [60, 200], ft: 0, eq: [bar(40, 40), flo]), 'Lâche, groupe-toi et tourne vers l’avant.', 'Salto'),
    _f(Pose(hx: 96, hy: 80, t: 35, a: const [90, 90], l: const [110, 205], pin: feet(108, F), eq: [bar(40, 40), flo]), 'Ouvre et réceptionne fléchi.'),
  ], aka: 'Front flip dismount'),
  Move('backflipdismount', 'Sortie salto arrière', _eli, 'Barre fixe', 'Quitter la barre en salto arrière au bout du balancier.', [
    _d(_hang(bx: 40, by: 30, t: 335, l: const [150, 150], hx: 52), 'Grand balancier vers l’avant.'),
    _m(Pose(hx: 78, hy: 48, t: 160, a: const [60, 60], l: const [300, 160], ft: 0, chest: -1, eq: [bar(40, 30), flo]), 'Lâche en haut du balancier et groupe vers l’arrière.', 'Salto'),
    _f(Pose(hx: 96, hy: 80, t: 35, a: const [90, 90], l: const [110, 205], pin: feet(108, F), eq: [bar(40, 30), flo]), 'Réception jambes fléchies.'),
  ], aka: 'Backflip dismount'),

  // ---------- Jambes ----------
  Move('jumpsquat', 'Squat sauté', _deb, 'Sol', 'Squat puis saut vertical explosif.', [
    _d(_squatBot, 'Squat bas, bras devant.'),
    _m(Pose(hx: 60, hy: 46, t: 0, a: const [200, 200], l: const [180, 180], ft: 0), 'Explose vers le haut, corps tendu.', 'Saut'),
    _f(_squatBot, 'Amortis dans le squat.'),
  ], aka: 'Jump squat'),
  Move('splitjump', 'Fentes sautées', _int, 'Sol', 'En fente, tu sautes et inverses les jambes en l’air.', [
    _d(Pose(hx: 58, hy: 78, t: 0, l: const [115, 180], lf: const [195, 262], pin: {J.anN: const V(76, F), J.knF: const V(46, 100)}), 'Fente basse.'),
    _m(Pose(hx: 60, hy: 58, t: 0, a: const [160, 160], l: const [150, 190], lf: const [215, 200], ft: -60), 'Saute et croise les jambes en l’air.', 'Saut'),
    _f(Pose(hx: 58, hy: 78, t: 0, lf: const [115, 180], l: const [195, 262], pin: {J.anF: const V(76, F), J.knN: const V(46, 100)}), 'Retombe en fente, jambes inversées.'),
  ], aka: 'Split jump'),
  Move('boxjump', 'Saut sur box', _deb, 'Box', 'Saut groupé pour atterrir sur une box.', [
    _d(Pose(hx: 32, hy: 80, t: 40, a: const [200, 200], l: const [110, 205], pin: feet(44, F), eq: [flo, box(80, 112, 72)]), 'Squat, bras derrière.'),
    _m(Pose(hx: 70, hy: 42, t: 15, a: const [60, 60], l: const [80, 200], ft: -80, eq: [flo, box(80, 112, 72)]), 'Explose et remonte les genoux.', 'Saut'),
    _f(Pose(hx: 86, hy: 50, t: 35, a: const [95, 95], l: const [110, 205], pin: feet(96, 72), eq: [flo, box(80, 112, 72)]), 'Réception souple sur la box.'),
  ], aka: 'Box jump'),
  Move('broadjump', 'Saut en longueur', _int, 'Sol', 'Saut horizontal le plus loin possible, pieds joints.', [
    _d(Pose(hx: 18, hy: 80, t: 50, a: const [215, 215], l: const [110, 205], pin: feet(30, F)), 'Squat, bras lancés vers l’arrière.'),
    _m(Pose(hx: 62, hy: 56, t: 55, a: const [60, 60], l: const [230, 230], ft: -40), 'Projette-toi vers l’avant, bras devant.', 'Envol'),
    _f(Pose(hx: 94, hy: 80, t: 40, a: const [95, 95], l: const [110, 205], pin: feet(106, F)), 'Réception en squat, bras devant.'),
  ], aka: 'Broad jump'),
  Move('shrimpsquat', 'Shrimp squat', _av, 'Sol', 'Squat sur une jambe, l’autre pied tenu derrière toi.', [
    _d(_stand(lf: const [175, 290], af: const [205, 200], ft: -90), 'Sur une jambe, attrape l’autre pied derrière.'),
    _f(Pose(hx: 54, hy: 84, t: 30, a: const [90, 90], af: const [200, 190], l: const [112, 208], lf: const [200, 285], pin: {J.anN: const V(62, F), J.knF: const V(44, 101)}), 'Descends jusqu’à poser le genou arrière au sol.'),
  ], aka: 'Shrimp squat'),
  Move('sissysquat', 'Sissy squat', _av, 'Sol', 'Sur la pointe des pieds, genoux en avant, buste incliné en arrière.', [
    _d(Pose(hx: 57, hy: 56, l: const [180, 180], ft: -38, pin: toes(62, F)), 'Sur la pointe des pieds.'),
    _f(Pose(hx: 54, hy: 82, t: 330, a: const [90, 90], l: const [120, 205], ft: -30, pin: toes(66, F)), 'Pousse les genoux vers l’avant et bascule, hanches-genoux alignés.'),
  ], aka: 'Sissy squat'),
  Move('assistedsissy', 'Sissy squat assisté', _int, 'Poteau', 'Une main sur un support pour garder l’équilibre.', [
    _d(Pose(hx: 57, hy: 56, l: const [180, 180], a: const [120, 90], ft: -38, pin: {...toes(62, F), J.wrN: const V(86, 54), J.wrF: const V(86, 54)}, eq: [flo, pole(88)]), 'Une main sur le poteau, sur la pointe des pieds.'),
    _f(Pose(hx: 54, hy: 82, t: 330, a: const [70, 70], l: const [120, 205], ft: -30, pin: {...toes(66, F), J.wrN: const V(86, 66), J.wrF: const V(86, 66)}, eq: [flo, pole(88)]), 'Descends en gardant hanches et genoux alignés.'),
  ], aka: 'Assisted sissy squat'),
  Move('skatersquat', 'Skater squat', _int, 'Sol', 'Squat sur une jambe, l’autre pliée derrière, genou vers le sol.', [
    _d(_stand(lf: const [175, 270], a: const [90, 90]), 'Sur une jambe, l’autre pliée derrière.'),
    _f(Pose(hx: 52, hy: 84, t: 35, a: const [90, 90], l: const [112, 208], lf: const [195, 270], pin: {J.anN: const V(62, F), J.knF: const V(46, 101)}), 'Descends jusqu’à effleurer le sol avec le genou arrière.'),
  ], aka: 'Skater squat'),
  Move('onelegcalf', 'Mollet sur une jambe', _deb, 'Sol', 'Montée sur la pointe d’un seul pied.', [
    _d(_stand(x: 56, lf: const [170, 260]), 'Sur un pied, l’autre jambe pliée.'),
    _f(Pose(hx: 57, hy: 56, l: const [180, 180], lf: const [170, 260], ft: -38, pin: {J.toeN: const V(62, F)}), 'Monte au maximum sur la pointe.'),
  ], aka: 'One-leg calf raise'),
  Move('explosivelunges', 'Fentes explosives', _int, 'Sol', 'Fentes avec poussée explosive à chaque répétition.', [
    _d(Pose(hx: 58, hy: 78, t: 0, l: const [115, 180], lf: const [195, 262], pin: {J.anN: const V(76, F), J.knF: const V(46, 100)}), 'Fente basse, buste droit.'),
    _m(Pose(hx: 60, hy: 58, t: 0, a: const [40, 40], af: const [220, 220], l: const [150, 190], lf: const [215, 200], ft: -60), 'Pousse fort, bras opposés comme en sprint.', 'Saut'),
    _f(Pose(hx: 58, hy: 78, t: 0, lf: const [115, 180], l: const [195, 262], pin: {J.anF: const V(76, F), J.knN: const V(46, 100)}), 'Réceptionne en fente contrôlée.'),
  ], aka: 'Explosive lunges'),

  // ---------- Mobilité ----------
  Move('germanhang', 'German hang', _int, 'Barre · Anneaux', 'Suspendu bras derrière le dos : étirement profond des épaules.', [
    _d(_hangFl, 'Suspendu face à la barre.'),
    _m(Pose(hx: 58, hy: 52, t: 180, a: const [0, 0], l: const [130, 40], chest: -1, eq: [bar(55, 38)], pin: hands(55, 38)), 'Passe à l’envers en groupant.', 'Renversé'),
    _f(_germanHang, 'Descends doucement derrière, bras tendus, et respire.'),
  ], aka: 'German hang'),
  Move('jeffersoncurl', 'Jefferson curl', _int, 'Box', 'Enroulement vertèbre par vertèbre, debout sur une box.', [
    _d(_stand(x: 50, y: 78, eq: [flo, box(28, 58, 78)]), 'Debout sur la box, genoux tendus.'),
    _f(Pose(hx: 46, hy: 38, t: 168, hd: 10, a: const [178, 178], l: const [184, 184], pin: feet(50, 78), eq: [flo, box(28, 58, 78)]), 'Enroule lentement la colonne, mains vers le sol sous la box.'),
  ], aka: 'Jefferson curl'),
  Move('bridge', 'Pont', _deb, 'Sol', 'Le pont complet : épaules, dos et hanches en extension.', [
    _d(Pose(hx: 60, hy: 99, t: 270, a: const [5, 250], l: const [45, 160], ft: -70, pin: {J.hip: const V(60, 99), ...feet(80, F), ...hands(30, F)}), 'Sur le dos, mains à côté des oreilles, pieds près des fesses.'),
    _f(Pose(hx: 62, hy: 60, t: 240, a: const [205, 205], l: const [130, 180], ft: -80, pin: {...feet(82, F), ...hands(30, F)}), 'Pousse dans les mains et les pieds, bras tendus, hanches hautes.'),
  ], aka: 'Bridge'),
  Move('wallbridge', 'Pont contre le mur', _deb, 'Mur', 'Descendre en pont en marchant des mains sur le mur.', [
    _d(_stand(x: 50, a: const [320, 320], t: 345, eq: [flo, wall(20)], extra: hands(21, 30)), 'Dos au mur, bras tendus au-dessus de la tête, mains au mur.'),
    _f(Pose(hx: 62, hy: 66, t: 245, a: const [215, 215], l: const [130, 180], ft: -80, pin: {...feet(76, F), ...hands(21, 82)}, eq: [flo, wall(20)]), 'Descends les mains le long du mur en ouvrant les hanches.'),
  ], aka: 'Wall bridge'),
  Move('backbend', 'Backbend', _int, 'Sol', 'Depuis debout, se cambrer jusqu’au pont.', [
    _d(_stand(x: 62, a: const [5, 5]), 'Debout, bras tendus au-dessus de la tête.'),
    _m(_stand(x: 62, t: 320, a: const [290, 290], hd: -30, l: const [160, 195]), 'Pousse les hanches en avant et cambre le haut du dos.', 'Cambré'),
    _f(Pose(hx: 62, hy: 60, t: 240, a: const [205, 205], l: const [130, 180], ft: -80, pin: {...feet(76, F), ...hands(26, F)}), 'Pose les mains au sol : tu es en pont.'),
  ], aka: 'Backbend'),
  Move('frontsplit', 'Grand écart facial', _int, 'Sol', 'Une jambe devant, l’autre derrière, bassin au sol.', [
    _d(Pose(hx: 60, hy: 80, t: 0, a: const [180, 180], l: const [115, 180], lf: const [200, 268], pin: {J.anN: const V(80, F), J.knF: const V(46, 101), ...hands(70, F)}), 'Fente basse, genou arrière au sol, mains au sol.'),
    _f(Pose(hx: 60, hy: 99, t: 0, a: const [90, 90], l: const [90, 90], lf: const [270, 270], ft: -90, pin: {J.hip: const V(60, 99)}), 'Glisse jusqu’à poser le bassin, jambes tendues.'),
  ], aka: 'Front split'),
  Move('sidesplit', 'Grand écart facial latéral', _av, 'Sol', 'Les deux jambes sur les côtés, bassin au sol.', [
    _d(Pose(hx: 60, hy: 80, t: 20, a: const [160, 160], l: const [235, 235], lf: const [125, 125], ft: 90, ftf: -90, chest: 0, pin: {...hands(60, F)}), 'Vue de face : pieds très écartés, mains au sol.'),
    _f(Pose(hx: 60, hy: 99, t: 0, a: const [240, 240], af: const [120, 120], l: const [270, 270], lf: const [90, 90], ft: 90, ftf: -90, chest: 0, pin: {J.hip: const V(60, 99)}), 'Écarte jusqu’au sol, buste droit.'),
  ], aka: 'Side split'),
  Move('pancake', 'Pancake', _int, 'Sol', 'Assis jambes écartées, poitrine vers le sol.', [
    _d(Pose(hx: 50, hy: 99, t: 0, a: const [90, 90], l: const [90, 90], ft: 0, pin: {J.hip: const V(50, 99)}), 'Assis jambes tendues et écartées, dos droit.'),
    _f(Pose(hx: 50, hy: 99, t: 82, a: const [92, 92], l: const [90, 90], ft: 0, pin: {J.hip: const V(50, 99)}), 'Bascule le bassin vers l’avant et pose la poitrine.'),
  ], aka: 'Pancake'),
  Move('shoulderstand', 'Chandelle', _deb, 'Sol', 'Sur les épaules, corps vertical, mains dans le dos.', [
    _d(Pose(hx: 60, hy: 99, t: 270, a: const [90, 90], l: const [90, 90], ft: 0, pin: {J.hip: const V(60, 99)}), 'Allongé sur le dos, bras le long du corps.'),
    _f(Pose(hx: 42, hy: 70, t: 180, hd: 90, a: const [95, 345], l: const [0, 0], ft: 0, pin: {J.sh: const V(40, 98), J.elN: const V(54, 101), J.elF: const V(54, 101)}), 'Monte les jambes et les hanches, mains qui soutiennent le dos.'),
  ], aka: 'Shoulder stand'),

  // ---------- Élite ----------
  Move('victorian', 'Victorian', _eli, 'Anneaux', 'Corps horizontal à hauteur des anneaux, bras tendus vers les pieds.', [
    _d(_lever(chest: -1, a: const [355, 355], eq: [rings(55, 38)]), 'Back lever aux anneaux.'),
    _f(Pose(hx: 50, hy: 40, t: 270, a: const [110, 110], l: const [90, 90], ft: 0, chest: 1, eq: [rings(70, 47)], pin: hands(70, 47)), 'Monte le corps au niveau des anneaux, bras tendus le long des hanches.'),
  ], aka: 'Victorian'),
  Move('victorianpress', 'Victorian press', _eli, 'Anneaux', 'Depuis la Victorian, pousser sans élan vers une position d’appui.', [
    _d(Pose(hx: 50, hy: 40, t: 270, a: const [110, 110], l: const [90, 90], ft: 0, chest: 1, eq: [rings(70, 47)], pin: hands(70, 47)), 'Victorian.'),
    _f(_pl(x: 70, y: 47, eq: [rings(70, 47)]), 'Pousse et bascule jusqu’à la planche aux anneaux.'),
  ], aka: 'Victorian press'),
  Move('oafl', 'Front lever à un bras', _eli, 'Barre fixe', 'Le front lever tenu d’une seule main.', [
    _d(_fullFl, 'Front lever à deux bras.'),
    _f(_lever(chest: 1, af: const [100, 140], pinF: false), 'Lâche une main et garde l’horizontale.'),
  ], aka: 'One-arm front lever'),
  Move('nakayama', 'Nakayama', _eli, 'Anneaux', 'Élément de force aux anneaux qui arrive en croix de fer, bras tendus.', [
    _d(Pose(hx: 65, hy: 40, t: 180, a: const [330, 330], af: const [30, 30], l: const [0, 0], ft: 0, chest: 0, eq: [rings(48, 40), rings(82, 40)], pin: {J.wrN: const V(48, 40), J.wrF: const V(82, 40)}), 'Vue de face : suspension renversée, bras tendus.'),
    _f(Pose(hx: 65, hy: 68, t: 0, a: const [270, 270], af: const [90, 90], l: const [180, 180], ft: 0, chest: 0, eq: [rings(36, 40), rings(94, 40)], pin: {J.wrN: const V(36, 40), J.wrF: const V(94, 40)}), 'Rotation bras tendus jusqu’à la croix de fer.'),
  ], aka: 'Nakayama'),
  Move('azarian', 'Azarian', _eli, 'Anneaux', 'Rotation arrière bras tendus jusqu’à la croix de fer.', [
    _d(Pose(hx: 65, hy: 66, t: 0, a: const [190, 190], af: const [170, 170], l: const [90, 90], ft: 0, chest: 0, eq: [rings(58, 66), rings(72, 66)], pin: {J.wrN: const V(58, 66), J.wrF: const V(72, 66)}), 'Vue de face : appui aux anneaux en L.'),
    _m(Pose(hx: 65, hy: 40, t: 180, a: const [330, 330], af: const [30, 30], l: const [0, 0], ft: 0, chest: 0, eq: [rings(48, 40), rings(82, 40)], pin: {J.wrN: const V(48, 40), J.wrF: const V(82, 40)}), 'Bascule vers l’arrière, bras tendus.', 'Rotation'),
    _f(Pose(hx: 65, hy: 68, t: 0, a: const [270, 270], af: const [90, 90], l: const [180, 180], ft: 0, chest: 0, eq: [rings(36, 40), rings(94, 40)], pin: {J.wrN: const V(36, 40), J.wrF: const V(94, 40)}), 'Termine en croix de fer.'),
  ], aka: 'Azarian'),
  Move('impossibledip', 'Impossible dip', _eli, 'Barres parallèles', 'Des avant-bras posés sur les barres à l’appui bras tendus, sans bouger les mains.', [
    _d(Pose(hx: 60, hy: 72, t: 0, a: const [180, 90], l: const [175, 235], eq: [pbars(40, 92, 58), flo], pin: {J.elN: const V(60, 58), J.elF: const V(60, 58), ...hands(74, 58)}), 'Avant-bras posés sur les barres, coudes sous les épaules.'),
    _f(Pose(hx: 72, hy: 57, t: 0, a: const [180, 180], l: const [175, 235], eq: [pbars(40, 92, 58), flo], pin: hands(74, 58)), 'Pousse pour décoller les coudes jusqu’aux bras tendus.'),
  ], aka: 'Impossible dip'),
  Move('impossiblepushup', 'Impossible push-up', _eli, 'Sol', 'De la planche sur les avant-bras à la pompe bras tendus, mains fixes.', [
    _d(Pose(hx: 58, hy: 90, t: 76, a: const [180, 90], l: const [256, 256], pin: {J.elN: const V(78, 101), J.elF: const V(78, 101), ...toes(18, F), ...hands(92, 101)}), 'Planche sur les avant-bras.'),
    _f(_plank(hand: const V(92, F), toe: const V(18, F), t: 64), 'Décolle les coudes et pousse jusqu’aux bras tendus.'),
  ], aka: 'Impossible push-up'),
];

final Map<String, Move> moveById = {for (final m in moves) m.id: m};

const moveCategories = [
  MoveCategory('fond', 'Fondamentaux', 0xFF7BC67B, [
    'pushup', 'diamondpushup', 'widepushup', 'archerpushup', 'declinepushup', 'pikepushup', 'hindupushup',
    'pseudoplanchepushup', 'pullup', 'chinup', 'neutralpullup', 'widepullup', 'closepullup', 'archerpullup',
    'australianpullup', 'dips', 'benchdips', 'squat', 'bulgarian', 'pistol', 'lunges', 'cossack', 'nordic',
    'glutebridge', 'calfraise',
  ]),
  MoveCategory('core', 'Core / abdos', 0xFF5AA9FF, [
    'plank', 'sideplank', 'hollow', 'archhold', 'lsit', 'tucklsit', 'vsit', 'compression', 'hangkneeraise',
    'hanglegraise', 'toestobar', 'windshield', 'dragonflag', 'abwheel', 'flraises', 'fullfl',
  ]),
  MoveCategory('hs', 'Handstand / équilibre', 0xFFB58CFF, [
    'handstand', 'wallhs', 'freehs', 'hsshouldertaps', 'hspu', 'pikehspu', 'pushup90', 'hspress', 'oahs',
    'hswalk', 'hstohspu',
  ]),
  MoveCategory('planche', 'Planche', 0xFFFF6B6B, [
    'planchelean', 'tuckpl', 'advtuckpl', 'straddlepl', 'fullpl', 'onelegpl', 'maltese', 'fullplpushup',
    'tuckplpushup', 'straddleplpushup',
  ]),
  MoveCategory('fl', 'Front lever', 0xFFFF9F43, [
    'tuckfl', 'advtuckfl', 'onelegfl', 'straddlefl', 'fullfl', 'flraises', 'flpulls', 'flrows', 'flpullup', 'fltomu',
  ]),
  MoveCategory('bl', 'Back lever', 0xFFF5D547, [
    'skinthecat', 'tuckbl', 'advtuckbl', 'onelegbl', 'straddlebl', 'fullbl', 'blraises',
  ]),
  MoveCategory('mu', 'Muscle-up', 0xFFBDBDBD, [
    'muscleup', 'kippingmu', 'strictmu', 'barmu', 'ringmu', 'chesttobarmu', 'falsegripmu', 'slowmu', 'oamu',
    'mu360', 'mu540', 'mutohs',
  ]),
  MoveCategory('flag', 'Drapeaux / latéral', 0xFFC08A5A, [
    'humanflag', 'tuckflag', 'straddleflag', 'flagpullup', 'flagraises', 'sidelever',
  ]),
  MoveCategory('force', 'Force avancée', 0xFF4CD9A0, [
    'oapushup', 'archerpushup', 'oap', 'oachinup', 'assistedoap', 'oamu', 'tigerbend', 'supermanpushup',
    'aztecpushup', 'pushup90', 'hspu', 'deficithspu', 'fullplpushup', 'maltesepushup',
  ]),
  MoveCategory('free', 'Freestyle / explosif', 0xFFFF7A3D, [
    'clappushup', 'doubleclap', 'pushup360', 'supermanpushup', 'behindbackclap', 'pushup180', 'mu360', 'mu540',
    'barspin', 'pullup360', 'frontflipdismount', 'backflipdismount',
  ]),
  MoveCategory('legs', 'Jambes / explosivité', 0xFF6FD0E0, [
    'jumpsquat', 'splitjump', 'boxjump', 'broadjump', 'pistol', 'shrimpsquat', 'nordic', 'sissysquat',
    'assistedsissy', 'skatersquat', 'cossack', 'onelegcalf', 'explosivelunges',
  ]),
  MoveCategory('mob', 'Mobilité', 0xFFE58FD0, [
    'skinthecat', 'germanhang', 'jeffersoncurl', 'bridge', 'wallbridge', 'backbend', 'frontsplit', 'sidesplit',
    'pancake', 'shoulderstand', 'lsit', 'vsit', 'hspress',
  ]),
  MoveCategory('elite', 'Skills extrêmes', 0xFFE7B54A, [
    'fullpl', 'fullplpushup', 'maltese', 'victorian', 'fullfl', 'flpullup', 'oafl', 'oahs', 'oap', 'oamu',
    'pushup90', 'hspress', 'victorianpress', 'nakayama', 'azarian', 'impossibledip', 'impossiblepushup',
  ]),
];
