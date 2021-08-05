import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    ),
  );
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _ageController = TextEditingController();
  TextEditingController _rollNumberController = TextEditingController();
  Operation operationType = Operation.Add;
  int id = 1;
  String name = "";
  int age = 0, rollNumber = 0;
  String dataId = "";
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Flutter",
        ),
        centerTitle: true,
      ),
      body: StreamBuilder(
        stream: firestore.collection('users').snapshots(),
        builder: (context, AsyncSnapshot ss) {
          if (ss.hasData) {
            QuerySnapshot data = ss.data;

            return ListView.builder(
              itemCount: data.docs.length,
              itemBuilder: (context, i) {
                Map? m = data.docs[i].data() as Map?;

                return ListTile(
                  leading: Text("${i + 1}"),
                  title: Text("${m!['name']}"),
                  subtitle: Text("${m["age"]}"),
                  trailing: Wrap(
                    children: [
                      IconButton(
                        onPressed: () async {
                          setState(() {
                            operationType = Operation.Update;
                            dataId = data.docs[i].id;
                          });
                          _nameController.text = m['name'];
                          _ageController.text = m['age'].toString();
                          _rollNumberController.text =
                              m['rollNumber'].toString();
                          getForm();
                        },
                        icon: Icon(
                          Icons.edit,
                          color: Colors.blue,
                        ),
                      ),
                      IconButton(
                        onPressed: () async {
                          DocumentReference documentReferencer = firestore
                              .collection('users')
                              .doc(data.docs[i].id);

                          await documentReferencer
                              .delete()
                              .whenComplete(() =>
                                  print('Note item deleted from the database'))
                              .catchError((e) => print(e));
                        },
                        icon: Icon(
                          Icons.delete,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          }
          return Center(
            child: Text("No data found..."),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            operationType = Operation.Add;
          });
          getForm();
        },
        child: Icon(Icons.add),
      ),
    );
  }

  getForm() {
    showDialog(
      context: context,
      builder: (context) {
        return SingleChildScrollView(
          child: AlertDialog(
            title: Text("Database"),
            content: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    autofocus: true,
                    controller: _nameController,
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.name,
                    validator: (val) {
                      if (val!.isEmpty) {
                        return "Enter Your Name First.......";
                      }
                      return null;
                    },
                    onSaved: (val) {
                      setState(() {
                        name = val!;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: "Name",
                      hintText: "Enter Name",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: _ageController,
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.number,
                    validator: (val) {
                      if (val!.isEmpty) {
                        return "Enter Your Name First.......";
                      }
                      if (int.tryParse(val) == null) {
                        return "Please Enter Valid Age.......";
                      }
                      return null;
                    },
                    onSaved: (val) {
                      setState(() {
                        age = int.parse(val!);
                      });
                    },
                    decoration: InputDecoration(
                      labelText: "Age",
                      hintText: "Enter Age",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: _rollNumberController,
                    textInputAction: TextInputAction.done,
                    keyboardType: TextInputType.number,
                    validator: (val) {
                      if (val!.isEmpty) {
                        return "Enter Your Name First.......";
                      }
                      if (int.tryParse(val) == null) {
                        return "Please Enter Valid Age.......";
                      }
                      return null;
                    },
                    onSaved: (val) {
                      setState(() {
                        rollNumber = int.parse(val!);
                      });
                    },
                    decoration: InputDecoration(
                      labelText: "Roll Number",
                      hintText: "Enter RollNumber",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 10),
                ],
              ),
            ),
            actions: [
              OutlinedButton(
                onPressed: () {
                  _rollNumberController.clear();
                  _nameController.clear();
                  _ageController.clear();
                  Navigator.of(context).pop();
                },
                child: Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (operationType == Operation.Add) {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      DocumentReference documentReferencer =
                          firestore.collection('users').doc();

                      Map<String, dynamic> data = <String, dynamic>{
                        "name": name,
                        "age": age,
                        "rollNumber": rollNumber,
                      };

                      await documentReferencer
                          .set(data)
                          .whenComplete(
                              () => print("Notes item added to the database"))
                          .catchError((e) => print(e));
                    }
                  } else {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      DocumentReference documentReferencer =
                          firestore.collection('users').doc(dataId);

                      Map<String, dynamic> data = <String, dynamic>{
                        "name": name,
                        "age": age,
                        "rollNumber": rollNumber,
                      };

                      await documentReferencer
                          .update(data)
                          .whenComplete(
                              () => print("Note item updated in the database"))
                          .catchError((e) => print(e));
                    }
                  }

                  Navigator.of(context).pop();
                },
                child: Text("Submit"),
              ),
            ],
          ),
        );
      },
    );
  }
}

enum Operation {
  Add,
  Update,
}
