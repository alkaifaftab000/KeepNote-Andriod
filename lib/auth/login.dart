import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:keep_note/Pages/home_screen.dart';
import 'package:keep_note/auth/firebase_auth.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  AuthScreenState createState() => AuthScreenState();
}

class AuthScreenState extends State<AuthScreen> {
  final _authService = AuthService();
  bool _isLoading = false;

  // Google Sign-In Method
  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Attempt Google Sign-In
      UserCredential? userCredential = await _authService.signInWithGoogle();

      if (userCredential != null) {
        // Navigate to HomeScreen on successful sign-in
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    } catch (e) {
      // Show error dialog
      _showErrorDialog(e.toString());
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Error Dialog
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('An Error Occurred'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: const Text('Okay'),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.grey.shade800,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(
                  Icons.note_alt_outlined,
                  size: size.width < 600 ? 80 : 100,
                  color: Colors.amber,
                ),
                SizedBox(height: size.height * 0.02),
                Text(
                  'Keep Note',
                  style: TextStyle(
                    fontFamily: 'Pop',
                    fontSize: size.width < 600 ? 32 : 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                SizedBox(height: size.height * 0.03),
                Text(
                  'Capture your thoughts, anywhere, anytime',
                  style: TextStyle(
                    fontFamily: 'Pop',
                    fontSize: size.width < 600 ? 14 : 16,
                    color: Colors.grey[400],
                  ),
                  textAlign: TextAlign.center,
                ),

                // Illustration
                SizedBox(height: size.height * 0.08),
                Image.asset(
                  'asset/image/auth.png', // Add your illustration
                  height: size.height * 0.3,
                ),

                // Google Sign In Button
                SizedBox(height: size.height * 0.03),
                // ... (previous code remains the same)

                // Google Sign In Button
                const SizedBox(height: 30),
                _buildGoogleSignInButton(context),

                // Skip Button
                // const SizedBox(height:20),
                // TextButton(
                //   onPressed:() {
                //     Navigator.push(context,MaterialPageRoute(builder: (context)=>const HomeScreen()));},
                //   child: Text(
                //     'Skip for now',
                //     style: TextStyle(
                //       fontFamily: 'Pop',
                //       color: Colors.grey[400],
                //       fontSize: 16,
                //
                //     ),
                //   ),
                // ),
                SizedBox(height: size.height * 0.06),
                Text(
                  'By continuing, you agree to our',
                  style: TextStyle(
                    fontFamily: 'Pop',
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () {},
                      child: const Text(
                        'Terms of Service',
                        style: TextStyle(
                          fontFamily: 'Pop',
                          color: Colors.amber,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    Text(
                      'and',
                      style: TextStyle(
                        fontFamily: 'Pop',
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: const Text(
                        'Privacy Policy',
                        style: TextStyle(
                          fontFamily: 'Pop',
                          color: Colors.amber,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),

                // ... (rest of the previous code remains the same)
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGoogleSignInButton(BuildContext context) {
    return _isLoading
        ? const CircularProgressIndicator(color: Colors.amber)
        : InkWell(
            onTap: _handleGoogleSignIn,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'asset/image/img.png', // Use local asset instead of network image
                    height: 24,
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Continue with Google',
                    style: TextStyle(
                      fontFamily: 'Pop',
                      color: Colors.black87,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
  }
}
