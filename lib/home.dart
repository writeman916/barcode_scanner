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

  bool isLoading = false;
  late List<Product> products = [
    Product(code: '012334968', productName: 'productName', productPrice: 9000, createdTime: getCurrentDate())
  ];

  createAlertDialog4Edit(BuildContext context, Product? product){
      return _existProductCase(context, product!);
  }

  createAlertDialog4New(BuildContext context, String code){
    return _newProductCase(context, code, true);
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> scanBarcodeNormal() async {
    String barcodeScanRes;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'Cancel', true, ScanMode.BARCODE);

    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;
    Product? result =  await ProductDatabase.instance.readProduct(barcodeScanRes);
    if(result == null) {
      createAlertDialog4New(context, barcodeScanRes);
    }else{
      createAlertDialog4Edit(context, result);
    }
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
     //   Product(code:'111112', productName: 'Pepsi', note: '12314', productPrice: 10000,createdTime: getCurrentDate())
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
              //onPressed: () => scanBarcodeNormal(),
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
      String price = NumberFormat('#,##,000').format(products[index].productPrice);
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 1.0, horizontal: 5.0),
        child: Card(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
              gradient: LinearGradient(
                colors: [
                  Colors.lightGreen,
                  Colors.lightGreen.shade300,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${products[index].productName}: $price',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'notes: ${products[index].note}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                  Spacer(),
                  IconButton(
                    color: Colors.white,
                    onPressed: () {
                      ProductDatabase.instance.delete(products[index].code);
                      setState(() {
                        refreshProducts();
                      });
                    },
                    icon: const Icon(Icons.delete_outlined),
                    alignment: Alignment.center,
                  ),
                ],
              ),
            ),
          )
        ),
      );
    },
  );

  _newProductCase (context, String scannedCode, bool processMode) async {
    TextEditingController nameController = TextEditingController();
    TextEditingController priceController = TextEditingController();
    TextEditingController noteController = TextEditingController();

    if(!processMode){
      Product? curProduct =  await ProductDatabase.instance.readProduct(scannedCode);
      nameController.text = curProduct!.productName;
      priceController.text = curProduct.productPrice.toString();
      noteController.text = curProduct.note!;
    }

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
            onPressed: () async {
              if(!processMode){
                int? curID = await ProductDatabase.instance.getIDbyCode(scannedCode);
                ProductDatabase.instance.update(
                    Product(
                        id: curID,
                        code:'$scannedCode',
                        productName: nameController.text.toString(),
                        note: noteController.text.toString(),
                        productPrice: int.parse(priceController.text.toString()),
                        createdTime: getCurrentDate())
                );
              }else{
                ProductDatabase.instance.create(
                    Product(
                        code:'$scannedCode',
                        productName: nameController.text.toString(),
                        note: noteController.text.toString(),
                        productPrice: int.parse(priceController.text.toString()),
                        createdTime: getCurrentDate())
                );
              }
              Navigator.of(context).pushNamedAndRemoveUntil('/', ModalRoute.withName('/'));
              setState(() {
                refreshProducts();
                noteController.clear();
                nameController.clear();
                priceController.clear();
              });
            },
            child: Text(
              "Save",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          )
        ]).show();
  }

  _existProductCase(context, Product product) {

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
            Text(
            '${product.productName}: $price VND',
            style: TextStyle(
              color: Colors.lightGreen[700],
              fontSize: 25,
              ),
            ),
            Text(
              'note: ${product.note}',
              style: TextStyle(
                color: Colors.lightGreen[700],
                fontSize: 15,
              ),
            ),
          ],
        ),
        buttons: [
          DialogButton(
            child: Text(
              "OK",
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            onPressed: () => Navigator.pop(context),
            color: Color.fromRGBO(0, 179, 134, 1.0),
          ),
          DialogButton(
            child: Text(
              "EDIT",
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            onPressed: () {
              _newProductCase(context, product.code, false);
            },
            gradient: LinearGradient(colors: [
              Color.fromRGBO(0, 179, 134, 1.0),
              Color.fromRGBO(52, 138, 199, 1.0),
            ]),
          )
        ]).show();
  }
}