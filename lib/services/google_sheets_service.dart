import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';
import '../models/inventory_item.dart';

class GoogleSheetsService {
  final String webAppUrl; // URL du script Google Apps Script publié en tant que Web App

  GoogleSheetsService(this.webAppUrl);

  // Importation des produits depuis Google Sheets
  Future<List<Product>> importProducts() async {
    final response = await http.get(Uri.parse('$webAppUrl?action=importProducts'));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((e) => Product.fromMap(e)).toList();
    } else {
      throw Exception('Erreur lors de l\'importation Google Sheets');
    }
  }

  // Exportation de l'inventaire vers Google Sheets
  Future<bool> exportInventory({
    required String inventoryName,
    required List<InventoryItem> history,
    required List<Map<String, dynamic>> totals,
  }) async {
    final payload = {
      'action': 'exportInventory',
      'inventoryName': inventoryName,
      'history': history.map((e) => e.toMap()).toList(),
      'totals': totals,
    };

    final response = await http.post(
      Uri.parse(webAppUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(payload),
    );

    return response.statusCode == 200;
  }
}
