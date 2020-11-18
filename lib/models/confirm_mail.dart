import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class ConfirmMailCredentials {
  String email;

  ConfirmMailCredentials({@required this.email});

  Map<String, dynamic> toJson() {
    return {
      "email": email,
    };
  }
}
