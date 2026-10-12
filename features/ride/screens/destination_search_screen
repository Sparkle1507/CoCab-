import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

class DestinationSearchScreen extends StatefulWidget {
  final String pickupAddress;
  final LatLng pickupLatLng;
  final String? initialDestination;
  const DestinationSearchScreen({
    super.key,
    required this.pickupAddress,
    required this.pickupLatLng,
    this.initialDestination,
  });
  @override
  State<DestinationSearchScreen> createState() => _DestinationSearchScreenState();
}

class _DestinationSearchScreenState extends State<DestinationSearchScreen> {
  late TextEditingController _pickupController;
  late TextEditingController _destinationController;
  final FocusNode _dropoffFocus = FocusNode();
  List<dynamic> _searchResults = [];
  Timer? _debounce;

  late LatLng _selectedPickup;
  LatLng? _selectedDropoff;
  String? _selectedDropoffName;

  final List<Map<String, dynamic>> recentPlaces = [
    {
      "name": "Home",
      "address": "24, Anna Nagar West, Chennai",
      "icon": Icons.home_rounded,
      "color": const Color(0xFFF59E0B),
      "lat": 13.0850,
      "lon": 80.2100
    },
    {
      "name": "Office",
      "address": "Tidel Park, Taramani, Chennai",
      "icon": Icons.work_rounded,
      "color": const Color(0xFF78716C),
      "lat": 12.9896,
      "lon": 80.2475
    },
    {
      "name": "Phoenix MarketCity",
      "address": "Velachery Main Rd, Velachery",
      "icon": Icons.shopping_bag_rounded,
      "color": const Color(0xFF3B82F6),
      "lat": 12.9915,
      "lon": 80.2160
    },
    {
      "name": "Chennai Airport",
      "address": "Tirusulam, Chennai - 600016",
      "icon": Icons.flight_rounded,
      "color": const Color(0xFF6366F1),
      "lat": 12.9716,
      "lon": 80.1891
    },
  ];

  // UI-only palette (matches CoCab tracking look)
  static const Color _bg = Color(0xFFF4F6F5);
  static const Color _card = Colors.white;
  static const Color _dark = Color(0xFF111827);
  static const Color _muted = Color(0xFF6B7280);
  static const Color _lime = Color(0xFFC7F365);
  static const Color _forest = Color(0xFF16382C);
  static const Color _line = Color(0xFFE5E7EB);

