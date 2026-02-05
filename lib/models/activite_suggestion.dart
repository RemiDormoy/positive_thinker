import 'package:equatable/equatable.dart';

class ActiviteSuggestion extends Equatable {
  final String titre;
  final String description;
  final String explication;

  const ActiviteSuggestion({required this.titre, required this.description, required this.explication});

  @override
  List<Object?> get props => [titre, description, explication];
}
