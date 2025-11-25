import 'package:flutter/material.dart';

/// AI가 전달해준 가이드 문구를
/// 카메라 화면 중앙에 반투명 박스로 띄워주는 위젯.
class AiGuidanceOverlay extends StatelessWidget {
  /// AI가 넘겨주는 가이드 텍스트.
  /// null 또는 빈 문자열이면 UI를 숨김.
  final String? guidanceText;

  /// 애니메이션으로 서서히 보여줄지 여부
  final bool enabled;

  const AiGuidanceOverlay({
    super.key,
    required this.guidanceText,
    this.enabled = true,
  });

  bool get _hasMessage =>
      guidanceText != null && guidanceText!.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    // 카메라 터치 동작에 영향 없도록 IgnorePointer
    return IgnorePointer(
      ignoring: true,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: enabled && _hasMessage ? 1.0 : 0.0,
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDirectionIcon(),
                const SizedBox(width: 8),
                Text(
                  guidanceText ?? '',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDirectionIcon() {
    final text = guidanceText ?? '';

    IconData icon;

    if (text.contains('왼쪽')) {
      icon = Icons.undo;
    } else if (text.contains('오른쪽')) {
      icon = Icons.redo;
    } else if (text.contains('위')) {
      icon = Icons.arrow_upward;
    } else if (text.contains('아래')) {
      icon = Icons.arrow_downward;
    } else {
      icon = Icons.radio_button_checked; // 기본 아이콘 (중앙 유지 등)
    }

    return Icon(
      icon,
      color: Colors.white,
      size: 20,
    );
  }
}
