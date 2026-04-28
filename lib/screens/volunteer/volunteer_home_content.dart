import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/app_providers.dart';
import '../../models/task.dart';


import '../../widgets/category_icon.dart';

class VolunteerHomeContent extends StatelessWidget {
  final VoidCallback? onExploreTasks;
  
  const VolunteerHomeContent({super.key, this.onExploreTasks});

  void _showHowItWorks(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 24),
            Text('How NeedsBridge Works', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 24),
            const _HowItWorksRow(),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                child: const Text('Got it!'),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final volunteerProv = context.watch<VolunteerProvider>();

    final activeTask = volunteerProv.activeTaskFor('v3');
    final completedCount = volunteerProv.completedTasks.length;
    final hours = 68;
    final impact = 420;

    return RefreshIndicator(
      onRefresh: () async {
        await volunteerProv.loadTasks();
      },
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF5F7FB), Color(0xFFF0F4F8)],
          ),
        ),
        child: SingleChildScrollView(
physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 140),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Hero Banner
              _HeroBanner(
                onExplore: () {
                  if (onExploreTasks != null) {
                    onExploreTasks!();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Explore Tasks - Go to Tasks tab!')),
                    );
                  }
                },
                onHowItWorks: () => _showHowItWorks(context),
              ),
              const SizedBox(height: 28),

              // 1.5 Quick Actions (AI Tools)
              const _QuickActions(),
              const SizedBox(height: 28),

              // 2. Stats Cards
              _StatsRow(completed: completedCount, hours: hours, impact: impact),
              const SizedBox(height: 28),

              // 3. Urgent Needs Near You
_SectionHeader(title: 'Urgent Needs Near You'),
              _UrgentNeedsHorizontal(newTasks: volunteerProv.newTasks),
              const SizedBox(height: 28),


              if (activeTask != null) ...[
                const SizedBox(height: 24),
                _ActiveTaskCard(task: activeTask),
              ],
              
              const SizedBox(height: 28),
              _SectionHeader(title: 'Filter by Skills'),
              const _SkillsChipsRow(),
              
              const SizedBox(height: 28),
              _SectionHeader(title: 'Recent Activity'),
              const _RecentActivityList(),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroBanner extends StatelessWidget {
  final VoidCallback onExplore;
  final VoidCallback onHowItWorks;
  const _HeroBanner({required this.onExplore, required this.onHowItWorks});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF2E7D32), Color(0xFF4CAF50)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              'Make every hour of help count',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Discover urgent community needs near you and volunteer where your skills matter most.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.white70,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onExplore,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF2E7D32),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Explore Tasks', style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: onHowItWorks,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white70, width: 1.5),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('How it works', style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  final int completed;
  final int hours;
  final int impact;
  const _StatsRow({
    required this.completed,
    required this.hours,
    required this.impact,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      clipBehavior: Clip.none,
      child: Row(
        children: [
          SizedBox(width: 140, child: _StatCard(label: 'Tasks\nCompleted', value: '$completed', icon: Icons.task_alt, color: const Color(0xFF2E7D32))),
          const SizedBox(width: 16),
          SizedBox(width: 140, child: _StatCard(label: 'Hours\nContributed', value: '$hours', icon: Icons.schedule, color: const Color(0xFF1565C0))),
          const SizedBox(width: 16),
          SizedBox(width: 140, child: _StatCard(label: 'Community\nImpact', value: '$impact', icon: Icons.people, color: const Color(0xFF4CAF50))),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shadowColor: color.withOpacity(0.3),
      shape: RoundedRectangleBorder(borderRadius: const BorderRadius.all(Radius.circular(20))),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 12),
            Text(value, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Color(0xFF1A1A1A))),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF666666), fontWeight: FontWeight.w600), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onSeeAll;
  const _SectionHeader({required this.title, this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
  Text(title, style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
            color: const Color(0xFF1A1A1A),
          )),
          if (onSeeAll != null) TextButton(
            onPressed: onSeeAll,
            child: const Text('See All', style: TextStyle(color: Color(0xFF1565C0))),
          ),
        ],
      ),
    );
  }
}

class _UrgentNeedsHorizontal extends StatelessWidget {
  final List<Task> newTasks;
  const _UrgentNeedsHorizontal({required this.newTasks});

  @override
  Widget build(BuildContext context) {
    final demoTasks = _getDemoUrgentTasks();
    return SizedBox(
      height: 180,
      child: ListView(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        padding: const EdgeInsets.symmetric(vertical: 4),
        children: [
          ...demoTasks.map((task) => _UrgentTaskCard(task: task)),
          if (newTasks.isNotEmpty) ...newTasks.take(1).map((task) => _UrgentTaskCard(task: task)),
          _SeeMoreCard(),
        ],
      ),
    );
  }

