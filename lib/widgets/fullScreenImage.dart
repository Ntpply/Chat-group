import 'package:flutter/material.dart';
import 'dart:typed_data';

class FullScreenImage extends StatelessWidget {
  final Uint8List imageBytes;

  const FullScreenImage({super.key, required this.imageBytes});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Center(
          child: InteractiveViewer(
            minScale: 1.0,
            maxScale: 4.0,
            child: Image.memory(imageBytes),
          ),
        ),
      ),
    );
  }
}

