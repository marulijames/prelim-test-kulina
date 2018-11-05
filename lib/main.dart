import 'package:flutter/services.dart';
import './routes.dart';
import 'package:flutter/material.dart';

void main() =>
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
        .then((_) {
      runApp(new Routes());
    });
