import 'dart:typed_data';

import 'package:image/image.dart' as img;

// image가 모델로 들어가기 전 전처리하는 함수
ByteBuffer preprocessImage(Uint8List rgbFlatList, int width, int height) {
  // Image 객체로 변환
  img.Image originalImage = img.Image.fromBytes(
    width: width,
    height: height,
    bytes: rgbFlatList.buffer,
    order: img.ChannelOrder.rgb,
  );

  // Resize
  img.Image resizedImage = img.copyResize(
    originalImage,
    width: 640,
    height: 640,
    interpolation: img.Interpolation.nearest,
  );

  // Normalize
  var imageBytes = resizedImage.getBytes(order: img.ChannelOrder.rgb);

  Float32List floatList = Float32List(640 * 640 * 3);

  int bufferIndex = 0;
  for (int i = 0; i < imageBytes.length; i++) {
    floatList[bufferIndex++] = imageBytes[i] / 255.0;
  }

  return floatList.buffer;
}