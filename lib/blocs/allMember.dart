import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import '../events/allMember.dart';
import '../states/allMember.dart';

class AllMemberBloc extends Bloc<AllMemberEvent, AllMemberState> {
  final String baseUrl;

  AllMemberBloc(this.baseUrl) : super(const AllMemberState()) {
    on<FetchMembers>(_onFetchMembers);
    on<AddMember>(_onAddMember);
    on<RemoveMember>(_onRemoveMember);
  }

  Future<void> _onFetchMembers(FetchMembers event, Emitter<AllMemberState> emit) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final res = await http.get(Uri.parse('$baseUrl/chat/members/${event.roomId}'));
      final data = json.decode(res.body);
      if (res.statusCode == 200) {
        emit(state.copyWith(members: List<Map<String, dynamic>>.from(data['members']), isLoading: false));
      } else {
        emit(state.copyWith(isLoading: false, error: data['error']));
      }
    } catch (_) {
      emit(state.copyWith(isLoading: false, error: 'เกิดข้อผิดพลาดในการโหลดสมาชิก'));
    }
  }

  Future<void> _onAddMember(AddMember event, Emitter<AllMemberState> emit) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/chat/updateMember/${event.roomId}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': event.username}),
      );
      final data = json.decode(res.body);
      if (res.statusCode == 200) {
        add(FetchMembers(event.roomId));
      } else {
        emit(state.copyWith(error: data['error']));
      }
    } catch (_) {
      emit(state.copyWith(error: 'ไม่สามารถเพิ่มสมาชิกได้'));
    }
  }

  Future<void> _onRemoveMember(RemoveMember event, Emitter<AllMemberState> emit) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/chat/removeMember/${event.roomId}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': event.username}),
      );
      final data = json.decode(res.body);
      if (res.statusCode == 200) {
        add(FetchMembers(event.roomId));
      } else {
        emit(state.copyWith(error: data['error']));
      }
    } catch (_) {
      emit(state.copyWith(error: 'ไม่สามารถลบสมาชิกได้'));
    }
  }
}
