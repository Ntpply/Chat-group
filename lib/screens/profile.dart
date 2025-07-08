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
    return BlocConsumer<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state.isLoggedOut) {
          Navigator.pushReplacementNamed(context, '/');
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.grey[50],
          appBar: AppBar(
            title: const Text(
              'โปรไฟล์',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            backgroundColor: Colors.blue[600],
            elevation: 0,
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                // Profile Header
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Hero(
                        tag: 'user-avatar',
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.blue[400]!, Colors.blue[600]!],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(50),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blue.withOpacity(0.3),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              state.username != null
                                  ? state.username![0].toUpperCase()
                                  : '',
                              style: const TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        state.username ?? 'ไม่พบชื่อผู้ใช้',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.email_outlined,
                            size: 18,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 8),
                          Text(
                            state.email ?? '',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.verified_user,
                              size: 16,
                              color: Colors.green[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'ผู้ใช้งานยืนยันตัวตน',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.green[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Menu Section
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'การตั้งค่า',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildMenuCard(
                        icon: Icons.edit_outlined,
                        title: 'แก้ไขโปรไฟล์',
                        subtitle: 'เปลี่ยนแปลงข้อมูลส่วนตัว',
                        onTap: () {},
                      ),
                      const SizedBox(height: 8),
                      _buildMenuCard(
                        icon: Icons.notifications_outlined,
                        title: 'การแจ้งเตือน',
                        subtitle: 'จัดการการแจ้งเตือน',
                        onTap: () {
                          Navigator.pushNamed(context, '/notifications');
                        },
                      ),
                      const SizedBox(height: 8),
                      _buildMenuCard(
                        icon: Icons.security_outlined,
                        title: 'ความปลอดภัย',
                        subtitle: 'เปลี่ยนรหัสผ่าน',
                        onTap: () {},
                      ),
                      const SizedBox(height: 8),
                      _buildMenuCard(
                        icon: Icons.help_outline,
                        title: 'ช่วยเหลือ',
                        subtitle: 'คำถามที่พบบ่อย',
                        onTap: () {},
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Logout Button
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _showLogoutDialog(context);
                    },
                    icon: const Icon(Icons.logout_rounded, size: 24),
                    label: const Text(
                      'ออกจากระบบ',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[500],
                      foregroundColor: Colors.white,
                      elevation: 3,
                      shadowColor: Colors.red.withOpacity(0.3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: 1,
            onTap: (index) => _onItemTapped(context, index),
            backgroundColor: Colors.white,
            selectedItemColor: Colors.blue[600],
            unselectedItemColor: Colors.grey[400],
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
            elevation: 0,
            type: BottomNavigationBarType.fixed,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.chat_rounded),
                label: 'แชท',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_rounded),
                label: 'โปรไฟล์',
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMenuCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.blue[600], size: 24),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(fontSize: 13, color: Colors.grey[600]),
        ),
        trailing: Icon(
          Icons.chevron_right_rounded,
          color: Colors.grey[400],
          size: 24,
        ),
        onTap: onTap,
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'ออกจากระบบ',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          content: Text(
            'คุณต้องการออกจากระบบหรือไม่?',
            style: TextStyle(color: Colors.grey[600]),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: Text(
                'ยกเลิก',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                context.read<ProfileBloc>().add(LogoutEvent());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[500],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'ออกจากระบบ',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );
  }
}
