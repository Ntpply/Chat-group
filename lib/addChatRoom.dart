import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AddChatRoomScreen extends StatefulWidget {
  const AddChatRoomScreen({super.key});

  @override
  State<AddChatRoomScreen> createState() => _AddChatRoomScreenState();
}

class _AddChatRoomScreenState extends State<AddChatRoomScreen> {
  String? currentUsername;
  String? userId;
  final secureStorage = const FlutterSecureStorage();
  final TextEditingController roomNameController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  List<String> memberUsernames = [];

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    try {
      final storedUserId = await secureStorage.read(key: 'userId');
      if (storedUserId == null) return;

      userId = storedUserId;

      final url = Uri.parse('http://192.168.1.55:8000/users/user/$userId');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          currentUsername = data['username'];
          memberUsernames.add(currentUsername!);
        });
      } else {
        print('Error fetching user data: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception fetching user data: $e');
    }
  }

  void addMember() async {
    final username = usernameController.text.trim();

    if (username.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('กรอกชื่อผู้ใช้ที่ต้องการเพิ่ม')));
      return;
    }

    if (username == currentUsername) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('ไม่ต้องเพิ่มตัวเองซ้ำ')));
      return;
    }

    final checkUrl = Uri.parse('http://192.168.1.55:8000/chat/check/$username');
    final checkResponse = await http.get(checkUrl);

    if (checkResponse.statusCode == 200) {
      if (!memberUsernames.contains(username)) {
        setState(() {
          memberUsernames.add(username);
          usernameController.clear();
        });
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('เพิ่มชื่อซ้ำไม่ได้')));
      }
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('ไม่พบบัญชีผู้ใช้ $username')));
    }
  }

  Future<void> createChatRoom() async {
    final roomName = roomNameController.text.trim();

    if (roomName.isEmpty || memberUsernames.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('กรุณากรอกชื่อห้องและสมาชิกอย่างน้อย 2 คน')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    final url = Uri.parse('http://192.168.1.55:8000/chat/newChatRoom');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': roomName, 'members': memberUsernames}),
    );

    setState(() {
      isLoading = false;
    });

    if (response.statusCode == 201) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('สร้างห้องแชทสำเร็จ')));
      Navigator.pop(context);
    } else {
      final error = jsonDecode(response.body)['error'] ?? 'เกิดข้อผิดพลาด';
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
    }
  }

  void removeMember(String username) {
    if (username == currentUsername) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ไม่สามารถลบตัวเองออกจากสมาชิกได้')),
      );
      return;
    }
    setState(() {
      memberUsernames.remove(username);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (currentUsername == null) {
      return Scaffold(
        appBar: AppBar(title: Text('สร้างห้องแชท')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('สร้างห้องแชท')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: roomNameController,
              decoration: InputDecoration(labelText: 'ชื่อห้องแชท'),
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: usernameController,
                    decoration: InputDecoration(
                      labelText: 'เพิ่มชื่อผู้ใช้',
                      hintText: 'เช่น pear123',
                    ),
                  ),
                ),
                IconButton(icon: Icon(Icons.add), onPressed: addMember),
              ],
            ),
            SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: memberUsernames
                  .map(
                    (username) => Chip(
                      label: Text(username),
                      deleteIcon: username == currentUsername
                          ? null
                          : Icon(Icons.close),
                      onDeleted: username == currentUsername
                          ? null
                          : () => removeMember(username),
                    ),
                  )
                  .toList(),
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: isLoading ? null : createChatRoom,
              icon: Icon(Icons.check),
              label: Text(isLoading ? 'กำลังสร้าง...' : 'สร้างห้องแชท'),
            ),
          ],
        ),
      ),
    );
  }
}
