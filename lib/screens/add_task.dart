import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';

class AddTask extends StatefulWidget {
  @override
  _AddTaskState createState() => _AddTaskState();
}

class _AddTaskState extends State<AddTask> {
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime currentDate = DateTime.now();

    final DateTime picked = (await showDatePicker(
      context: context,
      initialDate: selectedDate ?? currentDate,
      firstDate: currentDate, // Set the first date to today
      lastDate: DateTime(2101),
    ))!;

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay picked = (await showTimePicker(
      context: context,
      initialTime: selectedTime ?? TimeOfDay.now(),
    ))!;

    if (picked != null && picked != selectedTime) {
      setState(() {
        selectedTime = picked;
      });
    }
  }

  addTaskToFirebase(BuildContext context) async {
    if(titleController.text.isEmpty){
      Fluttertoast.showToast(msg: 'Please enter a title');
      return;
    }
    if(descriptionController.text.isEmpty){
      Fluttertoast.showToast(msg: 'Please enter a description');
      return;
    }
    if (selectedDate == null){
      Fluttertoast.showToast(msg: 'Please select a date');
      return;
    }
    if(selectedTime == null){
      Fluttertoast.showToast(msg: 'Please select a time');
      return;
    }

    FirebaseAuth auth = FirebaseAuth.instance;
    final User user = await auth.currentUser!;
    String uid = user.uid;

    DateTime userDateTime = DateTime(
      selectedDate!.year,
      selectedDate!.month,
      selectedDate!.day,
      selectedTime!.hour,
      selectedTime!.minute,
    );

    await FirebaseFirestore.instance
        .collection('tasks')
        .doc(uid)
        .collection('mytasks')
        .doc(userDateTime.toUtc().toString()) // Use UTC time for consistency
        .set({
      'title': titleController.text,
      'description': descriptionController.text,
      'time': userDateTime.toString(),
      'timestamp': userDateTime,
    });
    Fluttertoast.showToast(msg: 'Data Added');

    // Navigate back to the home screen
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('New Task')),
      body: Container(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              child: TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: 'Enter Title',
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
                  labelText: 'Enter Description',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10), // Set custom border radius
                  ),
                ),
              ),
            ),
            SizedBox(height: 10),
            Container(
              child: Row(
                children: [
                  Text(selectedDate != null
                      ? 'Date: ${selectedDate!.toLocal().toString().split(' ')[0]}'
                      : 'Select Date'),
                  SizedBox(width: 20),
                  ElevatedButton(
                    style : ButtonStyle(
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0), // Stylish border radius
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
                    onPressed: () => _selectDate(context),
                    child: Text('Select Date'),
                  ),
                ],
              ),
            ),
            Container(
              child: Row(
                children: [
                  Text(selectedTime != null
                      ? 'Time: ${selectedTime!.format(context)}'
                      : 'Select Time'),
                  SizedBox(width: 20),
                  ElevatedButton(
                    style : ButtonStyle(
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0), // Stylish border radius
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
                    onPressed: () => _selectTime(context),
                    child: Text('Select Time'),
                  ),
                ],
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
                  'Add Task',
                  style: GoogleFonts.roboto(fontSize: 18),
                ),
                onPressed: () {
                  addTaskToFirebase(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
