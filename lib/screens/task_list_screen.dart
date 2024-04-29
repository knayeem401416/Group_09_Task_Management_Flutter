import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:task_management/screens/profile_screen.dart';
import 'package:task_management/screens/statics.dart';

class TaskListScreen extends StatelessWidget {
  final String userId;

  TaskListScreen({required this.userId});

  Future<String?> _fetchUserProfileImageUrl(String userId) async {
    try {
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .doc(userId)
          .get();
      return userSnapshot['ImageUrl'] as String?;
    } catch (e) {
      print('Failed to fetch user image URL: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Task List'),
        actions: <Widget>[
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: FutureBuilder(
              future: _fetchUserProfileImageUrl(userId),
              builder: (BuildContext context, AsyncSnapshot<String?> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.grey[300],
                    child: CircularProgressIndicator(
                      strokeWidth: 2.0,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  );
                } else if (snapshot.hasData && snapshot.data != null) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => Profile(userId: userId)),
                      );
                    },
                    child: CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.grey[300],
                      backgroundImage: NetworkImage(snapshot.data!),
                    ),
                  );
                } else {
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => Profile(userId: userId)),
                      );
                    },
                    child: CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.grey[300],
                      child: Icon(Icons.person, color: Colors.white),
                    ),
                  );
                }
              },
            ),
          ),
          PopupMenuButton(
            itemBuilder: (BuildContext context) => [
              PopupMenuItem(
                child: Text("Statics"),
                value: "statics",
              ),
              PopupMenuItem(
                child: Text("Help"),
                value: "help",
              ),
            ],
            onSelected: (String value) {
              if (value == "statics") {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Statics()),
                );
              } else if (value == "help") {
              }
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('tasks').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text('No Tasks',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            );
          } else {
            List<Widget> ongoingTasks = [];
            List<Widget> completedTasks = [];

            snapshot.data!.docs.forEach((doc) {
              Timestamp createdAtTimestamp =
                  doc['created_at'] ?? Timestamp.now();
              DateTime createdAt = createdAtTimestamp.toDate();
              String formattedDate =
                  '${createdAt.day}/${createdAt.month}/${createdAt.year} ${createdAt.hour}:${createdAt.minute}';
              print("Ongoinggg" + ongoingTasks.length.toString());
              print("Completetaskkk" + completedTasks.length.toString());

              ListTile taskTile = ListTile(
                title: Text(
                  doc['name'],
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  'Created at: $formattedDate',
                  style: TextStyle(color: Colors.grey),
                ),
                leading: Checkbox(
                  value: doc['status'] == 'done',
                  onChanged: (value) async {
                    if (value != null) {
                      await FirebaseFirestore.instance
                          .collection('tasks')
                          .doc(doc.id)
                          .update({
                        'status': value ? 'done' : 'to-do',
                      });
                    }
                  },
                ),
                onLongPress: () async {
                  showModalBottomSheet(
                    context: context,
                    builder: (BuildContext context) {
                      return Container(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            ListTile(
                              leading: Icon(Icons.edit),
                              title: Text('Update Task'),
                              onTap: () async {
                                TextEditingController _controller =
                                    TextEditingController(text: doc['name']);
                                String updatedTaskName = await showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text('Update Task'),
                                      content: TextField(
                                        controller: _controller,
                                        autofocus: true,
                                        decoration: InputDecoration(
                                            labelText: 'New Task Name'),
                                      ),
                                      actions: <Widget>[
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context, null);
                                          },
                                          child: Text('Cancel',
                                              style:
                                                  TextStyle(color: Colors.red)),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            String updatedName =
                                                _controller.text;
                                            Navigator.pop(context, updatedName);
                                          },
                                          child: Text('Update',
                                              style: TextStyle(
                                                  color: Colors.green)),
                                        ),
                                      ],
                                    );
                                  },
                                );

                                if (updatedTaskName != null) {
                                  await FirebaseFirestore.instance
                                      .collection('tasks')
                                      .doc(doc.id)
                                      .update({
                                    'name': updatedTaskName,
                                  });
                                }
                              },
                            ),
                            ListTile(
                              leading: Icon(Icons.notifications),
                              title: Text('Set Notification'),
                              onTap: () {

                                Navigator.pop(
                                    context);
                              },
                            ),
                            ListTile(
                              leading: Icon(Icons.delete),
                              title: Text('Delete Task'),
                              onTap: () async {
                                // Delete the task from Firestore
                                await FirebaseFirestore.instance
                                    .collection('tasks')
                                    .doc(doc.id)
                                    .delete();
                                Navigator.pop(
                                    context);
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              );

              if (doc['status'] == 'done') {
                completedTasks.add(taskTile);
              } else {
                ongoingTasks.add(taskTile);
              }
            });

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.all(1),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.transparent,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Completed Tasks',
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red),
                            ),
                            SizedBox(
                                height:
                                    8),
                            Text(
                              '${completedTasks.length}',
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 20),
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.all(1),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.transparent,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Ongoing Tasks',
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue),
                            ),
                            SizedBox(
                                height:
                                    8),
                            Text(
                              '${ongoingTasks.length}',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(
                    'Ongoing Tasks:',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.blue),
                  ),
                ),
                Expanded(
                  child: ListView(
                    children: ongoingTasks,
                  ),
                ),
                SizedBox(height: 16),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(
                    'Completed Tasks:',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.green),
                  ),
                ),
                Expanded(
                  child: ListView(
                    children: completedTasks,
                  ),
                ),
              ],
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          TextEditingController _controller = TextEditingController();
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Add Task'),
                content: TextField(
                  controller: _controller,
                  autofocus: true,
                  decoration: InputDecoration(labelText: 'Task Name'),
                ),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('Cancel', style: TextStyle(color: Colors.red)),
                  ),
                  TextButton(
                    onPressed: () async {
                      String taskName = _controller.text;
                      if (taskName.isNotEmpty) {
                        await FirebaseFirestore.instance
                            .collection('tasks')
                            .add({
                          'name': taskName,
                          'status': 'to-do',
                          'created_at': FieldValue
                              .serverTimestamp(),
                        });
                        Navigator.pop(context);
                      }
                    },
                    child: Text('OK', style: TextStyle(color: Colors.green)),
                  ),
                ],
              );
            },
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
