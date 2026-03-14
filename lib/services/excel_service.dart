import 'dart:io';
import 'package:excel/excel.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/product.dart';
import '../models/inventory_item.dart';

class ExcelService {
  // Importation via Isolates (compute)
  static Future<List<Product>> importProducts(String filePath) async {
    return await compute(_parseExcelFile, filePath);
  }

  static List<Product> _parseExcelFile(String filePath) {
    var bytes = File(filePath).readAsBytesSync();
    var excel = Excel.decodeBytes(bytes);
    List<Product> products = [];

    for (var table in excel.tables.keys) {
      var rows = excel.tables[table]?.rows;
      if (rows == null || rows.isEmpty) continue;

      // Détection des colonnes
      int? codeIdx, desIdx, barIdx;
      var header = rows.first;
      for (int i = 0; i < header.length; i++) {
        var val = header[i]?.value.toString().toLowerCase() ?? '';
        if (val.contains('code') && !val.contains('bar')) codeIdx = i;
        if (val.contains('designation') || val.contains('nom') || val.contains('produit')) desIdx = i;
        if (val.contains('barcode') || val.contains('barre')) barIdx = i;
      }

      // Par défaut si non trouvé
      codeIdx ??= 0;
      desIdx ??= 1;
      barIdx ??= 2;

      for (int i = 1; i < rows.length; i++) {
        var row = rows[i];
        if (row.length <= (codeIdx > desIdx ? codeIdx : desIdx)) continue;
        
        var code = row[codeIdx]?.value.toString() ?? '';
        var designation = row[desIdx]?.value.toString() ?? '';
        var barcode = row[barIdx]?.value.toString() ?? '';

        if (code.isNotEmpty) {
          products.add(Product(
            code: code,
            designation: designation,
            barcode: barcode,
          ));
        }
      }
    }
    return products;
  }

  // Exportation vers Excel avec 2 feuilles
  static Future<String> exportInventory({
    required String inventoryName,
    required List<InventoryItem> history,
    required List<Map<String, dynamic>> totals,
  }) async {
    return await compute(_generateExcelFile, {
      'name': inventoryName,
      'history': history,
      'totals': totals,
    });
  }

  static Future<String> _generateExcelFile(Map<String, dynamic> data) async {
    var excel = Excel.createExcel();
    
    // Feuille 1 : Historique
    Sheet sheet1 = excel['Historique'];
    sheet1.appendRow(['Code', 'Designation', 'Barcode', 'Quantite', 'Date']);
    for (var item in data['history'] as List<InventoryItem>) {
      sheet1.appendRow([
        item.productCode,
        item.designation,
        item.barcode,
        item.quantity,
        item.date.toIso8601String()
      ]);
    }

    // Feuille 2 : Totaux
    Sheet sheet2 = excel['Totaux'];
    sheet2.appendRow(['Code', 'Designation', 'Barcode', 'Quantite Totale']);
    for (var row in data['totals'] as List<Map<String, dynamic>>) {
      sheet2.appendRow([
        row['product_code'],
        row['designation'],
        row['barcode'],
        row['total_quantity']
      ]);
    }

    // Supprimer la feuille par défaut "Sheet1"
    if (excel.tables.containsKey('Sheet1')) excel.delete('Sheet1');

    var fileBytes = excel.save();
    var directory = await getTemporaryDirectory();
    String fileName = "${data['name']}_export.xlsx";
    File file = File("${directory.path}/$fileName");
    await file.writeAsBytes(fileBytes!);
    
    return file.path;
  }
}
