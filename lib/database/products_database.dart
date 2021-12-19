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
    final integeType = 'INTEGER NOT NULL';

    await db.execute('''
    CREATE TABLE $tableProducts (
    ${ProductFields.id} $idType,
    ${ProductFields.code} $textType,
    ${ProductFields.productName} $textType,
    ${ProductFields.productPrice} $integeType,
    ${ProductFields.note} $textType,
    ${ProductFields.createdTime} $textType,    
    )
    ''');
  }
  Future<Product> create(Product product) async {
    final db = await instance.database;

    final json = product.toJson();
    final colums =
        '${ProductFields.code}, ${ProductFields.productName}, ${ProductFields.productPrice}, ${ProductFields.note}, ${ProductFields.createdTime}';
    final values =
        '${json[ProductFields.code]}, ${json[ProductFields.productName]}, ${json[ProductFields.productPrice]}, ${json[ProductFields.note]}, ${json[ProductFields.createdTime]}';

    final id = await db.
    rawInsert('INSERT INTO table_name ($colums) VALUES ($values)');

    //final id =  await db.insert(tableProducts, product.toJson());

    return product.copy(id: id);
  }
  Future close() async {
    final db = await instance.database;
    db.close();
  }

}