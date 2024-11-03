import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:keep_note/Pages/note_view.dart';
import 'package:keep_note/Required/colors.dart';
import 'package:keep_note/home_screen_component/search_bar.dart';
import 'package:keep_note/home_screen_component/side_menu.dart';
import 'package:keep_note/home_screen_component/stag_view.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _drawerKey = GlobalKey<ScaffoldState>();
  bool isExpanded = false;

  @override
  void initState() {

    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    final ss = MediaQuery.of(context).size;

    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: ElevatedButton.icon(
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const NoteView()));
        },
        label: const Text(
          'Add',
          style:
              TextStyle(fontFamily: 'Pop', fontSize: 20, color: Colors.black),
        ),
        icon:  Icon(
          Icons.note_add_rounded,
          color: bgColor,
          size: 32,
        ),
        style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey.shade500,
            minimumSize: const Size(150, 60),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15))),
      ),
      key: _drawerKey,
      endDrawerEnableOpenDragGesture: true,
      drawer: const SideMenu(),
      backgroundColor: bgColor,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(ss.height * 0.08),
        child: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: bgColor,
          elevation: 0,
          title: Text(
            'Keep Note',
            style: TextStyle(
              color: white,
              fontSize: kIsWeb ? ss.width * 0.025 : 40,
              fontFamily: 'Pop',
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: true,
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Container(
              width: constraints.maxWidth,
              padding: EdgeInsets.symmetric(
                horizontal: ss.width * 0.04,
                vertical: ss.height * 0.02,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Search Bar
                  Row(
                    children: [
                      Expanded(
                        child: Search(global: _drawerKey),
                      ),
                    ],
                  ),

                  // Pinned Notes Section
                  _buildSectionTitle(
                    'Pinned Notes',
                    ss,
                    icon: Icons.push_pin_outlined,
                  ),
                  const StagView(query: 'Pin'),

                  SizedBox(height: ss.height * 0.03),

                  // All Notes Section
                  _buildSectionTitle(
                    'All',
                    ss,
                    icon: Icons.notes_outlined,
                  ),
                  const StagView(query: 'Read_All'),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title, Size ss, {IconData? icon}) {
    return Container(
      margin: EdgeInsets.symmetric(
        vertical:  ss.height * 0.02,
        horizontal: ss.width * 0.02,
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              color: white.withOpacity(0.7),
              size:kIsWeb ?ss.width * 0.025:25,
            ),
            SizedBox(width: ss.width * 0.02),
          ],
          Text(
            title,
            style: TextStyle(
              fontFamily: 'Pop',
              fontSize: kIsWeb ? ss.width * 0.02 : 20,
              fontWeight: FontWeight.w500,
              color: white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }
}
