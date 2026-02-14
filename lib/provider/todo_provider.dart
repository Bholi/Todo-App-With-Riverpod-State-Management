import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart';
import 'package:riverpod/legacy.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todo_project/model/todo_model.dart';

// ---------------------------------------------------------------------------
// Database Helper
// ---------------------------------------------------------------------------

class DatabaseHelper {
  DatabaseHelper._();
  static final DatabaseHelper instance = DatabaseHelper._();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'todos.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE todos(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            isCompleted INTEGER NOT NULL DEFAULT 0
          )
        ''');
      },
    );
  }

  Future<int> insertTodo(TodoModel todo) async {
    final db = await database;
    return db.insert('todos', todo.toMap());
  }

  Future<List<TodoModel>> getTodos() async {
    final db = await database;
    final maps = await db.query('todos');
    return maps.map((map) => TodoModel.fromMap(map)).toList();
  }

  Future<void> updateTodo(TodoModel todo) async {
    final db = await database;
    await db.update(
      'todos',
      todo.toMap(),
      where: 'id = ?',
      whereArgs: [todo.id],
    );
  }

  Future<void> deleteTodo(int id) async {
    final db = await database;
    await db.delete('todos', where: 'id = ?', whereArgs: [id]);
  }
}

// ---------------------------------------------------------------------------
// Notifier + Providers
// ---------------------------------------------------------------------------

class TodoNotifier extends AsyncNotifier<List<TodoModel>> {
  final _db = DatabaseHelper.instance;

  @override
  Future<List<TodoModel>> build() => _db.getTodos();

  Future<void> addTodo(String title) async {
    if (title.trim().isEmpty) return;
    final todo = TodoModel(id: 0, title: title.trim(), isCompleted: false);
    final id = await _db.insertTodo(todo);
    final saved = todo.copyWith(id: id);
    state = AsyncData([...state.value ?? [], saved]);
  }

  Future<void> toggleTodo(int id) async {
    final todos = state.value ?? [];
    final target = todos.firstWhere((t) => t.id == id);
    final toggled = target.copyWith(isCompleted: !target.isCompleted);
    await _db.updateTodo(toggled);
    state = AsyncData([
      for (final todo in todos)
        if (todo.id == id) toggled else todo,
    ]);
  }

  Future<void> deleteTodo(int id) async {
    await _db.deleteTodo(id);
    state = AsyncData(
      (state.value ?? []).where((todo) => todo.id != id).toList(),
    );
  }
}

final todoProvider =
    AsyncNotifierProvider<TodoNotifier, List<TodoModel>>(TodoNotifier.new);

final searchQueryProvider = StateProvider<String>((ref) => '');

final filteredTodosProvider = Provider<List<TodoModel>>((ref) {
  final todos = ref.watch(todoProvider).value ?? [];
  final query = ref.watch(searchQueryProvider).toLowerCase();
  if (query.isEmpty) return todos;
  return todos.where((todo) => todo.title.toLowerCase().contains(query)).toList();
});

final activeTodosProvider = Provider<List<TodoModel>>((ref) {
  final todos = ref.watch(filteredTodosProvider);
  return todos.where((todo) => !todo.isCompleted).toList();
});

final doneTodosProvider = Provider<List<TodoModel>>((ref) {
  final todos = ref.watch(filteredTodosProvider);
  return todos.where((todo) => todo.isCompleted).toList();
});

final remainingCountProvider = Provider<int>((ref) {
  final todos = ref.watch(todoProvider).value ?? [];
  return todos.where((todo) => !todo.isCompleted).length;
});
