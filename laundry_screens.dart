import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../core/theme.dart';
import '../../../core/app_state.dart';
import '../../ride/screens/ride_screens.dart';  
import '../../ride/screens/destination_search_screen.dart';
class LaundryShopsScreen extends StatefulWidget {
  const LaundryShopsScreen({super.key});
  @override
  State<LaundryShopsScreen> createState() => _LaundryShopsScreenState();
}

class _LaundryShopsScreenState extends State<LaundryShopsScreen> {
  List<dynamic> realShops = [];
  List<dynamic> filteredShops = [];
  bool isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  String _selectedService = 'Wash & Fold';

  @override
  void initState() {
    super.initState();
    _fetchRealShops();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchRealShops() async {
    final locState = LocationState.current.value;
    try {
      final url = Uri.parse('http://127.0.0.1:8000/nearby_laundries?lat=${locState.pickup.latitude}&lon=${locState.pickup.longitude}');
      final response = await http.get(url).timeout(const Duration(seconds: 15));
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            realShops = data['shops'] ?? [];
            filteredShops = realShops;
            isLoading = false;
          });
        }
      } else {
         if (mounted) setState(() { realShops = []; filteredShops = []; isLoading = false; });
      }
    } catch (e) {
      if (mounted) setState(() { realShops = []; filteredShops = []; isLoading = false; });
    }
  }

  void _filterShops(String query) {
    if (query.isEmpty) {
      setState(() => filteredShops = realShops);
      return;
    }
    setState(() {
      filteredShops = realShops.where((shop) {
        final name = (shop['name'] ?? '').toLowerCase();
        final address = (shop['address'] ?? '').toLowerCase();
        final searchLower = query.toLowerCase();
        return name.contains(searchLower) || address.contains(searchLower);
      }).toList();
    });
  }

  Widget _buildEmptyState(String title, String subtitle) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.local_laundry_service_outlined, size: 80, color: kBorderGrey),
            const SizedBox(height: 16),
            Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color.fromARGB(255, 0, 0, 0)), textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(subtitle, style: const TextStyle(fontSize: 14, color: kTextGrey, fontWeight: FontWeight.w500), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildLaundryServiceCard(String title, String subtitle, IconData icon) {
    bool isSelected = _selectedService == title;
    return GestureDetector(
      onTap: () => setState(() => _selectedService = title),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFECFDF5) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isSelected ? kPremiumGreen : kBorderGrey),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isSelected ? kPremiumGreen : kTextGrey, size: 32),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
            const SizedBox(height: 2),
            Text(subtitle, style: const TextStyle(color: kTextGrey, fontSize: 11, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA), 
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F8FA),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Laundry', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
        centerTitle: true,
      ), 
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white, 
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.grey.shade200, width: 1.5), 
                  boxShadow: [BoxShadow(color: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 3))], 
                ),
                child: TextField(
                  controller: _searchController, 
                  onChanged: _filterShops, 
                  style: const TextStyle(fontWeight: FontWeight.w600, color: kPremiumBlack),
                  decoration: InputDecoration(
                    hintText: 'Search laundry services...', 
                    hintStyle: TextStyle(color: Colors.grey.shade400, fontWeight: FontWeight.w600), 
                    prefixIcon: const Icon(Icons.search_rounded, color: kTextGrey), 
                    suffixIcon: _searchController.text.isNotEmpty 
                        ? IconButton(icon: const Icon(Icons.clear_rounded, color: kTextGrey), onPressed: () { _searchController.clear(); _filterShops(''); setState(() {}); }) 
                        : const Icon(Icons.mic_none_rounded, color: kTextGrey), 
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    filled: false,
                    contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                  )
                )
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: kPremiumIndigo.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                child: const Text('CHOOSE A SERVICE', style: TextStyle(fontSize: 10, color: kPremiumIndigo, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('What do you need?', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: kPremiumBlack)),
                  Text('View all', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: kPremiumGreen.withOpacity(0.8))),
                ],
              ),
              const SizedBox(height: 16),
              GridView.count(
                shrinkWrap: true, 
                physics: const NeverScrollableScrollPhysics(), 
                crossAxisCount: 2, 
                crossAxisSpacing: 12, 
                mainAxisSpacing: 12, 
                childAspectRatio: 1.35, 
                children: [
                  _buildLaundryServiceCard('Wash & Fold', 'Everyday wear', Icons.checkroom_rounded),
                  _buildLaundryServiceCard('Dry Cleaning', 'Premium care', Icons.dry_cleaning_rounded),
                  _buildLaundryServiceCard('Ironing', 'Crisp & neat', Icons.local_laundry_service_rounded),
                  _buildLaundryServiceCard('Home Linen', 'Bedding & more', Icons.bed_rounded),
                ],
              ),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF065F46),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(6)),
                      child: const Text('FIRST ORDER', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1.0)),
                    ),
                    const SizedBox(height: 12),
                    const Text('Fresh clothes, less work.', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 4),
                    Text('Get 30% off your first laundry pickup.', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const LaundryPickupTaskScreen()));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF065F46),
                        minimumSize: const Size(120, 38),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Book a pickup', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12)),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Popular near you', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: kPremiumBlack)),
                  Text('${filteredShops.length} places', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: kTextGrey)),
                ],
              ),
              const SizedBox(height: 16),
              if (isLoading) 
                const Padding(padding: EdgeInsets.only(top: 20), child: Center(child: CircularProgressIndicator(color: kPremiumIndigo))) 
              else if (realShops.isEmpty) 
                _buildEmptyState('No shops found nearby', 'Try changing your pickup location on the home screen.') 
              else if (filteredShops.isEmpty) 
                _buildEmptyState('No match found', "We couldn't find any shop matching your search.") 
              else 
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.only(bottom: 40), 
                  itemCount: filteredShops.length, 
                  itemBuilder: (context, index) { 
                    final shop = filteredShops[index]; 
                    return GestureDetector(
                      onTap: () { Navigator.push(context, MaterialPageRoute(builder: (context) => LaundryTrackingScreen(shopData: shop))); },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12), 
                        padding: const EdgeInsets.all(16), 
                        decoration: BoxDecoration(
                          color: Colors.white, 
                          borderRadius: BorderRadius.circular(20), 
                          border: Border.all(color: kBorderGrey.withOpacity(0.8)), 
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))]
                        ), 
                        child: Row(
                          children: [
                            Container(
                              width: 52, height: 52, alignment: Alignment.center, 
                              decoration: BoxDecoration(color: const Color(0xFFECFDF5), borderRadius: BorderRadius.circular(14)), 
                              child: const Icon(Icons.local_laundry_service_rounded, color: kPremiumGreen, size: 26)
                            ), 
                            const SizedBox(width: 14), 
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(shop['name'] ?? 'Laundry Shop', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
                                  const SizedBox(height: 4),
                                  Text(shop['address'] ?? '', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: kTextGrey, fontSize: 12, fontWeight: FontWeight.w500)),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      Text('$_selectedService • ', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: kTextGrey)),
                                      const Text('₹75/kg', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: kPremiumGreen)),
                                    ],
                                  )
                                ],
                              )
                            ), 
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4), 
                                  decoration: BoxDecoration(color: kPremiumGreen, borderRadius: BorderRadius.circular(6)), 
                                  child: const Row(
                                    children: [
                                      Text('4.8', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 11)),
                                      SizedBox(width: 2),
                                      Icon(Icons.star_rounded, color: Colors.white, size: 10)
                                    ],
                                  )
                                ),
                                const SizedBox(height: 12),
                                Text(shop['distance'] ?? 'N/A', style: const TextStyle(color: kTextGrey, fontWeight: FontWeight.w800, fontSize: 11))
                              ],
                            )
                          ]
                        )
                      ),
                    ); 
                  }
                )
            ]
          )
        )
      )
    );
  }
}

