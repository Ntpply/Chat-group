import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../events/register.dart';
import '../states/register.dart';
import '../blocs/register.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final usernameController = TextEditingController();
  final phoneController = TextEditingController();
  DateTime? selectedBirthDate;

  Future<void> _pickBirthDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        selectedBirthDate = picked;
      });
    }
  }

  void _submitForm(BuildContext context) {
    final username = usernameController.text.trim();
    final email = emailController.text.trim();
    final phone = phoneController.text.trim();
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;
    final birthdate = selectedBirthDate;

    if (username.isEmpty ||
        email.isEmpty ||
        phone.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty ||
        birthdate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('กรุณากรอกข้อมูลให้ครบถ้วน')),
      );
      return;
    }

    context.read<RegisterBloc>().add(RegisterSubmitted(
          username: username,
          email: email,
          phone: phone,
          password: password,
          confirmPassword: confirmPassword,
          birthdate: birthdate,
        ));
  }

  @override
  Widget build(BuildContext context) {
    final birthDateText = selectedBirthDate != null
        ? '${selectedBirthDate!.day}/${selectedBirthDate!.month}/${selectedBirthDate!.year}'
        : 'เลือกวันเกิด';

    return BlocProvider(
      create: (_) => RegisterBloc(),
      child: BlocConsumer<RegisterBloc, RegisterState>(
        listener: (context, state) {
          if (state.isSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('สมัครสมาชิกสำเร็จ')),
            );
            Navigator.pushReplacementNamed(context, '/login');
          } else if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage!)),
            );
          }
        },
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(title: Text('สมัครสมาชิก')),
            body: Padding(
              padding: const EdgeInsets.all(24.0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    TextField(
                      controller: usernameController,
                      decoration: InputDecoration(
                        labelText: 'ชื่อผู้ใช้',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: emailController,
                      decoration: InputDecoration(
                        labelText: 'อีเมล',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: 'เบอร์โทร',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'รหัสผ่าน',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: confirmPasswordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'ยืนยันรหัสผ่าน',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      readOnly: true,
                      onTap: _pickBirthDate,
                      controller: TextEditingController(text: birthDateText),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.calendar_today),
                        hintText: 'เลือกวันเกิด',
                      ),
                    ),
                    SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: state.isSubmitting
                          ? null
                          : () => _submitForm(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                        textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: state.isSubmitting
                          ? CircularProgressIndicator(color: Colors.white)
                          : Text('สมัครสมาชิก'),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
