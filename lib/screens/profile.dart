import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../events/profile.dart';
import '../states/profile.dart';
import '../blocs/profile.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _onItemTapped(BuildContext context, int index) {
    if (index == 0) {
      Navigator.pushReplacementNamed(context, '/home');
    } else if (index == 1) {
      Navigator.pushNamed(context, '/notifications');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProfileBloc()..add(LoadProfileEvent()),
      child: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state.isLoggedOut) {
            Navigator.pushReplacementNamed(context, '/');
          }
        },
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(title: Text('โปรไฟล์')),
            body: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(50),
                        ),
                      ),
                      SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(state.username ?? 'ไม่พบชื่อผู้ใช้',
                              style: TextStyle(fontSize: 18)),
                          Text(state.email ?? '',
                              style: TextStyle(color: Colors.grey[700])),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 30),
                  ElevatedButton.icon(
                    onPressed: () {
                      context.read<ProfileBloc>().add(LogoutEvent());
                    },
                    icon: Icon(Icons.logout),
                    label: Text('ออกจากระบบ'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: 2,
              onTap: (index) => _onItemTapped(context, index),
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.home), label: 'หน้าหลัก'),
                BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'แจ้งเตือน'),
                BottomNavigationBarItem(icon: Icon(Icons.person), label: 'โปรไฟล์'),
              ],
            ),
          );
        },
      ),
    );
  }
}
