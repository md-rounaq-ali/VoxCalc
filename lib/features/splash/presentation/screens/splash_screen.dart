import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../calculator/presentation/providers/calc_provider.dart';
import '../../../calculator/presentation/widgets/custom_scaffold.dart';
import '../../../onboarding/presentation/screens/onboarding_screen.dart';

/// Elite, futuristic splash screen featuring animated scanning laser elements.
class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  /// Triggers splash timings, shifting view automatically
  void _navigateToNext() async {
    await Future.delayed(const Duration(milliseconds: 3200));
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const OnboardingScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 800),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CalcProvider>(context, listen: false);
    final mode = provider.themeMode;
    final accent = AppTheme.getAccentColor(mode);

    return CustomScaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Glowing Futuristic Logo Circle
            Stack(
              alignment: Alignment.center,
              children: [
                // Outer Ripple
                Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: accent.withOpacity(0.15), width: 2),
                  ),
                )
                    .animate(onPlay: (controller) => controller.repeat())
                    .scale(begin: const Offset(1, 1), end: const Offset(1.3, 1.3), duration: 2.seconds)
                    .fadeOut(duration: 2.seconds),

                // Core Glass Box
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [accent.withOpacity(0.3), Colors.transparent],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    border: Border.all(color: accent.withOpacity(0.4), width: 1.5),
                  ),
                  child: const Icon(
                    Icons.calculate_rounded,
                    size: 48,
                    color: Colors.white,
                  ),
                )
                    .animate()
                    .shimmer(duration: 2.seconds, color: accent.withOpacity(0.5))
                    .shake(hz: 2, duration: 1.seconds),
              ],
            ),
            const SizedBox(height: 24),

            // Animated App Name
            Text(
              "VOXCALC",
              style: AppTextStyles.displayStyle(mode, fontSize: 32, glow: true),
            )
                .animate()
                .fadeIn(duration: 600.ms)
                .slideY(begin: 0.2, end: 0, duration: 600.ms),

            const SizedBox(height: 8),

            // Neon Scanning Subtitle
            Text(
              "THE ULTIMATE SMART MATH SUITE",
              style: AppTextStyles.bodyStyle(
                mode,
                fontSize: 10,
                fontWeight: FontWeight.w600,
                customColor: accent.withOpacity(0.8),
              ),
            )
                .animate()
                .fadeIn(delay: 400.ms, duration: 600.ms),

            const SizedBox(height: 48),

            // Continuous Scanning Laser Bar
            Container(
              width: 160,
              height: 2.5,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                gradient: LinearGradient(
                  colors: [Colors.transparent, accent, Colors.transparent],
                ),
                boxShadow: [
                  BoxShadow(color: accent.withOpacity(0.6), blurRadius: 6, spreadRadius: 1),
                ],
              ),
            )
                .animate(onPlay: (controller) => controller.repeat(reverse: true))
                .slideX(begin: -0.4, end: 0.4, duration: 1500.ms, curve: Curves.easeInOut),
          ],
        ),
      ),
    );
  }
}
