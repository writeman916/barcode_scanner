import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:barcode_scanner/model/product.dart';

class ProductDatabase {
  static final ProductDatabase instance = ProductDatabase._init();

  static Database? _database;

  ProductDatabase._init();

  Future<Database> get database async {
    if(_database != null) return _database!;

    _database = await _initDB('products.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 2, onCreate: _createDB, );
  }

  Future _createDB(Database db, int version) async {
    final idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    final textType = 'TEXT NOT NULL';
    final integerType = 'INTEGER NOT NULL';

    await db.execute('''
    CREATE TABLE $tableProducts (
    ${ProductFields.id} $idType,
    ${ProductFields.code} $textType,
    ${ProductFields.productName} $textType,
    ${ProductFields.productPrice} $integerType,
    ${ProductFields.note} $textType,
    ${ProductFields.createdTime} $textType    
    )
    ''');
  }
  Future<Product> create(Product product) async {
    final db = await instance.database;

     final json = product.toJson();
     final columns =
         '${ProductFields.code}, ${ProductFields.productName}, ${ProductFields.productPrice}, ${ProductFields.note}, ${ProductFields.createdTime}';
     final values =
         "'${json[ProductFields.code]}', '${json[ProductFields.productName]}', ${json[ProductFields.productPrice]}, '${json[ProductFields.note]}', '${json[ProductFields.createdTime]}'";

     final id = await db.
     rawInsert('INSERT INTO $tableProducts ($columns) VALUES ($values)');

    //final id =  await db.insert(tableProducts, product.toJson());

    return product.copy(id: id);
  }

  Future<Product?> readProduct(String code) async {
    final db = await instance.database;

    final maps = await db.query(
      tableProducts,
      columns: ProductFields.values,
      where:  '${ProductFields.code} = ?',
      whereArgs: [code],
    );

    if(maps.isNotEmpty) {
      return Product.fromJson(maps.first);
    } else {
      return null;
    }
  }

  Future<int?> getIDbyCode(String code) async {
    final db = await instance.database;

    final maps = await db.query(
      tableProducts,
      columns: ProductFields.values,
      where:  '${ProductFields.code} = ?',
      whereArgs: [code],
    );

    if(maps.isNotEmpty) {
      return Product.fromJson(maps.first).id;
    } else {
      return null;
    }
  }

  Future<List<Product>> readAllProducts() async {
    final db = await instance.database;

    final orderBy = '${ProductFields.createdTime} ASC';
    final result = await db.query(tableProducts, orderBy: orderBy);

    return result.map((json) => Product.fromJson(json)).toList();
  }

  Future<int> update(Product product) async {
    final db = await instance.database;

    return db.update(
      tableProducts,
      product.toJson(),
      where:  '${ProductFields.code} = ?',
      whereArgs: [product.code],
    );
  }

  Future<int> delete(String code) async {
    final db = await instance.database;

    return db.delete(
      tableProducts,
      where:  '${ProductFields.code} = ?',
      whereArgs: [code],
    );
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }

}