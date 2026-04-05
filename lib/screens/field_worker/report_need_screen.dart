import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../models/need.dart';
import '../../providers/app_providers.dart';
import '../../widgets/category_icon_grid.dart';

class ReportNeedScreen extends StatefulWidget {
  const ReportNeedScreen({super.key});

  @override
  State<ReportNeedScreen> createState() => _ReportNeedScreenState();
}

class _ReportNeedScreenState extends State<ReportNeedScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();

  String? _category;
  String _urgency = 'Medium';
  int _peopleAffected = 10;
  bool _submitting = false;

  @override
  void dispose() {
    _descCtrl.dispose();
    _locationCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_category == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a category')));
      return;
    }
    if (!_formKey.currentState!.validate()) return;

    setState(() => _submitting = true);
    final need = Need(
      id: 'n_${DateTime.now().millisecondsSinceEpoch}',
      category: NeedCategory.values.firstWhere((c) => c.name.toLowerCase() == _category!.toLowerCase(), orElse: () => NeedCategory.other),
      description: _descCtrl.text,
      urgencyScore: _urgency == 'Critical' ? 9.0 : _urgency == 'Medium' ? 5.5 : 2.5,
      urgencyLevel: _urgency == 'Critical' ? UrgencyLevel.critical : _urgency == 'Medium' ? UrgencyLevel.medium : UrgencyLevel.low,
      status: NeedStatus.reported,
      location: _locationCtrl.text,
      submittedBy: context.read<AuthProvider>().currentUser?.id ?? 'fw1',
      timestamp: DateTime.now(),
      peopleAffected: _peopleAffected,
    );

    await context.read<NeedsProvider>().submitNeed(need);
    if (mounted) {
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Need submitted successfully'),
          backgroundColor: const Color(0xFF388E3C),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Report a Need')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Category', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              CategoryIconGrid(selected: _category, onSelect: (c) => setState(() => _category = c)),
              const SizedBox(height: 20),
              Text('Description', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descCtrl,
                minLines: 3,
                maxLines: 5,
                decoration: const InputDecoration(hintText: 'Describe the need in detail...'),
                validator: (v) => v!.isEmpty ? 'Please add a description' : null,
              ),
              const SizedBox(height: 20),
              Text('Urgency Level', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              _UrgencySelector(selected: _urgency, onChanged: (v) => setState(() => _urgency = v)),
              const SizedBox(height: 20),
              Text('Location', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _locationCtrl,
                decoration: InputDecoration(
                  hintText: 'Enter location or use GPS',
                  prefixIcon: const Icon(Icons.location_on_outlined),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.my_location),
                    onPressed: () => _locationCtrl.text = 'Current Location (GPS)',
                    tooltip: 'Use current location',
                  ),
                ),
                validator: (v) => v!.isEmpty ? 'Please enter a location' : null,
              ),
              const SizedBox(height: 20),
              Text('People Affected: $_peopleAffected', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Row(
                children: [
                  IconButton.outlined(
                    onPressed: _peopleAffected > 1 ? () => setState(() => _peopleAffected--) : null,
                    icon: const Icon(Icons.remove),
                  ),
                  Expanded(
                    child: Center(
                      child: Text('$_peopleAffected', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
                    ),
                  ),
                  IconButton.outlined(
                    onPressed: () => setState(() => _peopleAffected++),
                    icon: const Icon(Icons.add),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Photo picker: integrate image_picker in production')));
                },
                icon: const Icon(Icons.photo_camera_outlined),
                label: const Text('Add Photo (optional)'),
                style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 48)),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _submitting ? null : _submit,
                  child: _submitting
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Submit Need'),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _UrgencySelector extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;
  const _UrgencySelector({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final options = [
      ('Low', const Color(0xFF388E3C), const Color(0xFFE8F5E9)),
      ('Medium', const Color(0xFFF57C00), const Color(0xFFFFF3E0)),
      ('Critical', const Color(0xFFD32F2F), const Color(0xFFFFEBEE)),
    ];
    return Row(
      children: options.map((option) {
        final (label, color, bg) = option;
        final isSelected = selected == label;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => onChanged(label),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? bg : Theme.of(context).colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: isSelected ? color : Theme.of(context).colorScheme.outlineVariant, width: isSelected ? 2 : 1),
                ),
                child: Text(label, style: TextStyle(color: isSelected ? color : Theme.of(context).colorScheme.onSurfaceVariant, fontWeight: FontWeight.w700, fontSize: 13), textAlign: TextAlign.center),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
