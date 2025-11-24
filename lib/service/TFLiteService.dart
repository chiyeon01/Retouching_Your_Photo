import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:camera_widget/pages/camera_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

Future<List<dynamic>> _runInference(Map<String, dynamic> params) async {
  final image = params['cameraImage'] as CameraImage;
  final interpreterAddress = params['interpreterAddress'] as int;

  final inputShape = params['inputShape'] as List<int>;
  final outputShape = params['outputShape'] as List<int>;
  final normMean = params['normMean'] as double;
  final normStd = params['normStd'] as double;

  final interpreter = Interpreter.fromAddress(interpreterAddress);

  final inputSize = inputShape[1];

  final img.Image? convertedImage = _convertCameraImage(image);

  if (convertedImage == null) {
    print("이미지 변환 실패");
    return [];
  }

  int size = convertedImage.width < convertedImage.height
      ? convertedImage.width
      : convertedImage.height;

  final img.Image croppedImage = img.copyCrop(
    convertedImage,
    x: (convertedImage.width - size) ~/ 2,
    y: (convertedImage.height - size) ~/ 2,
    width: size,
    height: size,
  );

  final img.Image resizedImage = img.copyResize(
    croppedImage,
    width: inputSize,
    height: inputSize,
  );

  final imageBytes = resizedImage.getBytes(order: img.ChannelOrder.rgb);
  final normalizedPixels = imageBytes.map((pixel) {
    return (pixel - normMean) / normStd;
  }).toList();

  final inputBuffer = Float32List.fromList(normalizedPixels);
  final inputTensor = inputBuffer.reshape(inputShape);

  final outputCount = outputShape[0] * outputShape[1];
  final output = Float32List(outputCount).reshape(outputShape);

  interpreter.run(inputTensor, output);

  final List<double> outputList = output[0];
  int maxIndex = 0;

  for (int i = 0; i < outputList.length; i++) {
    if (outputList[i] > outputList[maxIndex]) {
      maxIndex = i;
    }
  }

  return [maxIndex];
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

  final Uint8List yPlane = image.planes[0].bytes;
  final Uint8List uPlane = image.planes[1].bytes;
  final Uint8List vPlane = image.planes[2].bytes;

  final imageResult = img.Image(width: width, height: height);

  for (int y = 0; y < height; y++) {
    final int yIndexBase = y * width;
    final int uvRowIndex = (y >> 1) * uvRowStride;

    for (int x = 0; x < width; x++) {
      final int uvIndex = uvRowIndex + (x >> 1) * uvPixelStride;
      final int index = yIndexBase + x;

      final yp = yPlane[index];
      final up = uPlane[uvIndex];
      final vp = vPlane[uvIndex];

      int r = yp + ((vp - 128) * 1436 >> 10);
      int g = yp - ((up - 128) * 352 >> 10) - ((vp -128) * 731 >> 10);
      int b = yp + ((up - 128) * 1814 >> 10);

      if (r < 0) r = 0; else if (r > 255) r = 255;
      if (g < 0) g = 0; else if (g > 255) g = 255;
      if (b < 0) b = 0; else if (b > 255) b = 255;

      imageResult.setPixelRgb(x, y, r, g, b);
    }
  }

  return imageResult;
}

class TFLiteService {
  late Interpreter _interpreter;
  late List<int> _inputShape;
  late List<int> _outputShape;

  bool _isModelLoaded = false;

  final double _normMean = 0.0;
  final double _normStd = 255.0;

  Future<void> loadModel(CameraMode mode) async {
    try {
      if (mode == CameraMode.portrait) {
        _interpreter =
        await Interpreter.fromAsset('assets/models/portrait_model.tflite');
      } else if (mode == CameraMode.landscape) {
        _interpreter =
        await Interpreter.fromAsset('assets/models/landscape_model.tflite');
      }
      _inputShape = _interpreter
          .getInputTensor(0)
          .shape;
      _outputShape = _interpreter
          .getOutputTensor(0)
          .shape;
      _isModelLoaded = true;
      print('모델 로드 완료. Input: $_inputShape, Output: $_outputShape');
    } catch (e) {
      print('모델 로드 실패: $e');
    }
  }

  Future<List<dynamic>> runInference(CameraImage cameraImage) async {
    if (!_isModelLoaded) {
      print("모델이 아직 로드되지 않았습니다.");
      return [];
    }

    final params = {
      'cameraImage': cameraImage,
      'interpreterAddress': _interpreter.address,
      'inputShape': _inputShape,
      'outputShape': _outputShape,
      'normMean': _normMean,
      'normStd': _normStd,
    };

    return await compute(_runInference, params);
  }

  void dispose() {
    if (_isModelLoaded) {
      _interpreter.close();
    }
  }
}