
import 'package:flutter/material.dart';
import 'package:to_do_app/main.dart';
class MainLayout extends StatefulWidget {


  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  List<Widget> Screen = [
    ToDoApp(filter: 'All',),
    ToDoApp(filter: 'inCompleted',),
    ToDoApp(filter: 'Completed',),
  ];
  int index = 0;
  @override


  Widget build(BuildContext context) {
    return Scaffold(
      body: Screen[index],
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.pink,
        unselectedItemColor: Colors.white,
        backgroundColor: Colors.black,
        currentIndex: index,
        onTap: (v) {
          index = v;
          setState(() {});
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Tasks'),
          BottomNavigationBarItem(icon: Icon(Icons.check), label: 'Completed'),
        ],
      ),
    );
  }
}

