import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'newToDo.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Screen'),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: _newToDo,
      ),
      body: _content(context),
    );
  }

  Widget _content(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(20),
      child: StreamBuilder(
        stream: Firestore.instance.collection('todos').snapshots(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
              return _errorMessage(context, 'No connection is made');
              break;
            case ConnectionState.waiting:
              return Center(child: CircularProgressIndicator());
              break;
            case ConnectionState.active:
            case ConnectionState.done:
              if (snapshot.hasError) {
                return _errorMessage(context, snapshot.error.toString());
              } else if (!snapshot.hasData) {
                return _errorMessage(context, 'No Data');
              }
              return _drawScreen(context, snapshot.data);
              break;
          }
          return null;
        },
      ),
    );
  }

  void _newToDo() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => NewToDo()));
  }

  Widget _errorMessage(BuildContext context, String message) {
    return Center(
      child: Text(
        message,
        style: TextStyle(color: Colors.red),
      ),
    );
  }

  Widget _drawScreen(BuildContext context, QuerySnapshot data) {
    return ListView.builder(
      itemCount: data.documents.length,
      itemBuilder: (BuildContext context, int position) {
        return ListTile(
          title: Text(data.documents[position]['body']),
        );
      },
    );
  }
}
