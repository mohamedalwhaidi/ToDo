import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'newToDo.dart';
import 'utilites.dart';

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
        onPressed: _pushToNewToDo,
      ),
      body: _content(context),
    );
  }

  Widget _content(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(20),
      child: StreamBuilder(
        stream:
        Firestore.instance.collection('todos').orderBy('done').snapshots(),
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

  void _pushToNewToDo() {
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

  bool _isDone(QuerySnapshot data, int position) {
    return data.documents[position]['done'];
  }

  Widget _drawScreen(BuildContext context, QuerySnapshot data) {
    return ListView.builder(
      itemCount: data.documents.length,
      itemBuilder: (BuildContext context, int position) {
        return Card(
          child: Dismissible(
            key: ValueKey(position),
            background: _backgroundOnSwipeListTile(),
            onDismissed: _deleteOnSwipeListTile(data, position),
            child: ListTile(
              title: Text(data.documents[position]['body'],
                  style: TextStyle(
                      decoration: _isDone(data, position)
                          ? TextDecoration.lineThrough
                          : TextDecoration.none)),
//              trailing: _deleteTrailing(data, position),
              leading: _leadingDone(data,position),
            ),
          ),
        );
      },
    );
  }

  Widget _leadingDone(QuerySnapshot data, int position) {
    return IconButton(
      icon: Icon(Icons.assignment_turned_in),
      color: (_isDone(data, position)) ? Colors.green : Colors.green.shade100,
      onPressed: () {
        if (_isDone(data, position)) {
          Firestore.instance
              .collection(collections['todos'])
              .document(data.documents[position].documentID)
              .updateData({'done': false});
        } else {
          Firestore.instance
              .collection(collections['todos'])
              .document(data.documents[position].documentID)
              .updateData({'done': true});
        }
      },
    );
  }

  Widget _deleteTrailing(QuerySnapshot data, int position) {
    return IconButton(
      icon: Icon(Icons.delete),
      color: Colors.red.shade300,
      onPressed: () {
        Firestore.instance
            .collection(collections['todos'])
            .document(data.documents[position].documentID)
            .delete();
      },
    );
  }

  Widget _backgroundOnSwipeListTile() {
    return Container(
      alignment: AlignmentDirectional.topEnd,
      color: Colors.red,
      child: Padding(
        padding: const EdgeInsets.only(top: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              'DELETE',
              style: TextStyle(
                  fontSize: 20, letterSpacing: 20, color: Colors.white),
            ),
            Icon(
              Icons.delete,
              color: Colors.white,
              size: 30,
            ),
          ],
        ),
      ),
    );
  }

  _deleteOnSwipeListTile(QuerySnapshot data, int position) {
    return (direction) {
      setState(() {
        Firestore.instance
            .collection(collections['todos'])
            .document(data.documents[position].documentID)
            .delete();
      });
    };
  }
}
