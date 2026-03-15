// lib/screens/internal_chat_screen.dart
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
import '../providers/member_provider.dart';
import '../providers/chat_provider.dart';
import '../models/member.dart';

class InternalChatScreen extends StatefulWidget {
  const InternalChatScreen({super.key});

  @override
  State<InternalChatScreen> createState() => _InternalChatScreenState();
}

class _InternalChatScreenState extends State<InternalChatScreen> {
  final _messageController = TextEditingController();
  int? _selectedSenderId;

  @override
  void initState() {
    super.initState();

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    final memberProvider = Provider.of<MemberProvider>(context, listen: false);

    // Initialize socket if not already done
    if (auth.token != null && auth.userId != null) {
      chatProvider.initSocket(auth.token!, auth.userId!);
    }

    // Load chat history (only once per session)
    if (auth.token != null) {
      chatProvider.loadHistory(auth.token!);
    }

    // Default sender: current fronter or first member
    if (memberProvider.currentFrenterId != null) {
      _selectedSenderId = int.tryParse(memberProvider.currentFrenterId!);
    } else if (memberProvider.members.isNotEmpty) {
      _selectedSenderId = memberProvider.members.first.id;
    }

    if (_selectedSenderId != null) {
      chatProvider.setCurrentSender(_selectedSenderId!);
    }
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty || _selectedSenderId == null) return;

    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    chatProvider.sendMessage(text);
    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final memberProvider = Provider.of<MemberProvider>(context);
    final chatProvider = Provider.of<ChatProvider>(context);

    if (memberProvider.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (memberProvider.members.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Internal Chat')),
        body: const Center(child: Text('No members yet - add some first')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Internal Chat'),
        actions: [
          PopupMenuButton<int>(
            icon: const Icon(Icons.swap_horiz),
            tooltip: 'Switch who is speaking',
            onSelected: (int memberId) {
              setState(() => _selectedSenderId = memberId);
              chatProvider.setCurrentSender(memberId);
            },
            itemBuilder: (context) => memberProvider.members.map((member) {
              return PopupMenuItem<int>(
                value: member.id!,
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: member.color != null
                          ? Color(int.parse('0xFF${member.color!.substring(1)}'))
                          : Colors.grey,
                      child: Text(member.name[0].toUpperCase()),
                    ),
                    const SizedBox(width: 12),
                    Text(member.name),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true,
              padding: const EdgeInsets.all(8),
              itemCount: chatProvider.messages.length,
              itemBuilder: (context, index) {
                final msg = chatProvider.messages[chatProvider.messages.length - 1 - index];
                final sender = memberProvider.members.firstWhere(
                  (m) => m.id == msg.senderMemberId,
                  orElse: () => Member(
                    id: msg.senderMemberId,
                    name: 'Unknown',
                    createdAt: DateTime.now(),
                    updatedAt: DateTime.now(),
                  ),
                );

                final isMe = msg.senderMemberId == _selectedSenderId;

                return Align(
                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isMe ? Colors.indigo : Colors.grey[300],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                      children: [
                        Text(
                          sender.name,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isMe ? Colors.white70 : Colors.black87,
                          ),
                        ),
                        Text(
                          msg.content,
                          style: TextStyle(color: isMe ? Colors.white : Colors.black),
                        ),
                        Text(
                          msg.timestamp.toString().substring(11, 16),
                          style: TextStyle(fontSize: 10, color: isMe ? Colors.white60 : Colors.black54),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    Provider.of<ChatProvider>(context, listen: false).disposeSocket();
    _messageController.dispose();
    super.dispose();
  }
}