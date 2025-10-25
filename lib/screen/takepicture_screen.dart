import 'dart:io';
import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import '../models/tfmodel.dart';
import '../utils/to_rgb.dart';

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
  // camera controller로 camera 컨트롤.
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  final StreamController<CameraImage> imageStreamController = StreamController<CameraImage>();

  bool isStartStreaming = false;
  bool isBusy = false;

  String? testText;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    // CameraController 객체 설정
    _controller = CameraController(
      widget.camera, // 사용할 카메라
      ResolutionPreset.medium, // 해상도
      imageFormatGroup: ImageFormatGroup.bgra8888, // 이미지 포맷을 bgr로
    );

    // controller 초기화로 Future 타입 반환.
    // 이 과정을 거치지 않으면 사진을 찍을수도, preview도 실행 못함.
    _initializeControllerFuture = _controller.initialize().then(
      (_){
        if (isStartStreaming){
          return ;
        }

        _controller.startImageStream(
          (CameraImage image){
            // 하나의 프레임씩 처리
            if (isBusy) {
              return ;
            }

            // 현재 프레임 처리중..
            isBusy = true;

            try {
              imageStreamController.sink.add(image);
            } catch (e) {
              print(e);
            } finally {
              // 처리 끝
              isBusy = false;
            }
          }
        );
      }
    );
  }

  // controller dispose
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    // controller dispose frame별로 받아오는 streaming stop
    try {
      if (_controller.value.isStreamingImages){
        _controller.stopImageStream();
      }
    } catch (e) {}

    //dispose
    _controller.dispose();
    imageStreamController.close();
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
              return Column(
                children: [
                  CameraPreview(
                    _controller
                  ),
                  StreamBuilder(
                    stream: imageStreamController.stream,
                    builder: (context, snapshot) {
                      // 여기에 인공지능 모델 들어감.

                      // 1차원임에 주의!!!
                      final rgb_image = toRGB(snapshot.data!);
                      print('============================================');
                      print('return_model!!!!');

                      // final output = load_model(
                      //   rgb_image,
                      //   snapshot.data!.width,
                      //   snapshot.data!.height,
                      // );

                      print('output 처리 완료!!!');
                      //print(output);

                      return Text('${snapshot.data}');
                    }
                  ),
                ],
              );
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