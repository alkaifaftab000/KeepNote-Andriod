import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:keep_note/auth/firebase_auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:keep_note/password.dart';
import 'package:keep_note/services/controller.dart';
// Add this import

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final api = FirebaseController();
  int _count = 0;
  @override
  void initState() {
    super.initState();
    getCount();
  }

  Future<void> getCount() async {
    int count = await api.getRecordCount();
    setState(() {
      _count = count;
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = AuthService();
    final user = FirebaseAuth.instance.currentUser; // Get current user
    final size = MediaQuery.of(context).size;
    const Color bgColor = Color(0xFF212227);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: (AppBar(
        automaticallyImplyLeading: true,
        toolbarHeight: 40,
        backgroundColor: bgColor,
      )),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(size.width * 0.05),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Column(
                  children: [
                    // Profile Header
                    SizedBox(height: size.height * 0.03),
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.amber,
                          width: 4,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: size.width < 600 ? 50 : 70,
                        // If user has a profile photo, use it, otherwise use default
                        backgroundImage: user?.photoURL != null
                            ? NetworkImage(user!.photoURL!)
                            : const NetworkImage(
                                'https://i.pinimg.com/originals/ba/5a/03/ba5a031e198de02c39ac3465bf700df0.png'),
                      ),
                    ),
                    SizedBox(height: size.height * 0.02),
                    Text(
                      user?.displayName ??
                          'User', // Use display name if available
                      style: GoogleFonts.poppins(
                        fontSize: size.width < 600 ? 24 : 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      user?.email ??
                          'No email available', // Display user's email
                      style: GoogleFonts.poppins(
                        fontSize: size.width < 600 ? 14 : 16,
                        color: Colors.grey[400],
                      ),
                    ),

                    // Rest of your code remains the same...
                    SizedBox(height: size.height * 0.04),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade800,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatItem('Notes', _count.toString()),
                          _buildStatItem('Folders', '0'),
                          _buildStatItem('Shared', '0'),
                        ],
                      ),
                    ),

                    SizedBox(height: size.height * 0.04),
                    _buildMenuItem(
                        Icons.person_outline, 'Edit Profile', context),
                    _buildMenuItem(
                        Icons.notifications_outlined, 'Notifications', context),
                    _buildMenuItem(
                        Icons.security, 'Privacy & Security', context),
                    _buildMenuItem(
                        Icons.color_lens_outlined, 'Appearance', context),
                    _buildMenuItem(
                        Icons.help_outline, 'Help & Support', context),

                    SizedBox(height: size.height * 0.04),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: InkWell(
                        onTap: () {
                          final pin = PinManager();
                          pin.deletePin();
                          auth.logout(context);
                        },
                        child: Center(
                          child: Text(
                            'Log Out',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String title, String value) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.amber,
          ),
        ),
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.grey[400],
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem(IconData icon, String title, BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.amber),
        title: Text(
          title,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          color: Colors.grey,
          size: 18,
        ),
        onTap: () {
          // Handle menu item tap
        },
      ),
    );
  }
}
