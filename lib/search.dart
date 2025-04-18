import 'package:flutter/material.dart';
import 'package:to_do_app/sql_helper.dart';

class Search extends StatefulWidget {
  const Search({super.key});

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
 TextEditingController searchController = TextEditingController();
SQLHelper sqlHelper = SQLHelper();
 List<Map<String, dynamic>> searchResults = [];

 void search(String keyword) async {
   final results = await sqlHelper.searchTask(keyword);
   setState(() {
     searchResults = results;
   });
 }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Search',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
          ),
        ),
      ),
      backgroundColor: Colors.black,
      body: Column(
        children: [
          SizedBox(
            height: 30,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              onChanged: search ,
              controller: searchController,
              decoration: InputDecoration(
                labelText: 'Search',
                labelStyle: TextStyle(

                  color: Colors.white,
                ),
                prefixIcon: const Icon(Icons.search,
                  color: Colors.white,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: const BorderSide(color: Colors.white),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: const BorderSide(color: Colors.white),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: const BorderSide(color: Colors.white),
                ),
              ),

              style: const TextStyle(
                color: Colors.white,
              ),
            ),
          ),

          Expanded(
            child: ListView.builder(
                  itemCount: searchResults.length,
                  itemBuilder: (context, index) {
                    final task = searchResults[index];
                    return Card(
                      margin: const EdgeInsets.all(8.0),
                      child: ListTile(
                        title: Text(task['title']),
                        subtitle: Text(task['description']),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            setState(()async {

                              await sqlHelper.deleteTask(task['id']);
                              search(searchController.text);
                            });
                          },
                        ),
                      ),
                    );
              },
            ),
          ),
        ],
      ),
    );
  }
}
