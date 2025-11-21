import 'package:camera/camera.dart';

// RGB로 Flatten시켜주는 함수
List<int> toRGB(CameraImage image) {
  // B
  final List<int> B = image.planes[0].bytes;
  // G
  final List<int> G = image.planes[1].bytes;
  // R
  final List<int> R = image.planes[2].bytes;

  final List<List<int>> rgb_image = [];

  rgb_image.add(R);
  rgb_image.add(G);
  rgb_image.add(B);

  List<int> expanded_image = rgb_image.expand((x) => x).toList();

  return expanded_image;
}