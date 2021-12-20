import 'dart:async';

import 'package:barcode_scanner/database/products_database.dart';
import 'package:barcode_scanner/model/product.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:intl/intl.dart';


class Home extends StatefulWidget{

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String _scanBarcode = 'Unknown';

  bool isLoading = false;
  late List<Product> products = [
    Product(code: '012334968', productName: 'productName', productPrice: 9000, createdTime: getCurrentDate())
  ];

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

  returnString2Text() {
    createAlertDialog(context, 123456789);

    ProductDatabase.instance.create(
      Product(code:'123456789', productName: 'CocaCola', note: '12314', productPrice: 10000,createdTime: getCurrentDate())
    );
    refreshProducts();

    setState(() {
      _scanBarcode = '123456789';
    });
  }

  String getCurrentDate(){

    DateTime now = DateTime.now();
    String formattedDate = DateFormat('MM/dd/yyyy').format(now);

    return formattedDate;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    refreshProducts();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    ProductDatabase.instance.close();
    super.dispose();
  }

  Future refreshProducts() async {
    setState(() => isLoading = true);
    print(products.length);
    this.products = await ProductDatabase.instance.readAllProducts();
    print(products.length);
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
            backgroundColor: Colors.grey[900],
            floatingActionButton: FloatingActionButton(
              backgroundColor: Colors.amberAccent[700],
              // onPressed: () => scanBarcodeNormal(),
              onPressed: () => returnString2Text(),
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
            body: Center(
              child: isLoading
                  ? CircularProgressIndicator()
                  : products.isEmpty
                  ? Text(
                'No Notes',
                style: TextStyle(color: Colors.white, fontSize: 24),
              )
                  : buildProduct(),
            ),
        )
    );
  }

  Widget buildProduct() => ListView.builder(
    itemCount:  products.length,
    itemBuilder: (context, index){
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 1.0, horizontal: 4.0),
        child: Card(
          child: ListTile(
            onTap: () {
            },
            title: Text(products[index].productName.toString() + products[index].productPrice.toString()),
          ),
        ),
      );
    },
  );
}