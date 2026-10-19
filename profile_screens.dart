import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../core/theme.dart';
import '../../../core/app_state.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  Widget _buildMenuItem(IconData icon, String title, {String? subtitle, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 18.0, horizontal: 24.0),
            child: Row(
              children: [
                Icon(icon, color: Colors.black87, size: 26),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87)),
                      if (subtitle != null) ...[
                        const SizedBox(height: 4),
                        Text(subtitle, style: const TextStyle(fontSize: 14, color: Colors.grey)),
                      ]
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black54),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1, indent: 74, color: Color(0xFFF0F0F0)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Profile',
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Colors.black, letterSpacing: -0.5),
        ),
      ),
      body: ListView(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 16, offset: const Offset(0, 4)),
                BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4, offset: const Offset(0, 1)),
              ],
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFF1E3A8A), width: 1.5),
                        ),
                        child: const Icon(Icons.person, color: Color(0xFF1E3A8A), size: 28),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("HARIGARAN", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.black, letterSpacing: 0.5)),
                            const SizedBox(height: 4),
                            Text(
                              AppState.userPhone.value.replaceAll('+91 ', ''), 
                              style: const TextStyle(fontSize: 15, color: Colors.black87, fontWeight: FontWeight.w500)
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black54),
                    ],
                  ),
                ),
                const Divider(height: 1, thickness: 1, color: Color(0xFFF0F0F0)),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    children: [
                      const Icon(Icons.star, color: Color(0xFFFBBF24), size: 28),
                      const SizedBox(width: 20),
                      const Expanded(
                        child: Text("4.67 My Rating", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.black)),
                      ),
                      const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black54),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),

          _buildMenuItem(Icons.help_outline_rounded, "Help"),
          _buildMenuItem(Icons.account_balance_wallet_outlined, "Payment"),
          _buildMenuItem(Icons.history_rounded, "My Rides", onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const RideHistoryScreen()));
          }),
          _buildMenuItem(Icons.verified_user_outlined, "Safety"),
          _buildMenuItem(Icons.card_giftcard_rounded, "Refer and Earn", subtitle: "Get ₹50"),
          _buildMenuItem(Icons.workspace_premium_outlined, "My Rewards"),
          _buildMenuItem(Icons.notifications_none_rounded, "Notifications"),
          _buildMenuItem(Icons.shield_outlined, "Claims"),
          _buildMenuItem(Icons.settings_outlined, "Settings", onTap: () {
             AppState.logout(); 
          }),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class RideHistoryScreen extends StatefulWidget {
  const RideHistoryScreen({super.key});
  @override
  State<RideHistoryScreen> createState() => _RideHistoryScreenState();
}

class _RideHistoryScreenState extends State<RideHistoryScreen> {
  List<dynamic> _rides = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRideHistory();
  }

  Future<void> _fetchRideHistory() async {
    setState(() => _isLoading = true);
    try {
      final res = await http.get(Uri.parse('http://127.0.0.1:8000/rides')).timeout(const Duration(seconds: 4));
      if (res.statusCode == 200) {
        setState(() {
          _rides = jsonDecode(res.body);
          _isLoading = false;
        });
        return;
      }
    } catch (e) {}

    setState(() {
      _rides = [
        {
          "id": 101,
          "status": "Shared Cab Booked",
          "shared_distance_km": 4.8,
          "solo_fare": 280,
          "shared_fare": 175,
          "savings": 105,
        },
        {
          "id": 100,
          "status": "Solo Cab Booked",
          "shared_distance_km": 2.5,
          "solo_fare": 95,
          "shared_fare": 95,
          "savings": 0,
        }
      ];
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundLight, 
      appBar: AppBar(title: const Text('Your Trips'), actions: [IconButton(icon: const Icon(Icons.refresh_rounded), onPressed: _fetchRideHistory)]), 
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: kPremiumIndigo)) 
        : _rides.isEmpty 
          ? const Center(child: Text('No past rides found', style: TextStyle(color: kTextGrey, fontWeight: FontWeight.w800))) 
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 30), 
              itemCount: _rides.length, 
              itemBuilder: (context, index) { 
                final ride = _rides[index]; 
                final bool isShared = (ride['savings'] ?? 0) > 0; 
                final fare = ride['shared_fare'] ?? ride['solo_fare'] ?? 0; 
                return Container(
                  margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(16), 
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(23), border: Border.all(color: kBorderGrey.withOpacity(0.65)), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 5))]), 
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start, 
                    children: [
                      Row(
                        children: [
                          Container(width: 46, height: 46, alignment: Alignment.center, decoration: BoxDecoration(color: isShared ? const Color(0xFFEEF2FF) : kBackgroundLight, borderRadius: BorderRadius.circular(15)), child: Icon(isShared ? Icons.people_alt_rounded : Icons.local_taxi_rounded, color: isShared ? kPremiumIndigo : kPremiumBlack, size: 23)), 
                          const SizedBox(width: 11), 
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(isShared ? 'CoCab Share' : 'Solo Ride', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15.5)), const SizedBox(height: 3), Text('Ride #${ride['id'] ?? index + 1}', style: const TextStyle(color: kTextGrey, fontSize: 11, fontWeight: FontWeight.w700))])), 
                          Text('₹$fare', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900))
                        ]
                      ), 
                      const SizedBox(height: 15), 
                      Row(
                        children: [
                          Column(children: [Container(width: 9, height: 9, decoration: const BoxDecoration(color: kPremiumGreen, shape: BoxShape.circle)), Container(width: 2, height: 24, color: kBorderGrey), Container(width: 9, height: 9, decoration: const BoxDecoration(color: Color(0xFFEF4444), shape: BoxShape.circle))]), 
                          const SizedBox(width: 11), 
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Pickup location', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: kTextGrey)), const SizedBox(height: 8), Text('Drop location • ${ride['shared_distance_km'] ?? 0} km', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: kPremiumBlack))]))
                        ]
                      ), 
                      if (isShared) ...[
                        const SizedBox(height: 12), 
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9), 
                          decoration: BoxDecoration(color: const Color(0xFFECFDF5), borderRadius: BorderRadius.circular(13)), 
                          child: Row(
                            children: [
                              const Icon(Icons.savings_rounded, color: kPremiumGreen, size: 17), 
                              const SizedBox(width: 7), 
                              Text('Saved ₹${ride['savings']} with CoCab', style: const TextStyle(color: Color(0xFF047857), fontSize: 11.5, fontWeight: FontWeight.w900))
                            ]
                          )
                        )
                      ]
                    ]
                  )
                ); 
              }
            )
    );
  }
}