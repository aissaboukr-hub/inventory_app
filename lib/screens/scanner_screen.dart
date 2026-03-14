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
          // Correction Switch Camera
          ValueListenableBuilder(
            valueListenable: controller,
            builder: (context, state, child) {
              return IconButton(
                icon: Icon(
                  // On utilise state.cameraDirection au lieu de state.facing
                  state.cameraDirection == CameraFacing.front
                      ? Icons.camera_front
                      : Icons.camera_rear,
                ),
                onPressed: () => controller.switchCamera(),
              );
            },
          ),
          // Correction Switch Camera
          ValueListenableBuilder(
            valueListenable: controller,
            builder: (context, state, child) {
              return IconButton(
                icon: Icon(
                  state.facing == CameraFacing.front
                      ? Icons.camera_front
                      : Icons.camera_rear,
                ),
                onPressed: () => controller.switchCamera(),
              );
            },
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

    if (!mounted) return;

    if (product != null) {
      _showQuantityDialog(context, product);
    } else {
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
          Navigator.pop(context);
          setState(() => isScanning = true);
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
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: 'OK',
          onPressed: () {
            setState(() => isScanning = true);
          },
        ),
      ),
    );
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted && !isScanning) setState(() => isScanning = true);
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}