import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod/legacy.dart';
import 'package:todo_project/model/todo_model.dart';

class TodoNotifier extends Notifier<List<TodoModel>> {
  int _nextId = 0;

  @override
  List<TodoModel> build() => [];

  void addTodo(String title) {
    if (title.trim().isEmpty) return;
    state = [...state, TodoModel(id: _nextId++, title: title.trim(), isCompleted: false)];
  }

  void toggleTodo(int id) {
    state = [
      for (final todo in state)
        if (todo.id == id) todo.copyWith(isCompleted: !todo.isCompleted) else todo,
    ];
  }

  void deleteTodo(int id) {
    state = state.where((todo) => todo.id != id).toList();
  }
}

final todoProvider = NotifierProvider<TodoNotifier, List<TodoModel>>(TodoNotifier.new);

final searchQueryProvider = StateProvider<String>((ref) => '');

final filteredTodosProvider = Provider<List<TodoModel>>((ref) {
  final todos = ref.watch(todoProvider);
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
  final todos = ref.watch(todoProvider);
  return todos.where((todo) => !todo.isCompleted).length;
});
