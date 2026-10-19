import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart'; // ✨ Google Fonts Import

import 'core/theme.dart';
import 'core/app_state.dart';
import 'features/auth/screens/auth_screens.dart'; 
import 'navigation/main_navigation_screen.dart';  
import 'features/onboarding/screens/onboarding_screens.dart'; 

bool isFirebaseWorking = false;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, statusBarIconBrightness: Brightness.dark));
  
  await AppState.checkLogin();
  try { 
    await Firebase.initializeApp(); 
    isFirebaseWorking = true; 
  } catch (e) { 
    isFirebaseWorking = false; 
  }
  runApp(const CabApp());
}

class CabApp extends StatelessWidget {
  const CabApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: AppState.isLoggedIn,
      builder: (context, isLoggedIn, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'CoCab Premium',
          theme: ThemeData(
            useMaterial3: true,
            primaryColor: kPremiumIndigo,
            scaffoldBackgroundColor: kBackgroundLight,
            
            // ✨ PUDHU CODE: App full-a Poppins font apply aagum ✨
            textTheme: GoogleFonts.poppinsTextTheme(), 
            
            colorScheme: ColorScheme.fromSeed(seedColor: kPremiumIndigo, brightness: Brightness.light),
            appBarTheme: const AppBarTheme(
              elevation: 0,
              scrolledUnderElevation: 0,
              backgroundColor: kBackgroundLight,
              foregroundColor: kPremiumBlack,
              centerTitle: false,
              surfaceTintColor: Colors.transparent,
              systemOverlayStyle: SystemUiOverlayStyle.dark,
              titleTextStyle: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: kPremiumBlack, letterSpacing: -0.6),
            ),
            inputDecorationTheme: const InputDecorationTheme(
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(18)), borderSide: BorderSide.none),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(18)), borderSide: BorderSide(color: kBorderGrey)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(18)), borderSide: BorderSide(color: kPremiumIndigo, width: 1.6)),
              contentPadding: EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                elevation: 0,
                minimumSize: const Size(double.infinity, 54),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(17)),
                textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
              ),
            ),
            outlinedButtonTheme: OutlinedButtonThemeData(
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 52),
                side: const BorderSide(color: kBorderGrey),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(17)),
                textStyle: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
            snackBarTheme: SnackBarThemeData(
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              backgroundColor: kPremiumBlack,
              contentTextStyle: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          home: isLoggedIn 
              ? const MainNavigationScreen() 
              : const SplashAnimationScreen(),  
        );
      }
    );
  }
}