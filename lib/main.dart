import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(MyApp());
}

class Note {
  Color color;
  final int id;
  String title;
  String content;

  Note({
    required this.color,
    required this.id,
    required this.title,
    required this.content,
  });
}

List<Note> notes = [];

void addNewNote(Note note) {
  notes.insert(0, note);
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: NotesScreen(),
    );
  }
}

class NotesScreen extends StatefulWidget {
  @override
  _NotesScreenState createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  String _query = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _query = _searchController.text;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredNotes = notes
        .where((note) => note.title.toLowerCase().contains(_query.toLowerCase()))
        .toList();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: _buildSearchBar(),
        actions: [
          IconButton(
            icon: Icon(Icons.info_outline, color: Colors.white),
            onPressed: () {
              // Info button action
            },
          ),
        ],
      ),
      body: filteredNotes.isEmpty
          ? Center(
              child: Text(
                'No notes found!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
            )
          : ListView.builder(
              itemCount: filteredNotes.length,
              itemBuilder: (context, index) {
                final note = filteredNotes[index];
                return Dismissible(
                  key: Key(note.id.toString()),
                  direction: DismissDirection.endToStart,
                  onDismissed: (direction) {
                    setState(() {
                      notes.remove(note);
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Note deleted')),
                    );
                  },
                  background: Container(
                    color: Colors.red,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Icon(Icons.delete, color: Colors.white),
                      ),
                    ),
                  ),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NoteDetailPage(
                            note: note,
                            onSave: (updatedNote) {
                              setState(() {
                                final index = notes.indexWhere((n) => n.id == updatedNote.id);
                                if (index != -1) {
                                  notes[index] = updatedNote;
                                }
                              });
                            },
                            isEditing: true,
                          ),
                        ),
                      );
                    },
                    child: Card(
                      color: note.color,
                      child: ListTile(
                        title: Text(note.title),
                        subtitle: Text(note.content),
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NoteDetailPage(
                onSave: (note) {
                  setState(() {
                    addNewNote(note);
                  });
                },
                isEditing: false,
              ),
            ),
          );
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.grey[800],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: 'Search...',
        hintStyle: TextStyle(color: Colors.white54),
        border: InputBorder.none,
        suffixIcon: Icon(Icons.search, color: Colors.white),
      ),
    );
  }
}

class NoteDetailPage extends StatefulWidget {
  final Note? note;
  final Function(Note) onSave;
  final bool isEditing;

  NoteDetailPage({this.note, required this.onSave, required this.isEditing});

  @override
  _NoteDetailPageState createState() => _NoteDetailPageState();
}

class _NoteDetailPageState extends State<NoteDetailPage> {
  late TextEditingController titleController;
  late TextEditingController contentController;
  Color _selectedColor = Colors.primaries[Random().nextInt(Colors.primaries.length)];

  @override
  void initState() {
    super.initState();
    if (widget.isEditing && widget.note != null) {
      titleController = TextEditingController(text: widget.note!.title);
      contentController = TextEditingController(text: widget.note!.content);
      _selectedColor = widget.note!.color;
    } else {
      titleController = TextEditingController();
      contentController = TextEditingController();
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return await _showExitConfirmationDialog(context);
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () async {
              bool shouldPop = await _showExitConfirmationDialog(context);
              if (shouldPop) {
                Navigator.pop(context);
              }
            },
          ),
          title: Text(
            widget.isEditing ? 'Edit Note' : 'Add Note',
            style: TextStyle(color: Colors.white),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.color_lens, color: _selectedColor),
              onPressed: () => _showColorPickerDialog(context),
            ),
            IconButton(
              icon: Icon(Icons.save, color: Colors.white),
              onPressed: () {
                final note = Note(
                  color: _selectedColor,
                  id: widget.isEditing ? widget.note!.id : notes.length + 1,
                  title: titleController.text,
                  content: contentController.text,
                );
                widget.onSave(note);
                Navigator.pop(context);
              },
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: titleController,
                style: TextStyle(color: Colors.white, fontSize: 24),
                decoration: InputDecoration(
                  hintText: 'Title',
                  hintStyle: TextStyle(color: Colors.white54),
                  border: InputBorder.none,
                ),
              ),
              TextField(
                controller: contentController,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Type something...',
                  hintStyle: TextStyle(color: Colors.white54),
                  border: InputBorder.none,
                ),
                maxLines: null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showColorPickerDialog(BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Select a Color'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              _colorPickerButton(context, Colors.red),
              _colorPickerButton(context, Colors.green),
              _colorPickerButton(context, Colors.blue),
              _colorPickerButton(context, Colors.yellow),
              _colorPickerButton(context, Colors.orange),
            ],
          ),
        ),
      ),
    );
  }

  Widget _colorPickerButton(BuildContext context, Color color) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedColor = color;
        });
        Navigator.of(context).pop(); // Close the dialog
      },
      child: Container(
        width: 30,
        height: 30,
        margin: EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: _selectedColor == color ? Colors.white : Colors.transparent,
            width: 2,
          ),
        ),
      ),
    );
  }

  Future<bool> _showExitConfirmationDialog(BuildContext context) async {
    return (await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Discard changes?'),
        content: Text('If you go back now, your changes will be lost.'),
        actions: [
          TextButton(
            child: Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          TextButton(
            child: Text('Discard'),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    )) ?? false;
  }
}
