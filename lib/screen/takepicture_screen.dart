import 'dart:io';
import 'dart:async';

import 'package:camera/camera.dart';
import 'package:camera_widget/models/TFLiteService.dart';
import 'package:flutter/material.dart';

import '../utils/to_rgb.dart';

class TakePictureScreen extends StatefulWidget {
  final List<CameraDescription> cameras;

  const TakePictureScreen({
    super.key,
    required this.cameras,
  });

  @override
  State<TakePictureScreen> createState() => _TakePictureScreenState();
}

class _TakePictureScreenState extends State<TakePictureScreen> {
  late CameraController _controller;
  late TFLiteService _tfLiteService;

  bool _isProcessing = false;

  String _statusMessage = "추론 대기 중...";
  Timer? _statusTimer;

  @override
  void initState() {
    super.initState();

    _tfLiteService = TFLiteService();
    _tfLiteService.loadModel().then((_) {
      _initializeCamera();
    });
  }

  void _initializeCamera() async {
    _controller = CameraController(
      widget.cameras[0],
      ResolutionPreset.medium,
      enableAudio: false,
    );

    try {
      await _controller.initialize();
      if (!mounted) return;

      _controller.startImageStream((CameraImage image) {
        if (_isProcessing) {
          return;
        }

        _isProcessing = true;

        _tfLiteService.runInference(image).then((results) {
          if (results.isNotEmpty) {
            _statusTimer?.cancel();

            setState(() {
              _statusMessage = "추론 성공!";
            });

            _statusTimer = Timer(Duration(seconds: 1), () {
              if (mounted) {
                setState(() {
                  _statusMessage = "추론 대기 중...";
                });
              }
            });
          }
        }).whenComplete(() {
          _isProcessing = false;
        });
      });

      setState(() {});
    } catch (e) {
      print("카메라 초기화 실패: $e");
    }
  }

  @override
  void dispose() {
    _statusTimer?.cancel();
    _controller.stopImageStream();
    _controller.dispose();
    _tfLiteService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_controller.value.isInitialized) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('take a picture'),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          CameraPreview(_controller),
          _buildResultsWidget(),
        ],
      ),
    );
  }

  Widget _buildResultsWidget() {
    return Positioned(
      bottom: 20,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: _statusMessage == "추론 성공!"
                ? Colors.green.withOpacity(0.7)
                : Colors.black.withOpacity(0.5),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            _statusMessage,
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      )
    );
  }
}