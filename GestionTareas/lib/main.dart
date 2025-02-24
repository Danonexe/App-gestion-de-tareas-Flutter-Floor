import 'package:flutter/material.dart';
import 'package:gestiontareas/models/Tarea.dart';
import 'database/database.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final database = await AppDatabase.getInstance();
  runApp(MyApp(database: database));
}

class MyApp extends StatelessWidget {
  final AppDatabase database;

  const MyApp({Key? key, required this.database}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lista de Tareas',
      theme: ThemeData(
        primarySwatch: Colors.green,
        primaryColor: const Color(0xFF1B5E20),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1B5E20),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFF1B5E20),
        ),
        checkboxTheme: CheckboxThemeData(
          fillColor: MaterialStateProperty.resolveWith<Color>((states) {
            if (states.contains(MaterialState.selected)) {
              return const Color(0xFF1B5E20);
            }
            return Colors.grey;
          }),
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: TaskListScreen(database: database),
    );
  }
}

class TaskListScreen extends StatefulWidget {
  final AppDatabase database;

  const TaskListScreen({Key? key, required this.database}) : super(key: key);

  @override
  _TaskListScreenState createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  List<Task> _tasks = [];
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final tasks = await widget.database.taskDao.findAllTasks();
    setState(() {
      _tasks = tasks;
    });
  }

  Future<void> _addTask() async {
    if (_textController.text.isNotEmpty) {
      final task = Task(
        description: _textController.text,
        isCompleted: false,
      );
      await widget.database.taskDao.insertTask(task);
      _textController.clear();
      _loadTasks();
    }
  }

  Future<void> _toggleTaskStatus(Task task) async {
    final updatedTask = Task(
      id: task.id,
      description: task.description,
      isCompleted: !task.isCompleted,
    );
    await widget.database.taskDao.updateTask(updatedTask);
    _loadTasks();
  }

  Future<void> _deleteTask(Task task) async {
    await widget.database.taskDao.deleteTask(task);
    _loadTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Tareas'),
      ),
      body: _tasks.isEmpty
          ? Center(
        child: Text(
          'No hay tareas.',
          style: TextStyle(color: Colors.green[800]),
        ),
      )
          : ListView.builder(
        itemCount: _tasks.length,
        itemBuilder: (context, index) {
          final task = _tasks[index];
          return ListTile(
            leading: Checkbox(
              value: task.isCompleted,
              onChanged: (_) => _toggleTaskStatus(task),
            ),
            title: Text(
              task.description,
              style: TextStyle(
                decoration: task.isCompleted
                    ? TextDecoration.lineThrough
                    : null,
                color: task.isCompleted
                    ? Colors.grey
                    : const Color(0xFF2E7D32),
              ),
            ),
            onLongPress: () => _deleteTask(task),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text(
                  'Agregar Tarea',
                  style: TextStyle(color: Colors.green[800]),
                ),
                content: TextField(
                  controller: _textController,
                  decoration: InputDecoration(
                    hintText: 'Descripción de la tarea',
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.green[800]!),
                    ),
                  ),
                  autofocus: true,
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Cancelar', style: TextStyle(color: Colors.red[300])),
                  ),
                  TextButton(
                    onPressed: () {
                      _addTask();
                      Navigator.pop(context);
                    },
                    child: Text(
                      'Guardar',
                      style: TextStyle(color: Colors.green[800]),
                    ),
                  ),
                ],
              );
            },
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}