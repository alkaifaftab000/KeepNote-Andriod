import 'dart:async';
import 'package:flutter/material.dart';
import 'package:keep_note/Pages/home_screen.dart';
import 'package:keep_note/Required/colors.dart';
import 'package:keep_note/services/controller.dart';

class NoteEdit extends StatefulWidget {
  final dynamic query;
  final dynamic heading;
  final dynamic note;
  final dynamic id;

  const NoteEdit({
    super.key,
    this.query,
    this.heading,
    this.note,
    this.id,
  });

  @override
  State<NoteEdit> createState() => _NoteEditState();
}

class _NoteEditState extends State<NoteEdit>
    with SingleTickerProviderStateMixin {
  final _firebaseController = FirebaseController();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Make _noteState late to initialize it in initState
  late Map<String, int> _noteState;

  @override
  void initState() {
    super.initState();
    _initializeNoteState();
    _initializeControllers();
    _setupAnimations();
  }

  void _initializeNoteState() {
    // Initialize with all states as 0
    _noteState = {
      'Pin': 0,
      'Archive': 0,
      'Bin': 0,
      'Hide': 0,
    };

    // Set the initial state based on which screen we came from
    if (widget.query != null) {
      String query = widget.query.toString();
      if (_noteState.containsKey(query)) {
        _noteState[query] = 1;
      }
    }
  }

  void _initializeControllers() {
    _titleController.text = widget.heading?.toString() ?? 'Sample Heading';
    _contentController.text =
        widget.note?.toString() ?? 'This is a sample note, just an example';
  }

  void _setupAnimations() {
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
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _toggleNoteState(String key, String message) {
    setState(() {
      if (key == widget.query) {
        // If we're toggling the state that matches our query (e.g., unhiding from Hidden screen)
        _noteState[key] = _noteState[key] == 1 ? 0 : 1;
        String actionText = _noteState[key] == 1 ? 'added to' : 'removed from';
        _showSnackBar('Note $actionText $key');
      } else {
        // If we're toggling a different state
        if (_noteState[key] == 1) {
          // Turn off if it's already on
          _noteState[key] = 0;
          _showSnackBar('Removed from $key');
        } else {
          // Reset all states and turn this one on
          _noteState.updateAll((k, value) => 0);
          _noteState[key] = 1;
          _showSnackBar('Added to $key');
        }
      }
    });
  }

  Future<void> _updateNote() async {
    // Check if we're trying to save a note that's being unhidden
    if (widget.query == 'Hide' && _noteState['Hide'] == 0) {
      // Note is being unhidden
      _showSnackBar('Note unhidden');
    }

    Map<String, dynamic> updateData = {
      ..._noteState,
      'Id': widget.id.toString(),
      'Title': _titleController.text,
      'Content': _contentController.text,
    };

    await _firebaseController.update(widget.id.toString(), updateData);
    await _navigateHomeWithMessage('Note Saved');
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

  Widget _buildActionButtons() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _ActionButton(
            herotag: 'Hide_Button',
            tooltip: _noteState['Hide'] == 1 ? 'Unhide' : 'Hide',
            icon: _noteState['Hide'] == 1
                ? Icons.lock_rounded
                : Icons.lock_open_rounded,
            label: _noteState['Hide'] == 1 ? 'Unhide' : 'Hide',
            color: Colors.grey,
            isActive: _noteState['Hide'] == 1,
            onPressed: () => _toggleNoteState('Hide',
                _noteState['Hide'] == 1 ? 'Note unhidden' : 'Note hidden'),
          ),
          const SizedBox(width: 20),
          _ActionButton(
            herotag: 'Bin_Button',
            tooltip: _noteState['Bin'] == 1 ? 'Restore' : 'Move to Bin',
            icon: Icons.delete_forever,
            label: _noteState['Bin'] == 1 ? 'Restore' : 'Bin',
            color: Colors.redAccent,
            isActive: _noteState['Bin'] == 1,
            onPressed: () => _toggleNoteState(
              'Bin',
              _noteState['Bin'] == 1 ? 'Note restored' : 'Note moved to bin',
            ),
          ),
          const SizedBox(width: 20),
          _ActionButton(
            herotag: 'Save_Button',
            tooltip: 'Save',
            icon: Icons.save_rounded,
            label: 'Save',
            color: Colors.amberAccent.shade700,
            isActive: false,
            onPressed: _updateNote,
          ),
          const SizedBox(width: 20),
          _ActionButton(
            herotag: 'Pin_Button',
            tooltip: _noteState['Pin'] == 1 ? 'Unpin' : 'Pin',
            icon: Icons.push_pin_rounded,
            label: _noteState['Pin'] == 1 ? 'Unpin' : 'Pin',
            color: Colors.blueAccent.shade700,
            isActive: _noteState['Pin'] == 1,
            onPressed: () => _toggleNoteState(
              'Pin',
              _noteState['Pin'] == 1 ? 'Note unpinned' : 'Note pinned',
            ),
          ),
          const SizedBox(width: 20),
          _ActionButton(
            herotag: 'Archive_Button',
            tooltip: _noteState['Archive'] == 1 ? 'Unarchive' : 'Archive',
            icon: Icons.archive_rounded,
            label: _noteState['Archive'] == 1 ? 'Unarchive' : 'Archive',
            color: Colors.greenAccent.shade700,
            isActive: _noteState['Archive'] == 1,
            onPressed: () => _toggleNoteState(
              'Archive',
              _noteState['Archive'] == 1 ? 'Note unarchived' : 'Note archived',
            ),
          ),
        ],
      ),
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
          'Edit Note',
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
                        controller: _titleController,
                        hint: 'Note Title',
                        fontSize: 28,
                        isTitle: true,
                        maxLines: 1),
                    const SizedBox(height: 16),
                    _buildNoteField(
                      controller: _contentController,
                      hint: 'Write your note here...',
                      fontSize: 18,
                      maxLines: 30,
                    ),
                    const SizedBox(height: 100),
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

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label, herotag, tooltip;
  final Color color;
  final VoidCallback onPressed;
  final bool isActive;

  const _ActionButton({
    required this.herotag,
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
    required this.tooltip,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      heroTag: herotag,
      onPressed: onPressed,
      tooltip: tooltip,
      backgroundColor: isActive ? color : color.withOpacity(0.6),
      label: Row(
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 30,
          ),
          const SizedBox(width: 4),
        ],
      ),
    );
  }
}
