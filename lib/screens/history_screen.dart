import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/inventory_viewmodel.dart';
import 'inventory_detail_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InventoryViewModel>().loadInventories();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Historique')),
      body: Consumer<InventoryViewModel>(
        builder: (context, vm, child) {
          if (vm.isLoading) return const Center(child: CircularProgressIndicator());
          if (vm.inventories.isEmpty) {
            return const Center(child: Text('Aucun historique d\'inventaire trouvé.'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: vm.inventories.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final inv = vm.inventories[index];
              return Card(
                elevation: 4,
                child: ListTile(
                  title: Text(inv.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(inv.date.toLocal().toString().split('.')[0]),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    vm.selectInventory(inv);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const InventoryDetailScreen()));
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
