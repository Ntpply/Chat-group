import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? userName;
  String? userPhone;
  String? userId;
  final secureStorage = const FlutterSecureStorage();
  List<dynamic> chatRooms = [];

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    try {
      final storedUserId = await secureStorage.read(key: 'userId');
      if (storedUserId == null) return;

      final url = Uri.parse('http://192.168.1.55:8000/users/user/$storedUserId');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          userId = storedUserId;
          userName = data['username'];
          userPhone = data['phone'];
        });
        await fetchChatRooms(storedUserId);
      } else {
        print('Error fetching user data: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception fetching user data: $e');
    }
  }

  Future<void> fetchChatRooms(String userId) async {
    try {
      final url = Uri.parse('http://192.168.1.55:8000/chat/chatRoom/$userId');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          chatRooms = data;
        });
      } else {
        print('Error fetching chatrooms: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception fetching chatrooms: $e');
    }
  }

  void _goToProfile() {
  Navigator.pushReplacementNamed(context, '/profile');
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('หน้าหลัก')),
      body: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
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
                      userName != null ? userName![0].toUpperCase() : '',
                      style: TextStyle(fontSize: 40, color: Colors.white),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(userName ?? 'ไม่พบชื่อผู้ใช้', style: TextStyle(fontSize: 20)),
                    Text(userPhone ?? '', style: TextStyle(color: Colors.grey[700])),
                  ],
                ),
              ],
            ),

            SizedBox(height: 20),

            // Add Chat Button
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, '/addChatRoom', arguments: userName);
              },
              icon: Icon(Icons.chat),
              label: Text('เพิ่มแชท'),
            ),

            SizedBox(height: 10),

            Text('ห้องแชทของคุณ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

            // Chat Rooms List
            Expanded(
              child: chatRooms.isEmpty
                  ? Center(child: Text('ยังไม่มีห้องแชท'))
                  : ListView.builder(
                      itemCount: chatRooms.length,
                      itemBuilder: (context, index) {
                        final chatRoom = chatRooms[index];
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
                                'userName': userName,
                              },
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: (index) {
          if (index == 2) _goToProfile();
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'แชท'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'แจ้งเตือน'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'โปรไฟล์'),
        ],
      ),
    );
  }
}
