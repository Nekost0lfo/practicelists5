# Отчёт по практическому занятию №5
## Работа со списками. Передача данных между модулями

**ФИО:** Батов Даниил Артемович  
**Группа:** ЭФБО-10-23
**Дисциплина:** Программирование корпоративных систем  
**Преподаватель:** Адышкин Сергей Сергеевич  

---

## Цели практического занятия

- Научиться отображать коллекции данных с помощью ListView.builder
- Освоить базовую навигацию Navigator.push / Navigator.pop и передачу данных через конструктор
- Научиться добавлять, редактировать и удалять элементы списка без внешних пакетов и сложных архитектур

---

## Ход работы

### Шаг 1: Создание проекта и структуры файлов

Создан проект Flutter с следующей структурой:
```
lib/
  main.dart
  edit_note_page.dart
  models/
    note.dart
```

### Шаг 2: Реализация модели данных

Создана модель Note для представления заметок:

```dart
class Note {
  final String id;
  String title;
  String body;

  Note({required this.id, required this.title, required this.body});

  Note copyWith({String? title, String? body}) => Note(
        id: id,
        title: title ?? this.title,
        body: body ?? this.body,
      );
}
```

Модель содержит уникальный идентификатор, заголовок и тело заметки. Метод `copyWith` позволяет создавать копии объекта с обновленными полями.

### Шаг 3: Реализация главного экрана со списком

Основной экран использует ListView.builder для эффективного отображения списка:

```dart
ListView.builder(
  itemCount: _filteredNotes.length,
  itemBuilder: (context, index) {
    final note = _filteredNotes[index];
    return Dismissible(
      key: ValueKey(note.id),
      background: Container(color: Colors.red),
      onDismissed: (direction) => _deleteNote(note),
      child: Card(
        child: ListTile(
          title: Text(note.title.isEmpty ? '(без названия)' : note.title),
          subtitle: Text(note.body, maxLines: 2),
          onTap: () => _editNote(note),
          trailing: IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: () => _deleteNote(note),
          ),
        ),
      ),
    );
  },
)
```

Используется ValueKey для стабильной идентификации элементов, Dismissible для свайп-удаления, и Card для улучшенного визуального представления.

### Шаг 4: Реализация навигации и передачи данных

Навигация между экранами реализована через Navigator:

```dart
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
```

Данные передаются через конструктор, а обновленные данные возвращаются через Navigator.pop.

### Шаг 5: Реализация функциональности поиска

Добавлен поиск с фильтрацией в реальном времени:

```dart
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
```

Поиск работает по заголовку и содержимому заметки, с автоматическим обновлением списка.

### Шаг 6: Реализация экрана редактирования

Экран редактирования использует Form для валидации:

```dart
Form(
  key: _formKey,
  child: Column(
    children: [
      TextFormField(
        initialValue: _title,
        decoration: const InputDecoration(labelText: 'Заголовок'),
        onSaved: (value) => _title = value!.trim(),
      ),
      TextFormField(
        initialValue: _body,
        decoration: const InputDecoration(labelText: 'Текст заметки'),
        minLines: 10,
        maxLines: null,
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Введите текст заметки';
          }
          return null;
        },
        onSaved: (value) => _body = value!.trim(),
      ),
    ],
  ),
)
```

Form обеспечивает валидацию обязательных полей и централизованное сохранение данных.

---

## Скриншоты работы приложения

### Главный экран со списком заметок
<img width="576" height="1280" alt="image" src="https://github.com/user-attachments/assets/0b23c791-4434-4435-9454-1e177ba28e68" />


### Экран создания новой заметки
<img width="576" height="1280" alt="image" src="https://github.com/user-attachments/assets/3b6af335-7afe-4213-a881-aa1270779497" />

<img width="576" height="1280" alt="image" src="https://github.com/user-attachments/assets/851fc9dd-b9f6-460b-ae4c-e345a3edb8e0" />


### Экран редактирования заметки
<img width="576" height="1280" alt="image" src="https://github.com/user-attachments/assets/6ffe7d94-8b49-4050-8a46-2ee7060299b6" />

<img width="576" height="1280" alt="image" src="https://github.com/user-attachments/assets/c6b83173-d831-4fae-9367-8b4e8a8e2ff9" />


### Удаление заметки с подтверждением
<img width="576" height="1280" alt="image" src="https://github.com/user-attachments/assets/c165d384-614d-40b0-ba5a-7f2fa5d32832" />

<img width="576" height="1280" alt="image" src="https://github.com/user-attachments/assets/29fff567-6f5b-452a-b611-0aa7206357d5" />


### Поиск по заметкам
<img width="576" height="1280" alt="image" src="https://github.com/user-attachments/assets/29a7ae4e-3010-49c0-a519-8df1e610bb82" />


---

## Выводы

### Что получилось:
При выполнении практической работы были получены навыки отображения списков с помощью ListView.builder, а также работы с самими списками. Были реализованы CRUD операции и добавлена функциональность поиска с фильтрацией. Реализовано свайп удаление с подтверждением.

### Что было сложным:
- Организация корректной передачи данных между экранами
- Реализация отмены удаления через SnackBar
- Настройка правильной работы ключей (Keys) для анимаций
- Оптимизация производительности при большом количестве элементов

### Итоги:
Приложение полностью соответствует требованиям практического задания. Все основные и дополнительные функции работают корректно.
