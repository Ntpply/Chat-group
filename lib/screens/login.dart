import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/login.dart';
import '../states/login.dart';
import '../events/login.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  void _listenLoginState(BuildContext context, LoginState state) {
    if (state.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.errorMessage!)),
      );
    } else if (!state.isLoading) {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LoginBloc(),
      child: Scaffold(
        appBar: AppBar(title: Text('เข้าสู่ระบบ')),
        body: BlocConsumer<LoginBloc, LoginState>(
          listener: _listenLoginState,
          builder: (context, state) {
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: 'อีเมล/ชื่อผู้ใข้',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: passwordController,
                    decoration: InputDecoration(
                      labelText: 'รหัสผ่าน',
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                  ),
                  SizedBox(height: 24),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/register');
                    },
                    child: Text('ยังไม่มีบัญชี? สมัครสมาชิก'),
                  ),
                  ElevatedButton(
                    onPressed: state.isLoading
                        ? null
                        : () {
                            final email = emailController.text.trim();
                            final password = passwordController.text.trim();
                            context.read<LoginBloc>().add(
                                  LoginPressed(email: email, password: password),
                                );
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                      textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: state.isLoading
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text('เข้าสู่ระบบ'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
