abstract class ChatEvent {}

class InitializeChat extends ChatEvent {
  final String roomId;
  final String roomName;
  final String userName;

  InitializeChat(this.roomId, this.roomName, this.userName);
}

class FetchUserId extends ChatEvent {}

class FetchMessages extends ChatEvent {}

class ConnectSocket extends ChatEvent {}

class SendMessage extends ChatEvent {
  final String content;
  final String type;
  SendMessage(this.content, this.type);
}

class ReceiveMessage extends ChatEvent {
  final Map<String, dynamic> message;
  ReceiveMessage(this.message);
}

class PickAndSendImage extends ChatEvent {}

class ClearError extends ChatEvent {}

class ScrollToBottom extends ChatEvent {}
