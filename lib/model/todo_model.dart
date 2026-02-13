class TodoModel {
  final int id;
  final String title;
  final bool isCompleted;

  TodoModel({required this.title, required this.id, required this.isCompleted});

  TodoModel copyWith({String? title, int? id, bool? isCompleted}) {
    return TodoModel(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
