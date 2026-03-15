// lib/screens/account_settings_screen.dart
/*
 -----------------------------------------------------------------------------
 Simply Systems
 A mobile app (iOS & Android) for plural systems to manage system members,
 track fronting history, communicate internally via real-time chat, etc.
-----------------------------------------------------------------------------
 Copyright (C) 2026 Vayrian

 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU Affero General Public License as published
 by the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU Affero General Public License for more details.

 You should have received a copy of the GNU Affero General Public License
 along with this program.  If not, see https://www.gnu.org/licenses/.

*/

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';

class AccountSettingsScreen extends StatelessWidget {
  const AccountSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Account Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          ListTile(
            leading: const Icon(Icons.email),
            title: Text(auth.token != null ? 'Logged in' : 'Not logged in'),
            subtitle: Text('Account management coming soon (change password, etc.)'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () async {
              final auth = Provider.of<AuthProvider>(context, listen: false);
              await auth.logout();
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, '/'); // or direct to LoginScreen
              }
            },
          ),
          // Add the "Enable offline use on this device" toggle here later
        ],
      ),
    );
  }
}