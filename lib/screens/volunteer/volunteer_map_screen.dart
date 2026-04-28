import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_providers.dart';
import '../../widgets/task_card.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class VolunteerMapScreen extends StatelessWidget {
  const VolunteerMapScreen({super.key});

  Set<Marker> _buildTaskMarkers(List tasks) {
    final markers = <Marker>{};
    for (int i = 0; i < tasks.length; i++) {
      final t = tasks[i];
      final hue = t.status == 'new'
          ? BitmapDescriptor.hueBlue
          : BitmapDescriptor.hueOrange;
      markers.add(Marker(
        markerId: MarkerId(t.id),
        position: LatLng(28.6139 + (i * 0.006), 77.2090 + (i * 0.004)),
        icon: BitmapDescriptor.defaultMarkerWithHue(hue),
        infoWindow: InfoWindow(
          title: t.title,
          snippet: '${t.urgencyLevel} • ${t.distanceKm} km',
        ),
      ));
    }
    return markers;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final volunteerProv = context.watch<VolunteerProvider>();
    final nearbyTasks = [...volunteerProv.newTasks, ...volunteerProv.activeTasks];

    return Scaffold(
      appBar: AppBar(title: const Text('Nearby Tasks')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: SizedBox(
              height: 300,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: GoogleMap(
                  initialCameraPosition: const CameraPosition(
                    target: LatLng(28.6139, 77.2090),
                    zoom: 12,
                  ),
                  markers: _buildTaskMarkers(nearbyTasks),
                  myLocationEnabled: false,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: true,
                  mapToolbarEnabled: false,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text('${nearbyTasks.length} tasks nearby', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                const Spacer(),
                const Icon(Icons.filter_list, size: 20),
                const SizedBox(width: 4),
                const Text('Filter'),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              itemCount: nearbyTasks.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (ctx, i) {
                final task = nearbyTasks[i];
                return Column(
                  children: [
                    TaskCard(task: task, tab: task.status == 'new' ? 'new' : 'active'),
                    const SizedBox(height: 6),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Navigate: integrate Google Maps deep link in production')),
                          );
                        },
                        icon: const Icon(Icons.navigation_outlined),
                        label: const Text('Navigate'),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
