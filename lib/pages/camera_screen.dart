import 'dart:async';

import 'package:camera/camera.dart';
import 'package:camera_widget/models/TFLiteService.dart';
import 'package:flutter/material.dart';
import 'package:camera_widget/pages/camera_layout.dart';
import 'package:camera_widget/pages/image_preview_page.dart';

class CameraScreen extends StatefulWidget {
  final List<CameraDescription> cameras;

  const CameraScreen({
    super.key,
    required this.cameras,
  });

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  late TFLiteService _tfLiteService;

  bool _isProcessing = false;
  bool _isCameraInitialized = false;

  String _statusMessage = '대기중...';
  Timer? _statusTimer;

  int _currentCameraIndex = 0;
  XFile? _lastPicture;

  final Map<int, String> _labels = const {
    0: '카메라 흔들림',
    1: '좋음',
    2: '왼쪽으로 회전',
    3: '오른쪽으로 회전',
    4: '아래로 기울이기',
    5: '위로 기울이기',
  };

  @override
  void initState() {
    super.initState();

    _tfLiteService = TFLiteService();
    _tfLiteService.loadModel();
    _initCamera();
  }

  Future<void> _initCamera() async {
    await _setupCameraController();
    if (mounted) {
      setState(() {
        _isCameraInitialized = true;
      });
    }
  }

  Future<void> _setupCameraController() async {
    if (widget.cameras.isEmpty) return;

    _controller = CameraController(
      widget.cameras[_currentCameraIndex],
      ResolutionPreset.high,
      enableAudio: false,
    );

    await _controller.initialize();
    setState(() {});

    _controller.startImageStream((CameraImage image) {
      if (_isProcessing) {
        return;
      }

      _isProcessing = true;

      _tfLiteService.runInference(image).then((results) {
        if (results.isNotEmpty) {
          _statusTimer?.cancel();

          setState(() {
            _statusMessage = _labels[results[0]]!;
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

      setState(() {});
    });
  }

  @override
  void dispose() {
    _statusTimer?.cancel();
    _controller.dispose();
    _tfLiteService.dispose();
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

    if (!_isCameraInitialized) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return  SafeArea(
      child: CameraLayout(
        controller: _controller,
        lastPicture: _lastPicture,
        onCapture: _onCapture,
        onSwitchCamera: _onSwitchCamera,
        onThumbnailTap: _onThumbnailTap,
        aiGuidanceText: _statusMessage,
      ),
    );
  }
}
