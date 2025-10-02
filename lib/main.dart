import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'l10n/app_localizations.dart';
import 'providers/tournament_provider.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TournamentProvider(),
      child: Consumer<TournamentProvider>(
        builder: (context, provider, _) {
          return MaterialApp(
            title: 'Badminton Tournament Manager',
            debugShowCheckedModeBanner: false,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            locale: provider.locale,
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: Color(0xFF255EA8),
                brightness: Brightness.light,
              ),
              useMaterial3: true,
            ),
            darkTheme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: Color(0xFF255EA8),
                brightness: Brightness.dark,
              ),
              useMaterial3: true,
            ),
            themeMode: provider.themeMode,
            home: const HomeScreen(),
          );
        },
      ),
    );
  }
}
