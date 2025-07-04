import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../events/home.dart';
import '../states/home.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

  HomeBloc() : super(const HomeState()) {
    on<LoadUserDataEvent>(_onLoadUserData);
    on<LoadChatRoomsEvent>(_onLoadChatRooms);
  }

  Future<void> _onLoadUserData(
      LoadUserDataEvent event, Emitter<HomeState> emit) async {
    emit(state.copyWith(isLoading: true));
    try {
      final storedUserId = await secureStorage.read(key: 'userId');
      if (storedUserId == null) return;

      final url = Uri.parse('http://192.168.1.55:8000/users/user/$storedUserId');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        emit(state.copyWith(
          userId: storedUserId,
          userName: data['username'],
          userPhone: data['phone'],
          isLoading: false,
        ));

        add(LoadChatRoomsEvent(storedUserId));
      } else {
        emit(state.copyWith(isLoading: false, error: 'โหลดข้อมูลผู้ใช้ล้มเหลว'));
      }
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> _onLoadChatRooms(
      LoadChatRoomsEvent event, Emitter<HomeState> emit) async {
    try {
      final url = Uri.parse('http://192.168.1.55:8000/chat/chatRoom/${event.userId}');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        emit(state.copyWith(chatRooms: data));
      } else {
        emit(state.copyWith(error: 'โหลดห้องแชทล้มเหลว'));
      }
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }
}
