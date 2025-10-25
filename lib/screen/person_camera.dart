import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class PersonCamera extends StatelessWidget {
  final firstCamera;

  const PersonCamera({
    super.key,
    required this.firstCamera,
  });

  @override
  Widget build(BuildContext context) {
    return TakePictureScreen(
      camera: firstCamera,
    );
  }
}

class TakePictureScreen extends StatefulWidget {
  // CameraController에서 controll할 카메라 선택
  final CameraDescription camera;

  const TakePictureScreen({
    super.key,
    required this.camera,
  });

  @override
  State<TakePictureScreen> createState() => _TakePictureScreenState();
}

class _TakePictureScreenState extends State<TakePictureScreen> {
  // camera controller로 camera controll
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _controller = CameraController(
      widget.camera, // 사용할 카메라
      ResolutionPreset.medium, // 해상도
    );

    // controller 초기화로 Future 타입 반환.
    // 이 과정을 거치지 않으면 사진을 찍을수도, preview도 실행 못함.
    _initializeControllerFuture = _controller.initialize();
  }

  // controller dispose
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('take a picture'),
      ),
      body: FutureBuilder(
          future: _initializeControllerFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done){
              return CameraPreview(_controller);
            } else {
              return const Center(
                  child: CircularProgressIndicator()
              );
            }
          }
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () async {
            try{
              await _initializeControllerFuture;

              final image = await _controller.takePicture();

              if (!context.mounted) return;

              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => DisplayPictureScreen(
                    imagePath: image.path,
                  ),
                ),
              );
            } catch (e) {
              print(e);
            }
          },
          child: const Icon(Icons.camera_alt)
      ),
    );
  }
}

class DisplayPictureScreen extends StatelessWidget {
  final String imagePath;

  const DisplayPictureScreen({
    super.key,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Display the Picture'),
      ),
      body: Image.file(File(imagePath)),
    );
  }
}