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
  // 하단 네비게이션 바 인덱스 상태 관리
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 1) {
      // TODO: 갤러리 화면으로 이동하거나 갤러리 피커 실행
      print("갤러리 실행");
      // 갤러리 작업 후 다시 홈(0)으로 돌아오게 하려면 아래 코드 주석 해제
      // Future.delayed(const Duration(milliseconds: 300), () {
      //   setState(() => _selectedIndex = 0);
      // });
    }
  }

  @override
  Widget build(BuildContext context) {
    // 테마 색상 정의 (참고 이미지의 청록색)
    const Color themeColor = Color(0xFF26C6DA);
    const Color backgroundColor = Color(0xFFF5F6F8); // 눈이 편안한 옅은 회색 배경

    return Scaffold(
      backgroundColor: backgroundColor,

      // 본문 영역
      body: Column(
        children: [
          // 1. 상단 헤더 (둥근 배경)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 70, 24, 40), // 상단 여백 넉넉히
            decoration: const BoxDecoration(
              color: themeColor,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(0, 5),
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
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // 2. 중앙 메인 버튼 영역 (인물/배경)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                children: [
                  // 인물 촬영 카드
                  Expanded(
                    child: _FeatureCard(
                      icon: Icons.person_rounded,
                      title: '인물 촬영',
                      subtitle: '인생샷을 위한\n구도 추천',
                      themeColor: themeColor,
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
                  const SizedBox(width: 16), // 카드 사이 간격
                  // 배경 촬영 카드
                  Expanded(
                    child: _FeatureCard(
                      icon: Icons.landscape_rounded,
                      title: '배경 촬영',
                      subtitle: '풍경을 담는\n완벽한 비율',
                      themeColor: themeColor,
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

          // 하단 여백 (버튼이 너무 바닥에 붙지 않게)
          const SizedBox(height: 40),
        ],
      ),

      // 3. 하단 네비게이션 바 (홈 / 갤러리)
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              spreadRadius: 0,
              offset: Offset(0, -2),
            )
          ],
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.white,
          selectedItemColor: themeColor, // 선택된 아이콘 색상
          unselectedItemColor: Colors.grey[400], // 선택 안 된 아이콘 색상
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          elevation: 0, // 상단 그림자는 Container로 처리함
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

// 기능 카드 위젯 (세로로 긴 형태)
class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color themeColor;
  final VoidCallback onTap;

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.themeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (context, constraints) {
          // 화면 크기에 비례하여 카드 높이 설정 (너무 길어지지 않게 제한)
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
                      color: themeColor.withOpacity(0.15),
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
                      // 아이콘 배경 원
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: themeColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(icon, size: 48, color: themeColor),
                      ),
                      const Spacer(),
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF333333),
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