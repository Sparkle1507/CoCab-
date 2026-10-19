import 'package:flutter/material.dart';
import '../../../core/theme.dart';

class TravelScreen extends StatelessWidget { 
  const TravelScreen({super.key}); 
  @override Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundLight, appBar: AppBar(title: const Text('Travel')), 
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(28), 
          child: Container(
            width: double.infinity, padding: const EdgeInsets.all(24), 
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(28), border: Border.all(color: kBorderGrey.withOpacity(0.7)), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 18, offset: const Offset(0, 5))]), 
            child: Column(
              mainAxisSize: MainAxisSize.min, 
              children: [
                Container(width: 68, height: 68, alignment: Alignment.center, decoration: BoxDecoration(color: kPremiumIndigo.withOpacity(0.10), shape: BoxShape.circle), child: const Icon(Icons.flight_takeoff_rounded, color: kPremiumIndigo, size: 32)), 
                const SizedBox(height: 18), 
                const Text('Travel is coming soon', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900)), 
                const SizedBox(height: 7), 
                const Text('Airport rides and intercity travel will appear here.', textAlign: TextAlign.center, style: TextStyle(color: kTextGrey, fontSize: 12.5, fontWeight: FontWeight.w600, height: 1.4))
              ]
            )
          )
        )
      )
    );
  }
}