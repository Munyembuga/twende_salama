import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:twende/screen/homeScreen.dart';
import 'package:twende/l10n/l10n.dart';
import 'package:twende/screen/splash_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

// Create a ChangeNotifier for locale changes
class LocaleProvider extends ChangeNotifier {
  Locale _locale = const Locale('en');

  Locale get locale => _locale;

  Future<void> setLocale(Locale locale) async {
    if (!S.supportedLocales.contains(locale)) return;

    _locale = locale;

    // Save to shared preferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', locale.languageCode);

    notifyListeners();
  }

  // Initialize from shared preferences
  Future<void> initLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final String? languageCode = prefs.getString('language_code');

    if (languageCode != null) {
      _locale = Locale(languageCode);
    }
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Create and initialize the locale provider
  final localeProvider = LocaleProvider();
  await localeProvider.initLocale();

  runApp(
    ChangeNotifierProvider<LocaleProvider>(
      create: (_) => localeProvider,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Listen to the locale provider
    final localeProvider = Provider.of<LocaleProvider>(context);

    return MaterialApp(
      title: 'Sango Taxi',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.red,
        primaryColor: const Color(0xFFF5141E),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      // Configure localization
      localizationsDelegates: const [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: S.supportedLocales,
      locale: localeProvider.locale,
      home: const SplashScreen(),
    );
  }
}
