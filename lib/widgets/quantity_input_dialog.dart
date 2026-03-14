import 'package:flutter/material.dart';
import '../models/product.dart';

class QuantityInputDialog extends StatefulWidget {
  final Product product;
  final Function(double) onSubmitted;
  final Function() onCancel;

  const QuantityInputDialog({
    super.key,
    required this.product,
    required this.onSubmitted,
    required this.onCancel,
  });

  @override
  State<QuantityInputDialog> createState() => _QuantityInputDialogState();
}

class _QuantityInputDialogState extends State<QuantityInputDialog> {
  final TextEditingController _controller = TextEditingController();
  bool _isNegative = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.product.designation, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text('Code: ${widget.product.code}', style: const TextStyle(fontSize: 14, color: Colors.grey)),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _controller,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              hintText: 'Saisir la quantité',
              prefixText: _isNegative ? '-' : '+',
              prefixStyle: TextStyle(
                color: _isNegative ? Colors.red : Colors.green,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildCorrectionButton('±', () => setState(() => _isNegative = !_isNegative)),
              _buildCorrectionButton('1', () => _appendValue('1')),
              _buildCorrectionButton('5', () => _appendValue('5')),
              _buildCorrectionButton('10', () => _appendValue('10')),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: widget.onCancel, child: const Text('ANNULER')),
        ElevatedButton(
          onPressed: () {
            double qty = double.tryParse(_controller.text) ?? 1.0;
            if (_isNegative) qty = -qty;
            widget.onSubmitted(qty);
          },
          child: const Text('OK'),
        ),
      ],
    );
  }

  Widget _buildCorrectionButton(String label, VoidCallback onPressed) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        shape: const CircleBorder(),
        padding: const EdgeInsets.all(12),
      ),
      child: Text(label),
    );
  }

  void _appendValue(String val) {
    _controller.text = val;
  }
}
