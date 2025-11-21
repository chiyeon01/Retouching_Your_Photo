import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'camera_screen.dart';

class MainScreen extends StatelessWidget {
  final List<CameraDescription> cameras;

  const MainScreen({super.key, required this.cameras});

  @override
  Widget build(BuildContext context) {
    final double buttonWidth = MediaQuery.of(context).size.width / 2.3;
    final double buttonHeight = buttonWidth * 1.1;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // 상단: 제목 2/3
            Expanded(
              flex: 2,
              child: Container(
                width: double.infinity,
                color: const Color(0xFF111827),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Retouching\nYour\nPhoto',
                      style: TextStyle(
                        fontSize: 60,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 하단 기능 버튼들 1/3
            Expanded(
              flex: 1,
              child: Container(
                width: double.infinity,
                color: const Color(0xFFF3F4F6),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _FullFeatureButton(
                      label: '인물',
                      icon: Icons.person,
                      width: buttonWidth,
                      height: buttonHeight,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CameraScreen(cameras: cameras),
                          ),
                        );
                      },
                    ),
                    _FullFeatureButton(
                      label: '배경',
                      icon: Icons.landscape,
                      width: buttonWidth,
                      height: buttonHeight,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CameraScreen(cameras: cameras),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FullFeatureButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final double width;
  final double height;
  final VoidCallback onTap;

  const _FullFeatureButton({
    required this.label,
    required this.icon,
    required this.width,
    required this.height,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: Ink(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              blurRadius: 12,
              offset: const Offset(0, 4),
              color: Colors.black.withOpacity(0.08),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50),
            const SizedBox(height: 12),
            Text(
              label,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
