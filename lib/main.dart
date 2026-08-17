import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:goalflow/theme/app_theme.dart';
import 'package:goalflow/utils/router.dart';
import 'package:goalflow/services/goal_provider.dart';
import 'package:goalflow/services/theme_provider.dart';
import 'package:goalflow/services/api_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Permanently show and enable the top status notification bar & navigation bar
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.edgeToEdge,
    overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom],
  );

  // Restore userId + userData from SharedPreferences
  final hasSession = await ApiService.loadSession();

  // Preload saved theme
  final prefs = await SharedPreferences.getInstance();
  final savedIsDark = prefs.getBool('user_theme_mode') ?? false;
  final initialThemeMode = savedIsDark ? ThemeMode.dark : ThemeMode.light;

  // Always start at /splash so the user sees the animated 'hello' on cold boot
  String initialRoute = '/splash';

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GoalProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider(initialMode: initialThemeMode)),
      ],
      child: GoalFlowApp(initialRoute: initialRoute),
    ),
  );
}

class GoalFlowApp extends StatelessWidget {
  final String initialRoute;
  const GoalFlowApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final isDark = themeProvider.isDarkMode;
        final overlayStyle = SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
          statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
          systemNavigationBarColor: Colors.transparent,
          systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        );

        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: overlayStyle,
          child: MaterialApp.router(
            title: 'GoalFlow',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            routerConfig: buildRouter(initialRoute),
          ),
        );
      },
    );
  }
}
