abstract class AddChatRoomEvent {}

class FetchUserData extends AddChatRoomEvent {}

class AddMember extends AddChatRoomEvent {
  final String username;
  AddMember(this.username);
}

class RemoveMember extends AddChatRoomEvent {
  final String username;
  RemoveMember(this.username);
}

class CreateChatRoom extends AddChatRoomEvent {
  final String roomName;
  CreateChatRoom(this.roomName);
}
