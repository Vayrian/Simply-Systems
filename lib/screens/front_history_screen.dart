// lib/screens/front_history_screen.dart
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
import 'package:intl/intl.dart';

import '../providers/member_provider.dart';
import '../models/front_log.dart';
import '../models/member.dart';  

class FrontHistoryScreen extends StatelessWidget {
  const FrontHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MemberProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Front History'),
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.frontHistory.isEmpty
              ? const Center(child: Text('No fronting history yet'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: provider.frontHistory.length,
                  itemBuilder: (context, index) {
                    final log = provider.frontHistory[index];

                    // Find member name (fallback if not in current list)
                    final member = provider.members.firstWhere(
                      (m) => m.id == log.memberId,
                      orElse: () => Member(
                        id: log.memberId,
                        name: 'Unknown Member',
                        createdAt: DateTime.now(),
                        updatedAt: DateTime.now(),
                      ),
                    );

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.indigo.withOpacity(0.2),
                          child: Text(member.name[0].toUpperCase()),
                        ),
                        title: Text(member.name),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Start: ${log.startText}'),
                            Text('End: ${log.endText}'),
                            Text('Duration: ${log.durationText}'),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}