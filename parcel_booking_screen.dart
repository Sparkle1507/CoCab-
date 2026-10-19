import 'package:flutter/material.dart';
import '../../../core/theme.dart';
import '../../../core/app_state.dart';
import '../../ride/screens/ride_screens.dart'; // Will be created in next step
import '../../ride/screens/destination_search_screen.dart';
class ParcelBookingScreen extends StatefulWidget {
  final String pickupAddress;
  final String dropAddress;
  final int baseFare;

  const ParcelBookingScreen({
    super.key, 
    required this.pickupAddress, 
    required this.dropAddress, 
    required this.baseFare
  });

  @override
  State<ParcelBookingScreen> createState() => _ParcelBookingScreenState();
}

class _ParcelBookingScreenState extends State<ParcelBookingScreen> {
  String selectedSize = 'Small';
  String selectedSpeed = 'Standard';
  late String _pickupAddress;
  late String _dropAddress;

  @override
  void initState() {
    super.initState();
    _pickupAddress = widget.pickupAddress;
    _dropAddress = widget.dropAddress;
  }

  @override
  Widget build(BuildContext context) {
    double distanceKm = 7.0; 
    int ratePerKm = 14; 
    if (selectedSize == 'Medium') {
      ratePerKm = 19; 
    } else if (selectedSize == 'Large') {
      ratePerKm = 21; 
    }

    int standardFare = (ratePerKm * distanceKm).round();
    int expressFare = standardFare + 40; 
    int totalFare = selectedSpeed == 'Standard' ? standardFare : expressFare;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F8FA),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                const Text('Send a parcel', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.black, letterSpacing: -0.5)),
                const SizedBox(height: 6),
                const Text('Fast, safe and right to your doorstep.', style: TextStyle(fontSize: 14, color: Colors.black54, fontWeight: FontWeight.w500)),
                const SizedBox(height: 24),

                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.grey.shade200),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(width: 12, height: 12, decoration: const BoxDecoration(color: Color(0xFF10B981), shape: BoxShape.circle)),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('PICKUP FROM', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.grey)),
                                const SizedBox(height: 4),
                                Text(_pickupAddress == widget.pickupAddress ? 'Current location' : _pickupAddress.split(',').first, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
                                const SizedBox(height: 2),
                                Text(_pickupAddress, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline, color: Colors.black54), 
                            onPressed: () async {
                              final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => DestinationSearchScreen(pickupAddress: _pickupAddress, pickupLatLng: LocationState.current.value.pickup)));
                              if (result != null) {
                                setState(() {
                                  _pickupAddress = result['dropoffName'];
                                });
                              }
                            }
                          )
                        ],
                      ),
                      Container(
                        margin: const EdgeInsets.only(left: 5),
                        height: 24,
                        alignment: Alignment.centerLeft,
                        child: Container(width: 2, height: 24, color: Colors.grey.shade300),
                      ),
                      Row(
                        children: [
                          Container(width: 12, height: 12, decoration: const BoxDecoration(color: Color(0xFFEF4444), shape: BoxShape.circle)),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('DELIVER TO', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.grey)),
                                const SizedBox(height: 4),
                                Text(_dropAddress == 'Select Drop Location' ? 'Select Drop Location' : _dropAddress.split(',').first, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
                                const SizedBox(height: 2),
                                Text(_dropAddress == 'Select Drop Location' ? 'Choose your delivery point' : _dropAddress, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline, color: Colors.black54), 
                            onPressed: () async {
                              final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => DestinationSearchScreen(pickupAddress: _pickupAddress, pickupLatLng: LocationState.current.value.pickup)));
                              if (result != null) {
                                setState(() {
                                  _dropAddress = result['dropoffName'];
                                });
                              }
                            }
                          )
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('What are you sending?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.black)),
                    Text('View guide', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.green.shade700)),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildSizeCard('Small', 'Up to 5 kg', Icons.mail_outline_rounded, selectedSize == 'Small'),
                    const SizedBox(width: 12),
                    _buildSizeCard('Medium', 'Up to 15 kg', Icons.inventory_2_outlined, selectedSize == 'Medium'),
                    const SizedBox(width: 12),
                    _buildSizeCard('Large', 'Up to 30 kg', Icons.inventory_outlined, selectedSize == 'Large'),
                  ],
                ),
                const SizedBox(height: 28),

                const Text('Delivery speed', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.black)),
                const SizedBox(height: 4),
                Text('Choose when it should arrive', style: TextStyle(fontSize: 13, color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
                const SizedBox(height: 16),
                _buildSpeedCard('Standard', 'Around 45 mins', '₹$standardFare', Icons.moped_rounded, selectedSpeed == 'Standard'),
                const SizedBox(height: 12),
                _buildSpeedCard('Express', 'Around 25 mins', '₹$expressFare', Icons.bolt_rounded, selectedSpeed == 'Express'),
                const SizedBox(height: 24),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey.shade200)),
                  child: Row(
                    children: [
                      Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.grey.shade100, shape: BoxShape.circle), child: const Icon(Icons.assignment_outlined, color: Colors.black87, size: 22)),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Package details', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.black)),
                            const SizedBox(height: 2),
                            Text('Enter contents, photo & handling instructions', style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -5))],
              borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            ),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Total fare', style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w600)),
                    Text('₹$totalFare', style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Colors.black)),
                  ],
                ),
                const SizedBox(width: 32),
                Expanded(
                  child: SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Searching for a delivery partner... 🛵')));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF065F46),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Book parcel', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20),
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSizeCard(String title, String weight, IconData icon, bool isSelected) {
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => selectedSize = title),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFECFDF5) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: isSelected ? const Color(0xFF10B981) : Colors.grey.shade200, width: isSelected ? 2 : 1),
          ),
          child: Column(
            children: [
              Icon(icon, color: isSelected ? const Color(0xFF065F46) : Colors.black54, size: 28),
              const SizedBox(height: 12),
              Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: isSelected ? const Color(0xFF065F46) : Colors.black)),
              const SizedBox(height: 4),
              Text(weight, style: TextStyle(fontSize: 10, color: isSelected ? const Color(0xFF065F46).withOpacity(0.8) : Colors.grey.shade600, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSpeedCard(String title, String desc, String price, IconData icon, bool isSelected) {
    return GestureDetector(
      onTap: () => setState(() => selectedSpeed = title),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFECFDF5) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? const Color(0xFF10B981) : Colors.grey.shade200, width: isSelected ? 2 : 1),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: isSelected ? Colors.white : Colors.grey.shade100, shape: BoxShape.circle),
              child: Icon(icon, color: isSelected ? const Color(0xFF065F46) : Colors.black87, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: isSelected ? const Color(0xFF065F46) : Colors.black)),
                  const SizedBox(height: 2),
                  Text(desc, style: TextStyle(fontSize: 12, color: isSelected ? const Color(0xFF065F46).withOpacity(0.8) : Colors.grey.shade600, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
            Text(price, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: isSelected ? const Color(0xFF065F46) : Colors.black)),
          ],
        ),
      ),
    );
  }
}