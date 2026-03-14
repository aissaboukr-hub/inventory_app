import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/product.dart';
import '../models/inventory.dart';
import '../models/inventory_item.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'inventory.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // Table des produits (référentiel)
        await db.execute('''
          CREATE TABLE products (
            code TEXT PRIMARY KEY,
            designation TEXT,
            barcode TEXT
          )
        ''');
        await db.execute('CREATE INDEX idx_products_barcode ON products(barcode)');

        // Table des inventaires (en-têtes)
        await db.execute('''
          CREATE TABLE inventories (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            date TEXT
          )
        ''');

        // Table des lignes d'inventaire
        await db.execute('''
          CREATE TABLE inventory_items (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            inventory_id INTEGER,
            product_code TEXT,
            designation TEXT,
            barcode TEXT,
            quantity REAL,
            date TEXT,
            FOREIGN KEY (inventory_id) REFERENCES inventories (id) ON DELETE CASCADE
          )
        ''');
        await db.execute('CREATE INDEX idx_items_barcode ON inventory_items(barcode)');
        await db.execute('CREATE INDEX idx_items_inv_id ON inventory_items(inventory_id)');
      },
    );
  }

  // Insertion en masse des produits avec transactions
  Future<void> insertProductsBatch(List<Product> products) async {
    final db = await database;
    await db.transaction((txn) async {
      final batch = txn.batch();
      for (var product in products) {
        batch.insert(
          'products',
          product.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      await batch.commit(noResult: true);
    });
  }

  // Recherche rapide d'un produit
  Future<Product?> getProductByBarcode(String barcode) async {
    final db = await database;
    final results = await db.query(
      'products',
      where: 'barcode = ?',
      whereArgs: [barcode],
      limit: 1,
    );
    if (results.isEmpty) return null;
    return Product.fromMap(results.first);
  }

  Future<List<Product>> searchProducts(String query) async {
    final db = await database;
    final results = await db.query(
      'products',
      where: 'code LIKE ? OR designation LIKE ? OR barcode LIKE ?',
      whereArgs: ['%$query%', '%$query%', '%$query%'],
      limit: 50,
    );
    return results.map((e) => Product.fromMap(e)).toList();
  }

  // Gestion des inventaires
  Future<int> createInventory(Inventory inventory) async {
    final db = await database;
    return await db.insert('inventories', inventory.toMap());
  }

  Future<List<Inventory>> getInventories() async {
    final db = await database;
    final results = await db.query('inventories', orderBy: 'date DESC');
    return results.map((e) => Inventory.fromMap(e)).toList();
  }

  Future<void> insertInventoryItem(InventoryItem item) async {
    final db = await database;
    await db.insert('inventory_items', item.toMap());
  }

  Future<List<InventoryItem>> getItemsForInventory(int inventoryId) async {
    final db = await database;
    final results = await db.query(
      'inventory_items',
      where: 'inventory_id = ?',
      whereArgs: [inventoryId],
      orderBy: 'date DESC',
    );
    return results.map((e) => InventoryItem.fromMap(e)).toList();
  }

  // Pour les totaux par produit
  Future<List<Map<String, dynamic>>> getTotalsForInventory(int inventoryId) async {
    final db = await database;
    return await db.rawQuery('''
      SELECT product_code, designation, barcode, SUM(quantity) as total_quantity
      FROM inventory_items
      WHERE inventory_id = ?
      GROUP BY product_code
    ''', [inventoryId]);
  }
}
