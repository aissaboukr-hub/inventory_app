import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/inventory_viewmodel.dart';
import '../models/product.dart';
import 'scanner_screen.dart';

class InventoryDetailScreen extends StatefulWidget {
  const InventoryDetailScreen({super.key});

  @override
  State<InventoryDetailScreen> createState() => _InventoryDetailScreenState();
}

class _InventoryDetailScreenState extends State<InventoryDetailScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Consumer<InventoryViewModel>(
      builder: (context, vm, child) {
        if (vm.activeInventory == null) return const Scaffold(body: Center(child: Text('Aucun inventaire actif.')));

        return Scaffold(
          appBar: AppBar(
            title: Text(vm.activeInventory!.name),
            actions: [
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: () => _showExportDialog(context, vm),
              ),
            ],
          ),
          body: Column(
            children: [
              _buildSearchHeader(context, vm),
              Expanded(
                child: vm.currentItems.isEmpty
                    ? const Center(child: Text('Aucun article saisi. Scannez un produit !'))
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: vm.currentItems.length,
                        separatorBuilder: (_, __) => const Divider(),
                        itemBuilder: (context, index) {
                          final item = vm.currentItems[index];
                          return ListTile(
                            title: Text(item.designation, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text('Code: ${item.productCode} | Barcode: ${item.barcode}'),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: item.quantity >= 0 ? Colors.green.shade100 : Colors.red.shade100,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                item.quantity.toString(),
                                style: TextStyle(
                                  color: item.quantity >= 0 ? Colors.green.shade900 : Colors.red.shade900,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.large(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ScannerScreen())),
            child: const Icon(Icons.qr_code_scanner, size: 36),
          ),
        );
      },
    );
  }

  Widget _buildSearchHeader(BuildContext context, InventoryViewModel vm) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).primaryColor.withOpacity(0.05),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Rechercher un produit (Nom, Code, Barcode)',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _manualSearchDialog(context, vm),
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.white,
        ),
        onChanged: (val) {
          // Vous pouvez ajouter une recherche en temps réel ici
        },
      ),
    );
  }

  void _manualSearchDialog(BuildContext context, InventoryViewModel vm) {
    // Dialogue de recherche avancée ou ajout manuel
  }

  void _showExportDialog(BuildContext context, InventoryViewModel vm) {
    // Boîte de dialogue pour exporter (Excel local ou Google Sheets)
  }
}
