import 'package:flutter/material.dart';
import 'package:sungoods/models/order.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class RiderOrderDetailScreen extends StatefulWidget {
  final Order order;

  const RiderOrderDetailScreen({super.key, required this.order});

  @override
  State<RiderOrderDetailScreen> createState() => _RiderOrderDetailScreenState();
}

class _RiderOrderDetailScreenState extends State<RiderOrderDetailScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _showBackToTop = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    setState(() {
      _showBackToTop = _scrollController.offset > 300;
    });
  }

  Future<void> _printInvoice(BuildContext context) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Header(
                level: 0,
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('HUBLI - INVOICE',
                        style: pw.TextStyle(
                            fontSize: 24, fontWeight: pw.FontWeight.bold)),
                    pw.Text('Order #${widget.order.id}',
                        style: pw.TextStyle(fontSize: 18)),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Customer Details:',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.Text('Name: ${widget.order.name}'),
                      pw.Text('Mobile: ${widget.order.mobile}'),
                      pw.Text('Email: ${widget.order.email ?? 'N/A'}'),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                          'Order Date: ${DateFormat('dd MMM yyyy').format(widget.order.orderDate)}'),
                      pw.Text('Payment Method: ${widget.order.paymentMethod}'),
                      pw.Text(
                          'Payment Status: ${widget.order.paymentStatus.toUpperCase()}'),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Text('Shipping Address:',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.Text(widget.order.addressTitle),
              pw.SizedBox(height: 20),
              pw.Table.fromTextArray(
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                headers: ['Product Name', 'Quantity', 'Price', 'Total'],
                data: List<List<String>>.from(widget.order.items.map((item) => [
                      item.productName,
                      item.quantity.toString(),
                      'Tk ${item.productPrice.toStringAsFixed(2)}',
                      'Tk ${item.totalCost.toStringAsFixed(2)}'
                    ])),
              ),
              pw.Divider(),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                          'Subtotal: Tk ${widget.order.subtotal.toStringAsFixed(2)}'),
                      pw.Text(
                          'Delivery Cost: Tk ${widget.order.deliveryCost.toStringAsFixed(2)}'),
                      pw.Divider(),
                      pw.Text(
                          'Grand Total: Tk ${widget.order.grandTotal.toStringAsFixed(2)}',
                          style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                ],
              ),
              if (widget.order.orderNote != null && widget.order.orderNote!.isNotEmpty) ...[
                pw.SizedBox(height: 20),
                pw.Text('Note:',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.Text(widget.order.orderNote!),
              ],
              pw.SizedBox(height: 40),
              pw.Center(child: pw.Text('Thank you for shopping with Hubli!')),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Hubli_Invoice_${widget.order.id}',
    );
  }

  String _getLatestStatusUpdate() {
    final status = widget.order.orderStatus.toLowerCase();
    DateTime? timestamp;
    String statusLabel = '';

    if (status == 'delivered' && widget.order.deliveredAt != null) {
      timestamp = widget.order.deliveredAt;
      statusLabel = 'Delivered at';
    } else if (status == 'shipped' && widget.order.shippedAt != null) {
      timestamp = widget.order.shippedAt;
      statusLabel = 'Shipped at';
    } else if (status == 'canceled' && widget.order.canceledAt != null) {
      timestamp = widget.order.canceledAt;
      statusLabel = 'Canceled at';
    } else if (widget.order.confirmedAt != null) {
      timestamp = widget.order.confirmedAt;
      statusLabel = 'Confirmed at';
    }

    if (timestamp != null) {
      return '$statusLabel: ${DateFormat('dd MMM yyyy, hh:mm a').format(timestamp)}';
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final latestUpdate = _getLatestStatusUpdate();

    return Scaffold(
      appBar: AppBar(
        title: Text('Order Details #${widget.order.id}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.print),
            tooltip: 'Print Invoice',
            onPressed: () => _printInvoice(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Status Overview Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              child: Container(
                padding: const EdgeInsets.all(16),
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).primaryColor.withOpacity(0.05),
                      Theme.of(context).primaryColor.withOpacity(0.1),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Order Status',
                                style: TextStyle(
                                    color: Colors.grey, fontSize: 13)),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: _getStatusColor(widget.order.orderStatus)
                                    .withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                widget.order.orderStatus.toUpperCase(),
                                style: TextStyle(
                                  color: _getStatusColor(widget.order.orderStatus),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text('Payment',
                                style: TextStyle(
                                    color: Colors.grey, fontSize: 13)),
                            const SizedBox(height: 4),
                            Text(
                              widget.order.paymentStatus.toUpperCase(),
                              style: TextStyle(
                                color: widget.order.paymentStatus == 'paid'
                                    ? Colors.green
                                    : Colors.orange,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    if (latestUpdate.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      const Divider(),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.access_time,
                              size: 16, color: Colors.blueGrey),
                          const SizedBox(width: 8),
                          Text(
                            latestUpdate,
                            style: const TextStyle(
                                color: Colors.blueGrey,
                                fontSize: 12,
                                fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // At a Glance Info Card
            _buildSectionTitle('Order Summary'),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    _buildInfoRow(Icons.payment, 'Payment Method',
                        widget.order.paymentMethod.toUpperCase()),
                    _buildInfoRow(
                        Icons.calendar_today,
                        'Order Date',
                        DateFormat('dd MMM yyyy, hh:mm a')
                            .format(widget.order.orderDate)),
                    if (widget.order.orderNote != null && widget.order.orderNote!.isNotEmpty)
                      _buildInfoRow(
                          Icons.note_alt, 'Order Note', widget.order.orderNote!,
                          isNote: true),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Customer Info
            _buildSectionTitle('Customer Information'),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    _buildInfoRow(Icons.person, 'Name', widget.order.name),
                    _buildInfoRow(Icons.phone, 'Mobile', widget.order.mobile),
                    _buildInfoRow(Icons.email, 'Email', widget.order.email ?? 'N/A'),
                    _buildInfoRow(
                        Icons.location_on, 'Shipping Address', widget.order.addressTitle),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Order Items
            _buildSectionTitle('Items Ordered'),
            ...widget.order.items.map((item) => Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    title: Text(item.productName),
                    subtitle: Text(
                        'Qty: ${item.quantity} x ৳ ${item.productPrice.toStringAsFixed(2)}'),
                    trailing: Text('৳ ${item.totalCost.toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                )),
            const SizedBox(height: 16),

            // Price Summary
            Card(
              color: Colors.grey[50],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildSummaryRow('Subtotal', widget.order.subtotal),
                    _buildSummaryRow('Delivery Fee', widget.order.deliveryCost),
                    const Divider(height: 24),
                    _buildSummaryRow('Grand Total', widget.order.grandTotal,
                        isBold: true),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
      floatingActionButton: _showBackToTop
          ? FloatingActionButton(
              onPressed: () {
                _scrollController.animateTo(
                  0,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                );
              },
              mini: true,
              backgroundColor: Theme.of(context).primaryColor,
              child: const Icon(Icons.arrow_upward, color: Colors.white),
            )
          : null,
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _printInvoice(context),
              icon: const Icon(Icons.print),
              label: const Text('Print as Invoice'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'shipped':
        return Colors.purple;
      case 'delivered':
        return Colors.green;
      case 'canceled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value,
      {bool isNote = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.blueGrey),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(color: Colors.grey, fontSize: 12)),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isNote ? FontWeight.bold : FontWeight.w500,
                    color: isNote ? Colors.redAccent : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, double amount, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                fontSize: isBold ? 18 : 14)),
        Text('৳ ${amount.toStringAsFixed(2)}',
            style: TextStyle(
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                fontSize: isBold ? 18 : 14,
                color: isBold ? Colors.green : Colors.black)),
      ],
    );
  }
}
