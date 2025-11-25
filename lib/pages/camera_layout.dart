import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:camera_widget/pages/ai_guidance_overlay.dart';

class CameraLayout extends StatelessWidget {
  final CameraController controller;
  final XFile? lastPicture;
  final VoidCallback onCapture;
  final VoidCallback onSwitchCamera;
  final VoidCallback? onThumbnailTap;

  //AI에서 받아온 가이드 텍스트
  final String? aiGuidanceText;

  const CameraLayout({
    super.key,
    required this.controller,
    required this.lastPicture,
    required this.onCapture,
    required this.onSwitchCamera,
    this.onThumbnailTap,
    this.aiGuidanceText,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size.width;

    return Column(
      children: [
        // 상단 2/3: 카메라 프리뷰
        Transform.scale(
          scale: 1.0,
          child: AspectRatio(
            aspectRatio: 3.0 / 4.0,
            child: OverflowBox(
              alignment: Alignment.center,
              child: FittedBox(
                fit: BoxFit.fitWidth,
                child: SizedBox(
                  width: size,
                  height: size * controller.value.aspectRatio,
                  child: Stack(
                    children: [
                      CameraPreview(controller)
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        AiGuidanceOverlay(
            guidanceText: aiGuidanceText
        ),

        // 하단 1/3: 컨트롤 영역
        Expanded(
          flex: 1,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 왼쪽: 마지막 사진 썸네일
                GestureDetector(
                  onTap: onThumbnailTap,
                  child: SizedBox(
                    width: 64,
                    height: 64,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: lastPicture != null
                          ? Image.file(
                        File(lastPicture!.path),
                        fit: BoxFit.cover,
                      )
                          : Container(
                        color: Colors.grey.shade900,
                        child: const Icon(
                          Icons.photo,
                          color: Colors.white54,
                        ),
                      ),
                    ),
                  ),
                ),

                // 가운데: 촬영 버튼
                GestureDetector(
                  onTap: onCapture,
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 4,
                      ),
                    ),
                    child: Center(
                      child: Container(
                        width: 56,
                        height: 56,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),

                // 오른쪽: 카메라 전환 버튼
                IconButton(
                  iconSize: 32,
                  onPressed: onSwitchCamera,
                  icon: const Icon(
                    Icons.cameraswitch,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}