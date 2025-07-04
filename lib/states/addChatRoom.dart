import 'package:equatable/equatable.dart';

class AddChatRoomState extends Equatable {
  final String? currentUsername;
  final String? userId;
  final List<String> memberUsernames;
  final bool isLoading;
  final String? error;

  const AddChatRoomState({
    this.currentUsername,
    this.userId,
    this.memberUsernames = const [],
    this.isLoading = false,
    this.error,
  });

  AddChatRoomState copyWith({
    String? currentUsername,
    String? userId,
    List<String>? memberUsernames,
    bool? isLoading,
    String? error,
  }) {
    return AddChatRoomState(
      currentUsername: currentUsername ?? this.currentUsername,
      userId: userId ?? this.userId,
      memberUsernames: memberUsernames ?? this.memberUsernames,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  @override
  List<Object?> get props =>
      [currentUsername, userId, memberUsernames, isLoading, error];
}
