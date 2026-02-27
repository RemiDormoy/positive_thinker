import 'dart:io';

import 'package:equatable/equatable.dart';

class PositiveChatMessage extends Equatable {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final bool isLoading;
  final File? image;

  const PositiveChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.isLoading = false,
    this.image,
  });

  @override
  List<Object?> get props => [text, isUser, timestamp, isLoading, image];
}
