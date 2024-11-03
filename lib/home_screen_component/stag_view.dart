import 'package:flutter/material.dart';
import 'package:keep_note/Pages/delete_view.dart';
import 'package:keep_note/Pages/note_edit.dart';
import 'package:keep_note/Required/colors.dart';
import 'package:keep_note/services/controller.dart';
import 'package:keep_note/services/model.dart';
import 'package:staggered_grid_view_flutter/widgets/staggered_grid_view.dart';
import 'package:staggered_grid_view_flutter/widgets/staggered_tile.dart';
import 'package:flutter_animate/flutter_animate.dart';

class StagView extends StatefulWidget {
  final String query;
  const StagView({super.key, required this.query});

  @override
  State<StagView> createState() => _StagViewState();
}

class _StagViewState extends State<StagView> {
  final FirebaseController _controller = FirebaseController();
  List<Model> notes = [];
  bool isLoading = true;
  String error = '';

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      setState(() {
        isLoading = true;
        error = '';
      });

      List<Model> fetchedNotes;
      if (widget.query == 'Read_All') {
        fetchedNotes = await _controller.fetchNotesWherePinBinArchiveZero();
      } else {
        fetchedNotes = await _controller.fetchNotesCategory(widget.query);
      }

      setState(() {
        notes = fetchedNotes;
        debugPrint('Fetched ${notes.length} notes');
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        debugPrint('Error fetching data: $e');
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Determine the number of columns based on screen width
        int crossAxisCount = constraints.maxWidth < 600
            ? 2
            : constraints.maxWidth < 900
                ? 3
                : 4;

        if (isLoading) {
          return const Center(
            child: CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 3,
            ),
          ).animate().fadeIn();
        }

        if (error.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 60,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Oops! Something went wrong',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  error,
                  style: const TextStyle(color: Colors.white70),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ).animate().fadeIn();
        }

        if (notes.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.note_alt_outlined,
                  color: Colors.white.withOpacity(0.6),
                  size: 80,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Add Notes Here',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Start creating your note!',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ).animate().fadeIn().scale();
        }

        return Padding(
          padding: EdgeInsets.symmetric(
            horizontal: constraints.maxWidth < 600 ? 12 : 20,
          ),
          child: StaggeredGridView.countBuilder(
            shrinkWrap: true,
            itemCount: notes.length,
            crossAxisCount: crossAxisCount * 2,
            mainAxisSpacing: constraints.maxWidth < 600 ? 12 : 20,
            crossAxisSpacing: constraints.maxWidth < 600 ? 12 : 20,
            staggeredTileBuilder: (index) => const StaggeredTile.fit(2),
            scrollDirection: Axis.vertical,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              final note = notes[index];
              return Hero(
                tag: 'note_${note.id}',
                child: GestureDetector(
                  onTap: () {
                    debugPrint(widget.query);
                    if (widget.query == 'Bin') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DeleteView(id: note.id),
                        ),
                      ).then((_) => fetchData());
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NoteEdit(
                            query: widget.query,
                            heading: note.title,
                            note: note.content,
                            id: note.id,
                          ),
                        ),
                      ).then((_) => fetchData());
                    }
                  },
                  child: Container(
                    margin: EdgeInsets.symmetric(
                      vertical: constraints.maxWidth < 600 ? 6 : 10,
                    ),
                    padding:
                        EdgeInsets.all(constraints.maxWidth < 600 ? 12 : 16),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                note.title,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Pop',
                                  fontSize:
                                      constraints.maxWidth < 600 ? 18 : 20,
                                  fontWeight: FontWeight.w600,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (note.pin == 1)
                              const Icon(
                                Icons.push_pin,
                                color: Colors.white70,
                                size: 20,
                              ).animate().scale(),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          note.content,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: constraints.maxWidth < 600 ? 14 : 15,
                            fontFamily: 'Pop',
                            height: 1.5,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 10,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              note.date,
                              style: TextStyle(
                                color: Colors.grey.withOpacity(0.8),
                                fontSize: 11,
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.white.withOpacity(0.3),
                              size: 10,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ).animate().fadeIn(
                      delay: Duration(milliseconds: 50 * index),
                    ),
              );
            },
          ),
        );
      },
    );
  }
}
