import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../models/user_model.dart';
import '../models/timeinout_models.dart';
import '../services/timeinout_api_service.dart';
import '../utils/constants.dart';

class TimeInOutScreen extends StatefulWidget {
  final UserModel user;
  final bool? showBottomNav; // Make nullable
  final VoidCallback? onNavigateToHome; // Add callback to navigate to home
  final Function(int)?
      onNavigateToTab; // Add callback to navigate to specific tab

  const TimeInOutScreen({
    super.key,
    required this.user,
    this.showBottomNav, // Optional parameter
    this.onNavigateToHome, // Optional callback
    this.onNavigateToTab, // Optional callback
  });

  @override
  State<TimeInOutScreen> createState() => _TimeInOutScreenState();
}

class _TimeInOutScreenState extends State<TimeInOutScreen> {
  final MobileScannerController _scannerController = MobileScannerController();
  bool _isProcessing = false;
  bool _hasScanned = false;

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  Future<void> _handleQRCode(String? qrCode) async {
    if (qrCode == null || _isProcessing || _hasScanned) return;

    setState(() {
      _isProcessing = true;
      _hasScanned = true;
    });

    try {
      final response = await TimeInOutApiService.scanQRCode(
        itoken: widget.user.id, // Send user ID, not token
        qrCode: qrCode,
      );

      if (!mounted) return;

      setState(() {
        _isProcessing = false;
      });

      if (response.isSuccess) {
        _showAttendanceDialog(response);
      } else {
        _showErrorDialog(response.message);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isProcessing = false;
        _hasScanned = false;
      });
      _showErrorDialog('Error scanning QR code: $e');
    }
  }

  void _showAttendanceDialog(TimeInOutResponse response) {
    final attendance = response.attendance;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.access_time, color: AppConstants.primaryColor),
            const SizedBox(width: 8),
            const Text('Attendance'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Extract and display message (HTML stripped)
              Text(
                _stripHtmlTags(response.message),
                style: const TextStyle(fontSize: 14),
              ),

              // Show action buttons if attendance exists
              if (attendance != null && attendance.buttonOne.isNotEmpty) ...[
                const SizedBox(height: 24),

                // Primary button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _handleAction(attendance, isPrimary: true);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppConstants.primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(
                      attendance.buttonOne,
                      style: const TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),

                // Secondary button if exists
                if (attendance.buttonTwo.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _handleAction(attendance, isPrimary: false);
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: AppConstants.primaryColor),
                      ),
                      child: Text(
                        attendance.buttonTwo,
                        style: TextStyle(
                            fontSize: 16, color: AppConstants.primaryColor),
                      ),
                    ),
                  ),
                ],
              ],
            ],
          ),
        ),
        actions: attendance == null || attendance.buttonOne.isEmpty
            ? [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    // Navigate to Programs tab (index 1) when not enrolled
                    if (widget.onNavigateToTab != null) {
                      widget.onNavigateToTab!(1); // Navigate to Programs tab
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.primaryColor,
                  ),
                  child:
                      const Text('OK', style: TextStyle(color: Colors.white)),
                ),
              ]
            : null,
      ),
    );
  }

  void _handleAction(TimeInOutModel attendance,
      {required bool isPrimary}) async {
    if (!isPrimary) {
      // Secondary button pressed (Later/Cancel)
      // Check if this is a time-in scenario (button says "Pay Now" or "Pay+Time-out")
      if (attendance.buttonOne.toLowerCase().contains('pay') &&
          !attendance.buttonOne.toLowerCase().contains('time-out')) {
        // User just timed in and clicked "Later" on "Pay Now" prompt
        _showSuccessDialog(
          'You have successfully timed in.',
        );
      } else if (attendance.timeIn != null &&
          attendance.timeIn!.isNotEmpty &&
          attendance.buttonTwo.toLowerCase().contains('later')) {
        // User is timed in and clicked "Later" (any scenario with time-in data)
        _showSuccessDialog(
          'You have successfully timed in.',
        );
      } else {
        _resetScanner();
      }
      return;
    }

    // Check if this is a "Time-in Again" action (action = "4")
    if (attendance.action == '4') {
      // User wants to time-in again after already timing out
      await _handleTimeInAgain(attendance);
      return;
    }

    // Determine action based on button text and attendance state
    String actionType = '1'; // Default: time-out
    String amount = '0';

    if (attendance.buttonOne.toLowerCase().contains('pay')) {
      // Show payment input dialog
      final enteredAmount = await _showPaymentDialog(attendance);
      if (enteredAmount == null) {
        _resetScanner();
        return;
      }
      amount = enteredAmount;

      if (attendance.buttonOne.toLowerCase().contains('time-out')) {
        // Pay + Time-out
        actionType = '1';
      } else {
        // Pay only
        actionType = '0';
      }
    } else if (attendance.buttonOne.toLowerCase().contains('time-out')) {
      // Time-out only
      actionType = '1';
      amount = '0';
    }

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final response = await TimeInOutApiService.submitTimeAction(
        actionType: actionType,
        dtrId: attendance.dtrId ?? '',
        amount: amount,
      );

      if (!mounted) return;
      Navigator.pop(context); // Close loading

      if (response.isSuccess) {
        _showSuccessDialog(response.message);
      } else {
        _showErrorDialog(response.message);
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // Close loading
      _showErrorDialog('Error submitting action: $e');
    }
  }

  Future<void> _handleTimeInAgain(TimeInOutModel attendance) async {
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final response = await TimeInOutApiService.timeInAgain(
        enrollmentId: attendance.enrollmentId,
      );

      if (!mounted) return;
      Navigator.pop(context); // Close loading

      if (response.isSuccess) {
        _showSuccessDialog(response.message);
      } else {
        _showErrorDialog(response.message);
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // Close loading
      _showErrorDialog('Error timing in again: $e');
    }
  }

  Future<String?> _showPaymentDialog(TimeInOutModel attendance) async {
    final TextEditingController amountController = TextEditingController();

    // Calculate balance
    final double totalAmount = double.tryParse(attendance.amount) ?? 0.0;
    final double paidAmount = double.tryParse(attendance.paid) ?? 0.0;
    final double balance = totalAmount - paidAmount;

    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Enter Payment Amount',
          style: TextStyle(fontSize: 18), // Smaller font size
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Total Paid: ₱${paidAmount.toStringAsFixed(2)}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            Text(
              'Balance: ₱${balance.toStringAsFixed(2)}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: amountController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Amount to Pay',
                prefixText: '₱',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final amount = amountController.text.trim();
              if (amount.isEmpty || double.tryParse(amount) == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter a valid amount')),
                );
                return;
              }
              Navigator.pop(context, amount);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.primaryColor,
            ),
            child: const Text('Submit', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            const SizedBox(width: 8),
            const Text('Success'),
          ],
        ),
        content: Text(_stripHtmlTags(message)),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              _resetScanner();
              // Navigate back to home tab if callback provided
              if (widget.onNavigateToHome != null) {
                // Use Future.microtask to ensure the dialog is fully closed first
                Future.microtask(() => widget.onNavigateToHome!());
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.primaryColor,
            ),
            child: const Text('OK', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.error, color: Colors.red),
            const SizedBox(width: 8),
            const Text('Error'),
          ],
        ),
        content: Text(_stripHtmlTags(message)),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _resetScanner();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _resetScanner() {
    setState(() {
      _hasScanned = false;
    });
  }

  String _stripHtmlTags(String html) {
    return html
        .replaceAll(RegExp(r'<br\s*/?>'), '\n')
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.showBottomNav == true
          ? null // Hide AppBar when embedded in dashboard
          : AppBar(
              title: const Text('Time In/Out'),
              backgroundColor: AppConstants.primaryColor,
              foregroundColor: Colors.white,
            ),
      body: Column(
        children: [
          // Instructions
          Container(
            padding: const EdgeInsets.all(16),
            color: AppConstants.primaryColor.withOpacity(0.1),
            child: Row(
              children: [
                Icon(Icons.qr_code_scanner,
                    color: AppConstants.primaryColor, size: 32),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Scan QR Code',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppConstants.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Point your camera at the gym\'s QR code to time in or out',
                        style: TextStyle(fontSize: 14, color: Colors.black87),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Scanner View
          Expanded(
            child: Stack(
              children: [
                MobileScanner(
                  controller: _scannerController,
                  onDetect: (capture) {
                    final List<Barcode> barcodes = capture.barcodes;
                    for (final barcode in barcodes) {
                      _handleQRCode(barcode.rawValue);
                      break;
                    }
                  },
                ),

                // Scanning overlay
                CustomPaint(
                  painter: ScannerOverlayPainter(),
                  child: Container(),
                ),

                // Loading indicator
                if (_isProcessing)
                  Container(
                    color: Colors.black54,
                    child: const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                  ),
              ],
            ),
          ),

          // Bottom info
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.info_outline, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  'Position QR code within the frame',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Custom painter for scanner overlay
class ScannerOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.5)
      ..style = PaintingStyle.fill;

    final scanAreaSize = size.width * 0.7;
    final left = (size.width - scanAreaSize) / 2;
    final top = (size.height - scanAreaSize) / 2;
    final right = left + scanAreaSize;
    final bottom = top + scanAreaSize;

    // Draw darkened areas around scan area
    canvas.drawPath(
      Path()
        ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
        ..addRect(Rect.fromLTRB(left, top, right, bottom))
        ..fillType = PathFillType.evenOdd,
      paint,
    );

    // Draw scan area border
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    canvas.drawRect(Rect.fromLTRB(left, top, right, bottom), borderPaint);

    // Draw corner brackets
    final cornerLength = 30.0;
    final cornerPaint = Paint()
      ..color = AppConstants.accentColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;

    // Top-left
    canvas.drawLine(
        Offset(left, top), Offset(left + cornerLength, top), cornerPaint);
    canvas.drawLine(
        Offset(left, top), Offset(left, top + cornerLength), cornerPaint);

    // Top-right
    canvas.drawLine(
        Offset(right, top), Offset(right - cornerLength, top), cornerPaint);
    canvas.drawLine(
        Offset(right, top), Offset(right, top + cornerLength), cornerPaint);

    // Bottom-left
    canvas.drawLine(
        Offset(left, bottom), Offset(left + cornerLength, bottom), cornerPaint);
    canvas.drawLine(
        Offset(left, bottom), Offset(left, bottom - cornerLength), cornerPaint);

    // Bottom-right
    canvas.drawLine(Offset(right, bottom), Offset(right - cornerLength, bottom),
        cornerPaint);
    canvas.drawLine(Offset(right, bottom), Offset(right, bottom - cornerLength),
        cornerPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
