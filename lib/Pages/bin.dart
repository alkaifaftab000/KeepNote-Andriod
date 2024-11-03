import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:keep_note/Required/colors.dart';
import 'package:keep_note/home_screen_component/search_bar.dart';
import 'package:keep_note/home_screen_component/side_menu.dart';
import 'package:keep_note/home_screen_component/stag_view.dart';

class Bin extends StatefulWidget {
  const Bin({super.key});

  @override
  State<Bin> createState() => _BinState();
}

class _BinState extends State<Bin> {
  final GlobalKey<ScaffoldState> _drawerKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final ss = MediaQuery.of(context).size;

    return Scaffold(
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
            'Bin Note',
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

                  // Section Title
                  Container(
                    margin: EdgeInsets.symmetric(
                      vertical: ss.height * 0.02,
                      horizontal: ss.width * 0.02,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.delete_outline,
                          color: white.withOpacity(0.7),
                          size: kIsWeb ?  ss.width * 0.025 :25,
                        ),
                        SizedBox(width: ss.width * 0.02),
                        Text(
                          'All',
                          style: TextStyle(
                            fontFamily: 'Pop',
                            fontSize: kIsWeb ? ss.width * 0.02 : 20,
                            fontWeight: FontWeight.w500,
                            color: white.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // StagView for Bin
                  const StagView(query: 'Bin'),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
