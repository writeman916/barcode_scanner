import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

class Home extends StatefulWidget{

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String _scanBarcode = 'Unknown';

  createAlertDialog(BuildContext context, scanResult){
    TextEditingController customController = TextEditingController();

    return showDialog(context: context, builder: (context){
      return AlertDialog(
        title: Text(
            'Barcode: $scanResult',
            style: TextStyle(
              color: Colors.grey[100],
              fontSize: 15,
            ),
        ),
        backgroundColor: Colors.grey,
        content: TextField(
          controller: customController,
        ),
        actions: <Widget>[
          MaterialButton(

            elevation: 5.0,
            child: Text('Submit'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          )
        ],
      );
    });
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> scanBarcodeNormal() async {
    String barcodeScanRes;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'Cancel', true, ScanMode.BARCODE);
      print(barcodeScanRes);
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;
    createAlertDialog(context, barcodeScanRes);
    setState(() {
      _scanBarcode = barcodeScanRes;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
            backgroundColor: Colors.grey[900],
            floatingActionButton: FloatingActionButton(
              backgroundColor: Colors.amberAccent[700],
              onPressed: () => scanBarcodeNormal(),
              child: const Icon(
                Icons.qr_code,
                color: Colors.black,
              ),
            ),
            floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
            appBar: AppBar(
                title: const Text('Barcode scan'),
              backgroundColor: Colors.black,
            ),
            body: Builder(builder: (BuildContext context) {
              return Container(
                  alignment: Alignment.center,
                  child: Flex(
                      direction: Axis.vertical,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text('Scan result : $_scanBarcode\n',
                            style: TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                            )
                        )
                      ]
                  )
              );
            })));
  }
}