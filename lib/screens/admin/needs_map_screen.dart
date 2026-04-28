import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/app_providers.dart';
import '../../models/need.dart';
import '../../widgets/urgency_badge.dart';
import '../../widgets/category_icon.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class NeedsMapScreen extends StatefulWidget {
  const NeedsMapScreen({super.key});

  @override
  State<NeedsMapScreen> createState() => _NeedsMapScreenState();
}

class _NeedsMapScreenState extends State<NeedsMapScreen> {
  String _activeFilter = 'All';
  final _filterOptions = ['All', 'Food', 'Medical', 'Shelter', 'Education', 'Sanitation'];
  GoogleMapController? _mapController;

  List<Need> _filtered(List<Need> all) {
    if (_activeFilter == 'All') return all;
    return all.where((n) => n.categoryLabel == _activeFilter).toList();
  }

  Set<Marker> _buildMarkers(List<Need> needs) {
    // Create markers from needs that have location data
    // Using a default Delhi position with small offsets for demonstration
    final markers = <Marker>{};
    for (int i = 0; i < needs.length; i++) {
      final n = needs[i];
      final markerColor = switch (n.urgencyLevel) {
        UrgencyLevel.critical => BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        UrgencyLevel.medium => BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
        UrgencyLevel.low => BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      };
      markers.add(Marker(
        markerId: MarkerId(n.id),
        position: LatLng(28.6139 + (i * 0.005), 77.2090 + (i * 0.003)),
        icon: markerColor,
        infoWindow: InfoWindow(
          title: n.categoryLabel,
          snippet: '${n.urgencyLabel} • ${n.location}',
          onTap: () => context.push('/admin/need/${n.id}'),
        ),
      ));
    }
    return markers;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final needs = context.watch<NeedsProvider>().needs;
    final filtered = _filtered(needs);

    return Scaffold(
      appBar: AppBar(title: const Text('Needs Map')),
      body: Stack(
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: SizedBox(
                  height: 280,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: GoogleMap(
                      initialCameraPosition: const CameraPosition(
                        target: LatLng(28.6139, 77.2090), // Delhi
                        zoom: 12,
                      ),
                      markers: _buildMarkers(filtered),
                      myLocationEnabled: false,
                      myLocationButtonEnabled: false,
                      zoomControlsEnabled: true,
                      mapToolbarEnabled: false,
                      onMapCreated: (controller) {
                        _mapController = controller;
                      },
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: SizedBox(
                  height: 36,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _filterOptions.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (_, i) {
                      final opt = _filterOptions[i];
                      final selected = _activeFilter == opt;
                      return FilterChip(
                        label: Text(opt),
                        selected: selected,
                        onSelected: (_) => setState(() => _activeFilter = opt),
                        showCheckmark: false,
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: filtered.isEmpty
                    ? Center(child: Text('No needs for this category', style: theme.textTheme.bodyMedium))
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (_, i) {
                          final n = filtered[i];
                          return _NeedListTile(need: n, onTap: () => context.push('/admin/need/${n.id}'));
                        },
                      ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/admin/add-need'),
        icon: const Icon(Icons.add),
        label: const Text('Add Need'),
      ),
    );
  }
}

class _NeedListTile extends StatelessWidget {
  final Need need;
  final VoidCallback? onTap;
  const _NeedListTile({required this.need, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dotColor = switch (need.urgencyLevel) {
      UrgencyLevel.critical => const Color(0xFFD32F2F),
      UrgencyLevel.medium => const Color(0xFFF57C00),
      UrgencyLevel.low => const Color(0xFF388E3C),
    };

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.colorScheme.outlineVariant),
        ),
        child: Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
            ),
            const SizedBox(width: 12),
            CategoryIconWidget(category: need.categoryLabel, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(need.categoryLabel, style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600)),
                  Text(need.location, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant), overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            UrgencyBadge(level: need.urgencyLabel, small: true),
          ],
        ),
      ),
    );
  }
}
