import 'package:equatable/equatable.dart';

class ProfileState extends Equatable {
  final String? username;
  final String? email;
  final bool isLoading;
  final bool isLoggedOut;

  const ProfileState({
    this.username,
    this.email,
    this.isLoading = false,
    this.isLoggedOut = false,
  });

  ProfileState copyWith({
    String? username,
    String? email,
    bool? isLoading,
    bool? isLoggedOut,
  }) {
    return ProfileState(
      username: username ?? this.username,
      email: email ?? this.email,
      isLoading: isLoading ?? this.isLoading,
      isLoggedOut: isLoggedOut ?? this.isLoggedOut,
    );
  }

  @override
  List<Object?> get props => [username, email, isLoading, isLoggedOut];
}
