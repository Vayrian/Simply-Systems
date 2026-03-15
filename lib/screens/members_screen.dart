// lib/screens/members_screen.dart
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
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../providers/auth_provider.dart';
import '../providers/member_provider.dart';
import 'member_edit_screen.dart';

class MembersScreen extends StatefulWidget {
  const MembersScreen({super.key});

  @override
  State<MembersScreen> createState() => _MembersScreenState();
}

class _MembersScreenState extends State<MembersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refresh();
    });
  }

  Future<void> _refresh() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final provider = Provider.of<MemberProvider>(context, listen: false);
    await provider.fetchAllData(auth.token);
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;

    if (hours > 0) {
      return '${hours}h ${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
  }

  Future<void> _toggleFronting(String? memberId) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final provider = Provider.of<MemberProvider>(context, listen: false);

    final newFrenterId = provider.currentFrenterId == memberId ? null : memberId;

    final success = await provider.setCurrentFrenter(newFrenterId, auth.token);
    if (success) {
      // No need for local timer restart — provider handles it
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final provider = Provider.of<MemberProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Members'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: provider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : provider.members.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.people_outline, size: 80, color: Colors.grey),
                        const SizedBox(height: 16),
                        const Text('No members yet', style: TextStyle(fontSize: 20)),
                        const SizedBox(height: 8),
                        const Text('Tap + to add your first member', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: provider.members.length,
                    itemBuilder: (context, index) {
                      final member = provider.members[index];
                      final isFronting = provider.currentFrenterId == member.id?.toString();
                      final avatarColor = member.color != null
                          ? Color(int.parse('0xFF${member.color!.substring(1)}'))
                          : Colors.blueGrey;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                radius: 32,
                                backgroundColor: avatarColor.withOpacity(0.2),
                                child: Text(
                                  member.name.isNotEmpty ? member.name[0].toUpperCase() : '?',
                                  style: TextStyle(fontSize: 28, color: avatarColor),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      member.name,
                                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                                    ),
                                    if (member.pronouns != null && member.pronouns!.isNotEmpty)
                                      Text(
                                        member.pronouns!,
                                        style: TextStyle(
                                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                                          fontSize: 14,
                                        ),
                                      ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        Container(
                                          width: 12,
                                          height: 12,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: isFronting ? Colors.green : Colors.grey[400],
                                            border: Border.all(color: Colors.white, width: 2),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          isFronting ? 'Fronting' : 'Not fronting',
                                          style: TextStyle(
                                            color: isFronting ? Colors.green : Colors.grey[600],
                                            fontWeight: isFronting ? FontWeight.w600 : FontWeight.normal,
                                          ),
                                        ),
                                        if (isFronting) ...[
                                          const SizedBox(width: 12),
                                          Text(
                                            '• ${provider.formatDuration(provider.currentFrontDuration)}',
                                            style: const TextStyle(
                                              color: Colors.green,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      Icons.swap_horiz,
                                      color: isFronting ? Colors.green : Colors.grey[600],
                                      size: 28,
                                    ),
                                    tooltip: isFronting ? 'Stop fronting' : 'Start fronting',
                                    onPressed: () => _toggleFronting(member.id?.toString()),
                                  ),
                                  PopupMenuButton<String>(
                                    onSelected: (value) async {
                                      if (value == 'edit') {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => MemberEditScreen(member: member),
                                          ),
                                        ).then((_) => _refresh());
                                      } else if (value == 'delete') {
                                        final confirm = await showDialog<bool>(
                                          context: context,
                                          builder: (ctx) => AlertDialog(
                                            title: const Text('Delete Member?'),
                                            content: const Text('This cannot be undone.'),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.pop(ctx, false),
                                                child: const Text('Cancel'),
                                              ),
                                              TextButton(
                                                onPressed: () => Navigator.pop(ctx, true),
                                                child: const Text('Delete', style: TextStyle(color: Colors.red)),
                                              ),
                                            ],
                                          ),
                                        );
                                        if (confirm == true) {
                                          await provider.deleteMember(member.id!, auth.token);
                                        }
                                      }
                                    },
                                    itemBuilder: (context) => [
                                      const PopupMenuItem(value: 'edit', child: Text('Edit')),
                                      const PopupMenuItem(
                                        value: 'delete',
                                        child: Text('Delete', style: TextStyle(color: Colors.red)),
                                      ),
                                    ],
                                    icon: const Icon(Icons.more_vert),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const MemberEditScreen()),
          ).then((_) => _refresh());
        },
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}