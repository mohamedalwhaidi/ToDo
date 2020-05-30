import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:todo/auth/login.dart';

import 'newToDo.dart';
import 'utilities.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _user;
  String _error;
  bool _hasError = false;
  bool _isLoading = true;
  String _name;

  @override
  void initState() {
    super.initState();
    _prepareData().then((user){
      //TODO: if user from prepare data not equal null bring second data and give it user
      if( user != null){
      _secondStepData(user);
      }
    });
  }

  Future<FirebaseUser> _prepareData() async {
    FirebaseAuth.instance.currentUser().then((user) {
      Firestore.instance
          .collection('profiles')
          .where('user_id', isEqualTo: user.uid)
          .getDocuments()
          .then((snapshotQuery) {
        setState(() {
          _name = snapshotQuery.documents[0]['name'];
          _user = user.uid;
          _hasError = false;
          _isLoading = false;
        });
        return user;
      });
    }).catchError((error) {
      setState(() {
        _hasError = true;
        _error = error.toString();
      });
      return null;
    });
    return null;
  }

  void _secondStepData(FirebaseUser user) {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isLoading
            ? Text('Home')
            : (_hasError ? _errorMessage(context, _error) : Text(_name)),
        centerTitle: true,
      ),
      drawer: _drawer(context),
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
      child: _isLoading
          ? _loading(context)
          : (_hasError
              ? _errorMessage(context, _error)
              : _streamContent(context)),
    );
  }

  Widget _streamContent(BuildContext context) {
    return StreamBuilder(
      stream: Firestore.instance
          .collection(collections['todos'])
          .where('user_id', isEqualTo: _user)
          .orderBy('done')
          .snapshots(),
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
    );
  }

  Widget _loading(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(),
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
              leading: _leadingDone(data, position),
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

  /*Widget _deleteTrailing(QuerySnapshot data, int position) {
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
  }*/

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

  Widget _drawer(BuildContext context) {
    return Drawer(
      child: ListView(
        children: <Widget>[
          DrawerHeader(child: null),
          ListTile(
            title: Text('LOGOUT'),
            trailing: Icon(Icons.exit_to_app),
            onTap: () async {
              FirebaseAuth.instance.signOut().then((_) {
                Navigator.of(context).pop();
                Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => LoginScreen()));
              });
            },
          )
        ],
      ),
    );
  }
}
