// lib/models/front_log.dart
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

import 'package:intl/intl.dart';

class FrontLog {
  final int id;
  final int memberId;
  final int userId;
  final DateTime startTime;
  final DateTime? endTime;
  final int? durationSeconds;

  FrontLog({
    required this.id,
    required this.memberId,
    required this.userId,
    required this.startTime,
    this.endTime,
    this.durationSeconds,
  });

  factory FrontLog.fromJson(Map<String, dynamic> json) {
    return FrontLog(
      id: json['id'],
      memberId: json['member_id'],
      userId: json['user_id'],
      startTime: DateTime.parse(json['start_time']),
      endTime: json['end_time'] != null ? DateTime.parse(json['end_time']) : null,
      durationSeconds: json['duration_seconds'],
    );
  }

  String get durationText {
    if (durationSeconds == null) return 'Ongoing';
    final minutes = durationSeconds! ~/ 60;
    final seconds = durationSeconds! % 60;
    return '$minutes min $seconds sec';
  }

  String get startText {
    return DateFormat('MMM d, y • h:mm a').format(startTime);
  }

  String get endText {
    return endTime != null
        ? DateFormat('MMM d, y • h:mm a').format(endTime!)
        : 'Ongoing';
  }
}