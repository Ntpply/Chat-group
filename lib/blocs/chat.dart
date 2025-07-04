import 'dart:convert';
import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../events/chat.dart';
import '../states/chat.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final secureStorage = const FlutterSecureStorage();
  final ImagePicker _picker = ImagePicker();
  IO.Socket? socket;

  ChatBloc() : super(const ChatState()) {
    on<InitializeChat>(_onInitializeChat);
    on<FetchUserId>(_onFetchUserId);
    on<FetchMessages>(_onFetchMessages);
    on<ConnectSocket>(_onConnectSocket);
    on<SendMessage>(_onSendMessage);
    on<ReceiveMessage>(_onReceiveMessage);
    on<PickAndSendImage>(_onPickAndSendImage);
    on<ClearError>(_onClearError);
  }

  Future<void> _onInitializeChat(InitializeChat event, Emitter<ChatState> emit) async {
    emit(state.copyWith(
      roomId: event.roomId,
      roomName: event.roomName,
      userName: event.userName,
      isLoading: true,
    ));
    add(FetchUserId());
  }

  Future<void> _onFetchUserId(FetchUserId event, Emitter<ChatState> emit) async {
    final id = await secureStorage.read(key: 'userId');
    emit(state.copyWith(userId: id));
    add(FetchMessages());
  }

  Future<void> _onFetchMessages(FetchMessages event, Emitter<ChatState> emit) async {
    if (state.roomId == null) return;
    try {
      final url = Uri.parse('http://192.168.1.55:8000/chat/messages/${state.roomId}');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final messages = data.map((msg) => {
          '_id': msg['_id'],
          'sender': msg['senderId']['username'],
          'senderId': msg['senderId']['_id'],
          'text': msg['content'],
          'type': msg['type'] ?? 'text',
          'timestamp': msg['timestamp'],
        }).toList();
        emit(state.copyWith(messages: messages.cast<Map<String, dynamic>>(), isLoading: false));
        add(ConnectSocket());
      } else {
        emit(state.copyWith(isLoading: false, error: 'โหลดข้อความไม่สำเร็จ'));
      }
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: 'เกิดข้อผิดพลาด: $e'));
    }
  }

  Future<void> _onConnectSocket(ConnectSocket event, Emitter<ChatState> emit) async {
    if (state.roomId == null) return;
    socket = IO.io('http://192.168.1.55:8000', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
      'reconnection': true,
      'reconnectionAttempts': 5,
      'reconnectionDelay': 1000,
    });

    socket?.connect();

    socket?.on('connect', (_) {
      socket?.emit('joinRoom', state.roomId);
    });

    socket?.on('reconnect', (_) {
      socket?.emit('joinRoom', state.roomId);
    });

    socket?.on('receiveMessage', (data) {
      add(ReceiveMessage(Map<String, dynamic>.from(data)));
    });

    socket?.on('disconnect', (_) {});
    socket?.on('connect_error', (error) {
      emit(state.copyWith(error: 'Socket connection error'));
    });
  }

  Future<void> _onSendMessage(SendMessage event, Emitter<ChatState> emit) async {
    if (socket == null || !socket!.connected || state.userId == null || state.roomId == null) {
      emit(state.copyWith(error: 'ไม่สามารถส่งข้อความได้ขณะนี้'));
      return;
    }

    socket?.emit('sendMessage', {
      'roomId': state.roomId,
      'senderId': state.userId,
      'text': event.content,
      'type': event.type,
    });
  }

  Future<void> _onReceiveMessage(ReceiveMessage event, Emitter<ChatState> emit) async {
    final updatedMessages = List<Map<String, dynamic>>.from(state.messages)..add(event.message);
    emit(state.copyWith(messages: updatedMessages));
  }

  Future<void> _onPickAndSendImage(PickAndSendImage event, Emitter<ChatState> emit) async {
    emit(state.copyWith(isSendingImage: true));
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 70,
      );

      if (image != null) {
        final bytes = await File(image.path).readAsBytes();
        final base64Image = base64Encode(bytes);
        final mimeType = _getMimeType(image.path);
        final base64WithPrefix = 'data:$mimeType;base64,$base64Image';

        add(SendMessage(base64WithPrefix, 'image'));
      }
    } catch (_) {}

    emit(state.copyWith(isSendingImage: false));
  }

  void _onClearError(ClearError event, Emitter<ChatState> emit) {
    emit(state.copyWith(error: null));
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

  @override
  Future<void> close() {
    socket?.disconnect();
    socket?.dispose();
    return super.close();
  }
}
