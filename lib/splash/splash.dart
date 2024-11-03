import 'package:flutter/material.dart';
import 'package:keep_note/splash/splash_service.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});
  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  final service = SplashService();
  @override
  void initState() {
    super.initState();
    service.isUserLoggedIn(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade800,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Image(
                image: AssetImage('asset/image/splash.gif'),
                width: 300,
                height: 300,
              ),
              const SizedBox(height: 70),
              LoadingAnimationWidget.discreteCircle(
                color: Colors.white,
                size: 35,
              ),
              const SizedBox(height: 100),
              const Text(
                '✍️ Keep Notes',
                style: TextStyle(
                  fontSize: 35,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Pop',
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 30),
              Text(
                '📝 Write • 💾 Save • 🛠️ Edit • 🗑️ Delete',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Pop',
                  color: Colors.grey[400],
                ),
              ),
              const SizedBox(height: 50),
              const Text('✨ Capture Ideas, Keep Memories, Get Things Done! 🚀',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Pop',
                    color: Colors.grey,
                  )),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
