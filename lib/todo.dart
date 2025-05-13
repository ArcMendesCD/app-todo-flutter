class Todo {
  final int? id;
  final String title;
  final String prioridade;
  String status;

  Todo({this.id, required this.title, required this.prioridade, required this.status});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'prioridade': prioridade,
      'status': status,
    };
  }

  factory Todo.fromMap(Map<String, dynamic> map) {
    return Todo(
      id: map['id'],
      title: map['title'],
      prioridade: map['prioridade'],
      status: map['status'],
    );
  }
}
