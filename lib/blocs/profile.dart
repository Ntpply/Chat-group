import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../events/profile.dart';
import '../states/profile.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

  ProfileBloc() : super(const ProfileState()) {
    on<LoadProfileEvent>(_onLoadProfile);
    on<LogoutEvent>(_onLogout);
  }

  Future<void> _onLoadProfile(
    LoadProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));

    final userId = await secureStorage.read(key: 'userId');
    if (userId == null) {
      emit(state.copyWith(isLoading: false));
      return;
    }

    final url = Uri.parse('http://192.168.1.55:8000/users/user/$userId');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        emit(
          state.copyWith(
            username: data['username'],
            email: data['email'],
            isLoading: false,
          ),
        );
      } else {
        emit(state.copyWith(isLoading: false));
      }
    } catch (e) {
      emit(state.copyWith(isLoading: false));
    }
  }

  Future<void> _onLogout(LogoutEvent event, Emitter<ProfileState> emit) async {
    await secureStorage.deleteAll();
    emit(state.copyWith(isLoggedOut: true));
  }
}
