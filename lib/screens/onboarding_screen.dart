// lib/screens/onboarding_screen.dart
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
import 'home_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _usernameController = TextEditingController();
  bool _showButtons = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _usernameController.addListener(() {
      setState(() {
        _showButtons = _usernameController.text.trim().isNotEmpty;
      });
    });
  }

  Future<void> _completeSetup(bool asSystem) async {
    final username = _usernameController.text.trim();
    if (username.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      await auth.updateProfile(
        isSystemOwner: asSystem,
        displayName: username,
      );

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Setup failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Welcome! Choose Your Role')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Pick a username',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                  hintText: 'e.g. The Collective / Friend123',
                ),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 32),
              if (_showButtons)
                Column(
                  children: [
                    ElevatedButton(
                      onPressed: _isLoading ? null : () => _completeSetup(true),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                        backgroundColor: Colors.indigo,
                      ),
                      child: const Text('Continue as System', style: TextStyle(fontSize: 18)),
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton(
                      onPressed: _isLoading ? null : () => _completeSetup(false),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                      ),
                      child: const Text('Continue as Friend of System', style: TextStyle(fontSize: 18)),
                    ),
                  ],
                )
              else
                const Text(
                  'Start typing to choose your role',
                  style: TextStyle(color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              if (_isLoading) ...[
                const SizedBox(height: 24),
                const Center(child: CircularProgressIndicator()),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }
}