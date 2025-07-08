import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/allMember.dart';
import '../events/allMember.dart';
import '../states/allMember.dart';

class AllMemberScreen extends StatefulWidget {
  const AllMemberScreen({super.key});

  @override
  State<AllMemberScreen> createState() => _AllMemberScreenState();
}

class _AllMemberScreenState extends State<AllMemberScreen> {
  late String roomId;
  late String roomName;
  late String? currentUsername;
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _addMember(BuildContext context) {
    final username = _controller.text.trim();
    if (username.isNotEmpty) {
      context.read<AllMemberBloc>().add(AddMember(roomId, username));
      _controller.clear();
    }
  }

  void _removeMember(BuildContext context, String username) {
    context.read<AllMemberBloc>().add(RemoveMember(roomId, username));
  }

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    roomId = args['roomId'];
    roomName = args['roomName'] ?? 'ห้อง';
    currentUsername = args['currentUsername'];

    return BlocProvider(
      create: (_) =>
          AllMemberBloc('http://192.168.1.55:8000')..add(FetchMembers(roomId)),
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          title: Text(
            'สมาชิกใน $roomName',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
          backgroundColor: Colors.blue[600],
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),
        body: BlocConsumer<AllMemberBloc, AllMemberState>(
          listener: (context, state) {
            if (state.error != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.error!),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            }
          },
          builder: (context, state) {
            if (state.isLoading) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.blue[600]!,
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'กำลังโหลด...',
                      style: TextStyle(color: Colors.grey[600], fontSize: 16),
                    ),
                  ],
                ),
              );
            }

            return Column(
              children: [
                // Add Member Section
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                         
                          SizedBox(width: 8),
                          Text(
                            'เพิ่มสมาชิกใหม่',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[800],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _controller,
                              decoration: InputDecoration(
                                hintText: 'ชื่อผู้ใช้',
                                hintStyle: TextStyle(color: Colors.grey[500]),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: Colors.grey[300]!,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: Colors.grey[300]!,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: Colors.blue[600]!,
                                  ),
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                filled: true,
                                fillColor: Colors.grey[50],
                              ),
                            ),
                          ),
                          SizedBox(width: 12),
                          Container(
                            height: 48,
                            child: ElevatedButton(
                              onPressed: () => _addMember(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue[600],
                                foregroundColor: Colors.white,
                                elevation: 3,
                                shadowColor: Colors.blue.withOpacity(0.3),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: EdgeInsets.symmetric(horizontal: 16),
                              ),
                              child: Icon(Icons.add, size: 24),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Members List Section
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      
                      SizedBox(width: 8),
                      Text(
                        'สมาชิกในห้อง',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                      ),
                      Spacer(),
                      Text(
                        '${state.members.length} คน',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 12),

                // Members List
                Expanded(
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 16),
                    child: state.members.isEmpty
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
                                  Icons.group_outlined,
                                  size: 48,
                                  color: Colors.grey[400],
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'ยังไม่มีสมาชิก',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'เชิญเพื่อนมาร่วมสนทนากันเลย!',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            itemCount: state.members.length,
                            itemBuilder: (context, index) {
                              final member = state.members[index];
                              final username =
                                  member['username'] ?? 'ไม่ทราบชื่อ';
                              final isCurrentUser = username == currentUsername;

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
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  leading: Hero(
                                    tag: 'member-$username',
                                    child: Container(
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: isCurrentUser
                                              ? [
                                                  Colors.green[400]!,
                                                  Colors.green[600]!,
                                                ]
                                              : [
                                                  Colors.blue[400]!,
                                                  Colors.blue[600]!,
                                                ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        borderRadius: BorderRadius.circular(24),
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                (isCurrentUser
                                                        ? Colors.green
                                                        : Colors.blue)
                                                    .withOpacity(0.3),
                                            blurRadius: 8,
                                            offset: Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Center(
                                        child: Text(
                                          username[0].toUpperCase(),
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  title: Row(
                                    children: [
                                      Text(
                                        username,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.grey[800],
                                        ),
                                      ),
                                      if (isCurrentUser) ...[
                                        SizedBox(width: 8),
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.green[100],
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Text(
                                            'คุณ',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.green[600],
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  subtitle: Text(
                                    isCurrentUser
                                        ? 'สมาชิกปัจจุบัน'
                                        : 'สมาชิกในห้อง',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  trailing: isCurrentUser
                                      ? null
                                      : IconButton(
                                          icon: Icon(
                                            Icons.remove_circle_outline,
                                            color: Colors.red[400],
                                            size: 24,
                                          ),
                                          onPressed: () =>
                                              _removeMember(context, username),
                                        ),
                                ),
                              );
                            },
                          ),
                  ),
                ),

                SizedBox(height: 20),
              ],
            );
          },
        ),
      ),
    );
  }
}
