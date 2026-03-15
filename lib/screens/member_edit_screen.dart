// lib/screens/member_edit_screen.dart
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

import '../models/member.dart';
import '../providers/auth_provider.dart';
import '../providers/member_provider.dart';

class MemberEditScreen extends StatefulWidget {
  final Member? member;

  const MemberEditScreen({super.key, this.member});

  @override
  State<MemberEditScreen> createState() => _MemberEditScreenState();
}

class _MemberEditScreenState extends State<MemberEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _pronounsController;
  late TextEditingController _descriptionController;
  late TextEditingController _colorController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.member?.name ?? '');
    _pronounsController = TextEditingController(text: widget.member?.pronouns ?? '');
    _descriptionController = TextEditingController(text: widget.member?.description ?? '');
    _colorController = TextEditingController(text: widget.member?.color ?? '#000000');
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final provider = Provider.of<MemberProvider>(context, listen: false);

    final data = {
      'name': _nameController.text.trim(),
      'pronouns': _pronounsController.text.trim().isEmpty ? null : _pronounsController.text.trim(),
      'description': _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
      'color': _colorController.text.trim(),
    };

    bool success;
    if (widget.member == null) {
      success = await provider.addMember(data, auth.token);
    } else {
      success = await provider.updateMember(widget.member!.id!, data, auth.token);
    }

    if (success && mounted) {
      Navigator.pop(context);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save. Check connection.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.member == null ? 'Add Member' : 'Edit Member'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (v) => v?.trim().isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _pronounsController,
                decoration: const InputDecoration(labelText: 'Pronouns'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _colorController,
                decoration: const InputDecoration(labelText: 'Color (Hex, e.g. #FF0000)'),
                validator: (v) {
                  if (v != null && v.isNotEmpty && !RegExp(r'^#[0-9A-Fa-f]{6}$').hasMatch(v)) {
                    return 'Invalid hex color';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _pronounsController.dispose();
    _descriptionController.dispose();
    _colorController.dispose();
    super.dispose();
  }
}