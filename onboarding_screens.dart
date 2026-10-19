import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import 'dart:ui'; 
import '../../../core/theme.dart';
import '../../../core/app_state.dart';
import '../../auth/screens/auth_screens.dart';
import '../../../navigation/main_navigation_screen.dart';

// ==========================================
// 🌊 1. ANIMATED SPLASH SCREEN
// ==========================================
class SplashAnimationScreen extends StatefulWidget {
  const SplashAnimationScreen({super.key});

  @override
  State<SplashAnimationScreen> createState() => _SplashAnimationScreenState();
}

class _SplashAnimationScreenState extends State<SplashAnimationScreen> with TickerProviderStateMixin {
  late AnimationController _orbitController;
  late AnimationController _zoomController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: kPremiumBlack,
    ));

    _orbitController = AnimationController(vsync: this, duration: const Duration(milliseconds: 2500))..repeat();

    _zoomController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _scaleAnimation = Tween<double>(begin: 1.0, end: 30.0).animate(CurvedAnimation(parent: _zoomController, curve: Curves.easeInExpo));
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _zoomController, curve: Curves.easeIn));

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        _zoomController.forward().then((_) {
          
          Widget nextScreen;
          if (!AppState.hasSeenOnboarding.value) {
            nextScreen = const OnboardingScreen(); 
          } else if (!AppState.isLoggedIn.value) {
            nextScreen = const LoginScreen(); 
          } else {
            nextScreen = const MainNavigationScreen(); 
          }

          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) => nextScreen,
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
              transitionDuration: const Duration(milliseconds: 500),
            ),
          );
        });
      }
    });
  }

  @override
  void dispose() {
    _orbitController.dispose();
    _zoomController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPremiumBlack,
      body: SizedBox.expand(
        child: AnimatedBuilder(
          animation: _zoomController,
          builder: (context, child) {
            return Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [kPremiumGreen.withOpacity(0.15), Colors.transparent],
                      stops: const [0.1, 1.0],
                    ),
                  ),
                ),
                
                Opacity(
                  opacity: 1.0 - _fadeAnimation.value,
                  child: SizedBox(
                    width: 220,
                    height: 220,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white.withOpacity(0.05), width: 1.5),
                          ),
                        ),
                        AnimatedBuilder(
                          animation: _orbitController,
                          builder: (context, child) {
                            return Transform.rotate(
                              angle: _orbitController.value * 2 * math.pi,
                              child: Align(
                                alignment: Alignment.topCenter,
                                child: Container(
                                  margin: const EdgeInsets.only(top: 0),
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: kPremiumGreen,
                                    shape: BoxShape.circle,
                                    boxShadow: [BoxShadow(color: kPremiumGreen.withOpacity(0.8), blurRadius: 10, spreadRadius: 2)],
                                  ),
                                ),
                              ),
                            );
                          }
                        ),
                      ],
                    ),
                  ),
                ),

                Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 72, height: 72,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            const Text('C', style: TextStyle(color: Colors.white, fontSize: 44, fontWeight: FontWeight.w900, fontFamily: 'Roboto')),
                            Positioned(
                              bottom: 18, right: 18,
                              child: Transform.rotate(
                                angle: -0.5,
                                child: const Icon(Icons.energy_savings_leaf_rounded, color: kPremiumGreen, size: 20),
                              ),
                            )
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (_zoomController.value < 0.3) ...[
                        const Text('CoCab', style: TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w900, letterSpacing: -1.0)),
                        const SizedBox(height: 8),
                        const Text('SAME ROUTE • LESS COST', style: TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 2.0)),
                      ]
                    ],
                  ),
                ),

                Positioned(
                  bottom: 50,
                  child: Opacity(
                    opacity: 1.0 - _fadeAnimation.value,
                    child: Row(
                      children: [
                        Container(width: 30, height: 1, color: Colors.white24),
                        const SizedBox(width: 12),
                        const Text('MOVING LIFE FORWARD', style: TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 2.0)),
                        const SizedBox(width: 12),
                        Container(width: 30, height: 1, color: Colors.white24),
                      ],
                    ),
                  ),
                ),

                if (_zoomController.value > 0.5)
                  Opacity(
                    opacity: (_zoomController.value - 0.5) * 2,
                    child: Container(color: Colors.white),
                  )
              ],
            );
          }
        ),
      ),
    );
  }
}

