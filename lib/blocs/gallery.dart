import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import '../events/gallery.dart';
import '../states/gallery.dart';


class GalleryBloc extends Bloc<GalleryEvent, GalleryState> {
  GalleryBloc() : super(const GalleryState()) {
    on<LoadGalleryImages>(_onLoadGalleryImages);
  }

  Future<void> _onLoadGalleryImages(
      LoadGalleryImages event, Emitter<GalleryState> emit) async {
    emit(state.copyWith(isLoading: true));
    try {
      final response = await http.get(
        Uri.parse('http://192.168.1.55:8000/chat/images/${event.roomId}'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final images = data.map<Map<String, dynamic>>((e) {
          return {
            'id': e['_id'],
            'base64': e['content'],
            'timestamp': e['timestamp'],
          };
        }).toList();

        emit(state.copyWith(images: images, isLoading: false));
      } else {
        emit(state.copyWith(
          isLoading: false,
          errorMessage: 'โหลดรูปไม่สำเร็จ (${response.statusCode})',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'เกิดข้อผิดพลาด: $e',
      ));
    }
  }
}
