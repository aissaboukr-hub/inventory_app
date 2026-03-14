import 'package:flutter/material.dart';
import '../services/excel_service.dart';
import '../services/google_sheets_service.dart';
import '../database/database_service.dart';
import '../models/product.dart';

class ImportExportViewModel extends ChangeNotifier {
  final DatabaseService _db = DatabaseService();
  bool isProcessing = false;
  String statusMessage = "";

  Future<void> importExcel(String filePath) async {
    isProcessing = true;
    statusMessage = "Lecture du fichier Excel...";
    notifyListeners();

    try {
      List<Product> products = await ExcelService.importProducts(filePath);
      statusMessage = "Importation de ${products.length} produits en cours...";
      notifyListeners();

      await _db.insertProductsBatch(products);
      statusMessage = "Importation réussie : ${products.length} produits.";
    } catch (e) {
      statusMessage = "Erreur d'importation : $e";
    } finally {
      isProcessing = false;
      notifyListeners();
    }
  }

  Future<void> importFromSheets(String url) async {
    isProcessing = true;
    statusMessage = "Connexion à Google Sheets...";
    notifyListeners();

    try {
      final sheetsService = GoogleSheetsService(url);
      List<Product> products = await sheetsService.importProducts();
      statusMessage = "Importation de ${products.length} produits en cours...";
      notifyListeners();

      await _db.insertProductsBatch(products);
      statusMessage = "Importation Sheets réussie : ${products.length} produits.";
    } catch (e) {
      statusMessage = "Erreur Google Sheets : $e";
    } finally {
      isProcessing = false;
      notifyListeners();
    }
  }

  Future<void> exportInventory({
    required String inventoryName,
    required dynamic history,
    required dynamic totals,
  }) async {
    isProcessing = true;
    statusMessage = "Génération du fichier Excel...";
    notifyListeners();

    try {
      String path = await ExcelService.exportInventory(
        inventoryName: inventoryName,
        history: history,
        totals: totals,
      );
      statusMessage = "Exportation terminée : $path";
    } catch (e) {
      statusMessage = "Erreur d'exportation : $e";
    } finally {
      isProcessing = false;
      notifyListeners();
    }
  }
}
