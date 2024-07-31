import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'task.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure widgets binding is initialized
  await Hive.initFlutter(); // Initialize Hive

  // Register the Hive adapter for the Task type
  Hive.registerAdapter(TaskAdapter());

  // Open the Hive box
  var box = await Hive.openBox<Task>('tasks');

  // If the box is empty, add default tasks
  if (box.isEmpty) {
    addTasks(box);
  }

  // Run the Flutter app
  runApp(const MyApp());
}

void addTasks(Box<Task> box) {
  // Create a list of default tasks
  List<Task> tasks = [
    Task(name: "home work", date: DateTime.now()),
    Task(name: "app building", date: DateTime.now()),
    Task(name: "watching movie", date: DateTime.now())
  ];

  // Add each task to the Hive box
  for (var task in tasks) {
    box.add(task);
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'To-Do-List'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // Get the Hive box for tasks
  Box<Task> tasks = Hive.box<Task>('tasks');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigator.push(
          //   context,
          //   SwipeablePageRoute(builder: (context) => NewTask()),
          // );
          addTask(context);
        },
        tooltip: 'Add Task',
        child: const Icon(Icons.add),
      ),
      body: ValueListenableBuilder<Box<Task>>(
        // Use ValueListenableBuilder to listen for changes in the box
        valueListenable: tasks.listenable(),
        builder: (context, box, _) {
          // Build a column with tasks
          return Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Center(
                child: Text(
                  "Tasks",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                    fontSize: 22,
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: box.length, // Use the length of the box
                  itemBuilder: (context, index) {
                    final task = box.getAt(index); // Retrieve task at the index
                    if (task == null) {
                      return SizedBox(); // Handle null task gracefully
                    }
                    return Card(
                      elevation: 16.0,
                      child: ListTile(
                        title: Text(task.name), // Access the task name
                        subtitle: Text(task.date.toString()), // Access the task date
                        trailing: SizedBox(
                          width: 96, // Fixed width to fit icons
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  tasks.deleteAt(index); // Correct method to delete by index
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit_note, color: Colors.grey),
                                onPressed: () {
                                  _editTask(context, index, task);
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              )
            ],
          );
        },
      ),
    );
  }


  // Method to handle task editing
  Future<void> _editTask(BuildContext context, int index, Task task) async {
    final TextEditingController _nameController = TextEditingController(text: task.name);

    // Show a dialog to edit the task
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Task'),
          content: TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Task Name'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final newName = _nameController.text.trim();
                if (newName.isNotEmpty) {
                  tasks.putAt(index, Task(name: newName, date: task.date));
                  setState(() {});
                }
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}

// method to add new task
Future<void> addTask(context)async {
  Box<Task> tasks=Hive.box<Task>('tasks');
  final TextEditingController nameController =  TextEditingController();
  final TextEditingController dateController =  TextEditingController();
    await showDialog(
        context: context,
        builder: (context){
          return AlertDialog(
            title: Text('Add Task'),
            content: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: "Task Name",
                      hintText: "home work",
                      border: OutlineInputBorder(),
                    ),
                    validator: (value){
                      if(value == null || value.isEmpty){
                        return "enter task date";
                      }
                      return null;
                    },
                  ),

                  TextFormField(
                    controller: dateController,
                    decoration: const InputDecoration(
                      labelText: "Date",
                      hintText: "dd/mm/yyyy",
                      border: OutlineInputBorder(),
                    ),
                    validator: (value){
                      if(value == null || value.isEmpty){
                        return "enter task name";
                      }
                      if (!RegExp(
                          r'^(0[1-9]|[12][0-9]|3[01])/(0[1-9]|1[0-2])/\d{4}$')
                          .hasMatch(value)) {
                        return "Please enter a valid date (dd/mm/yyyy)";
                      }
                      return null;
                    },

                  ),
                  const SizedBox(height: 16,),

                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                    onPressed: (){
                      Task task=Task(name:nameController.text,date:DateFormat('dd/mm/yyyy').parse( dateController.text));
                      tasks.add(task);
                      // task.save();
                    },
                    child: const Text('save')),
              ]
            );
        },
    );
}