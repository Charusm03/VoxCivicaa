import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../api_service.dart';
import '../app_theme.dart';
import 'petition_screen.dart';

class MapScreen extends StatefulWidget {
  final bool isEmbedded;
  const MapScreen({super.key, this.isEmbedded = false});
  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  List<Map<String, dynamic>> _complaints = [];
  bool _isLoading = true;
  bool _isPetitionLoading = false;
  LatLng _mapCenter = const LatLng(13.0827, 80.2707);

  final Map<String, Color> _catColors = {
    'roads': AppColors.navy,
    'electricity': AppColors.teal,
    'drainage': AppColors.mint,
    'water': AppColors.accent,
    'general': AppColors.textMuted,
  };
  final Map<String, IconData> _catIcons = {
    'roads': Icons.construction,
    'electricity': Icons.bolt,
    'drainage': Icons.water_drop,
    'water': Icons.water,
    'general': Icons.report_problem,
  };

  @override
  void initState() {
    super.initState();
    _loadComplaints();
  }

  Future<void> _loadComplaints() async {
    setState(() => _isLoading = true);
    final data = await getComplaints();
    
    LatLng initial = const LatLng(13.0827, 80.2707); // Default Chennai
    if (data.isNotEmpty) {
      final first = data.last; // Last generated usually at the end of the array, or just data.first
      initial = LatLng((first['lat'] as num).toDouble(), (first['lng'] as num).toDouble());
    }

    setState(() {
      _complaints = data;
      _mapCenter = initial;
      _isLoading = false;
    });
  }

  Color _getColor(String cat) =>
      _catColors[cat.toLowerCase()] ?? const Color(0xFF7F8C8D);
  IconData _getIcon(String cat) =>
      _catIcons[cat.toLowerCase()] ?? Icons.report_problem;

