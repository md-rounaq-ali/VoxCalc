import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/utils/haptic_helper.dart';
import '../../../calculator/presentation/providers/calc_provider.dart';
import '../../../calculator/presentation/screens/dashboard_screen.dart';
import '../../../calculator/presentation/widgets/custom_scaffold.dart';

/// Elite, gesture-driven onboarding slides presenting core smart features.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  final List<OnboardingSlide> _slides = [
    OnboardingSlide(
      title: "Scientific Calculator",
      description: "Tactile key mechanics mapping standard and scientific computations smoothly with glowing previews.",
      icon: Icons.keyboard_rounded,
    ),
    OnboardingSlide(
      title: "Voice-To-Math AI",
      description: "Speak calculations naturally. VoxCalc deciphers mathematical terms and triggers speech outputs instantly.",
      icon: Icons.mic_rounded,
    ),
    OnboardingSlide(
      title: "Handwriting Canvas",
      description: "Draw variables or standard equations with simple gestures. Tap solver sweep scanners to solve.",
      icon: Icons.gesture_rounded,
    ),
  ];

  void _onNext() {
    HapticHelper.triggerLightImpact();
    if (_currentIndex < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _finishOnboarding();
    }
  }

  void _finishOnboarding() {
    HapticHelper.triggerMediumImpact();
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const DashboardScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero).animate(animation),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CalcProvider>(context);
    final mode = provider.themeMode;
    final accent = AppTheme.getAccentColor(mode);
    final orientation = MediaQuery.of(context).orientation;
    final isLandscape = orientation == Orientation.landscape;

    return CustomScaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: isLandscape ? 8 : 16),
        child: Column(
          children: [
            // Top Nav Skipper
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: _finishOnboarding,
                child: Text(
                  "SKIP",
                  style: AppTextStyles.bodyStyle(
                    mode,
                    fontSize: isLandscape ? 11 : 13,
                    fontWeight: FontWeight.bold,
                    customColor: accent.withOpacity(0.8),
                  ),
                ),
              ),
            ),
            
            // Slider viewport
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (idx) {
                  setState(() => _currentIndex = idx);
                  HapticHelper.triggerLightImpact();
                },
                itemCount: _slides.length,
                itemBuilder: (context, index) {
                  final slide = _slides[index];
                  return Center(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Slide Glass Icon Card
                          Container(
                            width: isLandscape ? 70 : 130,
                            height: isLandscape ? 70 : 130,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppTheme.getKeyColor(mode, isOperator: true),
                              border: Border.fromBorderSide(AppTheme.getBorderSide(mode)),
                              boxShadow: [
                                BoxShadow(
                                  color: accent.withOpacity(0.1),
                                  blurRadius: 16,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Icon(
                              slide.icon,
                              size: isLandscape ? 32 : 54,
                              color: accent,
                            ),
                          ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack),
                          SizedBox(height: isLandscape ? 12 : 40),

                          // Slide Title
                          Text(
                            slide.title,
                            style: AppTextStyles.headerStyle(mode, fontSize: isLandscape ? 18 : 26, glow: true),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: isLandscape ? 8 : 16),

                          // Slide Description
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              slide.description,
                              style: AppTextStyles.bodyStyle(
                                mode,
                                fontSize: isLandscape ? 12 : 14,
                                customColor: AppTheme.getTextColor(mode).withOpacity(0.7),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Pagination Dots Indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _slides.length,
                (index) => Container(
                  width: _currentIndex == index ? 24 : 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: _currentIndex == index ? accent : accent.withOpacity(0.3),
                  ),
                ).animate(target: _currentIndex == index ? 1 : 0).scaleX(duration: 300.ms),
              ),
            ),
            SizedBox(height: isLandscape ? 12 : 32),

            // Floating Bottom Button
            SizedBox(
              width: double.infinity,
              height: isLandscape ? 40 : 52,
              child: ElevatedButton(
                onPressed: _onNext,
                style: ElevatedButton.styleFrom(
                  backgroundColor: accent,
                  elevation: 6,
                  shadowColor: accent.withOpacity(0.4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  _currentIndex == _slides.length - 1 ? "GET STARTED" : "CONTINUE",
                  style: AppTextStyles.bodyStyle(
                    mode,
                    fontSize: isLandscape ? 13 : 15,
                    fontWeight: FontWeight.bold,
                    customColor: Colors.black,
                  ),
                ),
              ),
            ),
            SizedBox(height: isLandscape ? 8 : 16),
          ],
        ),
      ),
    );
  }
}

/// Helper representing data objects inside the Onboarding Slide deck
class OnboardingSlide {
  final String title;
  final String description;
  final IconData icon;

  OnboardingSlide({
    required this.title,
    required this.description,
    required this.icon,
  });
}
