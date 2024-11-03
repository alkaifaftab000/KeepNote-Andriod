import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:keep_note/Pages/home_screen.dart';
import 'package:keep_note/Required/colors.dart';
import 'package:keep_note/services/controller.dart';

class NoteView extends StatefulWidget {
  const NoteView({super.key});

  @override
  State<NoteView> createState() => _NoteViewState();
}

class _NoteViewState extends State<NoteView>
    with SingleTickerProviderStateMixin {
  final update = FirebaseController();
  final titleController = TextEditingController(text: 'Sample Heading');
  final contentController =
      TextEditingController(text: 'This is a sample note, just an example');
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    titleController.dispose();
    contentController.dispose();
    super.dispose();
  }

  Future<void> _saveNote() async {
    String result = await update.insert(
        0, // default value for pin
        titleController.text,
        contentController.text,
        0, // default value for bin
        0, // default value for archive
        0);

    if (kDebugMode) {
      print(result);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(20),
        backgroundColor: Colors.black87,
        content: const Text(
          'Note Saved',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Pop',
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );

    await _animationController.reverse();
    await Future.delayed(const Duration(milliseconds: 300));
    if (mounted) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const HomeScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    }
  }

  Widget _buildNoteField({
    required TextEditingController controller,
    required String hint,
    required double fontSize,
    int? maxLines,
    bool isTitle = false,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double adjustedFontSize =
            constraints.maxWidth < 600 ? fontSize * 0.8 : fontSize;

        return Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.12),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          height: isTitle ? 80 : null,
          margin: EdgeInsets.symmetric(
            vertical: 8,
            horizontal: constraints.maxWidth * 0.02,
          ),
          child: TextField(
            controller: controller,
            cursorColor: white,
            maxLines: maxLines ?? 1,
            style: TextStyle(
              color: white,
              fontFamily: 'Pop',
              fontSize: adjustedFontSize,
              height: 1.5,
            ),
            textAlign: isTitle ? TextAlign.center : TextAlign.start,
            textAlignVertical: TextAlignVertical.center,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                color: white.withOpacity(0.5),
                fontSize: adjustedFontSize,
                fontFamily: 'Pop',
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 24,
                vertical: isTitle ? 0 : 16,
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Your Note',
          style: TextStyle(
            fontFamily: 'Pop',
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              double horizontalPadding = constraints.maxWidth * 0.05;

              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: 16,
                ),
                child: Column(
                  children: [
                    _buildNoteField(
                        controller: titleController,
                        hint: 'Note Title',
                        fontSize: 28,
                        isTitle: true,
                        maxLines: 1),
                    const SizedBox(height: 16),
                    _buildNoteField(
                      controller: contentController,
                      hint: 'Write your note here...',
                      fontSize: 18,
                      maxLines: 30,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: _saveNote,
        backgroundColor: Colors.blue,
        tooltip: 'Save Note',
        child: const Icon(Icons.save_rounded, color: Colors.white),
      ),
    );
  }
}
