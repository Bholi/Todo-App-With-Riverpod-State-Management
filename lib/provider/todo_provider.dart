import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart';
import 'package:riverpod/legacy.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todo_project/model/todo_model.dart';
import 'package:todo_project/provider/auth_provider.dart';

// ---------------------------------------------------------------------------
// SQLite Helper
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
      version: 2,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE todos(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            isCompleted INTEGER NOT NULL DEFAULT 0,
            firestoreId TEXT
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('ALTER TABLE todos ADD COLUMN firestoreId TEXT');
        }
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
// Firestore Helper
// ---------------------------------------------------------------------------

class FirestoreHelper {
  final _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _todosRef(String uid) =>
      _firestore.collection('users').doc(uid).collection('todos');

  Future<List<TodoModel>> getTodos(String uid) async {
    final snapshot = await _todosRef(uid).get();
    return snapshot.docs
        .map((doc) => TodoModel.fromFirestore(doc.id, doc.data()))
        .toList();
  }

  Future<String> addTodo(String uid, TodoModel todo) async {
    final docRef = await _todosRef(uid).add(todo.toFirestore());
    return docRef.id;
  }

  Future<void> updateTodo(String uid, TodoModel todo) async {
    if (todo.firestoreId == null) return;
    await _todosRef(uid).doc(todo.firestoreId).update(todo.toFirestore());
  }

  Future<void> deleteTodo(String uid, String firestoreId) async {
    await _todosRef(uid).doc(firestoreId).delete();
  }

  Future<void> uploadLocalTodos(String uid, List<TodoModel> todos) async {
    final batch = _firestore.batch();
    for (final todo in todos) {
      final docRef = _todosRef(uid).doc();
      batch.set(docRef, todo.toFirestore());
    }
    await batch.commit();
  }
}

// ---------------------------------------------------------------------------
// Notifier + Providers
// ---------------------------------------------------------------------------

class TodoNotifier extends AsyncNotifier<List<TodoModel>> {
  final _db = DatabaseHelper.instance;
  final _firestore = FirestoreHelper();

  String? get _uid => ref.read(authProvider).value?.uid;

  @override
  Future<List<TodoModel>> build() async {
    final user = ref.watch(authProvider).value;

    if (user == null) {
      return _db.getTodos();
    }

    // Logged in — upload only genuinely new local todos (no firestoreId),
    // skip cached ones (have firestoreId from previous sign-out sync).
    final localTodos = await _db.getTodos();
    final newLocal = localTodos.where((t) => t.firestoreId == null).toList();
    if (newLocal.isNotEmpty) {
      await _firestore.uploadLocalTodos(user.uid, newLocal);
    }
    // Clear all local data (cache + new) after sync
    for (final todo in localTodos) {
      await _db.deleteTodo(todo.id);
    }

    final todos = await _firestore.getTodos(user.uid);
    ref.read(lastSyncProvider.notifier).state = DateTime.now();
    return todos;
  }

  Future<void> addTodo(String title) async {
    if (title.trim().isEmpty) return;
    final todo = TodoModel(id: 0, title: title.trim(), isCompleted: false);

    if (_uid != null) {
      final firestoreId = await _firestore.addTodo(_uid!, todo);
      final saved = todo.copyWith(firestoreId: firestoreId);
      state = AsyncData([...state.value ?? [], saved]);
      ref.read(lastSyncProvider.notifier).state = DateTime.now();
    } else {
      final id = await _db.insertTodo(todo);
      final saved = todo.copyWith(id: id);
      state = AsyncData([...state.value ?? [], saved]);
    }
  }

  Future<void> toggleTodo(int id, {String? firestoreId}) async {
    final todos = state.value ?? [];
    final target = todos.firstWhere(
      (t) => firestoreId != null ? t.firestoreId == firestoreId : t.id == id,
    );
    final toggled = target.copyWith(isCompleted: !target.isCompleted);

    if (_uid != null && toggled.firestoreId != null) {
      await _firestore.updateTodo(_uid!, toggled);
      ref.read(lastSyncProvider.notifier).state = DateTime.now();
    } else {
      await _db.updateTodo(toggled);
    }

    state = AsyncData([
      for (final todo in todos)
        if (firestoreId != null
            ? todo.firestoreId == firestoreId
            : todo.id == id)
          toggled
        else
          todo,
    ]);
  }

  /// Save current in-memory todos to SQLite (called before sign-out).
  Future<void> syncToLocal() async {
    final todos = state.value ?? [];
    // Clear stale local data
    final old = await _db.getTodos();
    for (final t in old) {
      await _db.deleteTodo(t.id);
    }
    // Write current todos into SQLite
    for (final todo in todos) {
      await _db.insertTodo(todo);
    }
  }

  Future<void> deleteTodo(int id, {String? firestoreId}) async {
    if (_uid != null && firestoreId != null) {
      await _firestore.deleteTodo(_uid!, firestoreId);
      ref.read(lastSyncProvider.notifier).state = DateTime.now();
    } else {
      await _db.deleteTodo(id);
    }

    state = AsyncData(
      (state.value ?? []).where((todo) {
        if (firestoreId != null) return todo.firestoreId != firestoreId;
        return todo.id != id;
      }).toList(),
    );
  }
}

final todoProvider =
    AsyncNotifierProvider<TodoNotifier, List<TodoModel>>(TodoNotifier.new);

final lastSyncProvider = StateProvider<DateTime?>((ref) => null);

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
