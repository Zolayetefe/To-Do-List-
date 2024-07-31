import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'task.dart';

class NewTask extends StatefulWidget {
  const NewTask({super.key});

  @override
  State<NewTask> createState() => _NewTaskState();
}

class _NewTaskState extends State<NewTask> {
  Box<Task> tasks=Hive.box<Task>('tasks');
  final TextEditingController nameController =  TextEditingController();
  final TextEditingController dateController =  TextEditingController();
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('New Task'),
        centerTitle: true,
        backgroundColor: Colors.indigo,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
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
              ElevatedButton(onPressed: (){
               setState(() {
                 Task task=Task(name:nameController.text,date:DateFormat('dd/mm/yyyy').parse( dateController.text));
                 tasks.add(task);
                 task.save();
                 Navigator.pop(context);
               });
              }, child: const Text('save'))
            ],
          ),
      ),

    );
  }
}
