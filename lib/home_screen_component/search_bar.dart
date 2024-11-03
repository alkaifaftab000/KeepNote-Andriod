import 'package:flutter/material.dart';
import 'package:keep_note/Pages/note_edit.dart';
import 'package:keep_note/Pages/setting.dart';
import 'package:keep_note/Required/colors.dart';
import 'package:keep_note/services/controller.dart';
import 'package:keep_note/services/model.dart';

class Search extends StatefulWidget {
  final GlobalKey<ScaffoldState> global;
  const Search({super.key, required this.global});

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  final TextEditingController controller = TextEditingController();
  final search = FirebaseController();
  bool isSearching = false;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> searchAndNavigate() async {
    setState(() => isSearching = true);
    try {
      List<Model> results = await search.search(controller.text);
      if (results.isNotEmpty) {
        Model firstResult = results[0];
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NoteEdit(
              id: firstResult.id,
              heading: firstResult.title,
              note: firstResult.content,
            ),
          ),
        );
      } else {
        _showSnackBar('No results found', Icons.info_outline);
      }
    } catch (e) {
      debugPrint('Error searching: $e');
      _showSnackBar('An error occurred while searching', Icons.error_outline);
    } finally {
      setState(() => isSearching = false);
    }
  }

  void _showSnackBar(String message, IconData icon) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 8),
            Text(message),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(8),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.menu_rounded, color: Colors.white),
            iconSize: 28,
            splashRadius: 24,
            onPressed: () => widget.global.currentState?.openDrawer(),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: controller,
                      style: const TextStyle(
                        color: Colors.white,
                        fontFamily: 'Pop',
                        fontSize: 16,
                      ),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Search your notes...',
                        hintStyle: TextStyle(
                          color: white.withOpacity(0.7),
                          fontFamily: 'Pop',
                          fontSize: 16,
                        ),
                      ),
                      textInputAction: TextInputAction.search,
                      onSubmitted: (_) => searchAndNavigate(),
                    ),
                  ),
                  if (controller.text.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.clear, color: Colors.white70),
                      splashRadius: 20,
                      onPressed: () => setState(() => controller.clear()),
                    ),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: isSearching
                        ? const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white70),
                              ),
                            ),
                          )
                        : IconButton(
                            icon: const Icon(Icons.search_rounded,
                                color: Colors.white70),
                            splashRadius: 20,
                            onPressed: searchAndNavigate,
                          ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.grid_view_rounded, color: Colors.white),
            iconSize: 24,
            splashRadius: 24,
            onPressed: () {},
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border:
                  Border.all(color: Colors.white.withOpacity(0.2), width: 2),
            ),
            child: GestureDetector(
              onTap: (){
                Navigator.push(context,MaterialPageRoute(builder: (context)=> const ProfileScreen()));
              },
              child: CircleAvatar(
                radius: 18,
                backgroundColor: Colors.white.withOpacity(0.1),
                child: const Icon(Icons.account_circle_outlined,
                    color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
