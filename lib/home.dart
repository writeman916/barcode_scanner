import 'dart:async';

import 'package:barcode_scanner/database/products_database.dart';
import 'package:barcode_scanner/model/product.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:intl/intl.dart';
import 'package:rflutter_alert/rflutter_alert.dart';


class Home extends StatefulWidget{

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  late List<Product> products = [
    Product(code: '012334968', productName: 'productName', productPrice: 9000, createdTime: getCurrentDate())
  ];

  TextEditingController nameController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController noteController = TextEditingController();

  createAlertDialog4Edit(BuildContext context, Product? product){
      return _editProductCase(context, product!);
  }

  createAlertDialog4New(BuildContext context, String code){
    return _newProductCase(context, code);
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
    //createAlertDialog(context, barcodeScanRes);
  }

  returnString2Text() async {
    String barResult = '111111';
    Product? result =  await ProductDatabase.instance.readProduct(barResult);
    if(result == null) {
      createAlertDialog4New(context, barResult);
    }else{
      createAlertDialog4Edit(context, result);
    }


     // ProductDatabase.instance.create(
     //   Product(code:'111111', productName: 'Pepsi', note: '12314', productPrice: 10000,createdTime: getCurrentDate())
     // );
    refreshProducts();
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
            backgroundColor: Colors.white,
            floatingActionButton: FloatingActionButton(
              backgroundColor: Colors.lightGreen[700],
              // onPressed: () => scanBarcodeNormal(),
              onPressed: () => returnString2Text(),
              child: const Icon(
                Icons.qr_code,
                color: Colors.white,
              ),
            ),
            floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
            appBar: AppBar(
                title: const Text('Barcode scan'),
              backgroundColor: Colors.lightGreen[700],
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
          color: Colors.lightGreen[300],
          child: ListTile(
            onTap: () {
            },
            title: Text(products[index].productName.toString() + products[index].productPrice.toString()),
          ),
        ),
      );
    },
  );

  _newProductCase(context, String scannedCode) {
    Alert(
        style: AlertStyle(
            backgroundColor: Colors.white,
            titleStyle: TextStyle(color: Colors.lightGreen[700])
        ) ,
        context: context,
        title: "$scannedCode",
        content: Column(
          children: <Widget>[
            TextField(
              cursorColor: Colors.lightGreen[700],
              decoration: InputDecoration(
                  labelStyle: TextStyle(
                    color: Colors.lightGreen[700],
                  ),
                  labelText: 'Product Name',
                  focusedBorder:  UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.lightGreen),
                  )
              ),
              controller: nameController,
            ),
            TextField(
              cursorColor: Colors.lightGreen[700],
              decoration: InputDecoration(
                  labelStyle: TextStyle(
                    color: Colors.lightGreen[700],
                  ),
                  labelText: 'Price',
                  focusedBorder:  UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.lightGreen),
                  )
              ),
              controller: priceController,
            ),
            TextField(
              cursorColor: Colors.lightGreen[700],
              decoration: InputDecoration(
                  labelStyle: TextStyle(
                    color: Colors.lightGreen[700],
                  ),
                  labelText: 'Note',
                  fillColor: Colors.white,
                  focusedBorder:  UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.lightGreen),
                  )
              ),
              controller: noteController,
            ),
          ],
        ),
        buttons: [
          DialogButton(
            color: Colors.lightGreen[700],
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Save",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          )
        ]).show();
  }

  _editProductCase(context, Product product) {
    String price = NumberFormat('#,##,000').format(product.productPrice);
    Alert(
        style: AlertStyle(
            backgroundColor: Colors.white,
            titleStyle: TextStyle(color: Colors.lightGreen[700])
        ) ,
        context: context,
        title: 'Code: ${product.code}',
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Align(
              alignment: Alignment.topLeft,
              child:
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${product.productName}',
                    style: TextStyle(
                      color: Colors.lightGreen[700],
                      fontWeight: FontWeight.bold,
                      fontSize: 30,
                    ),
                  ),
                  Text(
                    '$price VND',
                    style: TextStyle(
                      color: Colors.lightGreen[700],
                    ),
                  ),
                  Text(
                    'Notes: ${product.note}',
                    style: TextStyle(
                      color: Colors.lightGreen[700],
                    ),
                  ),
                ],
              ),


            ),
          ],
        ),
        buttons: [
          DialogButton(
            color: Colors.lightGreen[700],
            onPressed: () => Navigator.pop(context),
            child: Text(
              "OK",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          )
        ]).show();
  }
}