import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
class EditTodo extends StatefulWidget {
  final String docId;
  final String uid; // Add uid parameter to the constructor

  EditTodo({required this.docId, required this.uid});

  @override
  _EditTodoState createState() => _EditTodoState();
}

class _EditTodoState extends State<EditTodo> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchTodoData();
  }

  void fetchTodoData() async {
    // Fetch the existing todo data and set it to the controllers.
    final snapshot = await FirebaseFirestore.instance
        .collection('tasks')
        .doc(widget.uid) // Use the uid from the widget
        .collection('mytasks')
        .doc(widget.docId)
        .get();

    if (snapshot.exists) {
      final data = snapshot.data() as Map<String, dynamic>;
      titleController.text = data['title'];
      descriptionController.text = data['description'];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Edit Task')),
      body: Container(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              child: TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: 'Edit Title',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10), // Set custom border radius
                  ),
                ),
              ),
            ),
            SizedBox(height: 10),
            Container(
              child: TextField(
                controller: descriptionController,
                decoration: InputDecoration(
                  labelText: 'Edit Description',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10), // Set custom border radius
                  ),
                ),
              ),
            ),
            SizedBox(height: 10),
            Container(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ButtonStyle(
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0), // Stylish border radius
                    ),
                  ),
                  backgroundColor: MaterialStateProperty.resolveWith<Color>(
                        (Set<MaterialState> states) {
                      if (states.contains(MaterialState.pressed))
                        return Colors.blue;
                      return Colors.blueAccent;
                    },
                  ),
                ),
                child: Text(
                  'Update Todo',
                  style: TextStyle(fontSize: 18),
                ),
                onPressed: () {
                  updateTodo();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void updateTodo() async {
    // Update the todo in the Firestore database.
    if(titleController.text.isEmpty){
      Fluttertoast.showToast(msg: 'Please enter a title');
      return;
    }
    if(descriptionController.text.isEmpty){
      Fluttertoast.showToast(msg: 'Please enter a description');
      return;
    }
    await FirebaseFirestore.instance
        .collection('tasks')
        .doc(widget.uid) // Use the uid from the widget
        .collection('mytasks')
        .doc(widget.docId)
        .update({
      'title': titleController.text,
      'description': descriptionController.text,
    });
    Fluttertoast.showToast(msg: 'Todo updated successfully');
    Navigator.pop(context);
  }
}
