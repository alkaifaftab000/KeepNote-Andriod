import 'package:flutter/material.dart';
import 'package:keep_note/Pages/archive.dart';
import 'package:keep_note/Pages/bin.dart';
import 'package:keep_note/Pages/home_screen.dart';
import 'package:keep_note/Required/colors.dart';
import 'package:keep_note/Pages/setting.dart';
import 'package:keep_note/password.dart';

class SideMenu extends StatefulWidget {
  const SideMenu({super.key});

  @override
  State<SideMenu> createState() => _SideMenuState();
}

class _SideMenuState extends State<SideMenu>
    with SingleTickerProviderStateMixin {
  bool isExpanded = true;


  // Show the PIN dialog in the current context

  late AnimationController _animationController;
  late Animation<double> _animation;


  final List<MenuItemData> menuItems = [
    MenuItemData(Icons.home_rounded, 'Notes', const HomeScreen()),
    MenuItemData(Icons.archive_rounded, 'Archive', const Archive()),
    MenuItemData(Icons.lock_rounded, 'Hidden',const PinManagementScreen()),
    MenuItemData(Icons.delete_rounded, 'Bin', const Bin()),
    MenuItemData(Icons.settings_rounded, 'Settings', const ProfileScreen()),

  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleMenu() {
    setState(() {
      isExpanded = !isExpanded;
      if (isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bool isSmallScreen = size.width < 600;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: isExpanded ? (isSmallScreen ? size.width * 0.85 : 300) : 80,
      child: Drawer(
        backgroundColor: bgColor,
        child: Column(
          children: [
            _buildHeader(isSmallScreen),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    ...menuItems.map((item) => _buildAnimatedListTile(item)),
                  ],
                ),
              ),
            ),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isSmallScreen) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              height: 40, // Fixed height for the header
              child: Row(
                children: [
                  if (isExpanded)
                    Expanded(
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 200),
                        opacity: isExpanded ? 1 : 0,
                        child: Text(
                          'Keep Note',
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Pop',
                            fontSize: isSmallScreen ? 24 : 28,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis, // Handle text overflow
                        ),
                      ),
                    ),
                  SizedBox(
                      width:
                          isExpanded ? 8 : 0), // Spacing between title and button
                  SizedBox(
                    width: 40, // Fixed width for the button
                    height: 40, // Fixed height for the button
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      onPressed: _toggleMenu,
                      icon: AnimatedIcon(
                        icon: AnimatedIcons.menu_close,
                        progress: _animation,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: Divider(color: Colors.white30, thickness: 1),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedListTile(MenuItemData item) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: EdgeInsets.symmetric(
        horizontal: isExpanded ? 10 : 5,
        vertical: 5,
      ),
      child: Material(
        color: Colors.transparent,
        child: ListTile(
          contentPadding: EdgeInsets.symmetric(
            horizontal: isExpanded ? 15 : 5,
            vertical: 5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          leading: Padding(
            // Add left padding when collapsed to align icons
            padding: EdgeInsets.only(left: isExpanded ? 0 : 10),
            child: Icon(
              item.icon,
              color: Colors.white,
              // Increase icon size by 5% when collapsed
              size: isExpanded ? 35 : 35,
            ),
          ),
          title: AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: isExpanded ? 1 : 0,
            child: isExpanded
                ? Text(
              item.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontFamily: 'Pop',
              ),
              overflow: TextOverflow.ellipsis,
            )
                : null,
          ),
          onTap: () {
            if (item.navigateToWidget != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => item.navigateToWidget!,
                ),
              );
            }
          },
          hoverColor: Colors.white.withOpacity(0.1),
          selectedTileColor: Colors.white.withOpacity(0.1),
          splashColor: const Color(0xFF4FC8D3).withOpacity(0.3),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
      // child: const Divider(color: Colors.white30, thickness: 1),
    );
  }
}

class MenuItemData {
  final IconData icon;
  final String title;
  final Widget? navigateToWidget;

  MenuItemData(this.icon, this.title, this.navigateToWidget);
}
