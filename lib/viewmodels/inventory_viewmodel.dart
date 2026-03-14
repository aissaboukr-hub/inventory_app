import 'package:flutter/material.dart';
import '../models/product.dart';
import '../models/inventory.dart';
import '../models/inventory_item.dart';
import '../database/database_service.dart';

class InventoryViewModel extends ChangeNotifier {
  final DatabaseService _db = DatabaseService();

  List<Inventory> inventories = [];
  List<InventoryItem> currentItems = [];
  Inventory? activeInventory;

  bool isLoading = false;

  Future<void> loadInventories() async {
    isLoading = true;
    notifyListeners();
    inventories = await _db.getInventories();
    isLoading = false;
    notifyListeners();
  }

  Future<void> createNewInventory(String name) async {
    final id = await _db.createInventory(Inventory(name: name, date: DateTime.now()));
    await loadInventories();
    activeInventory = inventories.firstWhere((e) => e.id == id);
    notifyListeners();
  }

  Future<void> selectInventory(Inventory inventory) async {
    activeInventory = inventory;
    await loadCurrentItems();
    notifyListeners();
  }

  Future<void> loadCurrentItems() async {
    if (activeInventory == null) return;
    currentItems = await _db.getItemsForInventory(activeInventory!.id!);
    notifyListeners();
  }

  Future<Product?> findProduct(String barcode) async {
    return await _db.getProductByBarcode(barcode);
  }

  Future<List<Product>> searchProducts(String query) async {
    return await _db.searchProducts(query);
  }

  Future<void> addItemToInventory({
    required Product product,
    required double quantity,
  }) async {
    if (activeInventory == null) return;
    
    final item = InventoryItem(
      inventoryId: activeInventory!.id!,
      productCode: product.code,
      designation: product.designation,
      barcode: product.barcode,
      quantity: quantity,
      date: DateTime.now(),
    );
    
    await _db.insertInventoryItem(item);
    await loadCurrentItems();
  }

  Future<List<Map<String, dynamic>>> getTotals() async {
    if (activeInventory == null) return [];
    return await _db.getTotalsForInventory(activeInventory!.id!);
  }
}
