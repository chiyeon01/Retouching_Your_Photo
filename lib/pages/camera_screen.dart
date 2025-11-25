import 'dart:async';

import 'package:camera/camera.dart';
import 'package:camera_widget/service/TFLiteService.dart';
import 'package:flutter/material.dart';
import 'package:camera_widget/pages/camera_layout.dart';
import 'package:camera_widget/pages/image_preview_page.dart';

enum CameraMode { portrait, landscape }

class CameraScreen extends StatefulWidget {
  final List<CameraDescription> cameras;
  final CameraMode mode;

  const CameraScreen({
    super.key,
    required this.cameras,
    required this.mode,
  });

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  late TFLiteService _tfLiteService;

  bool _isProcessing = false;
  bool _isCameraInitialized = false;
  bool _isModelLoaded = false;

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
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      await _tfLiteService.loadModel(widget.mode);
      _isModelLoaded = true;
    } catch (e) {
      debugPrint('모델 로드 실패: $e');
    }

    await _setupCameraController();

    if (mounted) {
      setState(() {
        _isCameraInitialized = true;
      });
    }
  }

  Future<void> _setupCameraController() async {
    print(widget.cameras.length);
    if (widget.cameras.isEmpty) return;

    _controller = CameraController(
      widget.cameras[_currentCameraIndex],
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.yuv420,
    );

    try {
      await _controller.initialize();

      if (!mounted) return;
      setState(() {});

      _controller.startImageStream((CameraImage image) {
        if (!mounted || _isProcessing || !_isModelLoaded) {
          return;
        }

        _isProcessing = true;
        // final stopwatch = Stopwatch()..start();

        _tfLiteService.runInference(image).then((results) {
          if (!mounted) return;
          // stopwatch.stop();
          // final int elapsed = stopwatch.elapsedMilliseconds;
          //
          // print('추론 소요 시간: ${elapsed}ms');

          if (results.isNotEmpty) {
            _statusTimer?.cancel();

            final String newMessage = _labels[results[0]] ?? '알 수 없음';

            if (_statusMessage != newMessage) {
              setState(() {
                _statusMessage = newMessage;
              });
            }

            _statusTimer = Timer(Duration(seconds: 1), () {
              if (mounted) {
                setState(() {
                  _statusMessage = "추론 대기 중...";
                });
              }
            });
          }
        }).catchError((e) {
          debugPrint("Inference error: $e");
        }).whenComplete(() {
          if (mounted) {
            _isProcessing = false;
          }
        });
      });
    } catch (e) {
      debugPrint("카메라 초기화 오류: $e");
    }
  }

  @override
  void dispose() {
    _statusTimer?.cancel();

    if (_controller.value.isInitialized && _controller.value.isStreamingImages) {
      _controller.stopImageStream();
    }

    _tfLiteService.dispose();

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

    if (!_isCameraInitialized) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return  CameraLayout(
      controller: _controller,
      lastPicture: _lastPicture,
      onCapture: _onCapture,
      onSwitchCamera: _onSwitchCamera,
      onThumbnailTap: _onThumbnailTap,
      aiGuidanceText: _statusMessage,
    );
  }
}
