import 'package:equatable/equatable.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

class LoadUserDataEvent extends HomeEvent {}

class LoadChatRoomsEvent extends HomeEvent {
  final String userId;

  const LoadChatRoomsEvent(this.userId);

  @override
  List<Object?> get props => [userId];
}
