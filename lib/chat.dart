import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'dart:io';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final secureStorage = const FlutterSecureStorage();
  final ImagePicker _picker = ImagePicker();

  IO.Socket? socket;
  List<Map<String, dynamic>> messages = [];
  String? roomId;
  String? roomName;
  String? userName;
  String? userId;
  bool isLoading = true;
  bool isSendingImage = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null) {
        roomId = args['roomId'];
        roomName = args['roomName'];
        userName = args['userName'];
        initializeChat();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (socket != null && !socket!.connected && roomId != null) {
      _reconnectSocket();
    }
  }

  void _reconnectSocket() {
    if (socket != null && roomId != null) {
      socket!.connect();
      socket!.emit('joinRoom', roomId);
    }
  }

  Future<void> initializeChat() async {
    await getUserId();
    await fetchMessages();
    await connectSocket();
  }

  Future<void> getUserId() async {
    userId = await secureStorage.read(key: 'userId');
  }

  Future<void> fetchMessages() async {
    try {
      final url = Uri.parse('http://192.168.1.55:8000/chat/messages/$roomId');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            messages = data
                .map(
                  (msg) => {
                    '_id': msg['_id'],
                    'sender': msg['senderId']['username'],
                    'senderId': msg['senderId']['_id'],
                    'text': msg['content'],
                    'type': msg['type'] ?? 'text',
                    'timestamp': msg['timestamp'],
                  },
                )
                .toList();
            isLoading = false;
          });
          _scrollToBottom();
        }
      }
    } catch (e) {
      print('Error fetching messages: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> connectSocket() async {
    socket = IO.io('http://192.168.1.55:8000', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
      'reconnection': true,
      'reconnectionAttempts': 5,
      'reconnectionDelay': 1000,
    });

    socket?.connect();

    socket?.on('connect', (_) {
      print('Connected to socket');
      socket?.emit('joinRoom', roomId);
    });

    socket?.on('reconnect', (_) {
      print('Reconnected to socket');
      socket?.emit('joinRoom', roomId);
    });

    socket?.on('receiveMessage', (data) {
      if (mounted) {
        setState(() {
          messages.add({
            '_id': data['_id'],
            'sender': data['sender'],
            'senderId': data['senderId'],
            'text': data['text'],
            'type': data['type'],
            'timestamp': data['timestamp'],
          });
        });
        _scrollToBottom();
      }
    });

    socket?.on('disconnect', (_) {
      print('Disconnected from socket');
    });

    socket?.on('connect_error', (error) {
      print('Connection error: $error');
    });
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty || userId == null) return;

    final messageText = _messageController.text.trim();
    _sendMessageToSocket(messageText, 'text');
    _messageController.clear();
  }

  Future<void> _pickAndSendImage() async {
    try {
      setState(() {
        isSendingImage = true;
      });

      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 70,
      );

      if (image != null && userId != null) {
        final bytes = await File(image.path).readAsBytes();
        final base64Image = base64Encode(bytes);
        final mimeType = _getMimeType(image.path);
        final base64WithPrefix = 'data:$mimeType;base64,$base64Image';

        _sendMessageToSocket(base64WithPrefix, 'image');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('เกิดข้อผิดพลาดในการส่งรูปภาพ: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isSendingImage = false;
        });
      }
    }
  }

  String _getMimeType(String path) {
    final extension = path.split('.').last.toLowerCase();
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      default:
        return 'image/jpeg';
    }
  }

  void _sendMessageToSocket(String content, String type) {
    if (socket == null || !socket!.connected) {
      print('Socket not connected, attempting to reconnect...');
      _reconnectSocket();

      Future.delayed(const Duration(milliseconds: 1000), () {
        if (socket != null && socket!.connected) {
          socket?.emit('sendMessage', {
            'roomId': roomId,
            'senderId': userId,
            'text': content,
            'type': type,
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('ไม่สามารถส่งข้อความได้ กรุณาลองใหม่'),
              backgroundColor: Colors.red,
            ),
          );
        }
      });
    } else {
      socket?.emit('sendMessage', {
        'roomId': roomId,
        'senderId': userId,
        'text': content,
        'type': type,
      });
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
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
      final months = [
        'มกราคม',
        'กุมภาพันธ์',
        'มีนาคม',
        'เมษายน',
        'พฤษภาคม',
        'มิถุนายน',
        'กรกฎาคม',
        'สิงหาคม',
        'กันยายน',
        'ตุลาคม',
        'พฤศจิกายน',
        'ธันวาคม',
      ];
      dateText = '${date.day} ${months[date.month - 1]} ${date.year + 543}';
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Expanded(child: Divider(color: Colors.grey[300])),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                dateText,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          Expanded(child: Divider(color: Colors.grey[300])),
        ],
      ),
    );
  }

  bool _shouldShowDateSeparator(int index) {
    if (index == 0) return true;

    final currentMessage = messages[index];
    final previousMessage = messages[index - 1];

    final currentDate = DateTime.parse(currentMessage['timestamp']);
    final previousDate = DateTime.parse(previousMessage['timestamp']);

    final currentDay = DateTime(
      currentDate.year,
      currentDate.month,
      currentDate.day,
    );
    final previousDay = DateTime(
      previousDate.year,
      previousDate.month,
      previousDate.day,
    );

    return currentDay != previousDay;
  }

  Widget _buildImageMessage(String base64Data, bool isMe, String timeString) {
    // ลบ prefix ออกจาก base64 string
    String imageData = base64Data;
    if (base64Data.contains(',')) {
      imageData = base64Data.split(',')[1];
    }

    return Container(
      constraints: const BoxConstraints(maxWidth: 250, maxHeight: 300),
      child: Column(
        crossAxisAlignment: isMe
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        mainAxisSize:
            MainAxisSize.min, // Add this to prevent unnecessary expansion
        children: [
          Flexible(
            // Wrap the ClipRRect with Flexible
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.memory(
                base64Decode(imageData),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 200,
                    height: 150,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.broken_image,
                      size: 48,
                      color: Colors.grey,
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            timeString,
            style: TextStyle(color: Colors.grey[600], fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildMessage(Map<String, dynamic> message) {
    final isMe = message['senderId'] == userId;
    final timestamp = DateTime.parse(message['timestamp']);
    final timeString =
        '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Row(
        mainAxisAlignment: isMe
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.grey[400],
              child: Text(
                message['sender'][0].toUpperCase(),
                style: const TextStyle(fontSize: 12, color: Colors.white),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isMe
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                if (!isMe)
                  Padding(
                    padding: const EdgeInsets.only(left: 12, bottom: 4),
                    child: Text(
                      message['sender'],
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                if (message['type'] == 'image')
                  _buildImageMessage(message['text'], isMe, timeString)
                else
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isMe ? Colors.blue[500] : Colors.grey[200],
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      crossAxisAlignment: isMe
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                      children: [
                        Text(
                          message['text'],
                          style: TextStyle(
                            color: isMe ? Colors.white : Colors.black87,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          timeString,
                          style: TextStyle(
                            color: isMe ? Colors.white70 : Colors.grey[600],
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          if (isMe) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.blue[400],
              child: Text(
                userName?[0].toUpperCase() ?? 'U',
                style: const TextStyle(fontSize: 12, color: Colors.white),
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  void dispose() {
    socket?.off('receiveMessage');
    socket?.off('connect');
    socket?.off('disconnect');
    socket?.off('reconnect');
    socket?.off('connect_error');
    socket?.disconnect();
    socket?.dispose();

    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(roomName ?? 'แชท'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        elevation: 1,
      ),
      body: Column(
        children: [
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : messages.isEmpty
                ? const Center(
                    child: Text(
                      'ยังไม่มีข้อความ\nเริ่มแชทกันเลย!',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      final timestamp = DateTime.parse(message['timestamp']);

                      return Column(
                        children: [
                          if (_shouldShowDateSeparator(index))
                            _buildDateSeparator(timestamp),
                          _buildMessage(message),
                        ],
                      );
                    },
                  ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey[300]!)),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  GestureDetector(
                    onTap: isSendingImage ? null : _pickAndSendImage,
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: isSendingImage
                            ? Colors.grey[400]
                            : Colors.grey[600],
                        shape: BoxShape.circle,
                      ),
                      child: isSendingImage
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(
                              Icons.image,
                              color: Colors.white,
                              size: 20,
                            ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'พิมพ์ข้อความ...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(color: Colors.blue[400]!),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                      maxLines: null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _sendMessage,
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.blue[500],
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.send,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
