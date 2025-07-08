import 'package:equatable/equatable.dart';

class AllMemberState extends Equatable {
  final List<Map<String, dynamic>> members;
  final bool isLoading;
  final String? error;

  const AllMemberState({
    this.members = const [],
    this.isLoading = false,
    this.error,
  });

  AllMemberState copyWith({
    List<Map<String, dynamic>>? members,
    bool? isLoading,
    String? error,
  }) {
    return AllMemberState(
      members: members ?? this.members,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  @override
  List<Object?> get props => [members, isLoading, error];
}
