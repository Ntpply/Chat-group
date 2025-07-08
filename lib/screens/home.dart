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
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          title: Text(
            'หน้าหลัก',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          backgroundColor: Colors.blue[600],
          elevation: 0,
          centerTitle: true,
        ),
        body: BlocBuilder<HomeBloc, HomeState>(
          builder: (context, state) {
            if (state.isLoading) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[600]!),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'กำลังโหลด...',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              );
            }

            return SingleChildScrollView(
              child: Column(
                children: [
                  // User Profile Card
                  Container(
                    margin: EdgeInsets.all(16),
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 15,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Hero(
                          tag: 'user-avatar',
                          child: Container(
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.blue[400]!, Colors.blue[600]!],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(35),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.blue.withOpacity(0.3),
                                  blurRadius: 10,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                state.userName != null ? state.userName![0].toUpperCase() : '',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                state.userName ?? 'ไม่พบชื่อผู้ใช้',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[800],
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                state.userPhone ?? '',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.verified_user,
                          color: Colors.green[500],
                          size: 24,
                        ),
                      ],
                    ),
                  ),

                  // Add Chat Button
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 16),
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushNamed(context, '/addChatRoom', arguments: state.userName);
                      },
                      icon: Icon(Icons.add_comment_rounded, size: 24),
                      label: Text(
                        'เพิ่มแชทใหม่',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[600],
                        foregroundColor: Colors.white,
                        elevation: 3,
                        shadowColor: Colors.blue.withOpacity(0.3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 24),

                  // Chat Rooms Section
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        
                        SizedBox(width: 8),
                        Text(
                          'ห้องแชทของคุณ',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[800],
                          ),
                        ),
                        Spacer(),
                        Text(
                          '${state.chatRooms.length} ห้อง',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 12),

                  // Chat Rooms List
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 16),
                    constraints: BoxConstraints(
                      minHeight: 200,
                      maxHeight: MediaQuery.of(context).size.height * 0.5,
                    ),
                    child: state.chatRooms.isEmpty
                        ? Container(
                            padding: EdgeInsets.all(32),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.grey[300]!,
                                width: 1,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.chat_bubble_outline_rounded,
                                  size: 48,
                                  color: Colors.grey[400],
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'ยังไม่มีห้องแชท',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'เริ่มต้นสนทนาใหม่กันเลย!',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: BouncingScrollPhysics(),
                            itemCount: state.chatRooms.length,
                            itemBuilder: (context, index) {
                              final chatRoom = state.chatRooms[index];
                              return Container(
                                margin: EdgeInsets.only(bottom: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 8,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: ListTile(
                                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  leading: Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: Colors.blue[100],
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      Icons.chat_rounded,
                                      color: Colors.blue[600],
                                      size: 24,
                                    ),
                                  ),
                                  title: Text(
                                    chatRoom['name'] ?? 'ห้องไม่มีชื่อ',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey[800],
                                    ),
                                  ),
                                  subtitle: Text(
                                    'แตะเพื่อเข้าสู่ห้องแชท',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  trailing: Icon(
                                    Icons.chevron_right_rounded,
                                    color: Colors.grey[400],
                                    size: 24,
                                  ),
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
                                ),
                              );
                            },
                          ),
                  ),
                  
                  SizedBox(height: 20),
                ],
              ),
            );
          },
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: Offset(0, -5),
              ),
            ],
          ),
          child: BottomNavigationBar(
            currentIndex: 0,
            onTap: (index) {
              if (index == 1) _goToProfile(context);
            },
            backgroundColor: Colors.white,
            selectedItemColor: Colors.blue[600],
            unselectedItemColor: Colors.grey[400],
            selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600),
            elevation: 0,
            type: BottomNavigationBarType.fixed,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.chat_rounded),
                label: 'แชท',
              ),
              // BottomNavigationBarItem(
              //   icon: Icon(Icons.notifications_rounded),
              //   label: 'แจ้งเตือน',
              // ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_rounded),
                label: 'โปรไฟล์',
              ),
            ],
          ),
        ),
      ),
    );
  }
}