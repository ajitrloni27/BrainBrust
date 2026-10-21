import 'package:flutter/material.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;
  final ThemeMode currentThemeMode;

  const SplashScreen({
    super.key,
    required this.onToggleTheme,
    required this.currentThemeMode,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  // Icon animations
  late final Animation<double> _iconScale;
  late final Animation<double> _iconFade;

  // "Welcome to" animations
  late final Animation<double> _welcomeFade;
  late final Animation<Offset> _welcomeSlide;

  // "BrainBurst" title animations
  late final Animation<double> _titleFade;
  late final Animation<Offset> _titleSlide;
  late final Animation<double> _titleGlow;

  // Subtitle animations
  late final Animation<double> _subtitleFade;
  late final Animation<Offset> _subtitleSlide;

  @override
  void initState() {
    super.initState();

    // Total duration ~3.2 seconds
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    );

    // 1. Icon: Scale up with elastic bounce + fade in (0.0s - 1.0s approx)
    _iconScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.36, curve: Curves.elasticOut),
      ),
    );
    _iconFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.22, curve: Curves.easeIn),
      ),
    );

    // 2. "Welcome to" text: fades in and slides up starting at ~0.6s
    _welcomeFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.20, 0.40, curve: Curves.easeOut),
      ),
    );
    _welcomeSlide = Tween<Offset>(
      begin: const Offset(0.0, 0.4),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.20, 0.42, curve: Curves.easeOutCubic),
      ),
    );

    // 3. "BrainBurst" title: fades in and slides up starting at ~1.1s (0.35 of 3.2s)
    _titleFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.35, 0.58, curve: Curves.easeOut),
      ),
    );
    _titleSlide = Tween<Offset>(
      begin: const Offset(0.0, 0.45),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.35, 0.60, curve: Curves.easeOutCubic),
      ),
    );

    // Subtle pulse / glow on title during and after appearance
    _titleGlow = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.48, 0.85, curve: Curves.easeInOut),
      ),
    );

    // 4. Subtitle: fades in and slides up starting at ~1.6s
    _subtitleFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.55, 0.74, curve: Curves.easeOut),
      ),
    );
    _subtitleSlide = Tween<Offset>(
      begin: const Offset(0.0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.55, 0.74, curve: Curves.easeOutCubic),
      ),
    );

    // 5. Hold final state for about 1 second, then navigate to topics screen
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _navigateToHome();
      }
    });

    _controller.forward();
  }

  void _navigateToHome() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => HomeScreen(
          onToggleTheme: widget.onToggleTheme,
          currentThemeMode: widget.currentThemeMode,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Gradient background adapted for both light and dark themes
    final gradientColors = isDark
        ? const [
            Color(0xFF0F172A),
            Color(0xFF1E1B4B),
            Color(0xFF0F172A),
          ]
        : const [
            Color(0xFFF8FAFC),
            Color(0xFFEEF2FF),
            Color(0xFFE0E7FF),
          ];

    final primaryColor = theme.colorScheme.primary;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: gradientColors,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // 1. Animated Icon (Scale + Fade + Elastic Bounce)
                      FadeTransition(
                        opacity: _iconFade,
                        child: ScaleTransition(
                          scale: _iconScale,
                          child: Container(
                            width: 104,
                            height: 104,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  primaryColor,
                                  const Color(0xFF8B5CF6),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(28),
                              boxShadow: [
                                BoxShadow(
                                  color: primaryColor.withAlpha(isDark ? 90 : 70),
                                  blurRadius: 28,
                                  offset: const Offset(0, 10),
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: const Stack(
                              alignment: Alignment.center,
                              children: [
                                Icon(
                                  Icons.psychology_rounded,
                                  size: 60,
                                  color: Colors.white,
                                ),
                                Positioned(
                                  right: 14,
                                  bottom: 14,
                                  child: Icon(
                                    Icons.bolt_rounded,
                                    size: 26,
                                    color: Color(0xFFFDE047),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 36),

                      // 2. "Welcome to" (Fade + Slide)
                      FadeTransition(
                        opacity: _welcomeFade,
                        child: SlideTransition(
                          position: _welcomeSlide,
                          child: Text(
                            'Welcome to',
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 2.0,
                              color: isDark
                                  ? const Color(0xFF94A3B8)
                                  : const Color(0xFF64748B),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // 3. "BrainBurst" (Fade + Slide + Glow)
                      FadeTransition(
                        opacity: _titleFade,
                        child: SlideTransition(
                          position: _titleSlide,
                          child: Text(
                            'BrainBurst',
                            style: TextStyle(
                              fontSize: 40.0,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -1.0,
                              color: isDark ? Colors.white : const Color(0xFF1E1B4B),
                              shadows: [
                                Shadow(
                                  color: primaryColor.withAlpha(
                                    (_titleGlow.value * (isDark ? 160 : 80)).toInt(),
                                  ),
                                  blurRadius: 18 * _titleGlow.value,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // 4. Subtitle: "Quick bursts of practice for your placements"
                      FadeTransition(
                        opacity: _subtitleFade,
                        child: SlideTransition(
                          position: _subtitleSlide,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.white.withAlpha(12)
                                  : Colors.black.withAlpha(8),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'Quick bursts of practice for your placements',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w500,
                                color: isDark
                                    ? const Color(0xFFCBD5E1)
                                    : const Color(0xFF475569),
                                height: 1.3,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
