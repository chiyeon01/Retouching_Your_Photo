import 'dart:io';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

class ImagePreviewPage extends StatelessWidget {
  final XFile picture;

  const ImagePreviewPage({
    super.key,
    required this.picture,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          '사진 미리보기',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Center(
        child: InteractiveViewer(
          maxScale: 4.0,
          child: Image.file(
            File(picture.path),
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
