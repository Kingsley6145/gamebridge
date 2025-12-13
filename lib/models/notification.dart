import 'package:flutter/material.dart';

class AppNotification {
  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final DateTime createdAt;
  final bool isRead;
  final Map<String, dynamic>? metadata; // For courseId, moduleId, etc.

  AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.createdAt,
    this.isRead = false,
    this.metadata,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      type: NotificationType.fromString(json['type']?.toString() ?? 'info'),
      createdAt: json['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              (json['createdAt'] is num)
                  ? (json['createdAt'] as num).toInt()
                  : int.tryParse(json['createdAt'].toString()) ?? 0,
            )
          : DateTime.now(),
      isRead: json['isRead'] == true || json['isRead'] == 'true',
      metadata: json['metadata'] != null
          ? Map<String, dynamic>.from(json['metadata'] as Map)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'type': type.toString(),
      'createdAt': createdAt.millisecondsSinceEpoch,
      'isRead': isRead,
      'metadata': metadata,
    };
  }

  AppNotification copyWith({
    String? id,
    String? title,
    String? message,
    NotificationType? type,
    DateTime? createdAt,
    bool? isRead,
    Map<String, dynamic>? metadata,
  }) {
    return AppNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      metadata: metadata ?? this.metadata,
    );
  }
}

enum NotificationType {
  moduleCompleted,
  quizOpened,
  info,
  achievement,
  warning;

  static NotificationType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'modulecompleted':
      case 'module_completed':
        return NotificationType.moduleCompleted;
      case 'quizopened':
      case 'quiz_opened':
        return NotificationType.quizOpened;
      case 'achievement':
        return NotificationType.achievement;
      case 'warning':
        return NotificationType.warning;
      default:
        return NotificationType.info;
    }
  }

  @override
  String toString() {
    switch (this) {
      case NotificationType.moduleCompleted:
        return 'moduleCompleted';
      case NotificationType.quizOpened:
        return 'quizOpened';
      case NotificationType.achievement:
        return 'achievement';
      case NotificationType.warning:
        return 'warning';
      default:
        return 'info';
    }
  }

  String get displayName {
    switch (this) {
      case NotificationType.moduleCompleted:
        return 'Module Completed';
      case NotificationType.quizOpened:
        return 'Quiz Available';
      case NotificationType.achievement:
        return 'Achievement';
      case NotificationType.warning:
        return 'Warning';
      default:
        return 'Information';
    }
  }

  IconData get icon {
    switch (this) {
      case NotificationType.moduleCompleted:
        return Icons.check_circle;
      case NotificationType.quizOpened:
        return Icons.quiz;
      case NotificationType.achievement:
        return Icons.emoji_events;
      case NotificationType.warning:
        return Icons.warning;
      default:
        return Icons.info;
    }
  }
}

