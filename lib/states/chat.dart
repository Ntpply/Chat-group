import 'package:equatable/equatable.dart';

class ChatState extends Equatable {
  final String? roomId;
  final String? roomName;
  final String? userName;
  final String? userId;
  final List<Map<String, dynamic>> messages;
  final bool isLoading;
  final bool isSendingImage;
  final String? error;

  const ChatState({
    this.roomId,
    this.roomName,
    this.userName,
    this.userId,
    this.messages = const [],
    this.isLoading = false,
    this.isSendingImage = false,
    this.error,
  });

  ChatState copyWith({
    String? roomId,
    String? roomName,
    String? userName,
    String? userId,
    List<Map<String, dynamic>>? messages,
    bool? isLoading,
    bool? isSendingImage,
    String? error,
  }) {
    return ChatState(
      roomId: roomId ?? this.roomId,
      roomName: roomName ?? this.roomName,
      userName: userName ?? this.userName,
      userId: userId ?? this.userId,
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      isSendingImage: isSendingImage ?? this.isSendingImage,
      error: error,
    );
  }

  @override
  List<Object?> get props => [
        roomId,
        roomName,
        userName,
        userId,
        messages,
        isLoading,
        isSendingImage,
        error,
      ];
}
