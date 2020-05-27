import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NewToDo extends StatefulWidget {
  @override
  _NewToDoState createState() => _NewToDoState();
}

class _NewToDoState extends State<NewToDo> {
  TextEditingController _todoController = TextEditingController();
  var _key = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _autoValidation = false;

  @override
  void dispose() {
    _todoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('New ToDo'),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.save),
        onPressed: _saveToDo,
      ),
      body: _isLoading ? _loading(context) : _todo(context),
    );
  }

  Widget _todo(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(30),
      child: Form(
        autovalidate: _autoValidation,
        key: _key,
        child: SingleChildScrollView(
          child: TextFormField(
            controller: _todoController,
            decoration: InputDecoration(hintText: 'Todo...'),
            validator: (value) {
              if (value.isEmpty) {
                return 'Todo is required';
              }
              return null;
            },
          ),
        ),
      ),
    );
  }

  Widget _loading(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  void _saveToDo() async {
    if (!_key.currentState.validate()) {
      setState(() {
        _autoValidation = true;
      });
    } else {
      setState(() {
        _isLoading = true;
      });
    }

    FirebaseAuth.instance.currentUser().then((user) {
      Firestore.instance.collection('todos').document().setData({
        'body': _todoController.text.trim(),
        'done': false,
        'user_id': user.uid,
      }).then((_) => Navigator.of(context).pop());
    });
  }
}
