import 'dart:async';
import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../events/addChatRoom.dart';
import '../states/addChatRoom.dart';

class AddChatRoomBloc extends Bloc<AddChatRoomEvent, AddChatRoomState> {
  final secureStorage = const FlutterSecureStorage();

  AddChatRoomBloc() : super(AddChatRoomState()) {
    on<FetchUserData>(_onFetchUserData);
    on<AddMember>(_onAddMember);
    on<RemoveMember>(_onRemoveMember);
    on<CreateChatRoom>(_onCreateChatRoom);
  }

  Future<void> _onFetchUserData(FetchUserData event, Emitter emit) async {
    final storedUserId = await secureStorage.read(key: 'userId');
    if (storedUserId == null) return;

    final url = Uri.parse('http://192.168.1.55:8000/users/user/$storedUserId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final username = data['username'];
      emit(state.copyWith(
        userId: storedUserId,
        currentUsername: username,
        memberUsernames: [username],
      ));
    } else {
      emit(state.copyWith(error: 'โหลดข้อมูลไม่สำเร็จ'));
    }
  }

  Future<void> _onAddMember(AddMember event, Emitter emit) async {
    final username = event.username.trim();

    if (username.isEmpty ||
        username == state.currentUsername ||
        state.memberUsernames.contains(username)) {
      return;
    }

    final checkUrl = Uri.parse('http://192.168.1.55:8000/chat/check/$username');
    final checkResponse = await http.get(checkUrl);

    if (checkResponse.statusCode == 200) {
      final newMembers = List<String>.from(state.memberUsernames)..add(username);
      emit(state.copyWith(memberUsernames: newMembers));
    } else {
      emit(state.copyWith(error: 'ไม่พบบัญชีผู้ใช้ $username'));
    }
  }

  void _onRemoveMember(RemoveMember event, Emitter emit) {
    if (event.username == state.currentUsername) return;
    final newMembers = List<String>.from(state.memberUsernames)
      ..remove(event.username);
    emit(state.copyWith(memberUsernames: newMembers));
  }

  Future<void> _onCreateChatRoom(CreateChatRoom event, Emitter emit) async {
    if (event.roomName.isEmpty || state.memberUsernames.length < 2) {
      emit(state.copyWith(error: 'กรอกชื่อห้องและเพิ่มสมาชิกอย่างน้อย 2 คน'));
      return;
    }

    emit(state.copyWith(isLoading: true));

    final url = Uri.parse('http://192.168.1.55:8000/chat/newChatRoom');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': event.roomName,
        'members': state.memberUsernames,
      }),
    );

    emit(state.copyWith(isLoading: false));

    if (response.statusCode != 201) {
      final error = jsonDecode(response.body)['error'] ?? 'เกิดข้อผิดพลาด';
      emit(state.copyWith(error: error));
    }
  }
}