// ==========================================
// ✨ 2. PREMIUM ONBOARDING SCREENS 
// ==========================================
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _onboardingData = [
    {
      "tag": "YOUR EVERYDAY RIDE",
      "tagColor": kPremiumGreen,
      "title": "Move around,\nwithout the wait.",
      "subtitle": "Book safe, reliable rides in seconds and follow every turn in real time.",
      "image": "https://images.unsplash.com/photo-1494976388531-d1058494cdd8?q=80&w=2000&auto=format&fit=crop", 
      "num": "01",
    },
    {
      "tag": "DOOR-TO-DOOR DELIVERY",
      "tagColor": const Color(0xFFF59E0B),
      "title": "Send parcels.\nWe'll handle the rest.",
      "subtitle": "From a forgotten key to a special package, send it securely across town.",
      "image": "https://images.unsplash.com/photo-1580674285054-bed31e145f59?q=80&w=2000&auto=format&fit=crop", 
      "num": "02",
    },
    {
      "tag": "FRESH CLOTHES, LESS WORK",
      "tagColor": kPremiumIndigo,
      "title": "Laundry day,\nmade effortless.",
      "subtitle": "Schedule a pickup and get freshly cleaned clothes delivered to your door.",
      "image": "https://images.unsplash.com/photo-1610557892470-55d9e80c0bce?q=80&w=2000&auto=format&fit=crop", 
      "num": "03",
    },
  ];

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
    ));
  }

  void _onSkip() async {
    await AppState.completeOnboarding();
    if (mounted) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
    }
  }

  // ✨ CONTINUE BUTTON LOGIC ✨
  void _onContinue() {
    if (_currentPage < _onboardingData.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _onSkip(); // Call the same skip function to save state & go to Login
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.grey.shade100, Colors.white],
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 20, 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 32, height: 32,
                            decoration: BoxDecoration(color: kPremiumBlack, borderRadius: BorderRadius.circular(10)),
                            child: const Stack(
                              alignment: Alignment.center,
                              children: [
                                Text('C', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)),
                                Positioned(bottom: 6, right: 6, child: Icon(Icons.energy_savings_leaf_rounded, color: kPremiumGreen, size: 10))
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Text('CoCab', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: kPremiumBlack, letterSpacing: -0.5)),
                        ],
                      ),
                      TextButton(
                        onPressed: _onSkip,
                        style: TextButton.styleFrom(foregroundColor: kTextGrey),
                        child: const Text('Skip', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                      )
                    ],
                  ),
                ),

                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) => setState(() => _currentPage = index),
                    itemCount: _onboardingData.length,
                    itemBuilder: (context, index) {
                      final data = _onboardingData[index];
                      return SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 10),
                            
                            Center(
                              child: Container(
                                width: double.infinity,
                                height: 220, 
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(28),
                                  image: DecorationImage(
                                    image: NetworkImage(data['image']),
                                    fit: BoxFit.cover,
                                    colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.08), BlendMode.darken),
                                  ),
                                  boxShadow: [
                                    BoxShadow(color: Colors.black.withOpacity(0.10), blurRadius: 20, offset: const Offset(0, 10))
                                  ],
                                ),
                                child: Stack(
                                  children: [
                                    Positioned(
                                      top: 16, right: 16,
                                      child: Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                                        child: Text(data['num'], style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: kPremiumBlack)),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            
                            const SizedBox(height: 28),
                            
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(data['tag'], style: TextStyle(color: data['tagColor'], fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                                const SizedBox(height: 10),
                                Text(data['title'], style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w900, color: kPremiumBlack, letterSpacing: -1.0, height: 1.1)),
                                const SizedBox(height: 12),
                                Text(data['subtitle'], style: const TextStyle(fontSize: 15, color: kTextGrey, fontWeight: FontWeight.w500, height: 1.4)),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                // ✨ BOTTOM SECTION: DOTS & CONTINUE BUTTON ✨
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                  child: Column(
                    children: [
                      // Pagination Dots
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          _onboardingData.length,
                          (index) => AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            height: 6,
                            width: _currentPage == index ? 24 : 6,
                            decoration: BoxDecoration(
                              color: _currentPage == index ? kPremiumGreen : Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Continue Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _onContinue,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kPremiumBlack,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            _currentPage == _onboardingData.length - 1 ? 'Get Started' : 'Continue',
                            style: const TextStyle(
                              fontSize: 17, 
                              fontWeight: FontWeight.w900, 
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}