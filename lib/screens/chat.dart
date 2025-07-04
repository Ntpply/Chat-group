import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/chat.dart';
import '../events/chat.dart';
import '../states/chat.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  String? roomId;
  String? roomName;
  String? userName;
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // เพิ่ม listener สำหรับการเลื่อนอัตโนมัติ
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom({bool animated = true}) {
    if (_scrollController.hasClients) {
      if (animated) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      } else {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    }
  }

  void _scrollToBottomDelayed() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 50), () {
        _scrollToBottom();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    roomId = args?['roomId'];
    roomName = args?['roomName'];
    userName = args?['userName'];
    
    return BlocProvider(
      create: (_) => ChatBloc()
        ..add(
          InitializeChat(
            args?['roomId'] ?? '',
            args?['roomName'] ?? '',
            args?['userName'] ?? '',
          ),
        ),
      child: BlocConsumer<ChatBloc, ChatState>(
        listener: (context, state) {
          if (state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error!),
                backgroundColor: Colors.red.shade400,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
            context.read<ChatBloc>().add(ClearError());
          }
          
          // เลื่อนไปล่าสุดเมื่อมีข้อความใหม่หรือเริ่มต้น
          if (state.messages.isNotEmpty) {
            _scrollToBottomDelayed();
          }
        },
        builder: (context, state) {
          return Scaffold(
            backgroundColor: Colors.grey.shade50,
            appBar: AppBar(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    state.roomName ?? 'แชท',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Text(
                    'กำลังออนไลน์',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              elevation: 0,
              shadowColor: Colors.transparent,
              actions: [
                IconButton(
                  icon: const Icon(Icons.more_vert, size: 24),
                  onPressed: () {
                    _showMenuOptions(context, state);
                  },
                  tooltip: 'ตัวเลือกเพิ่มเติม',
                ),
              ],
            ),
            body: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color.fromARGB(255, 255, 61, 12).withOpacity(0.05),
                    Colors.grey.shade50,
                  ],
                ),
              ),
              child: Column(
                children: [
                  Expanded(
                    child: state.isLoading
                        ? const Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Color(0xFF1976D2),
                              ),
                            ),
                          )
                        : state.messages.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.chat_bubble_outline,
                                      size: 64,
                                      color: Colors.grey.shade400,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'ยังไม่มีข้อความ',
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'เริ่มแชทกันเลย!',
                                      style: TextStyle(
                                        color: Colors.grey.shade500,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : NotificationListener<ScrollNotification>(
                                onNotification: (notification) {
                                  return false;
                                },
                                child: ListView.builder(
                                  controller: _scrollController,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  itemCount: state.messages.length,
                                  // เพิ่มประสิทธิภาพการเลื่อน
                                  physics: const BouncingScrollPhysics(),
                                  // ใช้ cache extent เพื่อการเลื่อนที่ราบรื่น
                                  cacheExtent: 1000,
                                  itemBuilder: (context, index) {
                                    final message = state.messages[index];
                                    final timestamp = DateTime.parse(
                                      message['timestamp'],
                                    );
                                    final showDateSeparator = _shouldShowDateSeparator(
                                      state.messages,
                                      index,
                                    );
                                    
                                    return Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        if (showDateSeparator)
                                          _buildDateSeparator(timestamp),
                                        _buildMessage(message, state.userName),
                                      ],
                                    );
                                  },
                                ),
                              ),
                  ),
                  _buildInputBar(context, state),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _navigateToImageGallery() {
    if (roomId == null || roomName == null) {
      print('Room ID or Room Name is null');
      return;
    }

    Navigator.pushNamed(
      context,
      '/gallery',
      arguments: {'roomId': roomId, 'roomName': roomName},
    );
  }

  bool _shouldShowDateSeparator(
    List<Map<String, dynamic>> messages,
    int index,
  ) {
    if (index == 0) return true;
    final currentDate = DateTime.parse(messages[index]['timestamp']);
    final previousDate = DateTime.parse(messages[index - 1]['timestamp']);
    return !(currentDate.year == previousDate.year &&
        currentDate.month == previousDate.month &&
        currentDate.day == previousDate.day);
  }

  Widget _buildDateSeparator(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDate = DateTime(date.year, date.month, date.day);
    
    String dateText;
    if (messageDate == today) {
      dateText = 'วันนี้';
    } else if (messageDate == yesterday) {
      dateText = 'เมื่อวาน';
    } else {
      dateText = '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    }

    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 16),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          dateText,
          style: TextStyle(
            color: Colors.grey.shade700,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildMessage(Map<String, dynamic> message, String? currentUserName) {
    final isMe = message['sender'] == currentUserName;
    final timestamp = DateTime.parse(message['timestamp']);
    final timeString = '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (!isMe)
            Padding(
              padding: const EdgeInsets.only(left: 12, bottom: 4),
              child: Text(
                message['sender'] ?? 'ไม่ทราบชื่อ',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade600,
                ),
              ),
            ),
          Row(
            mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (isMe) ...[
                Padding(
                  padding: const EdgeInsets.only(right: 8, bottom: 4),
                  child: Text(
                    timeString,
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ),
              ],
              Flexible(
                child: _buildMessageBubble(message, isMe),
              ),
              if (!isMe) ...[
                Padding(
                  padding: const EdgeInsets.only(left: 8, bottom: 4),
                  child: Text(
                    timeString,
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> message, bool isMe) {
    final borderRadius = isMe
        ? const BorderRadius.only(
            topLeft: Radius.circular(18),
            topRight: Radius.circular(4),
            bottomLeft: Radius.circular(18),
            bottomRight: Radius.circular(18),
          )
        : const BorderRadius.only(
            topLeft: Radius.circular(4),
            topRight: Radius.circular(18),
            bottomLeft: Radius.circular(18),
            bottomRight: Radius.circular(18),
          );

    Widget messageContent;
    if (message['type'] == 'image') {
      final base64Str = message['text'] as String;
      final imageBytes = base64Decode(base64Str.split(',').last);
      messageContent = ClipRRect(
        borderRadius: borderRadius,
        child: Image.memory(
          imageBytes,
          width: 200,
          fit: BoxFit.cover,

        ),
      );
    } else {
      messageContent = Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          gradient: isMe
              ? const LinearGradient(
                  colors: [Color(0xFF1976D2), Color(0xFF1565C0)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : LinearGradient(
                  colors: [Colors.white, Colors.grey.shade50],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
          borderRadius: borderRadius,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Text(
          message['text'] ?? '',
          style: TextStyle(
            color: isMe ? Colors.white : Colors.grey.shade800,
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
        ),
      );
    }

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.7,
      ),
      child: messageContent,
    );
  }

  Widget _buildInputBar(BuildContext context, ChatState state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1976D2).withOpacity(0.1),
                borderRadius: BorderRadius.circular(24),
              ),
              child: IconButton(
                icon: Icon(
                  state.isSendingImage ? Icons.hourglass_empty : Icons.image_outlined,
                  color: const Color(0xFF1976D2),
                  size: 22,
                ),
                onPressed: state.isSendingImage
                    ? null
                    : () {
                        context.read<ChatBloc>().add(PickAndSendImage());
                      },
                tooltip: 'ส่งรูปภาพ',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: _controller,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (value) {
                    _sendMessage(context);
                  },
                  style: const TextStyle(fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'พิมพ์ข้อความ...',
                    hintStyle: TextStyle(color: Colors.grey.shade500),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1976D2), Color(0xFF1565C0)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.send,
                  color: Colors.white,
                  size: 20,
                ),
                onPressed: () {
                  _sendMessage(context);
                },
                tooltip: 'ส่งข้อความ',
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _sendMessage(BuildContext context) {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    
    context.read<ChatBloc>().add(SendMessage(text, 'text'));
    _controller.clear();
    
    // เลื่อนไปข้อความล่าสุดหลังส่ง
    
  }

  void _showMenuOptions(BuildContext context, ChatState state) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: SafeArea(
            child: Wrap(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'ตัวเลือก',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade800,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildMenuTile(
                  ctx,
                  Icons.person_outline,
                  'ดูรายละเอียดสมาชิก',
                  const Color(0xFF1976D2),
                  () {
                    Navigator.pop(ctx);
                    // TODO: เพิ่มฟังก์ชันดูสมาชิก
                  },
                ),
                _buildMenuTile(
                  ctx,
                  Icons.photo_library_outlined,
                  'รูปภาพทั้งหมด',
                  const Color(0xFF388E3C),
                  () {
                    Navigator.pop(ctx);
                    _navigateToImageGallery();
                  },
                ),
                _buildMenuTile(
                  ctx,
                  Icons.exit_to_app_outlined,
                  'ออกจากห้องแชท',
                  const Color(0xFFD32F2F),
                  () {
                    Navigator.pop(ctx);
                    Navigator.pop(context);
                  },
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMenuTile(
    BuildContext context,
    IconData icon,
    String title,
    Color color,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.grey.shade800,
        ),
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
    );
  }
}