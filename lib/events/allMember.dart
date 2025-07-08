import 'package:equatable/equatable.dart';

abstract class AllMemberEvent extends Equatable {
  const AllMemberEvent();

  @override
  List<Object> get props => [];
}

class FetchMembers extends AllMemberEvent {
  final String roomId;

  const FetchMembers(this.roomId);

  @override
  List<Object> get props => [roomId];
}

class AddMember extends AllMemberEvent {
  final String roomId;
  final String username;

  const AddMember(this.roomId, this.username);

  @override
  List<Object> get props => [roomId, username];
}

class RemoveMember extends AllMemberEvent {
  final String roomId;
  final String username;

  const RemoveMember(this.roomId, this.username);

  @override
  List<Object> get props => [roomId, username];
}
