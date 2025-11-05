import 'dart:typed_data';

import 'package:camera_widget/utils/preprocessImage.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

Object loadModel(Uint8List input, int width, int height) async {
  // 모델 로드
  final interpreter = await Interpreter.fromAsset('asset/models/yolo11n_float16.tflite');

  // output shape
  var output = List.filled(1 * 8400 * 85, 0).reshape([1, 8400, 85]);

  // 전처리 이미지 반환
  final tensorImage = preprocessImage(
    input,
    width,
    height,
  );

  // 추론 -> output에 저장.
  print('=======================================');
  print('start inference!!!!');
  interpreter.run(tensorImage, output);
  print(output.length);

  return output;
}