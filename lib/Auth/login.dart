import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:personal_safety/Auth/Confirm_newEmail.dart';
import 'package:personal_safety/Auth/forget_password.dart';
import 'package:personal_safety/Auth/logout.dart';
import 'package:personal_safety/Auth/signupSuccessful.dart';
import 'package:personal_safety/componants/color.dart';
import 'package:personal_safety/componants/constant.dart';
import 'package:personal_safety/componants/mediaQuery.dart';
import 'package:personal_safety/componants/test.dart';
import 'package:personal_safety/models/login.dart';
import 'package:personal_safety/others/StaticVariables.dart';
import 'package:personal_safety/screens/main_page.dart';
import 'package:personal_safety/services/service_login.dart';
import 'package:get_it/get_it.dart';
import 'dart:developer';

import 'package:shared_preferences/shared_preferences.dart';

const key = 'token';
String value = '0';
Future<bool> saveTokenPreference(String token) async {
  final prefs = await SharedPreferences.getInstance();
  final value = token;
  prefs.setString(key, value);
}

getTokenPreference() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String token = prefs.getString(key);
  return token;
}

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  void saveToken(String resultToken) {
    saveTokenPreference(resultToken);
  }

  LoginService get userService => GetIt.instance<LoginService>();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool emailFlag = false;
  bool passwordFlag = false;
  bool _validate = false;
  bool passwordVisible = false;
  String errorMessages;
  LoginCredentials login;
  TextEditingController _loginController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  emailValidation() {
    if (_loginController.text.isEmpty) {
      emailFlag = false;
    } else
      emailFlag = true;
  }

  passwordValidation() {
    if (_passwordController.text.isEmpty) {
      passwordFlag = false;
    } else
      passwordFlag = true;
  }

  @override
  void initState() {
    _isLoading = false;
    super.initState();
  }

  ShowDialog(String title, String text) {
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              backgroundColor: primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
              title: Text(
                title,
                style: TextStyle(color: grey),
              ),
              content: Text(text, style: TextStyle(color: grey)),
              actions: <Widget>[
                FlatButton(
                    child: Text('OK', style: TextStyle(color: grey)),
                    onPressed: () {
                      setState(() {
                        _isLoading = false;
                      });
                      Navigator.of(context).pop();
                    })
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: primaryColor,
        resizeToAvoidBottomInset: true,
        body: GestureDetector(
          onTap: () => FocusScope.of(context).requestFocus(new FocusNode()),
          child: Center(
            child: Builder(builder: (_) {
              if (_isLoading) {
                return Center(
                    child: CustomLoadingIndicator(
                  customColor: grey,
                ));
              }
              return SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Column(children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 50),
                    child: Container(
                      height: displaySize(context).height * .4,
                      width: displaySize(context).width * .8,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30),
                          bottomLeft: Radius.circular(30),
                          topRight: Radius.circular(30),
                          bottomRight: Radius.circular(30),
                        ),
                      ),
                      child: SvgPicture.asset(
                        'assets/images/location.svg',
                        height: 250.0,
                        width: 50.0,
                      ),
                    ),
                  ),
                  Form(key: _formKey, child: LoginForm()),
                  Padding(
                    padding: const EdgeInsets.only(
                        top: 20, left: 70.0, bottom: 10, right: 70),
                    child: Container(
                      height: 50.0,
                      width: 300,
                      child: RaisedButton(
                        color: Accent1,
                        shape: RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(30),
                        ),
                        onPressed: () async {
                          emailValidation();
                          passwordValidation();
                          if (emailFlag == true && passwordFlag == true) {
                            setState(() async {
                              setState(() {
                                _isLoading = true;
                              });

                              print("TOKEN IS SET! TOKEN IS SET!");

                              final login = LoginCredentials(
                                email: _loginController.text,
                                password: _passwordController.text,
                              );
                              final result = await userService.Login(login);
                              debugPrint(
                                  "from login: " + result.status.toString());
                              debugPrint(
                                  "from login: " + result.result.toString());
                              debugPrint(
                                  "from login: " + result.hasErrors.toString());
                              final title =
                                  result.status == 0 ? 'Logged In!' : 'Error';
                              final text = result.status == 0
                                  ? 'You will be forwarded to the next page!'
                                  : "Wrong Username or Password.\n\nIf you haven't confirmed your email address, please check your inbox for a Confirmation email.";

                              if (result.status == 0) {
                                SharedPreferences prefs =
                                    await SharedPreferences.getInstance();
                                prefs.setString(
                                    'emailForQRCode', _loginController.text);
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => StaticVariables
                                                .prefs
                                                .getBool("firstlogin")
                                            ? SignUpSuccessful()
                                            : MainPage()));
                              } else {
                                showDialog(
                                    context: context,
                                    builder: (_) => AlertDialog(
                                          backgroundColor: primaryColor,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(20.0),
                                          ),
                                          title: Text(
                                            title,
                                            style: TextStyle(color: grey),
                                          ),
                                          content: Text(text,
                                              style: TextStyle(color: grey)),
                                          actions: <Widget>[
                                            FlatButton(
                                                child: Text('OK',
                                                    style:
                                                        TextStyle(color: grey)),
                                                onPressed: () {
                                                  setState(() {
                                                    _isLoading = false;
                                                  });
                                                  Navigator.of(context).pop();
                                                })
                                          ],
                                        ));
                              }
                            });
                          } else {
                            ShowDialog(
                                "Error", "Email and Password cannot be empty.");
                          }
                        },
                        child: Center(
                          child: Text(
                            'Login',
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ]),
              );
            }),
          ),
        ));
  }

  LoginForm() {
    return Stack(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(top: 20, left: 20),
          child: Text(
            "Login",
            style: TextStyle(color: Colors.white, fontSize: 50),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: 85.0, left: 20.0, right: 20.0),
          child: Container(
            height: displaySize(context).height * .07,
            decoration: kBoxDecorationStyle,
            child: TextField(
              keyboardType: TextInputType.emailAddress,
              style: new TextStyle(color: Colors.black),
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.all(20),
                hintText: "Email",
                errorText: _validate ? 'Value Can\'t Be Empty' : null,
                errorBorder: InputBorder.none,
                border: InputBorder.none,
              ),
              controller: _loginController,
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: 155.0, left: 20.0, right: 20.0),
          child: Container(
            height: displaySize(context).height * .07,
            decoration: kBoxDecorationStyle,
            child: TextField(
              controller: _passwordController,
              style: new TextStyle(color: Colors.black),
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.all(20),
                hintText: "Password",
                errorText: _validate ? 'Value Can\'t Be Empty' : null,
                prefixIcon: Icon(Icons.lock),
                suffixIcon: IconButton(
                  icon: Icon(
                    // Based on passwordVisible state choose the icon
                    passwordVisible ? Icons.visibility_off : Icons.visibility,
                    color: Theme.of(context).primaryColorDark,
                  ),
                  onPressed: () {
                    // Update the state i.e. toogle the state of passwordVisible variable
                    setState(() {
                      passwordVisible = !passwordVisible;
                    });
                  },
                ),
                errorBorder: InputBorder.none,
                border: InputBorder.none,
              ),
              obscureText: passwordVisible,
            ),
          ),
        ),
        Row(
          children: <Widget>[
            Container(
              alignment: Alignment(.7, 0.0),
              padding: EdgeInsets.only(top: 220, left: 20.0),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ForgetPassword()));
                },
                child: Text(
                  'Forgot Password?',
                  style: TextStyle(
                      color: Accent1,
                      fontFamily: 'Roboto',
                      decoration: TextDecoration.underline),
                ),
              ),
            ),
            SizedBox(
              width: 65,
            ),
            Container(
              alignment: Alignment(.7, 0.0),
              padding: EdgeInsets.only(top: 220, left: 20.0),
              child: InkWell(
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => ConfirmEmail()));
                },
                child: Text(
                  "Resend Confirmation mail",
                  style: TextStyle(
                      color: Accent1,
                      fontFamily: 'Roboto',
                      decoration: TextDecoration.underline),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
