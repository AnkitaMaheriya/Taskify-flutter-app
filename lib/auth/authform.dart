import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class AuthForm extends StatefulWidget {
  @override
  _AuthFormState createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  final _formKey = GlobalKey<FormState>();
  var _email = '';
  var _password = '';
  var _username = '';
  bool isLoginPage = false;
  String? _errorText;
  bool isLoading = false;

  startAuthentication() {
    final formState = _formKey.currentState;

    if (formState != null) {
      final validity = formState.validate();
      FocusScope.of(context).unfocus();

      if (validity) {
        formState.save();

        // Start loading
        setState(() {
          isLoading = true;
          _errorText = null;
        });

        submitForm(_email, _password, _username);
      }
    }
  }

  submitForm(String email, String password, String username) async {
    final auth = FirebaseAuth.instance;
    try {
      UserCredential authResult;

      if (isLoginPage) {
        authResult = await auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
      } else {
        try {
          authResult = await auth.createUserWithEmailAndPassword(
            email: email,
            password: password,
          );
          String? uid = authResult.user?.uid;
          await FirebaseFirestore.instance.collection('users').doc(uid).set({
            'username': username,
            'email': email,
          });
        } catch (e) {
          setState(() {
            _errorText = e.toString().split("]")[1].trim();
          });
          isLoading = false; // Stop loading
          return;
        }
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorText = 'Invalid Email or Password!';
      });
    } catch (e) {
      print(e);
    } finally {
      // Stop loading in any case
      isLoading = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade800, // Use a dark gray background
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/todo.png', height: 160),
                SizedBox( height: 20,),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      if (!isLoginPage)
                        TextFormField(
                          keyboardType: TextInputType.emailAddress,
                          key: ValueKey('username'),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Username is required';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _username = value!;
                          },
                          style: TextStyle(color: Colors.white), // Text color
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20.0), // Stylish border radius
                              borderSide: BorderSide(),
                            ),
                            labelText: "Enter Username",
                            labelStyle: GoogleFonts.roboto(
                              color: Colors.white, // Label text color
                            ),
                          ),
                        ),
                      SizedBox(height: 10),
                      TextFormField(
                        keyboardType: TextInputType.emailAddress,
                        key: ValueKey('email'),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Email is required';
                          } else if (!value.contains('@') || !value.contains('.')) {
                            return 'Please enter a valid email address';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _email = value!;
                        },
                        style: TextStyle(color: Colors.white), // Text color
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20.0), // Stylish border radius
                            borderSide: BorderSide(),
                          ),
                          labelText: "Enter Email",
                          labelStyle: GoogleFonts.roboto(
                            color: Colors.white, // Label text color
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      TextFormField(
                        obscureText: true,
                        key: ValueKey('password'),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Password is required';
                          } else if (value.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _password = value!;
                        },
                        style: TextStyle(color: Colors.white), // Text color
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20.0), // Stylish border radius
                            borderSide: BorderSide(),
                          ),
                          labelText: "Enter Password",
                          labelStyle: GoogleFonts.roboto(
                            color: Colors.white, // Label text color
                          ),
                        ),
                      ),
                      if (_errorText != null)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Text(
                            _errorText!,
                            style: TextStyle(
                              color: Colors.red,
                            ),
                          ),
                        ),
                      SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        height: 60,
                        child: ElevatedButton(
                          child: isLoginPage
                              ? Text('Login', style: TextStyle(fontSize: 16))
                              : Text('SignUp', style: TextStyle(fontSize: 16)),
                          style: ButtonStyle(
                            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.0), // Stylish border radius
                              ),
                            ),
                            backgroundColor: MaterialStateProperty.all<Color>(
                              Colors.blueAccent,
                            ),
                          ),
                          onPressed: () {
                            setState(() {
                              _errorText = null; // Reset error text before login
                            });
                            startAuthentication();
                          },
                        ),
                      ),
                      SizedBox(height: 10),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            isLoginPage = !isLoginPage;
                            _errorText = null; // Reset error text when switching forms
                          });
                        },
                        child: isLoginPage
                            ? Text('Not a member?', style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ))
                            : Text('Already a Member?', style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        )),
                      ),
                    ],
                  ),
                ),
                if (isLoading)
                  Center(
                    child: CircularProgressIndicator(),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