  @override
  void initState() {
    super.initState();
    _pickupController = TextEditingController(text: widget.pickupAddress);
    _destinationController = TextEditingController(text: widget.initialDestination ?? "");
    _selectedPickup = widget.pickupLatLng;

    if (widget.initialDestination != null && widget.initialDestination!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _search(widget.initialDestination!);
      });
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _pickupController.dispose();
    _destinationController.dispose();
    _dropoffFocus.dispose();
    super.dispose();
  }

  Future<void> _search(String query) async {
    if (query.isEmpty) {
      setState(() => _searchResults = []);
      return;
    }
    try {
      final response = await http.get(
        Uri.parse(
          'https://nominatim.openstreetmap.org/search?q=$query, Tamil Nadu&format=json&limit=5',
        ),
      );
      if (response.statusCode == 200) {
        setState(() => _searchResults = jsonDecode(response.body));
      }
    } catch (e) {}
  }

  Widget _softShadowCard({
    required Widget child,
    EdgeInsetsGeometry padding = const EdgeInsets.all(18),
    BorderRadius? radius,
  }) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: _card,
        borderRadius: radius ?? BorderRadius.circular(24),
        border: Border.all(color: Colors.white),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(0.05),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.2,
        color: Colors.grey.shade500,
      ),
    );
  }

  Widget _placeTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: _card,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: _line),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F172A).withOpacity(0.03),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 14.5,
                        color: _dark,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11.5,
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: _muted),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isReadyToNavigate = _selectedDropoff != null && _selectedDropoffName != null;

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
              decoration: BoxDecoration(
                color: _card,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Material(
                    color: _card,
                    shape: const CircleBorder(),
                    elevation: 0,
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: _line, width: 1.4),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.arrow_back_ios_new_rounded, color: _dark, size: 18),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Plan your ride',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: _dark,
                            letterSpacing: -0.6,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Set pickup & drop location',
                          style: TextStyle(
                            fontSize: 13,
                            color: _muted,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Stack(
                alignment: Alignment.centerRight,
                children: [
                  _softShadowCard(
                    padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              children: [
                                Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF22C55E),
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 2),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF22C55E).withOpacity(0.35),
                                        blurRadius: 6,
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  width: 2,
                                  height: 28,
                                  margin: const EdgeInsets.symmetric(vertical: 4),
                                  decoration: BoxDecoration(
                                    color: _line,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                                const Icon(Icons.location_on_rounded, color: Color(0xFFE11D48), size: 18),
                              ],
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _sectionLabel('PICKUP'),
                                      const SizedBox(height: 2),
                                      TextField(
                                        controller: _pickupController,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 15.5,
                                          color: _dark,
                                        ),
                                        decoration: const InputDecoration(
                                          border: InputBorder.none,
                                          enabledBorder: InputBorder.none,
                                          focusedBorder: InputBorder.none,
                                          filled: false,
                                          contentPadding: EdgeInsets.zero,
                                          isDense: true,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Divider(height: 1, color: Colors.grey.shade100),
                                  const SizedBox(height: 10),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _sectionLabel('DROP'),
                                      const SizedBox(height: 2),
                                      TextField(
                                        controller: _destinationController,
                                        focusNode: _dropoffFocus,
                                        autofocus: true,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 15.5,
                                          color: _dark,
                                        ),
                                        decoration: InputDecoration(
                                          hintText: 'Where to?',
                                          hintStyle: TextStyle(
                                            color: Colors.grey.shade400,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          border: InputBorder.none,
                                          enabledBorder: InputBorder.none,
                                          focusedBorder: InputBorder.none,
                                          filled: false,
                                          contentPadding: EdgeInsets.zero,
                                          isDense: true,
                                        ),
                                        onChanged: (q) {
                                          if (_debounce?.isActive ?? false) _debounce!.cancel();
                                          _debounce = Timer(
                                            const Duration(milliseconds: 500),
                                            () => _search(q),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    right: 14,
                    child: Material(
                      color: _card,
                      borderRadius: BorderRadius.circular(22),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(22),
                        onTap: () {
                          final temp = _pickupController.text;
                          setState(() {
                            _pickupController.text = _destinationController.text;
                            _destinationController.text = temp;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(color: _line, width: 1.4),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.swap_vert_rounded, color: _forest, size: 16),
                              SizedBox(width: 4),
                              Text(
                                'Swap',
                                style: TextStyle(
                                  color: _forest,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _searchResults.isEmpty
                  ? ListView(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                      children: [
                        const SizedBox(height: 4),
                        _sectionLabel('RECENT PLACES'),
                        const SizedBox(height: 12),
                        ...recentPlaces.map(
                          (place) => _placeTile(
                            icon: place['icon'] as IconData,
                            iconColor: place['color'] as Color,
                            title: place['name'] as String,
                            subtitle: place['address'] as String,
                            onTap: () {
                              setState(() {
                                _destinationController.text = place['name'];
                                _selectedDropoffName = place['name'];
                                _selectedDropoff = LatLng(place['lat'], place['lon']);
                              });
                              FocusScope.of(context).unfocus();
                            },
                          ),
                        ),
                      ],
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                      itemCount: _searchResults.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (ctx, i) {
                        final p = _searchResults[i];
                        final name = p['display_name'].split(',')[0];
                        return _placeTile(
                          icon: Icons.place_rounded,
                          iconColor: const Color(0xFF4F46E5),
                          title: name,
                          subtitle: p['display_name'],
                          onTap: () {
                            setState(() {
                              _destinationController.text = name;
                              _selectedDropoffName = name;
                              _selectedDropoff = LatLng(
                                double.parse(p['lat']),
                                double.parse(p['lon']),
                              );
                            });
                            FocusScope.of(context).unfocus();
                          },
                        );
                      },
                    ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
              decoration: BoxDecoration(
                color: _card,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 20,
                    offset: const Offset(0, -6),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: isReadyToNavigate
                        ? const LinearGradient(
                            colors: [_forest, Color(0xFF1B4332)],
                          )
                        : null,
                    color: isReadyToNavigate ? null : const Color(0xFFE5E7EB),
                    boxShadow: isReadyToNavigate
                        ? [
                            BoxShadow(
                              color: _forest.withOpacity(0.28),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ]
                        : null,
                  ),
                  child: ElevatedButton(
                    onPressed: isReadyToNavigate
                        ? () {
                            Navigator.pop(context, {
                              'pickup': _selectedPickup,
                              'dropoff': _selectedDropoff,
                              'dropoffName': _selectedDropoffName,
                            });
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      disabledBackgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      foregroundColor: isReadyToNavigate ? Colors.white : Colors.grey.shade500,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: Text(
                      isReadyToNavigate ? 'Confirm destination' : 'Select a destination',
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
