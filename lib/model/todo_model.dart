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

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'isCompleted': isCompleted ? 1 : 0,
    };
  }

  factory TodoModel.fromMap(Map<String, dynamic> map) {
    return TodoModel(
      id: map['id'] as int,
      title: map['title'] as String,
      isCompleted: (map['isCompleted'] as int) == 1,
    );
  }
}
