import 'package:flutter/material.dart';
import 'models/note.dart';

class EditNotePage extends StatefulWidget {
  final Note? existing;

  const EditNotePage({super.key, this.existing});

  @override
  State<EditNotePage> createState() => _EditNotePageState();
}

class _EditNotePageState extends State<EditNotePage> {
  final _formKey = GlobalKey<FormState>();
  late String _title;
  late String _body;

  @override
  void initState() {
    super.initState();
    _title = widget.existing?.title ?? '';
    _body = widget.existing?.body ?? '';
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    
    _formKey.currentState!.save();

    final result = (widget.existing == null)
        ? Note(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            title: _title,
            body: _body,
          )
        : widget.existing!.copyWith(title: _title, body: _body);

    Navigator.pop(context, result);
  }

  void _cancel() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Редактировать заметку' : 'Новая заметка'),
        actions: [
          IconButton(
            onPressed: _save,
            icon: const Icon(Icons.check),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                initialValue: _title,
                decoration: const InputDecoration(
                  labelText: 'Заголовок',
                  border: OutlineInputBorder(),
                ),
                maxLength: 100,
                onSaved: (value) => _title = value!.trim(),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: TextFormField(
                  initialValue: _body,
                  decoration: const InputDecoration(
                    labelText: 'Текст заметки',
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                  minLines: 10,
                  maxLines: null,
                  expands: false,
                  onSaved: (value) => _body = value!.trim(),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Введите текст заметки';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _cancel,
                      icon: const Icon(Icons.cancel_outlined),
                      label: const Text('Отмена'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: _save,
                      icon: const Icon(Icons.check),
                      label: const Text('Сохранить'),
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