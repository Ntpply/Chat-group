import 'package:equatable/equatable.dart';

abstract class ProfileEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadProfileEvent extends ProfileEvent {}

class LogoutEvent extends ProfileEvent {}
