import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:keep_note/Required/colors.dart';
import 'package:keep_note/firebase_options.dart';
import 'package:keep_note/splash/splash.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: ThemeData(
            appBarTheme: AppBarTheme(iconTheme: IconThemeData(color: white)),
            scrollbarTheme: ScrollbarThemeData(
              thumbColor: WidgetStateProperty.all<Color>(Colors.white),
              trackColor: WidgetStateProperty.all<Color>(Colors.white),
              thickness: WidgetStateProperty.all<double>(8),
            )),
        debugShowCheckedModeBanner: false,
        home: const Splash());
  }
}
