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
        actions: [
          // Nuevo botón en la barra superior
          IconButton(
            icon: const Icon(Icons.assignment),
            tooltip: 'Formulario',
            onPressed: () {
              // Navegar a la pantalla de formulario
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FormScreen(database: widget.database),
                ),
              );
            },
          ),
        ],
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

// Nueva pantalla de formulario
class FormScreen extends StatefulWidget {
  final AppDatabase database;

  const FormScreen({Key? key, required this.database}) : super(key: key);

  @override
  _FormScreenState createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  String _selectedPriority = 'Media';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Formulario de Tarea'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Título del formulario
                Text(
                  'Datos de la tarea',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[800],
                  ),
                ),
                const SizedBox(height: 20),

                // Campo de nombre
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre de la tarea',
                    icon: Icon(Icons.task),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingrese un nombre';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Campo de email
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email de contacto',
                    icon: Icon(Icons.email),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                        return 'Ingrese un email válido';
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Campo de teléfono
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Teléfono',
                    icon: Icon(Icons.phone),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),

                // Selector de prioridad
                Row(
                  children: [
                    const Icon(Icons.priority_high, color: Colors.grey),
                    const SizedBox(width: 16),
                    Text('Prioridad:', style: TextStyle(fontSize: 16, color: Colors.green[800])),
                    const SizedBox(width: 10),
                    DropdownButton<String>(
                      value: _selectedPriority,
                      items: <String>['Baja', 'Media', 'Alta', 'Urgente']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _selectedPriority = newValue;
                          });
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 30),

                // Botones de acción
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    OutlinedButton.icon(
                      icon: const Icon(Icons.cancel),
                      label: const Text('Cancelar'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red[300],
                      ),
                    ),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.save),
                      label: const Text('Guardar'),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          // Mostrar diálogo de confirmación
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('Confirmar tarea', style: TextStyle(color: Colors.green[800])),
                                content: SingleChildScrollView(
                                  child: ListBody(
                                    children: [
                                      Text('Nombre: ${_nameController.text}'),
                                      const SizedBox(height: 8),
                                      Text('Email: ${_emailController.text}'),
                                      const SizedBox(height: 8),
                                      Text('Teléfono: ${_phoneController.text}'),
                                      const SizedBox(height: 8),
                                      Text('Prioridad: $_selectedPriority'),
                                    ],
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    child: Text('Cancelar', style: TextStyle(color: Colors.red[300])),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                  TextButton(
                                    child: Text('Confirmar', style: TextStyle(color: Colors.green[800])),
                                    onPressed: () {
                                      // Aquí se guardaría la tarea en la base de datos
                                      Navigator.of(context).pop(); // Cerrar diálogo

                                      // Mostrar mensaje de éxito
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: const Text('Tarea guardada correctamente'),
                                          backgroundColor: Colors.green[800],
                                          duration: const Duration(seconds: 2),
                                        ),
                                      );

                                      Navigator.of(context).pop(); // Volver a la pantalla principal
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[800],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}