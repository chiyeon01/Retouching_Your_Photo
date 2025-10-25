import 'package:tflite_flutter_helper_plus/tflite_flutter_helper_plus.dart';

// image가 모델로 들어가기 전 전처리하는 함수
TensorImage preprocessImage(List<int> rgbFlatList, int width, int height) {
  var tensorImage = TensorImage();

  // uint8 rgb -> 원본 사이즈로 resize
  tensorImage.loadRgbPixels(
    rgbFlatList,
    [height, width, 3], // 원본 CameraImage 크기
  );

  // Resize
  final resizeOp = ResizeOp(
    640, 640,
    ResizeMethod.nearestneighbour,
  );

  // Normalize
  final normalizeOp = NormalizeOp(0.0, 255.0);

  // processor -> image 변환
  tensorImage = ImageProcessorBuilder()
      .add(resizeOp) // resize
      .add(normalizeOp) // normalize
      .build() // build
      .process(tensorImage); // process 실행

  return tensorImage;
}