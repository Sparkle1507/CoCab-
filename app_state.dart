import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AppState {
  static final ValueNotifier<bool> isLoggedIn = ValueNotifier(false);
  static final ValueNotifier<bool> hasSeenOnboarding = ValueNotifier(false); // ✨ Pudhusa add panniyachu
  static final ValueNotifier<String> userPhone = ValueNotifier("+91 9876543210");
  static final ValueNotifier<bool> showBottomNav = ValueNotifier(true); 

  static Future<void> checkLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    isLoggedIn.value = prefs.getBool('isLoggedIn') ?? false;
    hasSeenOnboarding.value = prefs.getBool('hasSeenOnboarding') ?? false; // ✨ Memory la irundhu check pandrom
    userPhone.value = prefs.getString('userPhone') ?? "+91 9876543210";
  }

  static Future<void> completeOnboarding() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenOnboarding', true); // ✨ User paathutaanga nu save pandrom
    hasSeenOnboarding.value = true;
  }

  static Future<void> login(String phone) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('userPhone', "+91 $phone");
    userPhone.value = "+91 $phone";
    isLoggedIn.value = true;
  }

  static Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    try { await FirebaseAuth.instance.signOut(); } catch (e) {}
    isLoggedIn.value = false;
    showBottomNav.value = true;
  }
}

// ... LocationData and LocationState remains same ...
class LocationData {
  final LatLng pickup;
  final String address;
  LocationData({required this.pickup, required this.address});
}

class LocationState {
  static final LatLng userHomeLocation = const LatLng(13.0827, 80.2707);
  static final ValueNotifier<LocationData> current = ValueNotifier(LocationData(pickup: userHomeLocation, address: "Fetching address..."));

  static Future<void> updateLocation(LatLng newLoc) async {
    current.value = LocationData(pickup: newLoc, address: "Fetching address...");
    try {
      final url = Uri.parse('https://nominatim.openstreetmap.org/reverse?lat=${newLoc.latitude}&lon=${newLoc.longitude}&format=json');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        String displayName = data['display_name'] ?? "Selected Location";
        List<String> parts = displayName.split(',');
        String shortAddress = parts.length > 2 ? "${parts[0].trim()}, ${parts[1].trim()}, ${parts[2].trim()}" : displayName;
        current.value = LocationData(pickup: newLoc, address: shortAddress);
      } else {
        current.value = LocationData(pickup: newLoc, address: "Location Selected");
      }
    } catch (e) {
      current.value = LocationData(pickup: newLoc, address: "Location Selected");
    }
  }
}