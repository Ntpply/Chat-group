import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _selectedIndex = 2;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 0) {
      Navigator.pushNamed(context, '/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _pages = <Widget>[
      Center(child: Text('หน้าหลัก')), // index 0
      Center(child: Text('แจ้งเตือน')), // index 1
      Padding(
        padding: EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(50),
              ),
            ),
            Container(
              width: double.infinity, 
              margin: EdgeInsets.only(left: 10),
              decoration: BoxDecoration( color: Colors.blue,),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [Text('nitipoom'), Text('dasdasd')],
              ),
            ),
          ],
        ),
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: Text('โปรไฟล์')),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'หน้าหลัก'),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'แจ้งเตือน',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'โปรไฟล์'),
        ],
      ),
    );
  }
}
