import 'package:flutter/material.dart';
import 'models/note.dart';
import 'edit_note_page.dart';

void main() => runApp(const SimpleNotesApp());

class SimpleNotesApp extends StatelessWidget {
  const SimpleNotesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Simple Notes',
      theme: ThemeData(useMaterial3: true),
      home: const NotesPage(),
    );
  }
}

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  final List<Note> _notes = [
    Note(id: '1', title: 'Пример', body: 'Это пример заметки'),
    Note(id: '2', title: 'Покупки', body: 'Купить молоко и хлеб'),
    Note(id: '3', title: 'Задачи', body: 'Сделать домашнее задание по программированию'),
  ];

  List<Note> _filteredNotes = [];
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _filteredNotes = _notes;
    _searchController.addListener(_filterNotes);
  }

  void _filterNotes() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredNotes = _notes;
      } else {
        _filteredNotes = _notes.where((note) => 
          note.title.toLowerCase().contains(query) || 
          note.body.toLowerCase().contains(query)
        ).toList();
      }
    });
  }

  Future<void> _addNote() async {
    final newNote = await Navigator.push<Note>(
      context,
      MaterialPageRoute(builder: (_) => const EditNotePage()),
    );

    if (newNote != null) {
      setState(() {
        _notes.add(newNote);
        _filterNotes();
      });
    }
  }

  Future<void> _editNote(Note note) async {
    final updatedNote = await Navigator.push<Note>(
      context,
      MaterialPageRoute(builder: (_) => EditNotePage(existing: note)),
    );

    if (updatedNote != null) {
      setState(() {
        final index = _notes.indexWhere((n) => n.id == updatedNote.id);
        if (index != -1) {
          _notes[index] = updatedNote;
          _filterNotes();
        }
      });
    }
  }

  void _deleteNote(Note note) {
    setState(() {
      _notes.removeWhere((n) => n.id == note.id);
      _filterNotes();
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Заметка удалена'),
        action: SnackBarAction(
          label: 'Отменить',
          onPressed: () {
            setState(() {
              _notes.add(note);
              _filterNotes();
            });
          },
        ),
      ),
    );
  }

  void _startSearch() {
    setState(() {
      _isSearching = true;
    });
  }

  void _stopSearch() {
    setState(() {
      _isSearching = false;
      _searchController.clear();
      _filteredNotes = _notes;
    });
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      autofocus: true,
      decoration: const InputDecoration(
        hintText: 'Поиск по заголовку...',
        border: InputBorder.none,
        hintStyle: TextStyle(color: Colors.white70),
      ),
      style: const TextStyle(color: Colors.white),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearching ? _buildSearchField() : const Text('Simple Notes'),
        actions: _isSearching 
            ? [
                IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: _stopSearch,
                ),
              ]
            : [
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _startSearch,
                ),
              ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNote,
        child: const Icon(Icons.add),
      ),
      body: _filteredNotes.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.note_add, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Пока нет заметок.\nНажмите + чтобы добавить',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: _filteredNotes.length,
              itemBuilder: (context, index) {
                final note = _filteredNotes[index];
                return Dismissible(
                  key: ValueKey(note.id),
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.only(left: 16),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  secondaryBackground: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 16),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  confirmDismiss: (direction) async {
                    return await showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Удалить заметку?'),
                        content: Text('Вы уверены, что хотите удалить "${note.title}"?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text('Отмена'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: const Text('Удалить'),
                          ),
                        ],
                      ),
                    );
                  },
                  onDismissed: (direction) => _deleteNote(note),
                  child: Card(
                    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      title: Text(
                        note.title.isEmpty ? '(без названия)' : note.title,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        note.body,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      onTap: () => _editNote(note),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        onPressed: () => _deleteNote(note),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}