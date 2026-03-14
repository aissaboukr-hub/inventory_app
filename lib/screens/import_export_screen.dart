import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/import_export_viewmodel.dart';
import '../viewmodels/inventory_viewmodel.dart';

class ImportExportScreen extends StatefulWidget {
  const ImportExportScreen({super.key});

  @override
  State<ImportExportScreen> createState() => _ImportExportScreenState();
}

class _ImportExportScreenState extends State<ImportExportScreen> {
  final TextEditingController _urlController = TextEditingController(
    text: 'https://script.google.com/macros/s/VOTRE_ID/exec'
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Import / Export')),
      body: Consumer2<ImportExportViewModel, InventoryViewModel>(
        builder: (context, importVm, invVm, child) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildSectionTitle('Importation Référentiel (Produits)'),
              _buildCard(
                title: 'Importer depuis Excel (.xlsx)',
                subtitle: 'Sélectionner un fichier local',
                icon: Icons.upload_file,
                color: Colors.green,
                onTap: () => _pickExcelFile(context, importVm),
              ),
              _buildCard(
                title: 'Importer depuis Google Sheets',
                subtitle: 'Utiliser l\'URL du Google Apps Script',
                icon: Icons.cloud_download,
                color: Colors.blue,
                onTap: () => _importFromSheets(context, importVm),
              ),
              const SizedBox(height: 24),
              _buildSectionTitle('Exportation Inventaire Actif'),
              if (invVm.activeInventory == null)
                const Center(child: Text('Veuillez sélectionner un inventaire d\'abord.'))
              else ...[
                _buildCard(
                  title: 'Exporter vers Excel (.xlsx)',
                  subtitle: 'Générer un fichier avec historique et totaux',
                  icon: Icons.download_for_offline,
                  color: Colors.green,
                  onTap: () => _exportToExcel(context, importVm, invVm),
                ),
                _buildCard(
                  title: 'Exporter vers Google Sheets',
                  subtitle: 'Envoyer les données vers votre feuille en ligne',
                  icon: Icons.cloud_upload,
                  color: Colors.blue,
                  onTap: () => _exportToSheets(context, importVm, invVm),
                ),
              ],
              if (importVm.isProcessing) ...[
                const SizedBox(height: 24),
                const Center(child: CircularProgressIndicator()),
                const SizedBox(height: 12),
                Center(child: Text(importVm.statusMessage, textAlign: TextAlign.center)),
              ] else if (importVm.statusMessage.isNotEmpty) ...[
                const SizedBox(height: 12),
                Center(child: Text(importVm.statusMessage, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold))),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
    );
  }

  Widget _buildCard({required String title, required String subtitle, required IconData icon, required Color color, required VoidCallback onTap}) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(backgroundColor: color.withOpacity(0.1), child: Icon(icon, color: color)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        onTap: onTap,
      ),
    );
  }

  void _pickExcelFile(BuildContext context, ImportExportViewModel vm) {
    // Utiliser file_picker pour choisir un fichier
    vm.importExcel("/storage/emulated/0/Download/produits.xlsx"); // Exemple de chemin
  }

  void _importFromSheets(BuildContext context, ImportExportViewModel vm) {
    vm.importFromSheets(_urlController.text);
  }

  void _exportToExcel(BuildContext context, ImportExportViewModel importVm, InventoryViewModel invVm) async {
    final totals = await invVm.getTotals();
    importVm.exportInventory(
      inventoryName: invVm.activeInventory!.name,
      history: invVm.currentItems,
      totals: totals,
    );
  }

  void _exportToSheets(BuildContext context, ImportExportViewModel importVm, InventoryViewModel invVm) async {
    // Logique pour appeler GoogleSheetsService.exportInventory via le ViewModel
  }
}
