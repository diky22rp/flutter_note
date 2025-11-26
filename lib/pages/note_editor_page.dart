import 'package:flutter/material.dart';
import 'package:flutter_note/firestore_helper.dart';
import 'package:flutter_note/models/note_model.dart';

class NoteEditorPage extends StatefulWidget {
  final NoteModel? note; // <<— Tambahkan

  const NoteEditorPage({super.key, this.note});

  @override
  State<NoteEditorPage> createState() => _NoteEditorPageState();
}

class _NoteEditorPageState extends State<NoteEditorPage> {
  // final DbHelper dbHelper = DbHelper.instance;
  final FirestoreHelper dbHelper = FirestoreHelper();

  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // if edit , fill field
    if (widget.note != null) {
      _titleController.text = widget.note!.title;
      _contentController.text = widget.note!.content;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future _saveNote() async {
    if (_formKey.currentState!.validate()) {
      final now = DateTime.now().toIso8601String();

      if (widget.note == null) {
        // INSERT MODE
        await dbHelper.insertItem(
          NoteModel(
            noteId: null,
            title: _titleController.text,
            content: _contentController.text,
            createdAt: now,
            updatedAt: now,
            pinned: false,
          ),
        );
      } else {
        // UPDATE MODE
        await dbHelper.updateItem(
          NoteModel(
            noteId: widget.note!.noteId,
            title: _titleController.text,
            content: _contentController.text,
            createdAt: widget.note!.createdAt,
            updatedAt: now,
            pinned: widget.note!.pinned,
          ),
        );
      }

      Navigator.pop(context, true);
    }
  }

  void _cancelNote() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.note == null ? 'New Note' : 'Edit Note',
        ), // dynamic title
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  hintText: 'Enter note title',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(16)),
                  ),
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter a title'
                    : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _contentController,
                decoration: const InputDecoration(
                  labelText: 'Content',
                  hintText: 'Enter note content',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(16)),
                  ),
                  alignLabelWithHint: true,
                ),
                maxLines: 15,
                minLines: 10,
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter content'
                    : null,
              ),
              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _cancelNote,
                      icon: const Icon(Icons.cancel),
                      label: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _saveNote,
                      icon: const Icon(Icons.save),
                      label: const Text('Save'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
