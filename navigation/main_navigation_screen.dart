import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../core/app_state.dart';
import '../features/ride/screens/ride_screens.dart';
import '../features/services/screens/all_services_screen.dart';
import '../features/services/screens/travel_screen.dart';
import '../features/profile/screens/profile_screens.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});
  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  final List<Widget> _screens = [
    const HomeScreen(), 
    const AllServicesScreen(), 
    const TravelScreen(), 
    const AccountScreen()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: _screens[_currentIndex],
      bottomNavigationBar: ValueListenableBuilder<bool>(
        valueListenable: AppState.showBottomNav,
        builder: (context, showNav, child) {
          if (!showNav) return const SizedBox.shrink();
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 12),
              child: Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.96), 
                  borderRadius: BorderRadius.circular(24), 
                  boxShadow: [BoxShadow(color: kPremiumBlack.withOpacity(0.10), blurRadius: 28, offset: const Offset(0, 10))], 
                  border: Border.all(color: Colors.white)
                ),
                child: BottomNavigationBar(
                  currentIndex: _currentIndex,
                  onTap: (index) => setState(() => _currentIndex = index),
                  type: BottomNavigationBarType.fixed,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  selectedItemColor: kPremiumBlack,
                  unselectedItemColor: kTextGrey,
                  selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11),
                  unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11),
                  showUnselectedLabels: true,
                  items: [
                    BottomNavigationBarItem(icon: _navIcon(Icons.home_filled, 0), label: 'Ride'),
                    BottomNavigationBarItem(icon: _navIcon(Icons.grid_view_rounded, 1), label: 'Services'),
                    BottomNavigationBarItem(icon: _navIcon(Icons.flight_takeoff_rounded, 2), label: 'Travel'),
                    BottomNavigationBarItem(icon: _navIcon(Icons.person_rounded, 3), label: 'Account'),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _navIcon(IconData icon, int index) {
    final selected = _currentIndex == index;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220), 
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8), 
      decoration: BoxDecoration(color: selected ? kPremiumBlack : Colors.transparent, borderRadius: BorderRadius.circular(16)), 
      child: Icon(icon, color: selected ? Colors.white : kTextGrey, size: 21)
    );
  }
}
