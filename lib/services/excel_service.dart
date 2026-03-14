import 'dart:io';
import 'package:excel/excel.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import '../models/product.dart';
import '../models/inventory_item.dart';

class ExcelService {
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

      int? codeIdx, desIdx, barIdx;
      var header = rows.first;
      for (int i = 0; i < header.length; i++) {
        var val = header[i]?.value.toString().toLowerCase() ?? '';
        if (val.contains('code') && !val.contains('bar')) codeIdx = i;
        if (val.contains('designation') || val.contains('nom') || val.contains('produit')) desIdx = i;
        if (val.contains('barcode') || val.contains('barre')) barIdx = i;
      }

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
    
    Sheet sheet1 = excel['Historique'];
    sheet1.appendRow([
      TextCellValue('Code'), 
      TextCellValue('Designation'), 
      TextCellValue('Barcode'), 
      TextCellValue('Quantite'), 
      TextCellValue('Date')
    ]);

    for (var item in data['history'] as List<InventoryItem>) {
      sheet1.appendRow([
        TextCellValue(item.productCode),
        TextCellValue(item.designation),
        TextCellValue(item.barcode),
        IntCellValue(item.quantity.toInt()), // Correction: Conversion forcée en int
        TextCellValue(item.date.toIso8601String())
      ]);
    }

    Sheet sheet2 = excel['Totaux'];
    sheet2.appendRow([
      TextCellValue('Code'), 
      TextCellValue('Designation'), 
      TextCellValue('Barcode'), 
      TextCellValue('Quantite Totale')
    ]);

    for (var row in data['totals'] as List<Map<String, dynamic>>) {
      sheet2.appendRow([
        TextCellValue(row['product_code']?.toString() ?? ''),
        TextCellValue(row['designation']?.toString() ?? ''),
        TextCellValue(row['barcode']?.toString() ?? ''),
        IntCellValue(int.tryParse(row['total_quantity'].toString()) ?? 0)
      ]);
    }

    if (excel.tables.containsKey('Sheet1')) excel.delete('Sheet1');

    var fileBytes = excel.save();
    var directory = await getTemporaryDirectory();
    String fileName = "${data['name']}_export.xlsx";
    File file = File("${directory.path}/$fileName");
    await file.writeAsBytes(fileBytes!);
    
    return file.path;
  }
}