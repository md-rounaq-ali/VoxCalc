import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'core/services/service_locator.dart';
import 'core/theme/app_theme.dart';
import 'features/calculator/presentation/providers/calc_provider.dart';
import 'features/splash/presentation/screens/splash_screen.dart';

void main() async {
  // 1. Guarantee native widget platform bindings are fully established
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Disable Google Fonts HTTP fetching to prevent offline SocketException lags
  GoogleFonts.config.allowRuntimeFetching = false;

  // 3. Enable screen orientations support (Portrait & Landscape)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  // 4. Initialize GetIt Dependency Injections (Hive local persistency, TTS synthesis, Export services)
  await setupServiceLocator();

  // 5. Run standard application thread
  runApp(const VoxCalcApp());
}

/// Core application widget bootstrapping state managers and dynamic theme engines.
class VoxCalcApp extends StatelessWidget {
  const VoxCalcApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<CalcProvider>(
      create: (_) => CalcProvider(),
      child: Consumer<CalcProvider>(
        builder: (context, provider, _) {
          final activeThemeName = provider.activeTheme;
          
          return MaterialApp(
            title: 'VoxCalc',
            debugShowCheckedModeBanner: false,
            
            // Dynamic premium visual theme engine configs
            theme: AppTheme.getThemeData(activeThemeName),
            darkTheme: AppTheme.getThemeData(activeThemeName),
            themeMode: activeThemeName == "light_aurora" ? ThemeMode.light : ThemeMode.dark,
            
            // Set starting point to glowing SplashScreen route
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
