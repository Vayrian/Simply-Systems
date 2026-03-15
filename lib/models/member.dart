// lib/models/member.dart
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

class Member {
  final int? id;
  final String name;
  final String? pronouns;
  final String? description;
  final String? color;
  final DateTime createdAt;
  final DateTime updatedAt;

  Member({
    this.id,
    required this.name,
    this.pronouns,
    this.description,
    this.color,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Member.fromJson(Map<String, dynamic> json) {
    return Member(
      id: json['id'],
      name: json['name'],
      pronouns: json['pronouns'],
      description: json['description'],
      color: json['color'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'pronouns': pronouns,
      'description': description,
      'color': color,
    };
  }

  Member copyWith({
    int? id,
    String? name,
    String? pronouns,
    String? description,
    String? color,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Member(
      id: id ?? this.id,
      name: name ?? this.name,
      pronouns: pronouns ?? this.pronouns,
      description: description ?? this.description,
      color: color ?? this.color,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}