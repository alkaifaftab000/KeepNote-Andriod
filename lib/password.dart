import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:keep_note/Pages/hide.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PinManager {
  static const String _pinKey = 'user_pin';

  Future<void> addPin(String pin) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_pinKey, pin);
  }

  Future<void> deletePin() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_pinKey);
  }

  Future<bool> checkPin() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_pinKey);
  }

  Future<bool> verifyPin(String pin) async {
    final prefs = await SharedPreferences.getInstance();
    final storedPin = prefs.getString(_pinKey);
    return storedPin == pin;
  }
}

class PinManagementScreen extends StatefulWidget {
  const PinManagementScreen({super.key});

  @override
  PinManagementScreenState createState() => PinManagementScreenState();
}

class PinManagementScreenState extends State<PinManagementScreen> {
  final PinManager _pinManager = PinManager();
  final TextEditingController _pinController = TextEditingController();
  final TextEditingController _confirmPinController = TextEditingController();
  final FocusNode _pinFocusNode = FocusNode();
  final FocusNode _confirmPinFocusNode = FocusNode();

  bool _obscureText = true;
  bool _hasExistingPin = false;

  @override
  void initState() {
    super.initState();
    _checkExistingPin();
  }

  Future<void> _checkExistingPin() async {
    final hasPin = await _pinManager.checkPin();
    setState(() {
      _hasExistingPin = hasPin;
    });
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  Future<void> _handlePinAction() async {
    // Validate PIN
    if (_pinController.text.isEmpty) {
      _showErrorSnackBar('PIN cannot be empty');
      return;
    }

    if (_hasExistingPin) {
      // Verify existing PIN
      bool isCorrect = await _pinManager.verifyPin(_pinController.text);
      if (isCorrect) {
        _showSuccessSnackBar('PIN verified successfully');

        Navigator.push(
            context, MaterialPageRoute(builder: (context) => const Hide()));
      } else {
        _showErrorSnackBar('Incorrect PIN');
      }
    } else {
      // Create new PIN
      if (_pinController.text != _confirmPinController.text) {
        _showErrorSnackBar('PINs do not match');
        return;
      }

      if (_pinController.text.length < 4) {
        _showErrorSnackBar('PIN must be at least 4 digits');
        return;
      }

      await _pinManager.addPin(_pinController.text);
      _showSuccessSnackBar('PIN created successfully');
      Navigator.pop(context);
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Define a dark theme for the dialog
    final darkTheme = Theme.of(context).copyWith(
      dialogTheme: DialogTheme(
        backgroundColor: Colors.grey.shade900,
        surfaceTintColor: Colors.transparent,
      ),
      colorScheme: ColorScheme.dark(
        primary: Colors.blue.shade400,
        surface: Colors.grey.shade900,
      ),
    );

    return Theme(
      data: darkTheme,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: Colors.grey.shade700,
                width: 1,
              ),
            ),
            elevation: 8,
            child: Container(
              width: constraints.maxWidth > 600 ? 500 : double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey.shade900,
                borderRadius: BorderRadius.circular(16),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      _hasExistingPin ? 'Enter PIN' : 'Create PIN',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    _buildPinTextField(
                        controller: _pinController,
                        focusNode: _pinFocusNode,
                        labelText: _hasExistingPin
                            ? 'Enter your PIN'
                            : 'Create a new PIN',
                        helperText: _hasExistingPin ? '' : 'Do not forget pin'),
                    if (!_hasExistingPin) ...[
                      const SizedBox(height: 16),
                      _buildPinTextField(
                        controller: _confirmPinController,
                        focusNode: _confirmPinFocusNode,
                        labelText: 'Confirm new PIN',
                      ),
                    ],
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.grey.shade300,
                          ),
                          child: const Text('Cancel'),
                        ),
                        ElevatedButton(
                          onPressed: _handlePinAction,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade400,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(_hasExistingPin ? 'Verify' : 'Create'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPinTextField(
      {required TextEditingController controller,
      required FocusNode focusNode,
      required String labelText,
      helperText}) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      obscureText: _obscureText,
      style: const TextStyle(color: Colors.white),
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(6),
      ],
      decoration: InputDecoration(
        helperText: helperText,
        helperStyle: const TextStyle(color: Colors.red),
        labelText: labelText,
        labelStyle: TextStyle(color: Colors.grey.shade400),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade700),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade700),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.blue.shade400, width: 2),
        ),
        suffixIcon: IconButton(
          icon: Icon(
            _obscureText ? Icons.visibility_off : Icons.visibility,
            color: Colors.grey.shade400,
          ),
          onPressed: _togglePasswordVisibility,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pinController.dispose();
    _confirmPinController.dispose();
    _pinFocusNode.dispose();
    _confirmPinFocusNode.dispose();
    super.dispose();
  }
}
