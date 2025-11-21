import 'package:camera/camera.dart';
import 'package:camera_widget/pages/home_page.dart';
import 'package:camera_widget/pages/main_screen.dart';
import 'package:camera_widget/screen/home_screen.dart';
import 'package:flutter/material.dart';

late List<CameraDescription> cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  cameras = await availableCameras();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MainScreen(cameras: cameras),
    );
  }
}
