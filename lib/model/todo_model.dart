class TodoModel {
  final int id;
  final String title;
  final bool isCompleted;
  final String? firestoreId;

  TodoModel({
    required this.title,
    required this.id,
    required this.isCompleted,
    this.firestoreId,
  });

  TodoModel copyWith({String? title, int? id, bool? isCompleted, String? firestoreId}) {
    return TodoModel(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      firestoreId: firestoreId ?? this.firestoreId,
    );
  }

  // SQLite (uses int for bool)
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'isCompleted': isCompleted ? 1 : 0,
      'firestoreId': firestoreId,
    };
  }

  factory TodoModel.fromMap(Map<String, dynamic> map) {
    return TodoModel(
      id: map['id'] as int,
      title: map['title'] as String,
      isCompleted: (map['isCompleted'] as int) == 1,
      firestoreId: map['firestoreId'] as String?,
    );
  }

  // Firestore (uses native bool)
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'isCompleted': isCompleted,
    };
  }

  factory TodoModel.fromFirestore(String docId, Map<String, dynamic> data) {
    return TodoModel(
      id: 0,
      title: data['title'] as String,
      isCompleted: data['isCompleted'] as bool,
      firestoreId: docId,
    );
  }
}