  static List<Task> _getDemoUrgentTasks() => [
    Task(
      id: 'demo1',
      needId: 'need1',
      volunteerId: '',
      status: 'new',
      assignedAt: DateTime.now(),
      title: 'Food delivery for 20 families',
      location: 'Green Park, 2.3km',
      category: 'food',
      urgencyLevel: 'High',
      skillsNeeded: 'Delivery',
      reportedBy: 'NGO1',
      peopleAffected: 20,
      distanceKm: 2.3,
    ),
    Task(
      id: 'demo2',
      needId: 'need2',
      volunteerId: '',
      status: 'new',
      assignedAt: DateTime.now(),
      title: 'Medical camp volunteer needed',
      location: 'City Hospital, 1.8km',
      category: 'medical',
      urgencyLevel: 'Critical',
      skillsNeeded: 'Medical Help',
      reportedBy: 'Health NGO',
      peopleAffected: 50,
      distanceKm: 1.8,
    ),
    Task(
      id: 'demo3',
      needId: 'need3',
      volunteerId: '',
      status: 'new',
      assignedAt: DateTime.now(),
      title: 'Teaching support for children',
      location: 'Community Center, 3.1km',
      category: 'education',
      urgencyLevel: 'High',
      skillsNeeded: 'Teaching',
      reportedBy: 'Education NGO',
      peopleAffected: 30,
      distanceKm: 3.1,
    ),
    Task(
      id: 'demo4',
      needId: 'need4',
      volunteerId: '',
      status: 'new',
      assignedAt: DateTime.now(),
      title: 'Elder care home visit',
      location: 'Senior Home, 0.9km',
      category: 'eldercare',
      urgencyLevel: 'Medium',
      skillsNeeded: 'Elder Care',
      reportedBy: 'Senior Care',
      peopleAffected: 10,
      distanceKm: 0.9,
    ),
  ];
}

class _UrgentTaskCard extends StatelessWidget {
  final Task task;
  const _UrgentTaskCard({required this.task});

  @override
  Widget build(BuildContext context) {
    Color badgeColor = task.urgencyLevel == 'Critical' ? Colors.red : Colors.orange;
    return Card(
      margin: const EdgeInsets.only(right: 16, bottom: 12),
      elevation: 4,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Task: ${task.title}')),


        ),
        child: Container(
          width: 240,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CategoryIconWidget(category: task.category ?? 'other', size: 28),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: badgeColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(task.urgencyLevel ?? '', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                task.title ?? '', 
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                task.location ?? '', 
                style: TextStyle(color: const Color(0xFF666666)),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SeeMoreCard extends StatelessWidget {
  const _SeeMoreCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(right: 16),
      elevation: 2,
      child: Container(
        width: 240,
        height: 160,
        decoration: BoxDecoration(
          color: const Color(0xFFE8F5E9),
          borderRadius: BorderRadius.circular(20),
          border: const Border(


          left: BorderSide(color: Color(0xFF2E7D32), width: 4),
        ),
      ),
        child: const Icon(Icons.more_horiz, size: 48, color: Color(0xFF2E7D32)),
      ),
    );
  }
}

class _HowItWorksRow extends StatelessWidget {
  const _HowItWorksRow();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      clipBehavior: Clip.none,
      child: Row(
        children: [
          SizedBox(width: 160, child: _FeatureCard(
            icon: Icons.business,
            title: 'NGOs post needs',
            subtitle: 'Field workers report community needs via voice/app',
          )),
          const SizedBox(width: 16),
          SizedBox(width: 160, child: _FeatureCard(
            icon: Icons.smart_toy,
            title: 'AI matches',
            subtitle: 'Urgency ranking + skill/location matching',
          )),
          const SizedBox(width: 16),
          SizedBox(width: 160, child: _FeatureCard(
            icon: Icons.check_circle,
            title: 'You take action',
            subtitle: 'Real-time tracking & completion',
          )),
        ],
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                color: Color(0xFFE8F5E9),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: const Color(0xFF2E7D32), size: 24),
            ),
            const SizedBox(height: 10),
            Text(title, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text(subtitle, style: TextStyle(color: const Color(0xFF666666), fontSize: 12), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _SmartFeaturesGrid extends StatelessWidget {
  const _SmartFeaturesGrid();

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      crossAxisSpacing: 16,
  mainAxisSpacing: 12,
      childAspectRatio: 1.7,
      children: [
        _SmartFeature(icon: Icons.psychology, label: 'AI Priority\nMatching'),
        _SmartFeature(icon: Icons.map, label: 'Live Map\nTracking'),
        _SmartFeature(icon: Icons.mic, label: 'Voice Input'),
        _SmartFeature(icon: Icons.notifications, label: 'Real-time\nNotifications'),
        _SmartFeature(icon: Icons.translate, label: 'Multilingual\nSupport'),
        _SmartFeature(icon: Icons.sync, label: 'Firebase Sync'),
      ],
    );
  }
}

class _SmartFeature extends StatelessWidget {
  final IconData icon;
  final String label;
  const _SmartFeature({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: const Color(0xFF1565C0), size: 32),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, height: 1.3), textAlign: TextAlign.center),
          ),
        ],
      ),
    );
  }
}

