import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/audio/audio_service.dart';
import 'core/theme/colors.dart';
import 'core/theme/game_theme.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Force Landscape mode (iOS & Android) like a real high-end Unity game
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  // Enable sticky immersive full-screen mode (hides system bars for pure game feel)
  await SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.immersiveSticky,
  );

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: AppColors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.bgDark,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Initialize audio service
  AudioService.instance.init();

  runApp(const AvatarGameApp());
}

class AvatarGameApp extends StatelessWidget {
  const AvatarGameApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SPIDER-HERO: Symbiote Strike',
      debugShowCheckedModeBanner: false,
      theme: GameTheme.themeData.copyWith(
        textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme),
      ),
      home: const SplashScreen(),
    );
  }
}
