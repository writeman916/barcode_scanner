import 'package:flutter/material.dart';
import 'package:barcode_scanner/home.dart';

void main() => runApp(MaterialApp(
  debugShowCheckedModeBanner: false,
  initialRoute: '/',
  routes: {
    '/': (context) => Home(),
  },
));

