import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// QR rendering uses Google Charts image endpoint as a fallback

class QRModal extends StatelessWidget {
  final String payload;
  final String? title;

  const QRModal({super.key, required this.payload, this.title});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title ?? 'My QR Code',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(12),
              child: SizedBox(width: 220, height: 220, child: _buildQrPreview()),
            ),
            const SizedBox(height: 12),
            // Hide long base64 data URIs to keep the modal clean.
            if (payload.toLowerCase().startsWith('data:image'))
              const Text(
                'Embedded image (base64 hidden) — image shown above',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12),
              )
            else
              SelectableText(
                payload,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12),
              ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () async {
                    await Clipboard.setData(ClipboardData(text: payload));
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('QR payload copied')),
                      );
                    }
                  },
                  icon: const Icon(Icons.copy),
                  label: const Text('Copy'),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(Icons.check),
                  label: const Text('Close'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQrPreview() {
    try {
      final lower = payload.toLowerCase();
      if (lower.startsWith('data:image')) {
        final parts = payload.split(',');
        if (parts.length > 1) {
          final b64 = parts.sublist(1).join(',');
          final bytes = base64Decode(b64);
          return Image.memory(
            bytes,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => const Center(child: Text('QR preview unavailable')),
          );
        }
      }
    } catch (_) {}

    // Fallback to Google Charts QR generation for plain/text payloads
    final url = 'https://chart.googleapis.com/chart?cht=qr&chs=300x300&chl=${Uri.encodeComponent(payload)}';
    return Image.network(
      url,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) => const Center(child: Text('QR preview unavailable')),
    );
  }
}
