import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_providers.dart';
import '../../models/volunteer.dart';
import '../../widgets/volunteer_card.dart';
import '../../widgets/volunteer_detail_sheet.dart';

class VolunteerManagementScreen extends StatefulWidget {
  const VolunteerManagementScreen({super.key});

  @override
  State<VolunteerManagementScreen> createState() => _VolunteerManagementScreenState();
}

class _VolunteerManagementScreenState extends State<VolunteerManagementScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
    _searchCtrl.addListener(() => setState(() => _query = _searchCtrl.text.toLowerCase()));
  }

  @override
  void dispose() {
    _tabs.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  List<Volunteer> _filter(List<Volunteer> all, {bool? available}) {
    return all.where((v) {
      final matchesSearch = _query.isEmpty ||
          v.name.toLowerCase().contains(_query) ||
          v.skills.any((s) => s.toLowerCase().contains(_query));
      final matchesTab = available == null || v.isAvailable == available;
      return matchesSearch && matchesTab;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final volunteers = context.watch<VolunteerProvider>().volunteers;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Volunteers'),
        bottom: TabBar(
          controller: _tabs,
          tabs: const [Tab(text: 'All'), Tab(text: 'Available'), Tab(text: 'Busy')],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: TextField(
              controller: _searchCtrl,
              decoration: const InputDecoration(
                hintText: 'Search by name or skill...',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: TabBarView(
              controller: _tabs,
              children: [
                _VolunteerList(items: _filter(volunteers), onTap: _showDetail),
                _VolunteerList(items: _filter(volunteers, available: true), onTap: _showDetail),
                _VolunteerList(items: _filter(volunteers, available: false), onTap: _showDetail),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showDetail(Volunteer v) {
    VolunteerDetailSheet.show(context, v);
  }
}

class _VolunteerList extends StatelessWidget {
  final List<Volunteer> items;
  final ValueChanged<Volunteer> onTap;
  const _VolunteerList({required this.items, required this.onTap});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Center(child: Text('No volunteers found'));
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, i) => VolunteerCard(volunteer: items[i], onTap: () => onTap(items[i])),
    );
  }
}
