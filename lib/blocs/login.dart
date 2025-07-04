import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../events/login.dart';
import '../states/login.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc() : super(const LoginState()) {
    on<LoginPressed>(_onLoginPressed);
  }

  Future<void> _onLoginPressed(LoginPressed event, Emitter<LoginState> emit) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final url = Uri.parse('http://192.168.1.55:8000/users/login');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': event.email, 'password': event.password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final userId = data['userId'];

        final secureStorage = FlutterSecureStorage();
        await secureStorage.write(key: 'isLoggedIn', value: 'true');
        await secureStorage.write(key: 'userId', value: userId);

        emit(state.copyWith(isLoading: false));
      } else {
        final error = jsonDecode(response.body)['error'];
        emit(state.copyWith(isLoading: false, errorMessage: error));
      }
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }
}
