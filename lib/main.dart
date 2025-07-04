import 'package:flutter/material.dart';
import 'screens/home.dart';
import 'screens/login.dart';
import 'screens/register.dart';
import 'screens/profile.dart';
import 'widgets/isLogin.dart';

import 'screens/chat.dart'; 
import 'screens/addChatRoom.dart';
import 'screens/gallery.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      initialRoute: '/',
      routes: {
        '/': (context) =>  SplashScreen(),
        '/home': (context) => HomeScreen(),
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/profile': (context) => ProfileScreen(),
        '/chat': (context) => ChatScreen(),
        '/addChatRoom': (context) => AddChatRoomScreen(),
        '/gallery': (context) => GalleryScreen(),
      },
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.red,
          titleTextStyle: TextStyle(fontSize: 20, color: Colors.white),
        ),
      ),
    );
  }
}
