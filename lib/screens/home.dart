import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/home.dart';
import '../states/home.dart';
import '../events/home.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _goToProfile(BuildContext context) {
    Navigator.pushReplacementNamed(context, '/profile');
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => HomeBloc()..add(LoadUserDataEvent()),
      child: Scaffold(
        appBar: AppBar(title: Text('หน้าหลัก')),
        body: Padding(
          padding: const EdgeInsets.all(10),
          child: BlocBuilder<HomeBloc, HomeState>(
            builder: (context, state) {
              if (state.isLoading) {
                return Center(child: CircularProgressIndicator());
              }

              return Column(
                children: [
                  // User Info
                  Row(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Center(
                          child: Text(
                            state.userName != null ? state.userName![0].toUpperCase() : '',
                            style: TextStyle(fontSize: 40, color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(state.userName ?? 'ไม่พบชื่อผู้ใช้', style: TextStyle(fontSize: 20)),
                          Text(state.userPhone ?? '', style: TextStyle(color: Colors.grey[700])),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Add Chat Button
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(context, '/addChatRoom', arguments: state.userName);
                    },
                    icon: Icon(Icons.chat),
                    label: Text('เพิ่มแชท'),
                  ),

                  const SizedBox(height: 10),
                  const Text('ห้องแชทของคุณ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

                  // Chat Rooms List
                  Expanded(
                    child: state.chatRooms.isEmpty
                        ? Center(child: Text('ยังไม่มีห้องแชท'))
                        : ListView.builder(
                            itemCount: state.chatRooms.length,
                            itemBuilder: (context, index) {
                              final chatRoom = state.chatRooms[index];
                              return ListTile(
                                leading: Icon(Icons.chat_bubble_outline),
                                title: Text(chatRoom['name'] ?? 'ห้องไม่มีชื่อ'),
                                onTap: () {
                                  Navigator.pushNamed(
                                    context,
                                    '/chat',
                                    arguments: {
                                      'roomId': chatRoom['_id'],
                                      'roomName': chatRoom['name'],
                                      'userName': state.userName,
                                    },
                                  );
                                },
                              );
                            },
                          ),
                  ),
                ],
              );
            },
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: 0,
          onTap: (index) {
            if (index == 2) _goToProfile(context);
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'แชท'),
            BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'แจ้งเตือน'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'โปรไฟล์'),
          ],
        ),
      ),
    );
  }
}
