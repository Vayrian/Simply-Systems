// lib/providers/member_provider.dart
import 'dart:async';

import 'package:flutter/material.dart';

import '../models/member.dart';
import '../models/front_log.dart';
import '../services/api_service.dart';

class MemberProvider with ChangeNotifier {
  List<Member> _members = [];
  List<FrontLog> _frontHistory = [];
  bool _isLoading = false;
  String? _currentFrenterId;
  DateTime? _frontStartTime;

  // Live duration counter for CURRENT fronting session (resets on switch)
  Duration _currentFrontDuration = Duration.zero;
  Timer? _durationTimer;

  List<Member> get members => List.unmodifiable(_members);
  List<FrontLog> get frontHistory => List.unmodifiable(_frontHistory);
  bool get isLoading => _isLoading;
  String? get currentFrenterId => _currentFrenterId;
  DateTime? get frontStartTime => _frontStartTime;
  Duration get currentFrontDuration => _currentFrontDuration;

  MemberProvider() {
    // Start global duration increment timer
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_currentFrenterId != null && _frontStartTime != null) {
        _currentFrontDuration += const Duration(seconds: 1);
        notifyListeners();
      }
    });
  }

  Future<void> fetchAllData(String? token) async {
    if (token == null || token.isEmpty) {
      debugPrint('No token provided for fetchAllData');
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final api = ApiService();

      final jsonList = await api.getMembers(token: token);
      _members = jsonList.map((json) => Member.fromJson(json)).toList();

      final profile = await api.getUserProfile(token);
      debugPrint('Profile fetched: $profile');

      final fronterIdRaw = profile['current_fronter_id'];
      final newFrenterId = fronterIdRaw != null ? fronterIdRaw.toString() : null;

      final startTimeRaw = profile['front_start_time'];
      final newStartTime = startTimeRaw != null ? DateTime.tryParse(startTimeRaw) : null;

      if (newFrenterId != _currentFrenterId || newStartTime != _frontStartTime) {
        _currentFrenterId = newFrenterId;
        _frontStartTime = newStartTime;

        if (_currentFrenterId == null) {
          _currentFrontDuration = Duration.zero;
        } else {
          _currentFrontDuration = Duration.zero;
        }
      }

      final historyJson = await api.getFrontHistory(token);
      _frontHistory = historyJson.map((json) => FrontLog.fromJson(json)).toList();
    } catch (e, stack) {
      debugPrint('Data fetch failed: $e');
      debugPrint('Stack trace: $stack');
      _members = [];
      _currentFrenterId = null;
      _frontStartTime = null;
      _frontHistory = [];
      _currentFrontDuration = Duration.zero;
    }

    _isLoading = false;
    notifyListeners();
  }

  // ADD MEMBER
  Future<bool> addMember(Map<String, dynamic> data, String? token) async {
    if (token == null || token.isEmpty) return false;

    try {
      final api = ApiService();
      final created = await api.createMember(data, token: token);
      _members.add(Member.fromJson(created));
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Add failed: $e');
      return false;
    }
  }

  // UPDATE MEMBER
  Future<bool> updateMember(int id, Map<String, dynamic> data, String? token) async {
    if (token == null || token.isEmpty) return false;

    try {
      final api = ApiService();
      await api.updateMember(id, data, token: token);

      final index = _members.indexWhere((m) => m.id == id);
      if (index != -1) {
        final old = _members[index];
        _members[index] = old.copyWith(
          name: data['name'] as String?,
          pronouns: data['pronouns'] as String?,
          description: data['description'] as String?,
          color: data['color'] as String?,
          updatedAt: DateTime.now(),
        );
        notifyListeners();
      }
      return true;
    } catch (e) {
      debugPrint('Update failed: $e');
      return false;
    }
  }

  // DELETE MEMBER
  Future<bool> deleteMember(int id, String? token) async {
    if (token == null || token.isEmpty) return false;

    try {
      final api = ApiService();
      await api.deleteMember(id, token: token);

      _members = _members.where((m) => m.id != id).toList();

      if (_currentFrenterId == id.toString()) {
        _currentFrenterId = null;
        _frontStartTime = null;
        _currentFrontDuration = Duration.zero;
      }

      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Delete failed: $e');
      return false;
    }
  }

  // SET CURRENT FRONTER
  Future<bool> setCurrentFrenter(String? memberId, String? token) async {
    if (token == null || token.isEmpty) {
      debugPrint('No token for setCurrentFrenter');
      return false;
    }

    try {
      final api = ApiService();
      debugPrint("[MemberProvider] Setting fronter to: ${memberId ?? 'none'}");
      final updated = await api.setCurrentFrenter(token, memberId: memberId);

      _currentFrenterId = updated['current_fronter_id']?.toString();
      _frontStartTime = updated['front_start_time'] != null
          ? DateTime.tryParse(updated['front_start_time'])
          : null;

      // Reset live duration on any switch
      _currentFrontDuration = Duration.zero;

      // Refresh history
      final historyJson = await api.getFrontHistory(token);
      _frontHistory = historyJson.map((json) => FrontLog.fromJson(json)).toList();

      notifyListeners();
      debugPrint("[MemberProvider] Fronting updated successfully");
      return true;
    } catch (e) {
      debugPrint('Set fronter failed: $e');
      return false;
    }
  }

  // Total fronting time today (used on Home screen)
  Duration getFrontingTimeToday() {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day, 0, 0, 0);

    Duration total = Duration.zero;

    for (final log in _frontHistory) {
      if (log.startTime.isAfter(todayStart) ||
          (log.endTime != null && log.endTime!.isAfter(todayStart))) {
        final sessionStart = log.startTime.isBefore(todayStart) ? todayStart : log.startTime;
        final sessionEnd = log.endTime ?? now;

        if (sessionEnd.isAfter(sessionStart)) {
          total += sessionEnd.difference(sessionStart);
        }
      }
    }

    return total;
  }

  // Format for UI (blank until 1 minute)
  String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;

    if (hours > 0) {
      return '${hours}h ${minutes.toString().padLeft(2, '0')}m';
    } else if (minutes >= 1) {
      return '${minutes}m';
    } else {
      return '';  // ← Blank until at least 1 minute
    }
  }

  @override
  void dispose() {
    _durationTimer?.cancel();
    super.dispose();
  }
}