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

  Color headerColor = Color(0xFF141524);
  Color textColor = Colors.black54;
  Color deleteColor = Colors.grey;
  bool isLoading = false;
  bool isEnableDelete = false;
  late List<Product> products = [];

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
      _newProductCase(context, barcodeScanRes, true);
    }else{
      _existProductCase(context, result);
    }
  }

  returnString2Text() async {
    String barResult = '891234556786456';
    Product? result =  await ProductDatabase.instance.readProduct(barResult);
    if(result == null) {
      _newProductCase(context, barResult, true);
    }else{
      _existProductCase(context, result);
    }
    // ProductDatabase.instance.create(
    //     Product(code:'89123455678', productName: 'Tên qua dài giờ phải làm sao aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa', note: '12314', productPrice: 10000,createdTime: getCurrentDate())
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
              backgroundColor: headerColor,
              //onPressed: () => scanBarcodeNormal(),
              onPressed: () => returnString2Text(),
              child: const Icon(
                Icons.qr_code,
                color: Colors.white,
              ),
            ),
            floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
            appBar: AppBar(
              centerTitle: true,
              shadowColor: Colors.grey[700],
              title: const Text('Barcode scan', style: TextStyle(fontFamily: 'VNCOOP',color: Color(0xFF141524)),),
              backgroundColor: Colors.white,
              actions: [
                FlatButton(onPressed: () {
                  setState(() {
                    isEnableDelete = !isEnableDelete;
                    isEnableDelete ? deleteColor = Colors.black : deleteColor = Colors.grey;
                  });
                },
                    child: Icon(
                      Icons.delete_sweep_outlined,
                      size: 32,
                      color: deleteColor,)
                )
              ],
            ),
            body: Center(
              child: isLoading
                  ? CircularProgressIndicator(color: Colors.black54,)
                  : products.isEmpty
                  ? Text(
                'Empty',
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
      String price = NumberFormat('###,###,000').format(products[index].productPrice);
      return Container(
        decoration: BoxDecoration(
          boxShadow: [
            new BoxShadow(
              color: Colors.grey,
              blurRadius: 10.0,
              spreadRadius: -9.0,
              offset: Offset(
                1.0,
                1.0,
              )
            )
          ],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Stack(
          alignment: const Alignment(0.93,-1.3),
          children:[
            Card(
              margin: EdgeInsets.all(10.0),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: SizedBox(
                  width: 330,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FittedBox(
                        child:
                        Text(
                          '${products[index].productName}',
                          maxLines: 1,
                          style: TextStyle(
                            color: headerColor,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'segoesc',
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: 200,
                            child: Text(
                              '${products[index].note}',
                              maxLines: 2,
                              overflow: TextOverflow.clip,
                              style: TextStyle(
                                color: textColor,
                                fontSize: 12,
                                fontFamily: 'segoesc',
                              ),
                            ),
                          ),
                          Text(
                            '$price VNĐ',
                            style: TextStyle(
                              color: headerColor,
                              fontSize: 15,
                              fontFamily: 'segoesc',
                            ),
                          ),
                        ],
                      )
                    ],
                ),
              ),
            ),
          ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return ScaleTransition(scale: animation, child: child);
              },
              child: isEnableDelete ? IconButton(onPressed: (){_confirm2Delete(products[index].code);},
                  icon: new Icon(Icons.cancel, size: 30)) : Spacer(),
              ),
          ],
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
            titleStyle: TextStyle(color: headerColor,fontFamily: 'segoesc', fontSize: 25)
        ) ,
        context: context,
        title: "$scannedCode",
        content: Column(
          children: <Widget>[
            TextField(
              cursorColor: headerColor,
              style: TextStyle(color: headerColor),
              decoration: InputDecoration(
                  labelStyle: TextStyle(
                    color: textColor,
                      fontSize: 15,
                      fontFamily: 'segoesc'
                  ),
                  labelText: 'Product Name',
                  focusedBorder:  UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.black54),
                  )
              ),
              controller: nameController,
            ),
            TextField(
              cursorColor: headerColor,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              style: TextStyle(color: headerColor),
              decoration: InputDecoration(
                  labelStyle: TextStyle(
                    fontSize: 15,
                    color: textColor,
                      fontFamily: 'segoesc'
                  ),
                  labelText: 'Price',
                  focusedBorder:  UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.black54),
                  )
              ),
              controller: priceController,
            ),
            TextField(
              cursorColor: headerColor,
              style: TextStyle(color: headerColor),
              decoration: InputDecoration(
                  labelStyle: TextStyle(
                    fontSize: 15,
                    color: textColor,
                      fontFamily: 'segoesc'
                  ),
                  labelText: 'Note',
                  fillColor: Colors.white,
                  focusedBorder:  UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.black54),
                  )
              ),
              controller: noteController,
            ),
          ],
        ),
        buttons: [
          DialogButton(
            color: headerColor,
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
              style: TextStyle(color: Colors.white, fontSize: 20, fontFamily: 'segoesc'),
            ),
          )
        ]).show();
  }

  _existProductCase(context, Product product) {

    String price = NumberFormat('###,###,000').format(product.productPrice);
    Alert(
        style: AlertStyle(
            backgroundColor: Colors.white,
            titleStyle: TextStyle(color: headerColor, fontFamily: 'segoesc',fontWeight: FontWeight.bold, fontSize: 35,)
        ) ,
        context: context,
        title: '${product.code}',
        content: SizedBox(
          width: 300,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              FittedBox(
                child: Text(
                '${product.productName}',
                style: TextStyle(
                  color: headerColor,
                  fontSize: 30,
                  fontFamily: 'segoesc',
                  fontWeight: FontWeight.bold
                  ),
                ),
              ),
              Text(
                '$price VNĐ',
                style: TextStyle(
                    color: textColor,
                    fontSize: 17,
                    fontFamily: 'segoesc'
                ),
              ),
              Text(
                'note: ${product.note}',
                style: TextStyle(
                  color: textColor,
                  fontSize: 12,
                  fontFamily: 'segoesc'
                ),
              ),
            ],
          ),
        ),
        buttons: [
          DialogButton(
            child: Text(
              "OK",
              style: TextStyle(color: headerColor, fontSize: 18,fontFamily: 'segoesc'),
            ),
            onPressed: () => Navigator.pop(context),
            color: Colors.white,
            splashColor: Colors.grey,
          ),
          DialogButton(
            child: Text(
              "EDIT",
              style: TextStyle(color: headerColor, fontSize: 18,fontFamily: 'segoesc'),
            ),
            onPressed: () {
              _newProductCase(context, product.code, false);
            },
            color: Colors.white,
            splashColor: Colors.grey,
          )
        ]).show();
  }

  _confirm2Delete(String productCode) async {
    await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Do you want to Delete it?"),
          actions: <Widget>[
            FlatButton(
              child: Text("Yes"),
              onPressed: () {
                ProductDatabase.instance.delete(productCode);
                setState(() {
                  refreshProducts();
                });
                Navigator.pop(context, true);
              },
            ),
            FlatButton(
              child: Text("Cancel"),
              onPressed: () {
                Navigator.pop(context, true);
              },
            ),
          ],
        );
      },
    );
  }
}