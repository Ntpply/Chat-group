import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:convert';
import 'dart:typed_data';
import '../blocs/gallery.dart';
import '../events/gallery.dart';
import '../states/gallery.dart';
import '../widgets/fullScreenImage.dart';

class GalleryScreen extends StatelessWidget {
  const GalleryScreen({super.key});

  Widget buildImageItem(BuildContext context, Map<String, dynamic> imageData) {
    String base64 = imageData['base64'];
    if (base64.contains(',')) base64 = base64.split(',')[1];
    Uint8List bytes = base64Decode(base64);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => FullScreenImage(imageBytes: bytes)),
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.memory(
          bytes,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.grey[300],
              child: const Icon(Icons.broken_image),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    final roomId = args?['roomId'] ?? '';
    final roomName = args?['roomName'] ?? '';

    return BlocProvider(
      create: (_) => GalleryBloc()..add(LoadGalleryImages(roomId: roomId)),
      child: Scaffold(
        appBar: AppBar(
          title: Text('รูปภาพในแชท: $roomName'),
          backgroundColor: Colors.blue[600],
          foregroundColor: Colors.white,
        ),
        body: BlocBuilder<GalleryBloc, GalleryState>(
          builder: (context, state) {
            if (state.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.errorMessage != null) {
              return Center(child: Text(state.errorMessage!));
            }

            if (state.images.isEmpty) {
              return const Center(child: Text('ยังไม่มีรูปภาพในแชทนี้'));
            }

            return GridView.builder(
              padding: const EdgeInsets.all(8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
              ),
              itemCount: state.images.length,
              itemBuilder: (context, index) {
                return buildImageItem(context, state.images[index]);
              },
            );
          },
        ),
      ),
    );
  }
}
