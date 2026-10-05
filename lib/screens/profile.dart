import 'package:flutter/material.dart';

import '../data.dart';
import '../theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final TextEditingController _name;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: AppScope.read(context).name);
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _reset(AppState s) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Tout effacer ?', style: display(26)),
        content: Text('Séances, défis, étapes et trophées seront supprimés de ce téléphone.',
            style: body(14, color: C.muted)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annuler')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Tout effacer')),
        ],
      ),
    );
    if (ok == true) {
      s.resetAll();
      _name.clear();
      if (mounted) toast(context, 'Données effacées');
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final stats = [
      ('${s.sessionDays.length}', 'Séances notées'),
      ('${s.doneChallenges.length}', 'Défis relevés'),
      ('${s.masteredSkills}', 'Figures maîtrisées'),
      ('${s.trophies.length}', 'Trophées'),
    ];

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
        children: [
          Text('PROFIL', style: display(40, height: 1)),
          const SizedBox(height: 18),
          Text('Ton prénom', style: body(12, color: C.muted, weight: FontWeight.w600)),
          const SizedBox(height: 6),
          TextField(
            controller: _name,
            textCapitalization: TextCapitalization.words,
            style: body(15),
            onChanged: s.setName,
            decoration: InputDecoration(
              hintText: 'Comment on t’appelle ?',
              hintStyle: body(15, color: C.muted2),
              filled: true,
              fillColor: C.surface,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: C.border)),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: s.accent)),
            ),
          ),
          const SizedBox(height: 22),
          Text('STATISTIQUES', style: display(22, weight: FontWeight.w700)),
          const SizedBox(height: 10),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.7,
            children: [
              for (final (value, label) in stats)
                Panel(
                  radius: 16,
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(value, style: display(36, height: 1)),
                      Text(label, style: body(12, color: C.muted, weight: FontWeight.w600)),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 22),
          Text('COULEUR', style: display(22, weight: FontWeight.w700)),
          const SizedBox(height: 10),
          Row(
            children: [
              for (var i = 0; i < accentOptions.length; i++) ...[
                if (i > 0) const SizedBox(width: 10),
                Expanded(
                  child: Panel(
                    radius: 16,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    borderColor: s.accentIndex == i ? accentOptions[i] : C.border,
                    onTap: () => s.setAccent(i),
                    child: Column(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(color: accentOptions[i], shape: BoxShape.circle),
                          child: s.accentIndex == i ? const Icon(Icons.check, size: 18, color: C.bg) : null,
                        ),
                        const SizedBox(height: 8),
                        Text(accentNames[i], style: body(13, weight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 28),
          Center(
            child: TextButton.icon(
              onPressed: () => _reset(s),
              icon: const Icon(Icons.delete_outline, color: C.muted2, size: 18),
              label: Text('Effacer toutes mes données', style: body(13, color: C.muted2)),
            ),
          ),
        ],
      ),
    );
  }
}
