import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'data.dart';
import 'screens/challenges.dart';
import 'screens/home.dart';
import 'screens/profile.dart';
import 'screens/skills.dart';
import 'screens/trophies.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: C.nav,
    systemNavigationBarIconBrightness: Brightness.light,
  ));
  final state = AppState();
  await state.load();
  runApp(AppScope(notifier: state, child: const ChalkApp()));
}

class ChalkApp extends StatelessWidget {
  const ChalkApp({super.key});

  @override
  Widget build(BuildContext context) {
    final accent = AppScope.of(context).accent;
    final base = ThemeData(brightness: Brightness.dark, useMaterial3: true);
    return MaterialApp(
      title: 'Chalk',
      debugShowCheckedModeBanner: false,
      theme: base.copyWith(
        scaffoldBackgroundColor: C.bg,
        colorScheme: ColorScheme.dark(primary: accent, onPrimary: C.bg, surface: C.surface, onSurface: C.text),
        textTheme: base.textTheme.apply(
            fontFamily: GoogleFonts.dmSans().fontFamily, bodyColor: C.text, displayColor: C.text),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: C.text,
          contentTextStyle: body(14, color: C.bg, weight: FontWeight.w600),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        dialogTheme: const DialogThemeData(backgroundColor: C.surface),
        textSelectionTheme: TextSelectionThemeData(cursorColor: accent, selectionHandleColor: accent),
      ),
      home: const Shell(),
    );
  }
}

class Shell extends StatelessWidget {
  const Shell({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    return PopScope(
      canPop: s.tab == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) s.goTab(0);
      },
      child: Scaffold(
        body: IndexedStack(
          index: s.tab,
          children: const [HomeScreen(), ChallengesScreen(), SkillsScreen(), TrophiesScreen(), ProfileScreen()],
        ),
        bottomNavigationBar: const BottomNav(),
      ),
    );
  }
}

class BottomNav extends StatelessWidget {
  const BottomNav({super.key});

  static const _items = [
    (Icons.home_outlined, 'Accueil'),
    (Icons.local_fire_department_outlined, 'Défis'),
    (Icons.play_circle_outline, 'Tutos'),
    (Icons.emoji_events_outlined, 'Trophées'),
    (Icons.person_outline, 'Profil'),
  ];

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    return Container(
      decoration: const BoxDecoration(
        color: C.nav,
        border: Border(top: BorderSide(color: C.navBorder)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 68,
          child: Row(
            children: [
              for (var i = 0; i < _items.length; i++)
                Expanded(
                  child: InkResponse(
                    onTap: () => s.goTab(i),
                    child: Builder(builder: (context) {
                      final active = s.tab == i;
                      final color = active ? (i == 3 ? C.gold : s.accent) : C.muted2;
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(_items[i].$1, color: color, size: 24),
                          const SizedBox(height: 4),
                          Text(_items[i].$2,
                              style: body(11, color: color, weight: active ? FontWeight.w700 : FontWeight.w600)),
                        ],
                      );
                    }),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
