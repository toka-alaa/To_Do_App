import 'package:flutter/material.dart';
import 'package:to_do_app/search.dart';
import 'package:to_do_app/sql_helper.dart';

import 'model.dart';

class Tasks extends StatefulWidget {
  const Tasks({super.key});

  @override
  State<Tasks> createState() => _CompletedTasksScreenState();
}

class _CompletedTasksScreenState extends State<Tasks> {
  SQLHelper sqlHelper = SQLHelper();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: FutureBuilder(
          future: sqlHelper.loadTasks(),
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
                'No Tasks yet',
                style: TextStyle(color: Colors.white),
              );
            }
            return ListView.builder(
              itemCount: snapshot.data?.length,
              itemBuilder: (context, index) {
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
                          icon: const Icon(Icons.check_box),
                          onPressed: () {
                            // Handle delete action
                          },
                        ),
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
    );
  }
}
