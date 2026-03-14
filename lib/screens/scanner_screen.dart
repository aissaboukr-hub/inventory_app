import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import '../viewmodels/inventory_viewmodel.dart';
import '../models/product.dart';
import '../widgets/quantity_input_dialog.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final MobileScannerController controller = MobileScannerController();
  bool isScanning = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scanner Barcode'),
        actions: [
          IconButton(
            icon: ValueListenableBuilder(
              valueListenable: controller.torchState,
              builder: (context, state, child) {
                if (state == null) {
                  return const Icon(Icons.flash_off, color: Colors.grey); // Default icon when state is null
                }
                switch (state) {
                  case TorchState.off:
                    return const Icon(Icons.flash_off, color: Colors.grey);
                  case TorchState.on:
                    return const Icon(Icons.flash_on, color: Colors.yellow);
                  default:
                    return const Icon(Icons.flash_off, color: Colors.grey); // Default icon for undefined state
                }
              },
            ),
            onPressed: () => controller.toggleTorch(),
          ),
          IconButton(
            icon: ValueListenableBuilder(
              valueListenable: controller.cameraFacingState,
              builder: (context, state, child) {
                if (state == null) {
                  return const Icon(Icons.camera_rear); // Default icon when state is null
                }
                switch (state) {
                  case CameraFacing.front:
                    return const Icon(Icons.camera_front);
                  case CameraFacing.back:
                    return const Icon(Icons.camera_rear);
                  default:
                    return const Icon(Icons.camera_rear); // Default icon for undefined state
                }
              },
            ),
            onPressed: () => controller.switchCamera(),
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: controller,
            onDetect: (capture) {
              final List<Barcode> barcodes = capture.barcodes;
              if (barcodes.isNotEmpty && isScanning) {
                final barcode = barcodes.first.rawValue ?? "";
                if (barcode.isNotEmpty) {
                  setState(() => isScanning = false);
                  _handleScan(context, barcode);
                }
              }
            },
          ),
          // Superposition pour guider le scan
          Center(
            child: Container(
              width: 250,
              height: 150,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleScan(BuildContext context, String barcode) async {
    final vm = context.read<InventoryViewModel>();
    final product = await vm.findProduct(barcode);

    if (product != null) {
      // Produit trouvé, on demande la quantité
      _showQuantityDialog(context, product);
    } else {
      // Produit non trouvé
      _showProductNotFound(context, barcode);
    }
  }

  void _showQuantityDialog(BuildContext context, Product product) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => QuantityInputDialog(
        product: product,
        onSubmitted: (quantity) {
          context.read<InventoryViewModel>().addItemToInventory(
            product: product,
            quantity: quantity,
          );
          Navigator.pop(context); // Fermer le dialogue
          setState(() => isScanning = true); // Reprendre le scan
        },
        onCancel: () {
          Navigator.pop(context);
          setState(() => isScanning = true);
        },
      ),
    );
  }

  void _showProductNotFound(BuildContext context, String barcode) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Produit non trouvé : $barcode"),
        action: SnackBarAction(
          label: 'Ajouter',
          onPressed: () {
            // Logique pour ajouter le produit manuellement
            setState(() => isScanning = true);
          },
        ),
      ),
    );
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => isScanning = true);
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
