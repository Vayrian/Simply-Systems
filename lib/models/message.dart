// lib/models/message.dart
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

class Message {
  final int id;
  final int senderMemberId;
  final String senderName;
  final String senderColor;
  final String content;
  final DateTime timestamp;

  Message({
    required this.id,
    required this.senderMemberId,
    required this.senderName,
    required this.senderColor,
    required this.content,
    required this.timestamp,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      senderMemberId: json['sender_id'],
      senderName: json['sender_name'],
      senderColor: json['sender_color'],
      content: json['content'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}