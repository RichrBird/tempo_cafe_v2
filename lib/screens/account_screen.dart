// lib/account_screen.dart

import 'package:flutter/material.dart';
import 'package:tempo_cafe_v2/services/auth/auth_services.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  Future<void> _signOut(BuildContext context) async {
    await AuthServices().signOut();
    if (context.mounted) {
      Navigator.pushReplacementNamed(context, '/');
    }
  }

  @override
  Widget build(BuildContext context) {
    //final colors = Theme.of(context).colorScheme;
    //final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      // Use the scaffold background color from your theme
      //backgroundColor: colors.background,
      appBar: AppBar(
        // Use a transparent background to blend with the body
        backgroundColor: Colors.transparent,
        elevation: 0,
        /* leading: Icon(
          Icons.arrow_back,
          //color: colors.onBackground, // Icon color from theme
        ), */
        title: Text(
          'Account',
          /* style: textTheme.headlineSmall?.copyWith(
            color: colors.onBackground,
            fontWeight: FontWeight.bold,
          ), */
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () {
              _signOut(context);
            },
            child: Text(
              'Log Out',
            //  style: textTheme.bodyMedium?.copyWith(color: colors.primary),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Account Information Section
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Account Information',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 16),
                    _AccountOptionTile(
                      icon: Icons.person_outline,
                      title: 'Profile',
                      iconColor: Colors.blue,
                    ),
                    _AccountOptionTile(
                      icon: Icons.email_outlined,
                      title: 'Email Settings',
                      iconColor: Colors.green,
                    ),
                    _AccountOptionTile(
                      icon: Icons.lock_outline,
                      title: 'Change Password',
                      iconColor: Colors.red,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Other Options Section
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Other Options',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 16),
                    _AccountOptionTile(
                      icon: Icons.help_outline,
                      title: 'Help & Support',
                      iconColor: Colors.purple,
                    ),
                    _AccountOptionTile(
                      icon: Icons.settings_outlined,
                      title: 'Settings',
                      iconColor: Colors.orange,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Helper widget for the styled list tiles to avoid repeating code
class _AccountOptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color iconColor;

  const _AccountOptionTile({
    required this.icon,
    required this.title,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          color: colors.surface, // Card color from your theme
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: ListTile(
          onTap: () {
            // TODO: Handle tile tap
          },
          leading: Icon(
            icon,
            color: iconColor,
            size: 28,
          ),
          title: Text(
            title,
            style: textTheme.bodyLarge?.copyWith(
              color: colors.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          trailing: Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: colors.onSurface.withOpacity(0.5),
          ),
        ),
      ),
    );
  }
}