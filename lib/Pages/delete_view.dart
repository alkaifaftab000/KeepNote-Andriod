import 'dart:async';
import 'package:flutter/material.dart';
import 'package:keep_note/Pages/home_screen.dart';
import 'package:keep_note/Required/colors.dart';
import 'package:keep_note/services/controller.dart';

class DeleteView extends StatefulWidget {
  final String id;
  const DeleteView({super.key, required this.id});

  @override
  DeleteViewState createState() => DeleteViewState();
}

class DeleteViewState extends State<DeleteView>
    with SingleTickerProviderStateMixin {
  final FirebaseController update = FirebaseController();
  final TextEditingController titleController =
      TextEditingController(text: 'Sample Heading');
  final TextEditingController contentController =
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

  Future<void> _navigateHomeWithMessage(String message) async {
    _showSnackBar(message);
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

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(20),
        backgroundColor: Colors.black87,
        content: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(
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
  }

  Future<void> _deleteNote() async {
    await update.deleteRecord(widget.id);
    await _navigateHomeWithMessage('Note Deleted Successfully');
  }

  Future<void> _unBinNote() async {
    await update.update(widget.id, {'Bin': 0, 'Id': widget.id});
    await _navigateHomeWithMessage('Note Restored Successfully');
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
        // Adjust fontSize based on screen width
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

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _ActionButton(
          icon: Icons.delete_forever,
          label: 'Delete',
          color: Colors.redAccent,
          onPressed: _deleteNote,
        ),
        const SizedBox(width: 20),
        _ActionButton(
          icon: Icons.restore,
          label: 'Restore',
          color: Colors.greenAccent.shade700,
          onPressed: _unBinNote,
        ),
      ],
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
          'Deleted Note',
          style: TextStyle(
            fontFamily: 'Pop',
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Responsive padding based on screen width
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
                      maxLines: 1
                    ),
                    const SizedBox(height: 16),
                    _buildNoteField(
                      controller: contentController,
                      hint: 'Write your note here...',
                      fontSize: 18,
                      maxLines: 30,
                    ),
                    const SizedBox(height: 100), // Space for FAB
                  ],
                ),
              );
            },
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: _buildActionButtons(),
      ),
    );
  }
}

// Extracted Action Button Widget
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: FloatingActionButton.extended(
        heroTag: label,
        onPressed: onPressed,
        backgroundColor: color,
        icon: Icon(icon, color: Colors.white),
        label: Text(
          label,
          style: const TextStyle(
            fontFamily: 'Pop',
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
