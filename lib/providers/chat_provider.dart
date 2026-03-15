// lib/providers/chat_provider.dart
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import '../models/message.dart';
import '../services/api_service.dart';

class ChatProvider with ChangeNotifier {
  IO.Socket? _socket;
  List<Message> _messages = [];
  int? _currentSenderMemberId;
  bool _historyLoaded = false;  // Prevent reloading history multiple times

  List<Message> get messages => _messages;
  int? get currentSenderMemberId => _currentSenderMemberId;

  /// Initialize socket – call once after login
  void initSocket(String token, int userId) {
    if (_socket != null) {
      debugPrint('[CHAT] Socket already initialized - skipping');
      return;
    }

    debugPrint('[CHAT] Initializing socket...');

    _socket = IO.io(
      ApiService.baseUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .setExtraHeaders({'Authorization': 'Bearer $token'})
          .build(),
    );

    _socket!.onConnect((_) {
      debugPrint('[SOCKET] Connected');
      final room = 'system_$userId';
      _socket!.emit('join_system_chat', {'user_id': userId});
    });

    _socket!.onDisconnect((_) {
      debugPrint('[SOCKET] Disconnected');
    });

    _socket!.on('receive_message', (data) {
      debugPrint('[SOCKET] Received message: $data');
      final msg = Message.fromJson(data);

      // Ignore echoed own messages 
      if (msg.senderMemberId == _currentSenderMemberId) {
        debugPrint('[CHAT] Ignoring echoed own message: ${msg.content}');
        return;
      }

      _messages.add(msg);
      notifyListeners();
    });

    _socket!.on('error', (data) {
      debugPrint('[SOCKET ERROR] ${data['message']}');
    });
  }

  /// Load chat history – call once after login or first chat open
  Future<void> loadHistory(String token) async {
    if (_historyLoaded) {
      debugPrint('[CHAT] History already loaded - skipping');
      return;
    }

    try {
      final api = ApiService();
      final historyJson = await api.getMessages(token);
      debugPrint('[CHAT] Loaded ${historyJson.length} past messages from server');
      _messages = historyJson.map((json) => Message.fromJson(json)).toList();
      _historyLoaded = true;
      notifyListeners();
    } catch (e) {
      debugPrint('[CHAT] Failed to load history: $e');
    }
  }

  void setCurrentSender(int memberId) {
    _currentSenderMemberId = memberId;
    notifyListeners();
  }

  void joinChat(int partnerMemberId) {
    // Do NOT clear messages here – keep them across re-entry
    _currentSenderMemberId = partnerMemberId;
    debugPrint('[CHAT] Joined chat with partner ID: $partnerMemberId');
    notifyListeners();
  }

  void sendMessage(String content) {
    if (_socket == null || _currentSenderMemberId == null || content.trim().isEmpty) {
      debugPrint('[CHAT] Cannot send: socket or sender not ready');
      return;
    }

    final trimmed = content.trim();

    final messageData = {
      'user_id': _currentSenderMemberId,
      'sender_member_id': _currentSenderMemberId,
      'content': trimmed,
    };

    debugPrint('[CHAT] Sending message: $messageData');
    _socket!.emit('send_message', messageData);

    // Optimistic UI update
    final tempMsg = Message(
      id: DateTime.now().millisecondsSinceEpoch,
      senderMemberId: _currentSenderMemberId!,
      senderName: 'You',
      senderColor: '#6366f1',
      content: trimmed,
      timestamp: DateTime.now(),
    );
    _messages.add(tempMsg);
    notifyListeners();
  }

  void disposeSocket() {
    if (_socket != null) {
      debugPrint('[CHAT] Disposing socket');
      _socket!.disconnect();
      _socket = null;
    }
    _messages = [];
    _currentSenderMemberId = null;
    _historyLoaded = false;
    notifyListeners();
  }
}