import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:camera_widget/utils/preprocessImage.dart';
import 'package:flutter/foundation.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import 'package:yuv_converter/yuv_converter.dart';

late Interpreter _interpreter;
late List<int> _inputShape;
late TensorType _inputType;
late Tensor _outputTensor;

Future<void> loadModel() async {
  try {
    // 모델 로드
    _interpreter =
    await Interpreter.fromAsset('asset/models/yolo11n_float16.tflite');

    var inputTensor = _interpreter.getInputTensor(0);
    _inputShape = inputTensor.shape;
    _inputType = inputTensor.type;

    _outputTensor = _interpreter.getOutputTensor(0);

    print('모델 로드 성공. 입력: $_inputShape, 타입: $_inputType');
  } catch (e) {
    print('모델 로드 실패: $e');
  }
}

Future<void> runModelOnFrame(CameraImage cameraImage) async {
  img.Image rgbImage = await compute(convertCameraImageToImage, cameraImage);

  final Uint8List rgbBytes = rgbImage.getBytes(order: img.ChannelOrder.rgb);
  int width = rgbImage.width;
  int height = rgbImage.height;

  ByteBuffer inputBuffer = preprocessImage(rgbBytes, width, height);

  var outputShape = _outputTensor.shape;
  var outputType = _outputTensor.type;

  Map<int, Object> outputBuffers = {};

  if (outputType == TensorType.float32) {
    List<double> list = List.filled(outputShape[1], 0.0);
    List<List<double>> resultLists = [list];
    outputBuffers[0] = resultLists;
  } else {
    List<int> list = List.filled(outputShape[1], 0);
    List<List<int>> resultLists = [list];
    outputBuffers[0] = resultLists;
  }

  _interpreter.runForMultipleInputs([inputBuffer], outputBuffers);

  var rawResults = outputBuffers[0] as List<List<dynamic>>;

  List<dynamic> results = rawResults[0];

  print("AI 추론 결과: $results");
}

Future<img.Image> convertCameraImageToImage(CameraImage cameraImage) async {
  if (cameraImage.format.group == ImageFormatGroup.yuv420) {
    final Uint8List? abgrBytes = await YuvConverter.yuv420ToAbgr(
      cameraImage.planes[0].bytes,
      cameraImage.planes[1].bytes,
      cameraImage.planes[2].bytes,
      cameraImage.width,
      cameraImage.height,
      cameraImage.planes[1].bytesPerPixel!,
      cameraImage.planes[1].bytesPerRow,
    );

    if (abgrBytes == null) {
      throw Exception('YUV 변환 실패');
    }

    return img.Image.fromBytes(
      width: cameraImage.width,
      height: cameraImage.height,
      bytes: abgrBytes.buffer,
      order: img.ChannelOrder.abgr,
    );
  } else if (cameraImage.format.group == ImageFormatGroup.bgra8888) {
    return img.Image.fromBytes(
      width: cameraImage.width,
      height: cameraImage.height,
      bytes: cameraImage.planes[0].bytes.buffer,
      order: img.ChannelOrder.bgra,
      rowStride: cameraImage.planes[0].bytesPerRow,
    );
  } else {
    throw Exception('지원하지 않는 이미지 형식입니다.');
  }
}


