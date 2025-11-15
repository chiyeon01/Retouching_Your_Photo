import 'package:camera/camera.dart';
import 'package:camera_widget/screen/takepicture_screen.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  final List<CameraDescription> cameras;

  const HomeScreen({
    super.key,
    required this.cameras,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TakePictureScreen(
        cameras: cameras,
      ),
    );
  }
}
