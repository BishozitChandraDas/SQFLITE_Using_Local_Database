import 'package:flutter/material.dart';
import 'package:sqflite_operations/db_helper.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> _allData = [];

  //Get all data from Database
  void _refreshData() async {
    final data = await SqlHalper.getAllData();
    setState(() {
      _allData = data;
      // _isLoading = false;
      print("..Number of items ${_allData.length}");
    });
  }

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

//Add Data
  Future<void> _addData() async {
    await SqlHalper.createData(_titleController.text, _descController.text);
    _refreshData();
  }

//Update Data
  Future<void> _updateData(int id) async {
    await SqlHalper.updateData(id, _titleController.text, _descController.text);
    _refreshData();
  }

//Delete Data
  void _deleteData(int id) async {
    await SqlHalper.deleteData(id);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        backgroundColor: Colors.red, content: Text("Data Deleted")));
    _refreshData();
  }

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  void _showForm(int? id) async {
    // if id is not null than it will update other wise it will new data
    // When edit icon is pressed then id will be given to bottomshet function and
    //It eill edit
    if (id != null) {
      final existingData =
          _allData.firstWhere((element) => element['id'] == id);
      _titleController.text = existingData['title'];
      _descController.text = existingData['desc'];
    }

    showModalBottomSheet(
      context: context,
      elevation: 5,
      isScrollControlled: true,
      builder: (_) => Container(
        padding: EdgeInsets.only(
          top: 30,
          left: 15,
          right: 15,
          bottom: MediaQuery.of(context).viewInsets.bottom + 120,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Title",
              ),
            ),
            SizedBox(
              height: 20,
            ),
            TextField(
              controller: _descController,
              // maxLines: 4,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Desccription",
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(
              onPressed: () async {
                if (id == null) {
                  await _addData();
                }
                if (id != null) {
                  await _updateData(id);
                }

                _titleController.text = "";
                _descController.text = "";
//Hide Bottom Sheet
                Navigator.of(context).pop();
                print("Data Added");
              },
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Text(
                  id == null ? "Add Data" : "Update",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 48, 2, 2),
      // backgroundColor: const Color(0xffECEAF4),
      appBar: AppBar(
        title: const Text(" SQFLITE CURD Operations"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
              child: ListView.builder(
            itemCount: _allData.length,
            itemBuilder: (context, index) => Card(
              margin: const EdgeInsets.all(10),
              child: ListTile(
                
                title: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Text(
                    _allData[index]['title'],
                    style: const TextStyle(
                      fontSize: 20, color: Color.fromARGB(255, 2, 34, 58), fontWeight: FontWeight.w500
                    ),
                  ),
                ),
                subtitle: Text(
                  _allData[index]['desc'],
                  style: const TextStyle(fontSize: 17, color: Colors.black, fontWeight: FontWeight.w500),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () {
                        _showForm(_allData[index]['id']);
                      },
                      icon: const Icon(
                        Icons.edit,
                        color: Colors.indigo,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        _deleteData(_allData[index]['id']);
                      },
                      icon: const Icon(
                        Icons.delete,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ))
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showForm(null),
        child: const Icon(Icons.add),
      ),
    );
  }
}