  List<Marker> _buildMarkers() {
    return _complaints.map((c) {
      final lat = (c['lat'] as num).toDouble();
      final lng = (c['lng'] as num).toDouble();
      final cat = c['category']?.toString() ?? 'general';
      final urgency = c['urgency_level'] as int? ?? 1;
      
      Color pinColor;
      if (urgency >= 4) {
        pinColor = AppColors.urgent;
      } else if (urgency == 3) {
        pinColor = AppColors.teal;
      } else {
        pinColor = AppColors.resolved;
      }

      return Marker(
        point: LatLng(lat, lng),
        width: 60,
        height: 60,
        child: GestureDetector(
          onTap: () => _showComplaintSheet(c),
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: pinColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2.5),
                  boxShadow: [
                    BoxShadow(color: pinColor.withOpacity(0.5), blurRadius: 8, spreadRadius: 2)
                  ],
                ),
                child: Center(child: Icon(_getIcon(cat), color: Colors.white, size: 20)),
              ),
              if (urgency >= 4)
                Positioned(
                  top: -2,
                  right: -4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.urgent,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.white, width: 1.5),
                    ),
                    child: const Text('URGENT', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                  ),
                ),
            ],
          ),
        ),
      );
    }).toList();
  }

  void _showComplaintSheet(Map<String, dynamic> complaint) {
    final cat = complaint['category']?.toString() ?? 'general';
    final color = _getColor(cat);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setSheetState) => Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 16),
              Row(children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      color: color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10)),
                  child: Icon(_getIcon(cat), color: color, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(cat.toUpperCase(),
                              style: TextStyle(
                                  color: color,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  letterSpacing: 1)),
                          Row(
                            children: [
                              const Icon(Icons.thumb_up_rounded, color: Colors.green, size: 14),
                              const SizedBox(width: 4),
                              Text('${complaint['upvote_count'] ?? 0} upvotes',
                                  style: const TextStyle(color: AppColors.resolved, fontWeight: FontWeight.bold, fontSize: 12)),
                            ],
                          ),
                        ],
                      ),
                      if (complaint['petition'] != null && complaint['petition'].toString().isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Text(
                            complaint['petition'],
                            style: const TextStyle(
                              fontSize: 13,
                              fontFamily: 'monospace',
                              color: Color(0xFF1A1A2E),
                            ),
                            maxLines: 6,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ] else ...[
                        Text(complaint['text'] ?? '',
                            style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textDark)),
                      ],
                    ],
                  ),
                ),
              ]),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 4),
            Text('${_complaints.length} complaints near this area',
                style: const TextStyle(color: Colors.grey, fontSize: 13)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: ElevatedButton.icon(
                    onPressed: _isPetitionLoading
                        ? null
                        : () async {
                            setSheetState(() => _isPetitionLoading = true);
                            final ids = _complaints
                                .map((c) => c['id'].toString())
                                .toList();
                            final petition = await clusterPetition(
                                ids, 'Reported Area');
                            setSheetState(() => _isPetitionLoading = false);
                            if (context.mounted) {
                              Navigator.of(context).pop();
                              Navigator.of(context).push(MaterialPageRoute(
                                builder: (_) => PetitionScreen(
                                  petitionText: petition,
                                  complaint: _complaints
                                      .map((c) => c['text'])
                                      .join(', '),
                                  location: 'Reported Area',
                                  language: 'English',
                                ),
                              ));
                            }
                          },
                    icon: _isPetitionLoading
                        ? const SizedBox(
                            width: 16, height: 16,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.group_rounded, size: 18),
                    label: Text(
                      _isPetitionLoading
                          ? 'Wait...'
                          : 'Join (${_complaints.length})',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.navy,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final success = await upvoteComplaint(complaint['id'].toString());
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(success ? 'Upvoted!' : 'Already upvoted.')),
                        );
                        if (success) {
                          _loadComplaints();
                          Navigator.of(context).pop();
                        }
                      }
                    },
                    icon: const Icon(Icons.thumb_up, color: Colors.green, size: 16),
                    label: const Text('Upvote', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 13)),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
                      side: const BorderSide(color: AppColors.resolved),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final success = await flagComplaint(complaint['id'].toString());
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(success ? 'Flagged for review.' : 'Failed to flag.')),
                        );
                        if (success) {
                          Navigator.of(context).pop();
                          _loadComplaints();
                        }
                      }
                    },
                    icon: const Icon(Icons.flag, color: Colors.red, size: 16),
                    label: const Text('Flag', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 13)),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
                      side: const BorderSide(color: AppColors.urgent),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget mapBody = Stack(
      children: [
        if (!_isLoading)
          FlutterMap(
            options: MapOptions(
              initialCenter: _mapCenter,
              initialZoom: 15,
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.voxcivica.app',
              ),
              CircleLayer(
                circles: _complaints.map((c) => CircleMarker(
                  point: LatLng((c['lat'] as num).toDouble(), (c['lng'] as num).toDouble()),
                  radius: 40,
                  color: AppColors.teal.withOpacity(0.15),
                  borderColor: AppColors.teal,
                  borderStrokeWidth: 1.5,
                )).toList(),
              ),
              MarkerLayer(markers: _buildMarkers()),
            ],
          ),
          // Legend
          Positioned(
            top: 12, right: 12,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8)
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _catColors.entries.map((e) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Container(
                        width: 10, height: 10,
                        decoration: BoxDecoration(
                            color: e.value, shape: BoxShape.circle)),
                    const SizedBox(width: 6),
                    Text(e.key[0].toUpperCase() + e.key.substring(1),
                        style: const TextStyle(fontSize: 11)),
                  ]),
                )).toList(),
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black26,
              child: const Center(
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      CircularProgressIndicator(color: AppColors.teal),
                      SizedBox(height: 12),
                      Text('Loading complaints...'),
                    ]),
                  ),
                ),
              ),
            ),
          if (!_isLoading)
            Positioned(
              bottom: 20, left: 0, right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.navy,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                          color: AppColors.navy.withOpacity(0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 4)),
                    ],
                  ),
                  child: Text(
                    '${_complaints.length} civic issues - tap a pin',
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
        ],
      );

    if (widget.isEmbedded) return mapBody;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Community Map',
            style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.white)),
        backgroundColor: AppColors.navy,
        iconTheme: const IconThemeData(color: AppColors.white),
        elevation: 0,
        actions: [
          IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadComplaints,
              tooltip: 'Refresh'),
        ],
      ),
      body: mapBody,
    );
  }
}
