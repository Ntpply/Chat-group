import 'package:equatable/equatable.dart';

class HomeState extends Equatable {
  final String? userName;
  final String? userPhone;
  final String? userId;
  final List<dynamic> chatRooms;
  final bool isLoading;
  final String? error;

  const HomeState({
    this.userName,
    this.userPhone,
    this.userId,
    this.chatRooms = const [],
    this.isLoading = false,
    this.error,
  });

  HomeState copyWith({
    String? userName,
    String? userPhone,
    String? userId,
    List<dynamic>? chatRooms,
    bool? isLoading,
    String? error,
  }) {
    return HomeState(
      userName: userName ?? this.userName,
      userPhone: userPhone ?? this.userPhone,
      userId: userId ?? this.userId,
      chatRooms: chatRooms ?? this.chatRooms,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [userName, userPhone, userId, chatRooms, isLoading, error];
}