class _SkillsChipsRow extends StatelessWidget {
  const _SkillsChipsRow();

  @override
  Widget build(BuildContext context) {
    final skills = ['Teaching', 'Delivery', 'Medical Help', 'Food Support', 'Elder Care', 'Disaster Relief'];
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: skills.map((skill) => ChoiceChip(
        label: Text(skill),
        selected: false,
        onSelected: (_) => ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Filter tasks by $skill')),
        ),
        backgroundColor: const Color(0xFFE3F2FD),
        selectedColor: const Color(0xFF1565C0),
        labelStyle: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
      )).toList(),
    );
  }
}

class _RecentActivityList extends StatelessWidget {
  const _RecentActivityList();

  @override
  Widget build(BuildContext context) {
    final activities = _getDemoActivities();
    return Column(
      children: activities.map((activity) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: _ActivityTile(
          icon: activity['icon'] as IconData,
          title: activity['title'] as String,
          time: activity['time'] as String,
          color: activity['color'] as Color,
        ),
      )).toList(),
    );
  }

  static List<Map<String, dynamic>> _getDemoActivities() => [
    {'icon': Icons.assignment_turned_in, 'title': 'You accepted "Food delivery for 20 families"', 'time': '2h ago', 'color': const Color(0xFF2E7D32)},
    {'icon': Icons.smart_toy, 'title': 'AI matched you with medical support nearby', 'time': '5h ago', 'color': const Color(0xFF1565C0)},
    {'icon': Icons.group_add, 'title': '3 volunteers joined education support', 'time': '1d ago', 'color': const Color(0xFF4CAF50)},
    {'icon': Icons.home, 'title': 'Urgent shelter request completed today', 'time': '2d ago', 'color': const Color(0xFFFF9800)},
  ];
}

class _ActivityTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String time;
  final Color color;
  const _ActivityTile({
    required this.icon,
    required this.title,
    required this.time,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        title: Text(title, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
        subtitle: Text(time, style: const TextStyle(color: Color(0xFF666666))),
        trailing: const Icon(Icons.chevron_right, color: Color(0xFF999999)),
        onTap: () => ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(title)),
        ),
      ),
    );
  }
}

class _FeaturedImpactCard extends StatelessWidget {
  const _FeaturedImpactCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Color(0xFFE8F5E9),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.lightbulb_outline, color: Color(0xFF2E7D32), size: 32),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Solution Challenge Impact', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                      const SizedBox(height: 8),
                      Text(
                        'NGOs struggle with scattered paper-based reporting and delayed volunteer coordination.',
                        style: TextStyle(color: const Color(0xFF666666)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'NeedsBridge centralizes needs, prioritizes urgency with AI, and quickly connects the right volunteer to the right task.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Share NeedsBridge Impact!')),
                ),
                icon: const Icon(Icons.share, size: 20),
                label: const Text('Share Impact'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1565C0),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActiveTaskCard extends StatelessWidget {
  final Task task;
  const _ActiveTaskCard({required this.task});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
                  Icon(Icons.task_alt, color: Colors.white),
                  SizedBox(width: 8),
                  Text('Active Task', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                ],
              ),
              const SizedBox(height: 16),
              Text(task.title ?? '', style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.location_on, color: Colors.white70, size: 18),
                  const SizedBox(width: 8),
                  Expanded(child: Text(task.location ?? '', style: const TextStyle(color: Colors.white70, fontSize: 14))),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Open Task Details')),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Color(0xFF1565C0),
                  ),
                  child: const Text('Continue Task', style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  final _actions = const [
    (Icons.mic_outlined, 'Voice Report', '/fieldworker/voice', Color(0xFF7B1FA2)),
    (Icons.document_scanner_outlined, 'Scan Form', '/fieldworker/scan', Color(0xFF1565C0)),
  ];

  const _QuickActions();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('AI Assistant', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        Row(
          children: _actions.map((action) {
            final (icon, label, route, color) = action;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _ActionButton(icon: icon, label: label, color: color, route: route),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final String route;
  const _ActionButton({required this.icon, required this.label, required this.color, required this.route});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(route),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 26),
            const SizedBox(height: 6),
            Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
