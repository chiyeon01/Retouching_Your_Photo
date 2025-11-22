import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'camera_screen.dart';

class MainScreen extends StatefulWidget {
  final List<CameraDescription> cameras;

  const MainScreen({super.key, required this.cameras});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 1) {
      // TODO: 갤러리 실행 로직
      print("갤러리 실행");
    }
  }

  @override
  Widget build(BuildContext context) {
    // 색상 팔레트
    const Color deepIndigo = Color(0xFF1A237E); // 헤더 배경
    const Color pointBlue = Color(0xFF283593);  // 아이콘 및 강조색
    const Color backgroundColor = Color(0xFFF5F6F8); // 배경색

    return Scaffold(
      backgroundColor: backgroundColor,

      body: Column(
        children: [
          // 1. 상단 헤더
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 70, 24, 40),
            decoration: BoxDecoration(
              color: deepIndigo,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
              boxShadow: [
                BoxShadow(
                  // 기존 남색 계열 그림자에서 검정색 계열로 변경
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Retouching\nYour Photo',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '원하는 촬영 모드를 선택해주세요.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.85),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // 2. 중앙 메인 버튼 영역
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                children: [
                  // 인물 촬영 버튼
                  Expanded(
                    child: _FeatureCard(
                      icon: Icons.person_rounded,
                      title: '인물 촬영',
                      subtitle: '인생샷을 위한\n구도 추천',
                      iconColor: pointBlue,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CameraScreen(cameras: widget.cameras),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  // 배경 촬영 버튼
                  Expanded(
                    child: _FeatureCard(
                      icon: Icons.landscape_rounded,
                      title: '배경 촬영',
                      subtitle: '풍경을 담는\n완벽한 비율',
                      iconColor: pointBlue,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CameraScreen(cameras: widget.cameras),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 40),
        ],
      ),

      // 3. 하단 네비게이션 바
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black12, // 기본 검정 그림자 유지
              blurRadius: 10,
              spreadRadius: 0,
              offset: Offset(0, -2),
            )
          ],
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.white,
          selectedItemColor: deepIndigo,
          unselectedItemColor: Colors.grey[400],
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          showUnselectedLabels: true,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded, size: 28),
              label: '홈',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.photo_library_rounded, size: 28),
              label: '갤러리',
            ),
          ],
        ),
      ),
    );
  }
}

// 기능 카드 위젯 (_FeatureCard)
class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color iconColor;
  final VoidCallback onTap;

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (context, constraints) {
          final double cardHeight = constraints.maxHeight * 0.65;

          return Center(
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(24),
              child: Ink(
                height: cardHeight,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      // [수정됨] 기존 iconColor 기반에서 검정색 기반으로 변경
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // 아이콘 배경
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: iconColor.withOpacity(0.08),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(icon, size: 48, color: iconColor),
                      ),
                      const Spacer(),
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        subtitle,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                          height: 1.5,
                        ),
                      ),
                      const Spacer(),
                    ],
                  ),
                ),
              ),
            ),
          );
        }
    );
  }
}