class LaundryTrackingScreen extends StatefulWidget {
  final Map<String, dynamic> shopData;
  const LaundryTrackingScreen({super.key, required this.shopData});
  @override State<LaundryTrackingScreen> createState() => _LaundryTrackingScreenState();
}

class _LaundryTrackingScreenState extends State<LaundryTrackingScreen> with SingleTickerProviderStateMixin {
  final MapController _mapController = MapController();
  late AnimationController _carController;
  late Animation<double> _carAnimation;
  
  LatLng _userLocation = LocationState.current.value.pickup;
  late LatLng _shopLocation;
  late LatLng _currentLocation;
  
  List<LatLng> _routePoints = [];
  String _status = "Assigning Captain...";
  String _actionText = "";
  int _flowStep = 0; 

  @override
  void initState() {
    super.initState();
    _shopLocation = LatLng(widget.shopData["lat"] ?? 13.0, widget.shopData["lng"] ?? 80.2);
    _currentLocation = _userLocation;
    
    _carController = AnimationController(vsync: this, duration: const Duration(seconds: 5));
    _carAnimation = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _carController, curve: Curves.linear));
    _carAnimation.addListener(_updatePosition);
    _carController.addStatusListener((s) {
      if (s == AnimationStatus.completed && mounted) {
        if (_flowStep == 2) setState(() { _flowStep = 3; _status = "Clothes Washing at ${widget.shopData['name']} 🫧"; _actionText = "Wash Complete - Bring Back"; });
        if (_flowStep == 4) setState(() { _flowStep = 5; _status = "Rider Arrived at Your Location"; _actionText = "Verify Delivery OTP: 9999"; });
      }
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() { _flowStep = 1; _status = "Rider Arrived!"; _actionText = "Verify Pickup OTP: 1616 & Upload Photo"; });
    });
  }

  void _generateSimpleRoute(LatLng start, LatLng end) {
    _routePoints = [start, LatLng(start.latitude, end.longitude), end];
  }

  void _updatePosition() {
    if (_routePoints.isEmpty) return;
    double p = _carAnimation.value;
    if (p < 0.5) {
      double localP = p * 2;
      _currentLocation = LatLng(_routePoints[0].latitude + (_routePoints[1].latitude - _routePoints[0].latitude) * localP, _routePoints[0].longitude + (_routePoints[1].longitude - _routePoints[0].longitude) * localP);
    } else {
      double localP = (p - 0.5) * 2;
      _currentLocation = LatLng(_routePoints[1].latitude + (_routePoints[2].latitude - _routePoints[1].latitude) * localP, _routePoints[1].longitude + (_routePoints[2].longitude - _routePoints[1].longitude) * localP);
    }
    setState(() {});
    _mapController.move(_currentLocation, 14.0);
  }

  void _handleActionButton() {
    if (_flowStep == 1) {
      showDialog(context: context, builder: (c) => AlertDialog(
        title: const Text("Photo Uploaded ✅"),
        content: const Text("Clothes verified. Rider is taking them to the shop."),
        actions: [TextButton(onPressed: () {
          Navigator.pop(context);
          setState(() { _flowStep = 2; _status = "Heading to Shop..."; _actionText = ""; });
          _generateSimpleRoute(_userLocation, _shopLocation);
          _carController.forward(from: 0);
        }, child: const Text("OK", style: TextStyle(color: kPremiumIndigo)))],
      ));
    } else if (_flowStep == 3) {
      setState(() { _flowStep = 4; _status = "Washed Clothes Returning..."; _actionText = ""; });
      _generateSimpleRoute(_shopLocation, _userLocation);
      _carController.forward(from: 0);
    } else if (_flowStep == 5) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Delivery Successful! 👕✨'), backgroundColor: kPremiumGreen));
      Navigator.pop(context);
    }
  }

  @override void dispose() { _carController.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController, options: MapOptions(initialCenter: _userLocation, initialZoom: 13.0), 
            children: [
              TileLayer(urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png', userAgentPackageName: 'com.example.cocab'), 
              if (_routePoints.isNotEmpty) 
                PolylineLayer(polylines: [Polyline(points: _routePoints, strokeWidth: 4.0, color: kPremiumIndigo)]), 
              MarkerLayer(
                markers: [
                  Marker(point: _userLocation, child: const Icon(Icons.home_rounded, color: kPremiumGreen, size: 34)), 
                  Marker(point: _shopLocation, child: const Icon(Icons.local_laundry_service_rounded, color: kPremiumIndigo, size: 34)), 
                  if (_flowStep == 2 || _flowStep == 4) 
                    Marker(point: _currentLocation, child: const Icon(Icons.directions_bike_rounded, color: kPremiumBlack, size: 36))
                ]
              )
            ]
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16), 
              child: GestureDetector(
                onTap: () => Navigator.pop(context), 
                child: Container(width: 48, height: 48, alignment: Alignment.center, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(17), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 16, offset: const Offset(0, 6))]), child: const Icon(Icons.arrow_back_ios_new_rounded, size: 19))
              )
            )
          ),
          Align(
            alignment: Alignment.bottomCenter, 
            child: Container(
              margin: const EdgeInsets.fromLTRB(12, 0, 12, 12), padding: const EdgeInsets.all(18), 
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(28), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.13), blurRadius: 28, offset: const Offset(0, 8))]), 
              child: Column(
                mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, 
                children: [
                  Row(
                    children: [
                      Container(width: 46, height: 46, alignment: Alignment.center, decoration: BoxDecoration(color: kBackgroundLight, borderRadius: BorderRadius.circular(15)), child: const Icon(Icons.local_laundry_service_rounded, color: kPremiumIndigo, size: 24)), 
                      const SizedBox(width: 12), 
                      Expanded(child: Text(_status, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: kPremiumBlack))),
                    ]
                  ), 
                  const SizedBox(height: 8), 
                  Text(widget.shopData['name'] ?? 'Laundry partner', style: const TextStyle(color: kTextGrey, fontWeight: FontWeight.w600, fontSize: 12)), 
                  if (_actionText.isNotEmpty) ...[
                    const SizedBox(height: 14), 
                    SizedBox(
                      width: double.infinity, height: 52, 
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: kPremiumIndigo), 
                        onPressed: _handleActionButton, 
                        child: Text(_actionText, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14))
                      )
                    )
                  ]
                ]
              )
            )
          )
        ]
      )
    );
  }
}

