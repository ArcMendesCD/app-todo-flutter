import 'package:flutter/material.dart';
import 'todo.dart';
import 'todo_dao.dart'; // daozinho dicri

void main() {
  runApp(const TodoApp());
}

class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lista de coisinhas para fazer',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 88, 174, 214)),
        useMaterial3: true,
      ),
      home: const TodoPagPrincipal(),
    );
  }
}

class TodoPagPrincipal extends StatefulWidget {
  const TodoPagPrincipal({super.key});

  @override
  State<TodoPagPrincipal> createState() => _TodoPagPrincipalState();
}

class _TodoPagPrincipalState extends State<TodoPagPrincipal> {
  final TextEditingController _controller = TextEditingController();
  List<Todo> todos = [];
  String _prioridadeSelecionada = 'Médio'; // prioridade padrão

  String prioridadeParaChar(String prioridade) {
    switch (prioridade) {
      case 'Alto':
        return 'A';
      case 'Baixo':
        return 'B';
      case 'Médio':
      default:
        return 'M';
    }
  }

  @override
  void initState() {
    super.initState();
    fetchTodos();  
  }

  Future<void> fetchTodos() async {
    final rawTodos = await DataAccessObject.getTarefas();
    final list = rawTodos.map((e) => Todo(
      id: e['id'],
      title: e['titulo'],
      prioridade: e['prioridade'],
      status: e['status'],
    )).toList();

    setState(() {
      todos = list;
    });
  }

  Future<void> addTodo() async {
    final title = _controller.text.trim();
    if (title.isEmpty) return;

    final newTodo = Todo(
      id: 0, 
      title: title,
      prioridade: _prioridadeSelecionada,
      status: 'A', 
    );

    setState(() {
      todos.add(newTodo); 
    });

    await DataAccessObject.createTarefa(
      prioridadeParaChar(_prioridadeSelecionada),
      DateTime.now().add(const Duration(days: 7)), // datavencimento
      DateTime.now(), // data_criacao
      'A', // status
      '', // descricao
      title, // titulo
    );
  }


  Future<void> deleteTodo(int id) async {
    final todoToDelete = todos.firstWhere(
      (todo) => todo.id == id,
      orElse: () => Todo(id: -1, title: '', prioridade: 'Médio', status: 'A') 
    );

    if (todoToDelete.id == -1) return;

    setState(() {
      todos.removeWhere((todo) => todo.id == id);
    });

    await DataAccessObject.deleteTarefa(id);
  }



  Future<void> updateStatus(int id, String status) async {
    final todo = todos.firstWhere((todo) => todo.id == id);

    if (todo.status == status) return;

    setState(() {
      todo.status = status;
    });

    DateTime dataCriacao = DateTime.now();
    DateTime dataVencimento = DateTime.now().add(const Duration(days: 7));

    await DataAccessObject.updateTarefa(
      todo.id!,
      todo.prioridade,
      dataVencimento,
      dataCriacao,
      status,
      '',
      todo.title,
    );
  }


  Color getColorFromStatus(String status) {
    switch (status) {
      case 'A': 
        return Colors.red;
      case 'F': 
        return Colors.green;
      default:
        return Colors.black; 
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/wallpaper_rem.jpg"),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        appBar: AppBar(title: const Text("Lista de coisas para fazer")),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          controller: _controller,
                          decoration: const InputDecoration(labelText: 'Digite o título do TODO'),
                        ),
                        const SizedBox(height: 8),
                        DropdownButton<String>(
                          value: _prioridadeSelecionada,
                          items: const [
                            DropdownMenuItem(value: 'Alto', child: Text('Alto')),
                            DropdownMenuItem(value: 'Médio', child: Text('Médio')),
                            DropdownMenuItem(value: 'Baixo', child: Text('Baixo')),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _prioridadeSelecionada = value;
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: addTodo,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: todos.length,
                  itemBuilder: (context, index) {
                    final todo = todos[index];

                    Color titleColor = getColorFromStatus(todo.status);

                    return ListTile(
                      tileColor: todo.status == 'F' ? const Color.fromARGB(255, 255, 179, 255) : null,
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            todo.title,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: titleColor,  
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Prioridade: ${todo.prioridade}',
                            style: todo.prioridade == 'M'
                                ? const TextStyle(color: Color.fromARGB(255, 255, 153, 0))
                                : const TextStyle(color: Color.fromARGB(255, 252, 89, 89)),
                          ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.delete, color: Color.fromARGB(255, 77, 162, 211)),
                            onPressed: () => deleteTodo(todo.id!),
                          ),
                          IconButton(
                            icon: const Icon(Icons.check, color: Color.fromARGB(255, 190, 0, 248)),
                            onPressed: () => updateStatus(todo.id!, 'F'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
