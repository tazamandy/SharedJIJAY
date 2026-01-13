import 'package:flutter/material.dart';
import 'admin_qr_scanner_screen.dart';

class SuperadminQRScannerScreen extends StatelessWidget {
  final int eventId;
  final VoidCallback? onSuccess;

  const SuperadminQRScannerScreen({
    super.key,
    required this.eventId,
    this.onSuccess,
  });

  @override
  Widget build(BuildContext context) {
    return AdminQRScannerScreen(eventId: eventId, onSuccess: onSuccess);
  }
}