class LaundryPickupTaskScreen extends StatefulWidget {
  const LaundryPickupTaskScreen({super.key});

  @override
  State<LaundryPickupTaskScreen> createState() => _LaundryPickupTaskScreenState();
}

class _LaundryPickupTaskScreenState extends State<LaundryPickupTaskScreen> {
  String _pickupAddress = "Current Location";
  String _dropAddress = "Cocoab Care Laundry, 2nd...";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              child: Row(
                children: [
                  _buildStepCircle('1', 'Pickup', isActive: true),
                  Expanded(child: Container(height: 2, color: Colors.grey.shade300)),
                  _buildStepCircle('2', 'Verify', isActive: false),
                  Expanded(child: Container(height: 2, color: Colors.grey.shade300)),
                  _buildStepCircle('3', 'Delivery', isActive: false),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(color: const Color(0xFFECFDF5), borderRadius: BorderRadius.circular(6)),
                            child: const Text('PICKUP BY 10:30 AM', style: TextStyle(color: kPremiumGreen, fontSize: 10, fontWeight: FontWeight.w900)),
                          ),
                          const SizedBox(height: 12),
                          const Text('Laundry pickup &\ndelivery', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: kPremiumBlack, height: 1.2)),
                          const SizedBox(height: 6),
                          Text('Collect, verify and deliver to the laundry', style: TextStyle(color: Colors.grey.shade600, fontSize: 13, fontWeight: FontWeight.w500)),
                          
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: Divider(height: 1, thickness: 1, color: Color(0xFFF0F0F0)),
                          ),

                          Row(
                            children: [
                              Container(
                                width: 40, height: 40,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(color: Colors.grey.shade200, shape: BoxShape.circle),
                                child: const Text('AK', style: TextStyle(fontWeight: FontWeight.w800, color: Colors.black87)),
                              ),
                              const SizedBox(width: 12),
                              const Expanded(child: Text('Arun Kumar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800))),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(20)),
                                child: const Row(
                                  children: [
                                    Icon(Icons.checkroom_rounded, size: 14, color: Colors.black87),
                                    SizedBox(width: 4),
                                    Text('8 clothes', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.black87))
                                  ],
                                ),
                              )
                            ],
                          ),

                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: Divider(height: 1, thickness: 1, color: Color(0xFFF0F0F0)),
                          ),

                          IntrinsicHeight(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Column(
                                  children: [
                                    const Icon(Icons.arrow_upward_rounded, size: 16, color: kPremiumBlack),
                                    Expanded(child: Container(width: 2, color: Colors.grey.shade300, margin: const EdgeInsets.symmetric(vertical: 4))),
                                    const Icon(Icons.store_rounded, size: 16, color: Colors.grey),
                                  ],
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('PICKUP - CUSTOMER', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.grey)),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(_pickupAddress, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: kPremiumBlack)),
                                          ),
                                          IconButton(
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(),
                                            icon: const Icon(Icons.add_circle_outline, color: Colors.black54, size: 20),
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
                                      const SizedBox(height: 2),
                                      Text('Anna Nagar • 1.2 km from shop', style: TextStyle(fontSize: 12, color: Colors.grey.shade500, fontWeight: FontWeight.w500)),
                                      
                                      const SizedBox(height: 24),
                                      
                                      const Text('DELIVERY - LAUNDRY SHOP', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.grey)),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(_dropAddress, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: kPremiumBlack)),
                                          ),
                                          IconButton(
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(),
                                            icon: const Icon(Icons.add_circle_outline, color: Colors.black54, size: 20),
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
                                      const SizedBox(height: 2),
                                      Text('Anna Nagar • 2.8 km from pickup', style: TextStyle(fontSize: 12, color: Colors.grey.shade500, fontWeight: FontWeight.w500)),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFFECFDF5),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: const Color(0xFF10B981)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.photo_camera_front_rounded, color: kPremiumGreen, size: 20),
                              SizedBox(width: 8),
                              Text('Photo verification', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: kPremiumGreen)),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text('Place all clothes in one frame and take a clear photo before picking up.', style: TextStyle(fontSize: 12, color: Colors.green.shade800, fontWeight: FontWeight.w500)),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity, height: 48,
                            child: OutlinedButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.camera_alt_outlined, size: 18),
                              label: const Text('Take pickup photo', style: TextStyle(fontWeight: FontWeight.w800)),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: kPremiumGreen,
                                side: const BorderSide(color: kPremiumGreen, width: 1.5),
                                backgroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -5))],
              ),
              child: SizedBox(
                width: double.infinity, height: 56,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: kPremiumBlack,
                    side: const BorderSide(color: kBorderGrey, width: 1.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Start delivery to laundry shop', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward_rounded, size: 18),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildStepCircle(String step, String label, {required bool isActive}) {
    return Column(
      children: [
        Container(
          width: 28, height: 28,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isActive ? kPremiumGreen : Colors.grey.shade200,
            shape: BoxShape.circle,
          ),
          child: Text(step, style: TextStyle(color: isActive ? Colors.white : Colors.grey.shade600, fontWeight: FontWeight.w900, fontSize: 12)),
        ),
        const SizedBox(height: 6),
        Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: isActive ? kPremiumBlack : Colors.grey.shade500)),
      ],
    );
  }
}
