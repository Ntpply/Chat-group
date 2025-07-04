import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import '../events/register.dart';
import '../states/register.dart';

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  RegisterBloc() : super(const RegisterState()) {
    on<RegisterSubmitted>(_onRegisterSubmitted);
  }

  Future<void> _onRegisterSubmitted(
    RegisterSubmitted event,
    Emitter<RegisterState> emit,
  ) async {
    emit(state.copyWith(isSubmitting: true, errorMessage: null));

    if (event.password != event.confirmPassword) {
      emit(state.copyWith(
        isSubmitting: false,
        errorMessage: 'รหัสผ่านไม่ตรงกัน',
      ));
      return;
    }

    final url = Uri.parse('http://192.168.1.55:8000/users/register');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': event.email,
          'password': event.password,
          'username': event.username,
          'phone': event.phone,
          'birthdate': event.birthdate.toIso8601String(),
        }),
      );

      if (response.statusCode == 201) {
        emit(state.copyWith(isSubmitting: false, isSuccess: true));
      } else {
        final errorMsg = jsonDecode(response.body)['error'] ?? 'เกิดข้อผิดพลาด';
        emit(state.copyWith(isSubmitting: false, errorMessage: errorMsg));
      }
    } catch (e) {
      emit(state.copyWith(isSubmitting: false, errorMessage: e.toString()));
    }
  }
}
