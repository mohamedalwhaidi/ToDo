import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:todo/todo/homeScreen.dart';

import 'login.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _confirmPasswordController = TextEditingController();
  TextEditingController _nameController = TextEditingController();

  var _key = GlobalKey<FormState>();
  bool _autoValidation = false;
  bool _isLoading = false;
  String _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('REGISTER'),
        centerTitle: true,
      ),
      body: _isLoading ? _loading(context) : _form(context),
    );
  }

  Widget _form(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(36),
        child: Form(
          autovalidate: _autoValidation,
          key: _key,
          child: Column(
            children: <Widget>[
              TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(hintText: 'Your Name'),
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Name is required';
                    }
                    return null;
                  }),
              SizedBox(height: 20),
              TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(hintText: 'Your Email'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Email is required';
                    }
                    return null;
                  }),
              SizedBox(height: 20),
              TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(hintText: 'Password'),
                  keyboardType: TextInputType.visiblePassword,
                  obscureText: true,
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Password is required';
                    }
                    return null;
                  }),
              SizedBox(height: 20),
              TextFormField(
                  controller: _confirmPasswordController,
                  decoration: InputDecoration(hintText: 'Confirm Password'),
                  obscureText: true,
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Confirm password is required';
                    }
                    return null;
                  }),
              SizedBox(height: 20),
              Container(
                width: double.infinity,
                child: RaisedButton(
                  onPressed: _onRegisterClicked,
                  child: Text('Register'),
                ),
              ),
              SizedBox(height: 20),
              _errorMessage(context),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text('Have an account?'),
                  FlatButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) => LoginScreen()),
                      );
                    },
                    child: Text('Login'),
                  ),
                ],
              ),
            ],
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

  void _onRegisterClicked() async {
    if (!_key.currentState.validate()) {
      setState(() {
        _autoValidation = true;
      });
    } else {
      setState(() {
        _autoValidation = false;
        _isLoading = true;
      });
    }
    //TODO:Connect with firebase

    FirebaseAuth.instance
        .createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim())
        .then((authResult) {
      Firestore.instance.collection('profiles').document().setData({
        'name': _nameController.text.trim(),
        'user_id': authResult.user.uid,
      }).then((_) {
        Navigator.of(context)
            .pushReplacement(
            MaterialPageRoute(builder: (context) => HomeScreen()))
            .catchError((error) {
          setState(() {
            _isLoading = false;
            _error = "User registration error";
          });
        });
      });
    }).catchError((error) {
      setState(() {
        _isLoading = false;
        _error = "User registration error";
      });
    });
  }

  Widget _errorMessage(BuildContext context) {
    if (_error == null) {
      return Container();
    }
    return Text(
      _error,
      style: TextStyle(color: Colors.red),
    );
  }
}
