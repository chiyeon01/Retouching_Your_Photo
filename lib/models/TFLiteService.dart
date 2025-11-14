import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

Future<List<dynamic>> _runInference(Map<String, dynamic> params) async {
  final image = params['cameraImage'] as CameraImage;
  final interpreterAddress = params['interpreterAddress'] as int;
  final inputSize = params['inputSize'] as int;

  final interpreter = Interpreter.fromAddress(interpreterAddress);

  final img.Image? convertedImage = _convertCameraImage(image);

  if (convertedImage == null) {
    return [];
  }

  final img.Image resizedImage = img.copyResize(
    convertedImage,
    width: inputSize,
    height: inputSize,
  );

  final normalizedPixels = resizedImage.getBytes(order: img.ChannelOrder.rgb).map((pixel) {
    return pixel / 255.0;
  }).toList();

  final inputBuffer = Float32List.fromList(normalizedPixels);

  final inputTensor = inputBuffer.reshape([1, inputSize, inputSize, 3]);

  final output = List.filled(1 * 10, 0.0).reshape([1, 10]);

  interpreter.run(inputTensor, output);

  return output[0];
}

img.Image? _convertCameraImage(CameraImage image) {
  if (image.format.group == ImageFormatGroup.yuv420) {
    return _convertYUV420(image);
  } else if (image.format.group == ImageFormatGroup.bgra8888) {
    return img.Image.fromBytes(
      width: image.width,
      height: image.height,
      bytes: image.planes[0].bytes.buffer,
      order: img.ChannelOrder.bgra,
    );
  } else {
    print("지원하지 않는 이미지 형식입니다: ${image.format.group}");
    return null;
  }
}

img.Image _convertYUV420(CameraImage image) {
  final int width = image.width;
  final int height = image.height;
  final int uvRowStride = image.planes[1].bytesPerRow;
  final int uvPixelStride = image.planes[1].bytesPerPixel!;

  final imageResult = img.Image(width: width, height: height);

  for (int y = 0; y < height; y++) {
    for (int x = 0; x < width; x++) {
      final int uvIndex = uvPixelStride * (x / 2).floor() + uvRowStride * (y / 2).floor();
      final int index = y * width + x;

      final yp = image.planes[0].bytes[index];
      final up = image.planes[1].bytes[uvIndex];
      final vp = image.planes[2].bytes[uvIndex];

      int r = (yp + vp * 1436 / 1024 - 179).round().clamp(0, 255);
      int g = (yp - up * 46549 / 131072 + 44 - vp * 93604 / 131072 + 91).round().clamp(0, 255);
      int b = (yp + up * 1814 / 1024 - 227).round().clamp(0, 255);

      imageResult.setPixelRgb(x, y, r, g, b);
    }
  }

  return imageResult;
}

class TFLiteService {
  late Interpreter _interpreter;
  final int _inputSize = 512;

  Future<void> loadModel() async {
    _interpreter = await Interpreter.fromAsset('asset/models/yolo11n_float16.tflite');
    print('모델 로드 완료.');
    print('Input tensor: ${_interpreter.getInputTensor(0).shape}');
    print('Output tensor: ${_interpreter.getOutputTensor(0).shape}');
  }

  Future<List<dynamic>> runInference(CameraImage cameraImage) async {
    final params = {
      'cameraImage': cameraImage,
      'interpreterAddress': _interpreter.address,
      'inputSize': _inputSize,
    };

    return await compute(_runInference, params);
  }

  void dispose() {
    _interpreter.close();
  }
}