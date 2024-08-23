import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:todo_application/services/notification_service.dart';
import 'package:todo_application/view/HomeScreen/home_screen.dart';
import 'package:todo_application/view/SplashScreen.dart/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.init();
  final appDir = await getApplicationDocumentsDirectory();
  Hive.init(appDir.path);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: "Todos",
      home: SplashScreen(),
    );
  }
}
