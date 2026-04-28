import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/app_providers.dart';
import '../../models/app_user.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = context.watch<AuthProvider>().currentUser;

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          TextButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.edit_outlined, size: 18),
            label: const Text('Edit'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _ProfileHeader(user: user, theme: theme),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _InfoSection(user: user, theme: theme),
                  const SizedBox(height: 16),
                  if (user.role == UserRole.volunteer) _SkillsSection(skills: user.skills ?? [], theme: theme),
                  if (user.role == UserRole.ngoAdmin) _OrgSection(user: user, theme: theme),
                  const SizedBox(height: 16),
                  _SettingsSection(),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final AppUser user;
  final ThemeData theme;
  const _ProfileHeader({required this.user, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [theme.colorScheme.primary, theme.colorScheme.primary.withOpacity(0.7)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 44,
            backgroundColor: Colors.white.withOpacity(0.3),
            child: Text(
              user.name.substring(0, 1),
              style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w700, color: Colors.white),
            ),
          ),
          const SizedBox(height: 14),
          Text(user.name, style: theme.textTheme.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(user.roleLabel, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
          ),
        ],
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  final AppUser user;
  final ThemeData theme;
  const _InfoSection({required this.user, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Contact Information', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700, color: theme.colorScheme.primary)),
            const SizedBox(height: 12),
            _DetailRow(icon: Icons.email_outlined, label: 'Email', value: user.email),
            const Divider(height: 20),
            _DetailRow(icon: Icons.phone_outlined, label: 'Phone', value: user.phone),
            const Divider(height: 20),
            _DetailRow(icon: Icons.location_on_outlined, label: 'Location', value: user.location ?? 'Not set'),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _DetailRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            Text(value, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
          ],
        ),
      ],
    );
  }
}

class _SkillsSection extends StatelessWidget {
  final List<String> skills;
  final ThemeData theme;
  const _SkillsSection({required this.skills, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Skills', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700, color: theme.colorScheme.primary)),
                TextButton(onPressed: () {}, child: const Text('Edit Skills')),
              ],
            ),
            Wrap(spacing: 8, runSpacing: 8, children: skills.map((s) => Chip(label: Text(s))).toList()),
          ],
        ),
      ),
    );
  }
}

class _OrgSection extends StatelessWidget {
  final AppUser user;
  final ThemeData theme;
  const _OrgSection({required this.user, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Organization', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700, color: theme.colorScheme.primary)),
            const SizedBox(height: 12),
            _DetailRow(icon: Icons.business_outlined, label: 'Organization', value: user.orgName ?? 'Not set'),
            const Divider(height: 20),
            _DetailRow(icon: Icons.group_outlined, label: 'Members', value: '${user.memberCount ?? 0} members'),
          ],
        ),
      ),
    );
  }
}

class _SettingsSection extends StatefulWidget {
  @override
  State<_SettingsSection> createState() => _SettingsSectionState();
}

class _SettingsSectionState extends State<_SettingsSection> {
  bool _notifications = true;
  String _language = 'English';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: Text('Settings', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700, color: theme.colorScheme.primary)),
            ),
            SwitchListTile(
              title: const Text('Notifications'),
              secondary: const Icon(Icons.notifications_outlined),
              value: _notifications,
              onChanged: (v) => setState(() => _notifications = v),
            ),
            ListTile(
              leading: const Icon(Icons.language_outlined),
              title: const Text('Language'),
              trailing: DropdownButton<String>(
                value: _language,
                underline: const SizedBox(),
                items: ['English', 'Hindi', 'Tamil', 'Telugu', 'Bengali']
                    .map((l) => DropdownMenuItem(value: l, child: Text(l)))
                    .toList(),
                onChanged: (v) => setState(() => _language = v!),
              ),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.logout, color: Color(0xFFD32F2F)),
              title: const Text('Logout', style: TextStyle(color: Color(0xFFD32F2F), fontWeight: FontWeight.w600)),
              onTap: () {
                context.read<AuthProvider>().logout();
                context.go('/login');
              },
            ),
          ],
        ),
      ),
    );
  }
}
