import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:to_do_app/main_layout.dart';
import 'package:to_do_app/model.dart';
import 'package:to_do_app/search.dart';
import 'package:to_do_app/sql_helper.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  runApp(const MaterialApp(debugShowCheckedModeBanner: false, home: MainLayout()));
}

class ToDoApp extends StatefulWidget {
  final String filter ;
  const ToDoApp({super.key, required this.filter});

  @override
  State<ToDoApp> createState() => _ToDoAppState();
}

class _ToDoAppState extends State<ToDoApp> {

  SQLHelper sqlHelper = SQLHelper();

  bool isCompleted = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: FutureBuilder(
          future: sqlHelper.loadTasks(filter: widget.filter),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text(
                'Error: ${snapshot.error}',
                style: TextStyle(color: Colors.red),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Text(
                'No tasks yet',
                style: TextStyle(color: Colors.white),
              );
            }
            return ListView.builder(
              itemCount: snapshot.data?.length,
              itemBuilder: (context, index) {
                final task = snapshot.data![index];
                return Dismissible(
                  onDismissed: (direction) {
                    sqlHelper.deleteTask(snapshot.data![index]['id']).whenComplete(() {
                      setState(() {});
                    });
                  },
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  key: Key(snapshot.data![index]['id'].toString()),
                  child: InkWell(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (_) {
                          TextEditingController titleController =
                          TextEditingController(
                            text: snapshot.data![index]['title'],
                          );
                          TextEditingController descriptionController =
                          TextEditingController(
                            text: snapshot.data![index]['description'],
                          );

                          return AlertDialog(
                            title: const Text('Edit Task'),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TextFormField(
                                  controller: titleController,
                                  decoration: const InputDecoration(
                                    hintText: 'Title',
                                  ),
                                ),
                                TextFormField(
                                  controller: descriptionController,
                                  decoration: const InputDecoration(
                                    hintText: 'Description',
                                  ),
                                ),
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text(
                                  'Cancel',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  sqlHelper.editTask(
                                    Task(
                                      id: snapshot.data![index]['id'],
                                      title: titleController.text,
                                      description: descriptionController.text,
                                      createdAt: DateTime.now(),
                                      isCompleted: false,
                                    ),
                                  ).whenComplete(() {
                                    setState(() {});
                                  }
                                  );
                                  Navigator.pop(context);
                                },
                                child: const Text(
                                  'Edit',
                                  style: TextStyle(color: Colors.green),
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    },

                    child: Card(
                      margin: const EdgeInsets.all(10),
                      child: ListTile(
                        title: Text(snapshot.data![index]['title']),
                        subtitle: Text(snapshot.data![index]['description']),
                        trailing: IconButton(
                          icon: task['isCompleted'] == 1
                              ? const Icon(Icons.check_box, color: Colors.green)
                            : const Icon(Icons.check_box_outline_blank, color: Colors.grey),
                    onPressed: () async {
                      final updatedTask = Task(
                          id: task['id'],
                          title: task['title']?? '',
                          description: task['description']?? '',
                          createdAt: task['createdAt'] != null
                              ? DateTime.parse(task['createdAt'])
                              : DateTime.now(),
                          isCompleted: task['isCompleted'] == 0,
                      );

                      await sqlHelper.editTask(updatedTask);

                      setState(() {});
                    },
                  )

                ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),



      appBar: AppBar(
        title: const Text(
          'To Do App',
          style: TextStyle(fontSize: 25, color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Search()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () {
              sqlHelper.deleteAll().whenComplete(() {
                setState(() {});
              });
            },
          ),
        ],
        backgroundColor: Colors.black,
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.pink,
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) {
              TextEditingController titleController = TextEditingController();
              TextEditingController descriptionController = TextEditingController();

              return AlertDialog(
                title: const Text('Add Task'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: titleController,
                      decoration: const InputDecoration(hintText: 'Title'),
                    ),
                    TextFormField(
                      controller: descriptionController,
                      decoration: const InputDecoration(
                        hintText: 'Description',
                      ),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      sqlHelper
                          .addTask(
                          Task(
                            title: titleController.text.trim().isEmpty ? 'No Title' : titleController.text.trim(),
                            description: descriptionController.text.trim(),
                            createdAt: DateTime.now(),
                          )
                          )
                          .whenComplete(() {
                            setState(() {});
                          });
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'Add',
                      style: TextStyle(color: Colors.green),
                    ),
                  ),
                ],
              );
            },
          );
        },
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }
}
