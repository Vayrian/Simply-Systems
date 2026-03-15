// lib/screens/home_screen.dart
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
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../providers/auth_provider.dart';
import '../providers/member_provider.dart';
import 'login_screen.dart';
import 'members_screen.dart';
import 'front_history_screen.dart';
import 'internal_chat_screen.dart';
import '../theme/app_theme.dart';
import '../models/member.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final memberProvider = Provider.of<MemberProvider>(context);

    // Current fronter name
    String currentFronterName = 'None';
    Color? currentFronterColor;
    if (memberProvider.currentFrenterId != null) {
      final current = memberProvider.members.firstWhere(
        (m) => m.id.toString() == memberProvider.currentFrenterId,
        orElse: () => Member(id: 0, name: 'Unknown', createdAt: DateTime.now(), updatedAt: DateTime.now()),
      );
      currentFronterName = current.name;
      currentFronterColor = _parseColor(current.color);
    }
// Real fronting time today
    final frontingToday = memberProvider.getFrontingTimeToday();
    final frontingTodayText = memberProvider.formatDuration(frontingToday);
    
    // Recent fronters – last 5 from history (newest first)
    final recentFronters = memberProvider.frontHistory.take(5).map((log) {
      final member = memberProvider.members.firstWhere(
        (m) => m.id == log.memberId,
        orElse: () => Member(id: log.memberId, name: 'Unknown', createdAt: DateTime.now(), updatedAt: DateTime.now()),
      );
      final timeAgo = _timeAgo(log.startTime);
      final color = _parseColor(member.color);
      return {'name': member.name, 'timeAgo': timeAgo, 'color': color};
    }).toList();

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile header
              Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: AppTheme.accentPurple,
                    child: Text(
                      auth.displayName?.substring(0, 1).toUpperCase() ?? 'S',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          auth.displayName ?? 'System',
                          style: GoogleFonts.inter(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        Text(
                          'Dashboard',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.logout_rounded, color: AppTheme.textSecondary),
                    onPressed: () async {
                      await auth.logout();
                      if (context.mounted) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const LoginScreen()),
                        );
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Two main banners
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Current fronter banner
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppTheme.cardBg,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: AppTheme.accentTeal.withOpacity(0.4)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Current Fronter',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              if (currentFronterColor != null)
                                Container(
                                  width: 16,
                                  height: 16,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: currentFronterColor,
                                    boxShadow: [
                                      BoxShadow(
                                        color: currentFronterColor!.withOpacity(0.6),
                                        blurRadius: 8,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                ),
                              const SizedBox(width: 8),
                              Text(
                                currentFronterName,
                                style: GoogleFonts.inter(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.accentTeal,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

       // Fronting time today banner 
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.only(left: 8),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppTheme.cardBg,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: AppTheme.accentAmber.withOpacity(0.4)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Fronting Today',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            frontingTodayText,
                            style: GoogleFonts.inter(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.accentAmber,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Main navigation buttons (Members, Chat, History)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildFloatingAction(
                    icon: Icons.people_alt_rounded,
                    label: 'Members',
                    color: AppTheme.accentTeal,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const MembersScreen()),
                    ),
                  ),
                  _buildFloatingAction(
                    icon: Icons.chat_rounded,
                    label: 'Chat',
                    color: AppTheme.accentAmber,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const InternalChatScreen()),
                    ),
                  ),
                  _buildFloatingAction(
                    icon: Icons.history_rounded,
                    label: 'History',
                    color: AppTheme.accentPurple,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const FrontHistoryScreen()),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Recent Fronters 
              Text(
                'Recent Fronters',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: recentFronters.map((fronter) {
                    final color = fronter['color'] as Color;
                    return Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: AppTheme.cardBg,
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: color.withOpacity(0.4)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircleAvatar(
                              radius: 14,
                              backgroundColor: color,
                              child: Text(
                                (fronter['name'] as String)[0].toUpperCase(),
                                style: const TextStyle(color: Colors.white, fontSize: 12),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${fronter['name']} • ${fronter['timeAgo']}',
                              style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textPrimary),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 32),

              // Recent Activity feed (placeholder for now)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent Activity',
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      'See all',
                      style: GoogleFonts.inter(color: AppTheme.accentTeal),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildActivityItem(
                avatarColor: Colors.purple,
                name: 'Alex',
                time: '2h ago',
                content: 'Switched front to me for a bit – feeling good!',
              ),
              _buildActivityItem(
                avatarColor: Colors.teal,
                name: 'Jamie',
                time: '4h ago',
                content: 'Just added a new memory note for the group',
              ),
              _buildActivityItem(
                avatarColor: Colors.amber,
                name: 'Sam',
                time: '8h ago',
                content: 'Poll: Movie night tonight? 3 votes yes',
              ),

              const SizedBox(height: 40),

              // Bottom action buttons – Polls, Friends, Account Settings
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildFloatingAction(
                    icon: Icons.poll_rounded,
                    label: 'Polls',
                    color: AppTheme.accentAmber,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Polls feature coming soon')),
                      );
                    },
                  ),
                  _buildFloatingAction(
                    icon: Icons.group_add_rounded,
                    label: 'Friends',
                    color: AppTheme.accentTeal,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Friends feature coming soon')),
                      );
                    },
                  ),
                  _buildFloatingAction(
                    icon: Icons.settings_rounded,
                    label: 'Account',
                    color: AppTheme.accentPurple,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Account settings coming soon')),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // Helper: small stat card
  Widget _buildStatCard({
    required String title,
    required String value,
    required String subtitle,
    required Color color,
    required IconData icon,
  }) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            Text(
              title,
              style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textSecondary),
            ),
            Text(
              subtitle,
              style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  // Helper: floating action button style
  Widget _buildFloatingAction({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              shape: BoxShape.circle,
              border: Border.all(color: color.withOpacity(0.4), width: 2),
            ),
            child: Icon(icon, color: color, size: 32),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }

  // Helper: activity item
  Widget _buildActivityItem({
    required Color avatarColor,
    required String name,
    required String time,
    required String content,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: avatarColor,
            child: Text(
              name[0].toUpperCase(),
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      name,
                      style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 16),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      time,
                      style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 14),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: GoogleFonts.inter(fontSize: 15, color: AppTheme.textPrimary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper: time ago string
  String _timeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 8) {
      return DateFormat('MMM d').format(date);
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  // Helper: safe color parsing (handles both Color objects and hex strings)
  Color _parseColor(dynamic colorValue) {
    if (colorValue is Color) return colorValue;
    if (colorValue is String && colorValue.isNotEmpty) {
      try {
        String cleanHex = colorValue.replaceAll('#', '');
        if (cleanHex.length == 6) {
          cleanHex = 'FF$cleanHex';
        }
        return Color(int.parse(cleanHex, radix: 16));
      } catch (e) {
        debugPrint('Invalid color hex: $colorValue');
      }
    }
    return Colors.grey; // fallback
  }
}