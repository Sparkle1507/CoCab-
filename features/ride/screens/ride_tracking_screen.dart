import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:js' as js;

import '../../../core/app_state.dart';
import '../../../navigation/main_navigation_screen.dart';

class RideTrackingScreen extends StatefulWidget {
  final LatLng pickup;
  final LatLng dropoff;
  final Map<String, dynamic> rideData;
  final String rideType;
  const RideTrackingScreen({
    super.key,
    required this.pickup,
    required this.dropoff,
    required this.rideData,
    required this.rideType,
  });
  @override
  State<RideTrackingScreen> createState() => _RideTrackingScreenState();
}

class _RideTrackingScreenState extends State<RideTrackingScreen>
    with TickerProviderStateMixin {
  final MapController _mapController = MapController();
  late AnimationController _carController;
  late AnimationController _pulseController;
  late Animation<double> _carAnimation;
  late LatLng _startLocation;
  late LatLng _currentLocation;
  double _carHeading = 0.0;
  final LatLng passengerB = const LatLng(13.0300, 80.1700);

  List<LatLng> _routePoints = [];
  List<double> _cumulativeDistances = [];
  double _totalDistance = 0.0;

  // Brand
  final Color kLiteGreen = const Color(0xFFC7F365);
  final Color kCardBg = Colors.white;
  final Color kBgColor = const Color(0xFFF4F6F5);
  final Color kDarkText = const Color(0xFF111827);
  final Color kMint = const Color(0xFFE7F6EA);
  final Color kForest = const Color(0xFF16382C);
  final Color kMuted = const Color(0xFF6B7280);

  @override
  void initState() {
    super.initState();
    _startLocation = LatLng(widget.pickup.latitude - 0.015, widget.pickup.longitude - 0.015);
    _currentLocation = _startLocation;
    _carController = AnimationController(vsync: this, duration: const Duration(seconds: 18));
    _carAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _carController, curve: Curves.easeInOut),
    );
    _carAnimation.addListener(_updatePosition);

    _pulseController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1600))
      ..repeat(reverse: true);

    _fetchRoute();
  }

  Future<void> _fetchRoute() async {
    String waypoints =
        '${_startLocation.longitude},${_startLocation.latitude};${widget.pickup.longitude},${widget.pickup.latitude}';
    if (widget.rideType == "shared") {
      waypoints += ';${passengerB.longitude},${passengerB.latitude}';
    }
    waypoints += ';${widget.dropoff.longitude},${widget.dropoff.latitude}';
    try {
      final res = await http.get(
        Uri.parse('https://router.project-osrm.org/route/v1/driving/$waypoints?geometries=geojson'),
      );
      if (res.statusCode == 200) {
        final d = jsonDecode(res.body);
        if (d['code'] == 'Ok') {
          _routePoints = (d['routes'][0]['geometry']['coordinates'] as List)
              .map((p) => LatLng(p[1], p[0]))
              .toList();
          final distObj = const Distance();
          _cumulativeDistances = [0.0];
          _totalDistance = 0.0;
          for (int i = 0; i < _routePoints.length - 1; i++) {
            double dist = distObj.distance(_routePoints[i], _routePoints[i + 1]);
            _totalDistance += dist;
            _cumulativeDistances.add(_totalDistance);
          }
        }
      }
    } catch (e) {}
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) _carController.forward();
    });
  }

  void _updatePosition() {
    if (_routePoints.isEmpty || _totalDistance == 0) return;
    double target = _carAnimation.value * _totalDistance;
    for (int i = 0; i < _routePoints.length - 1; i++) {
      if (target <= _cumulativeDistances[i + 1]) {
        double p = (target - _cumulativeDistances[i]) / (_cumulativeDistances[i + 1] - _cumulativeDistances[i]);
        setState(() {
          _currentLocation = LatLng(
            _routePoints[i].latitude + (_routePoints[i + 1].latitude - _routePoints[i].latitude) * p,
            _routePoints[i].longitude + (_routePoints[i + 1].longitude - _routePoints[i].longitude) * p,
          );
          _carHeading = _calculateBearing(_routePoints[i], _routePoints[i + 1]);
        });
        _mapController.move(_currentLocation, 15.5);
        break;
      }
    }
  }

  double _calculateBearing(LatLng start, LatLng end) {
    double lat1 = start.latitude * math.pi / 180, lon1 = start.longitude * math.pi / 180;
    double lat2 = end.latitude * math.pi / 180, lon2 = end.longitude * math.pi / 180;
    double dLon = lon2 - lon1;
    double y = math.sin(dLon) * math.cos(lat2);
    double x = math.cos(lat1) * math.sin(lat2) - math.sin(lat1) * math.cos(lat2) * math.cos(dLon);
    return ((math.atan2(y, x) * 180 / math.pi) + 360) % 360 * math.pi / 180;
  }

  @override
  void dispose() {
    _carController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Widget _buildF1CarMarker() {
    return Transform.rotate(
      angle: _carHeading,
      child: SizedBox(
        width: 32,
        height: 58,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(top: 8, left: 0, child: _wheel(6, 14)),
            Positioned(top: 8, right: 0, child: _wheel(6, 14)),
            Positioned(bottom: 6, left: 0, child: _wheel(7, 16)),
            Positioned(bottom: 6, right: 0, child: _wheel(7, 16)),
            Positioned(
              top: 0,
              child: Container(
                width: 22,
                height: 4,
                decoration: BoxDecoration(color: kDarkText, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            Positioned(
              bottom: 0,
              child: Container(
                width: 26,
                height: 6,
                decoration: BoxDecoration(color: kDarkText, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            Positioned(
              top: 4,
              bottom: 4,
              child: Container(
                width: 11,
                decoration: BoxDecoration(color: kDarkText, borderRadius: BorderRadius.circular(4)),
              ),
            ),
            Positioned(
              top: 18,
              bottom: 14,
              child: Container(
                width: 18,
                decoration: BoxDecoration(
                  color: kLiteGreen,
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: [
                    BoxShadow(color: kLiteGreen.withOpacity(0.55), blurRadius: 8, spreadRadius: 0.5),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 24,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: Colors.black54, blurRadius: 2)],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _wheel(double w, double h) {
    return Container(
      width: w,
      height: h,
      decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(3)),
    );
  }

  Widget _buildPinBox(String digit) {
    return Container(
      width: 46,
      height: 54,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFFFBFDF6),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFD8E8A8), width: 1.4),
        boxShadow: [
          BoxShadow(color: kLiteGreen.withOpacity(0.22), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Text(
        digit,
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w900,
          color: kDarkText,
          fontFamily: 'Poppins',
          height: 1,
        ),
      ),
    );
  }

  Widget _glassCircle({required Widget child, required VoidCallback onTap}) {
    return ClipOval(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Material(
          color: Colors.white.withOpacity(0.86),
          child: InkWell(
            onTap: onTap,
            child: SizedBox(width: 44, height: 44, child: Center(child: child)),
          ),
        ),
      ),
    );
  }

  Widget _dotPin({required Color color, required Color ring}) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 3.5),
        boxShadow: [
          BoxShadow(color: color.withOpacity(0.35), blurRadius: 10, spreadRadius: 1),
        ],
      ),
    );
  }

  Widget _sectionCard({
    required Widget child,
    Color? color,
    EdgeInsets padding = EdgeInsets.zero,
    Color? border,
  }) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? kCardBg,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: border ?? Colors.white, width: 1),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(0.045),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _label(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.15,
        color: Colors.grey.shade500,
        fontFamily: 'Poppins',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: kBgColor,
        body: Stack(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.48,
              child: FlutterMap(
                mapController: _mapController,
                options: MapOptions(initialCenter: widget.pickup, initialZoom: 15.0),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.cocab',
                  ),
                  if (_routePoints.isNotEmpty)
                    PolylineLayer(
                      polylines: [
                        Polyline(points: _routePoints, strokeWidth: 10, color: kLiteGreen.withOpacity(0.28)),
                        Polyline(points: _routePoints, strokeWidth: 5.2, color: kDarkText),
                      ],
                    ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: widget.pickup,
                        width: 28,
                        height: 28,
                        child: _dotPin(color: kDarkText, ring: Colors.white),
                      ),
                      Marker(
                        point: widget.dropoff,
                        width: 28,
                        height: 28,
                        child: _dotPin(color: const Color(0xFFE11D48), ring: Colors.white),
                      ),
                      Marker(
                        point: _currentLocation,
                        width: 110,
                        height: 110,
                        child: AnimatedBuilder(
                          animation: _pulseController,
                          builder: (_, __) {
                            final t = 0.55 + (_pulseController.value * 0.45);
                            return Stack(
                              alignment: Alignment.center,
                              children: [
                                Container(
                                  width: 86 * t,
                                  height: 86 * t,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: kLiteGreen.withOpacity(0.18 + (0.12 * _pulseController.value)),
                                  ),
                                ),
                                Container(
                                  width: 54,
                                  height: 54,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: kLiteGreen.withOpacity(0.32),
                                    border: Border.all(color: Colors.white.withOpacity(0.7), width: 2),
                                  ),
                                ),
                                _buildF1CarMarker(),
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              top: MediaQuery.of(context).size.height * 0.32,
              height: MediaQuery.of(context).size.height * 0.16,
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        kBgColor.withOpacity(0),
                        kBgColor.withOpacity(0.55),
                        kBgColor,
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: topPad + 8,
              left: 16,
              right: 16,
              child: Row(
                children: [
                  _glassCircle(
                    onTap: () => Navigator.of(context).maybePop(),
                    child: Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: kDarkText),
                  ),
                  const Spacer(),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(22),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        color: Colors.white.withOpacity(0.88),
                        child: Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: const Color(0xFF16A34A),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(color: const Color(0xFF16A34A).withOpacity(0.55), blurRadius: 6),
                                ],
                              ),
                            ),
                            const SizedBox(width: 7),
                            Text(
                              'LIVE',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.1,
                                color: kDarkText,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  _glassCircle(
                    onTap: () {},
                    child: Icon(Icons.sos_rounded, size: 18, color: const Color(0xFFB91C1C)),
                  ),
                ],
              ),
            ),
            DraggableScrollableSheet(
              initialChildSize: 0.62,
              minChildSize: 0.62,
              maxChildSize: 0.95,
              snap: true,
              builder: (context, scrollController) {
                return Container(
                  decoration: BoxDecoration(
                    color: kBgColor,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.10),
                        blurRadius: 28,
                        offset: const Offset(0, -8),
                      ),
                    ],
                  ),
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 36),
                    children: [
                      Center(
                        child: Container(
                          width: 42,
                          height: 5,
                          margin: const EdgeInsets.only(bottom: 14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD1D5DB),
                            borderRadius: BorderRadius.circular(99),
                          ),
                        ),
                      ),
                      _sectionCard(
                        child: Column(
                          children: [
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 11),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [kLiteGreen, const Color(0xFFD6F78A)],
                                ),
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.directions_walk_rounded, size: 16, color: Color(0xFF1F2937)),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Walk to your pickup point',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 13,
                                      color: kDarkText,
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        RichText(
                                          text: TextSpan(
                                            style: TextStyle(
                                              fontSize: 22,
                                              fontWeight: FontWeight.w800,
                                              color: kDarkText,
                                              fontFamily: 'Poppins',
                                              height: 1.15,
                                            ),
                                            children: [
                                              const TextSpan(text: 'Pickup in '),
                                              TextSpan(
                                                text: '2 mins',
                                                style: TextStyle(
                                                  color: const Color(0xFF15803D),
                                                  fontWeight: FontWeight.w900,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Row(
                                          children: [
                                            Container(
                                              width: 6,
                                              height: 6,
                                              decoration: const BoxDecoration(
                                                color: Color(0xFF22C55E),
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              'Captain is 200 m away',
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: kMuted,
                                                fontWeight: FontWeight.w600,
                                                fontFamily: 'Poppins',
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    width: 52,
                                    height: 52,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF7F8F7),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(color: const Color(0xFFE5E7EB)),
                                    ),
                                    child: Icon(Icons.map_outlined, color: kDarkText.withOpacity(0.7), size: 24),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      _sectionCard(
                        padding: const EdgeInsets.fromLTRB(18, 18, 16, 18),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _label('START YOUR RIDE WITH'),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Share PIN with\ncaptain',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      height: 1.2,
                                      color: kDarkText,
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                _buildPinBox('1'),
                                const SizedBox(width: 6),
                                _buildPinBox('8'),
                                const SizedBox(width: 6),
                                _buildPinBox('3'),
                                const SizedBox(width: 6),
                                _buildPinBox('3'),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      _sectionCard(
                        color: kMint,
                        border: Colors.white.withOpacity(0.9),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(18, 16, 14, 12),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        _label('LOOKING NEARBY'),
                                        const SizedBox(height: 3),
                                        Text(
                                          'Want a closer captain?',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w800,
                                            color: kDarkText,
                                            fontFamily: 'Poppins',
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Material(
                                    color: kLiteGreen,
                                    borderRadius: BorderRadius.circular(22),
                                    child: InkWell(
                                      onTap: () {},
                                      borderRadius: BorderRadius.circular(22),
                                      child: const Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 13, vertical: 8),
                                        child: Row(
                                          children: [
                                            Icon(Icons.sync_rounded, color: Color(0xFF111827), size: 15),
                                            SizedBox(width: 4),
                                            Text(
                                              'Check',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w800,
                                                fontSize: 13,
                                                color: Color(0xFF111827),
                                                fontFamily: 'Poppins',
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Divider(height: 1, color: Colors.white.withOpacity(0.75)),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(18, 16, 18, 8),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(child: _numberPlate('TN 22 EB 7807')),
                                            const SizedBox(width: 8),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.circular(20),
                                                border: Border.all(color: const Color(0xFFE5E7EB)),
                                              ),
                                              child: const Row(
                                                children: [
                                                  Text(
                                                    '4.9',
                                                    style: TextStyle(
                                                      fontWeight: FontWeight.w800,
                                                      fontSize: 12,
                                                      fontFamily: 'Poppins',
                                                    ),
                                                  ),
                                                  SizedBox(width: 3),
                                                  Icon(Icons.star_rounded, color: Color(0xFFF59E0B), size: 14),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Maruti Suzuki Tour S',
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: kMuted,
                                            fontWeight: FontWeight.w600,
                                            fontFamily: 'Poppins',
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        Row(
                                          children: [
                                            Container(
                                              width: 42,
                                              height: 42,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                gradient: LinearGradient(
                                                  colors: [kLiteGreen, const Color(0xFF9ED44A)],
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                ),
                                                border: Border.all(color: Colors.white, width: 2),
                                              ),
                                              alignment: Alignment.center,
                                              child: Text(
                                                'AV',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w900,
                                                  fontSize: 13,
                                                  color: kForest,
                                                  fontFamily: 'Poppins',
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                _label('YOUR CAPTAIN'),
                                                const SizedBox(height: 2),
                                                Text(
                                                  'Aakash V',
                                                  style: TextStyle(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.w800,
                                                    color: kDarkText,
                                                    fontFamily: 'Poppins',
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  SizedBox(
                                    height: 72,
                                    child: Align(
                                      alignment: Alignment.centerRight,
                                      child: _carIllustration(),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: OutlinedButton.icon(
                                          onPressed: () {},
                                          icon: Icon(Icons.chat_bubble_outline_rounded, size: 17, color: kDarkText),
                                          label: Text(
                                            'Message Aakash',
                                            style: TextStyle(
                                              fontSize: 13.5,
                                              fontWeight: FontWeight.w800,
                                              color: kDarkText,
                                              fontFamily: 'Poppins',
                                            ),
                                          ),
                                          style: OutlinedButton.styleFrom(
                                            backgroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(vertical: 14),
                                            side: const BorderSide(color: Color(0xFFE5E7EB), width: 1.4),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Material(
                                        color: kForest,
                                        borderRadius: BorderRadius.circular(16),
                                        child: InkWell(
                                          onTap: () {},
                                          borderRadius: BorderRadius.circular(16),
                                          child: const SizedBox(
                                            width: 52,
                                            height: 52,
                                            child: Icon(Icons.call_rounded, color: Colors.white, size: 22),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      _sectionCard(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                        child: Row(
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              margin: const EdgeInsets.only(right: 12),
                              decoration: BoxDecoration(
                                color: kLiteGreen,
                                shape: BoxShape.circle,
                                border: Border.all(color: kDarkText, width: 2),
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _label('PICKUP FROM'),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Chennai Central, Main Entr...',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                      color: kDarkText,
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF7F8F7),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: const Color(0xFFE5E7EB)),
                              ),
                              child: Text(
                                'Trip details',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 12,
                                  color: kDarkText,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [kMint, const Color(0xFFF3FBEA)],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(color: kLiteGreen.withOpacity(0.45)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: kLiteGreen,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(Icons.favorite_rounded, color: kForest, size: 18),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Cocab Captain Care',
                                    style: TextStyle(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF2A593A),
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    'Fair rides. Happier captains. Better journeys.',
                                    style: TextStyle(
                                      fontSize: 10.5,
                                      color: Colors.grey.shade600,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Text(
                              'Know more',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF2A593A),
                                decoration: TextDecoration.underline,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),
                      Center(
                        child: Text(
                          'COCAB  ·  RIDE HAPPY',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 2.2,
                            color: Colors.grey.shade400,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _numberPlate(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7CC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF111827), width: 1.6),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.8,
          color: kDarkText,
          fontFamily: 'Poppins',
        ),
      ),
    );
  }

  Widget _carIllustration() {
    return SizedBox(
      width: 150,
      height: 70,
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          Positioned(
            right: 8,
            bottom: 8,
            child: Icon(Icons.directions_car_rounded, size: 92, color: kLiteGreen),
          ),
          Positioned(
            right: 28,
            bottom: 18,
            child: Row(
              children: [
                Container(
                  width: 15,
                  height: 15,
                  decoration: BoxDecoration(
                    color: kDarkText,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
                const SizedBox(width: 42),
                Container(
                  width: 15,
                  height: 15,
                  decoration: BoxDecoration(
                    color: kDarkText,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
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