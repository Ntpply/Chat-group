import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/addChatRoom.dart';
import '../events/addChatRoom.dart';
import '../states/addChatRoom.dart';

class AddChatRoomScreen extends StatefulWidget {
  const AddChatRoomScreen({super.key});

  @override
  State<AddChatRoomScreen> createState() => _AddChatRoomScreenState();
}

class _AddChatRoomScreenState extends State<AddChatRoomScreen> {
  final TextEditingController roomNameController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  bool isUsernameNotEmpty = false;

  @override
  void initState() {
    super.initState();
    usernameController.addListener(() {
      setState(() {
        isUsernameNotEmpty = usernameController.text.isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    roomNameController.dispose();
    usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AddChatRoomBloc()..add(FetchUserData()),
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          title: Text(
            'สร้างห้องแชท',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
          backgroundColor: Colors.blue[600],
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: BlocConsumer<AddChatRoomBloc, AddChatRoomState>(
          listener: (context, state) {
            if (state.error != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.white),
                      SizedBox(width: 12),
                      Expanded(child: Text(state.error!)),
                    ],
                  ),
                  backgroundColor: Colors.red[600],
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            }
          },
          builder: (context, state) {
            if (state.currentUsername == null) {
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
                      'กำลังโหลดข้อมูล...',
                      style: TextStyle(color: Colors.grey[600], fontSize: 16),
                    ),
                  ],
                ),
              );
            }

            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Card
                    Container(
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
                              Container(
                                padding: EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.blue[100],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.chat_bubble_outline_rounded,
                                  color: Colors.blue[600],
                                  size: 24,
                                ),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'สร้างห้องแชทใหม่',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey[800],
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'กำหนดชื่อห้องและเพิ่มสมาชิก',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 20),

                    // Room Name Section
                    Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ชื่อห้องแชท',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[800],
                            ),
                          ),
                          SizedBox(height: 12),
                          TextField(
                            controller: roomNameController,
                            decoration: InputDecoration(
                              hintText: 'ตั้งชื่อห้องแชทของคุณ',
                              prefixIcon: Icon(Icons.label_outline_rounded),
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
                              filled: true,
                              fillColor: Colors.grey[50],
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 20),

                    // Members Section
                    Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'สมาชิกในห้อง',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[800],
                                ),
                              ),
                              Spacer(),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.blue[100],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '${state.memberUsernames.length} คน',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.blue[700],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: usernameController,
                                  decoration: InputDecoration(
                                    hintText: 'เช่น pear123',
                                    prefixIcon: Icon(Icons.person_add_outlined),
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
                                    filled: true,
                                    fillColor: Colors.grey[50],
                                  ),
                                ),
                              ),
                              SizedBox(width: 12),
                              Container(
                                height: 56,
                                child: ElevatedButton(
                                  onPressed: usernameController.text.isEmpty
                                      ? null
                                      : () {
                                          context.read<AddChatRoomBloc>().add(
                                            AddMember(usernameController.text),
                                          );
                                          usernameController.clear();
                                        },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue[600],
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 2,
                                  ),
                                  child: Icon(Icons.add_rounded),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          // Members List
                          if (state.memberUsernames.isNotEmpty)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'สมาชิกที่เพิ่มแล้ว:',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey[700],
                                  ),
                                ),
                                SizedBox(height: 8),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: state.memberUsernames.map((
                                    username,
                                  ) {
                                    final isCurrentUser =
                                        username == state.currentUsername;
                                    return Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isCurrentUser
                                            ? Colors.blue[100]
                                            : Colors.grey[100],
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: isCurrentUser
                                              ? Colors.blue[300]!
                                              : Colors.grey[300]!,
                                          width: 1,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          if (isCurrentUser)
                                            Icon(
                                              Icons.account_circle,
                                              size: 16,
                                              color: Colors.blue[600],
                                            ),
                                          if (isCurrentUser) SizedBox(width: 4),
                                          Text(
                                            username,
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              color: isCurrentUser
                                                  ? Colors.blue[700]
                                                  : Colors.grey[700],
                                            ),
                                          ),
                                          if (isCurrentUser)
                                            Container(
                                              margin: EdgeInsets.only(left: 4),
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 4,
                                                vertical: 2,
                                              ),
                                              decoration: BoxDecoration(
                                                color: Colors.blue[600],
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                'คุณ',
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          if (!isCurrentUser)
                                            SizedBox(width: 8),
                                          if (!isCurrentUser)
                                            GestureDetector(
                                              onTap: () => context
                                                  .read<AddChatRoomBloc>()
                                                  .add(RemoveMember(username)),
                                              child: Icon(
                                                Icons.close_rounded,
                                                size: 16,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),

                    SizedBox(height: 30),

                    // Create Button
                    Container(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton.icon(
                        onPressed:
                            state.isLoading || roomNameController.text.isEmpty
                            ? null
                            : () {
                                context.read<AddChatRoomBloc>().add(
                                  CreateChatRoom(roomNameController.text),
                                );
                              },
                        icon: state.isLoading
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : Icon(
                                Icons.check_circle_outline_rounded,
                                size: 24,
                              ),
                        label: Text(
                          state.isLoading
                              ? 'กำลังสร้างห้องแชท...'
                              : 'สร้างห้องแชท',
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

                    SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
