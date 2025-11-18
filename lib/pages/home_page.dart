import 'dart:async';

import 'package:camera/camera.dart';
import 'package:camera_widget/models/TFLiteService.dart';
import 'package:flutter/material.dart';
import 'package:camera_widget/pages/camera_layout.dart';
import 'package:camera_widget/pages/image_preview_page.dart';

class HomePage extends StatefulWidget {
  final List<CameraDescription> cameras;

  const HomePage({
    super.key,
    required this.cameras,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  late TFLiteService _tfLiteService;

  String _statusMessage = '대기중...';
  Timer? _statusTimer;

  int _currentCameraIndex = 0;
  XFile? _lastPicture;

  @override
  void initState() {
    super.initState();

    _tfLiteService = TFLiteService();
    _tfLiteService.loadModel().then((_) {
      _setupCameraController();
    });
  }

  Future<void> _setupCameraController() async {
    if (widget.cameras.isEmpty) return;

    _controller = CameraController(
      widget.cameras[_currentCameraIndex],
      ResolutionPreset.high,
      enableAudio: false,
    );

    _initializeControllerFuture = _controller.initialize();
    setState(() {});
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onCapture() async {
    if (!_controller.value.isInitialized || _controller.value.isTakingPicture) {
      return;
    }

    try {
      final picture = await _controller.takePicture();
      setState(() {
        _lastPicture = picture;
      });
      // TODO: 여기서 파일 저장 경로 관리, 편집 화면 이동 등 붙이면 됨
    } catch (e) {
      debugPrint('Error taking picture: $e');
    }
  }

  Future<void> _onSwitchCamera() async {
    if (widget.cameras.length < 2) return;

    _currentCameraIndex = (_currentCameraIndex + 1) % widget.cameras.length;

    await _controller.dispose();
    await _setupCameraController();
  }

  void _onThumbnailTap() {
    if (_lastPicture == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ImagePreviewPage(
          picture: _lastPicture!,
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (widget.cameras.isEmpty) {
      return const Center(
        child: Text(
          '사용 가능한 카메라가 없습니다.',
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    return FutureBuilder<void>(
      future: _initializeControllerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            _controller.value.isInitialized) {
          return SafeArea(
            child: CameraLayout(
              controller: _controller,
              lastPicture: _lastPicture,
              onCapture: _onCapture,
              onSwitchCamera: _onSwitchCamera,
              onThumbnailTap: _onThumbnailTap,
              aiGuidanceText: _statusMessage,
            ),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text(
              '카메라 초기화 실패: ${snapshot.error}',
              style: const TextStyle(color: Colors.white),
            ),
          );
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }
}
