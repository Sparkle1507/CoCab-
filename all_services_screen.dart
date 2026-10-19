import 'package:flutter/material.dart';
import '../../../core/theme.dart';
import '../../../core/app_state.dart';
import '../../laundry/screens/laundry_screens.dart';
import '../../parcel/screens/parcel_booking_screen.dart';

class AllServicesScreen extends StatefulWidget {
  const AllServicesScreen({super.key});
  @override State<AllServicesScreen> createState() => _AllServicesScreenState();
}

class _AllServicesScreenState extends State<AllServicesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundLight, 
      appBar: AppBar(title: const Text('Services')), 
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 120), 
        children: [
          Container(
            padding: const EdgeInsets.all(20), 
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(26),
              image: const DecorationImage(
                image: AssetImage("assets/images/services_banner.png"), 
                fit: BoxFit.cover,
              ),
            ), 
            child: Row(
              children: [
                Container(
                  width: 48, 
                  height: 48, 
                  alignment: Alignment.center, 
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.20),
                    borderRadius: BorderRadius.circular(16),
                  ), 
                  child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 25),
                ), 
                const SizedBox(width: 13), 
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start, 
                    children: [
                      Text('Everything you need', style: TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.w900)), 
                      SizedBox(height: 4), 
                      Text('Ride, send, clean and explore from CoCab.', style: TextStyle(color: Colors.white70, fontSize: 12.5, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
              ],
            ),
          ), 
          const SizedBox(height: 18),
          const Text('Explore services', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, letterSpacing: -0.3)),
          const SizedBox(height: 10),
        GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14, 
            childAspectRatio: 0.82, // ✨ Text ulla ukkara height-a konjam yethiyachu ✨
            children: [
              // ✨ Thirumbavum Title text-a add panniyachu ✨
              _buildServiceCard(context, 'Laundry', 'assets/images/laundry.png', () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const LaundryShopsScreen()));
              }),
              _buildServiceCard(context, 'Parcel', 'assets/images/parcel.png', () { 
                Navigator.push(context, MaterialPageRoute(builder: (context) => ParcelBookingScreen(
                  pickupAddress: LocationState.current.value.address,
                  dropAddress: 'Select Drop Location',
                  baseFare: 60,
                ))); 
              }),
              _buildServiceCard(context, 'Food', 'assets/images/food.png', () {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Food delivery coming soon! 🍔')));
              }),
            ],
          )
        ],
      ),
    );
  }

  // ✨ INGA IMAGE.ASSET NU PAKKAVA MATHIYACHU ✨
// ✨ Title parameter-a thookiyachu, verum imagePath mattum dhaan
 // ✨ Title parameter-a thirumbavum ulla vangitom ✨
  Widget _buildServiceCard(BuildContext context, String title, String imagePath, VoidCallback onTap) {
    final iconTint = title == 'Laundry' ? kPremiumIndigo : (title == 'Parcel' ? kPremiumGreen : const Color(0xFFF59E0B));
    
    return GestureDetector(
      onTap: onTap, 
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.035), 
              blurRadius: 12, 
              offset: const Offset(0, 4)
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✨ TOP PART: Image is expanded and centered with minimal padding
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(4.0), // ✨ Padding-a romba korachachu! Ippo Image full length-kkum scale aagum.
                child: Center(
                  child: Image.asset(
                    imagePath, 
                    fit: BoxFit.contain, // ✨ full space capture aaga 'fit' is important mams
                  ), 
                ),
              ),
            ),
            
            // ✨ BOTTOM PART: Super compact area - mark border and size reduction parameters here
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 12), // ✨ Top and bottom padding-a tight compact padding pottachu
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min, 
                children: [
                  Text(
                    title, 
                    style: const TextStyle(
                      fontSize: 16.5, // Bold visual display standard scale
                      fontWeight: FontWeight.w900, 
                      color: Color(0xFF1F2937),
                    )
                  ), 
                  const SizedBox(height: 2), // custom margin gap
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Open service', 
                        style: TextStyle(
                          fontSize: 10.5, 
                          color: Color(0xFF9CA3AF), 
                          fontWeight: FontWeight.w700,
                        )
                      ),
                      Icon(
                        Icons.arrow_forward_rounded, 
                        size: 16, 
                        color: iconTint,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}