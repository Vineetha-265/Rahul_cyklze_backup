// import 'package:flutter/material.dart';

// class InvoicePage extends StatelessWidget {
//   const InvoicePage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[100],
//       appBar: AppBar(title: const Text("Invoice")),
//       body: LayoutBuilder(
//         builder: (context, constraints) {
//           return SingleChildScrollView(
//             padding: const EdgeInsets.all(16),
//             child: Center(
//               child: ConstrainedBox(
//                 constraints: const BoxConstraints(maxWidth: 650),
//                 child: Container(
//                   padding: const EdgeInsets.all(24),
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(12),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black12,
//                         blurRadius: 12,
//                         offset: Offset(0, 4),
//                       )
//                     ],
//                   ),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       _buildHeader(),
//                       const SizedBox(height: 24),
//                       _buildInvoiceDetails(),
//                       const SizedBox(height: 16),
//                       _buildTableContainer(),
//                       const SizedBox(height: 20),
//                       _buildSummary(),
//                       const SizedBox(height: 20),
//                       const Divider(),
//                       const SizedBox(height: 10),
//                       Align(
//                         alignment: Alignment.centerRight,
//                         child: Text(
//                           "Thank you for your business!",
//                           style: TextStyle(
//                               fontSize: 16, color: Colors.grey[700]),
//                         ),
//                       )
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }

//   // ───────────────────────────
//   // HEADER
//   // ───────────────────────────
//   Widget _buildHeader() {
//     return Wrap(
//       alignment: WrapAlignment.spaceBetween,
//       runSpacing: 12,
//       children: [
//         Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: const [
//             Text(
//               "YOUR COMPANY NAME",
//               style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//             ),
//             SizedBox(height: 6),
//             Text("123 Business Street"),
//             Text("New York, NY 10001"),
//             Text("Email: info@company.com"),
//           ],
//         ),
//         Column(
//           crossAxisAlignment: CrossAxisAlignment.end,
//           children: const [
//             Text(
//               "INVOICE",
//               style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
//             ),
//             SizedBox(height: 6),
//             Text("Date: 2025-01-10"),
//             Text("Invoice #: 001245"),
//           ],
//         ),
//       ],
//     );
//   }

//   // ───────────────────────────
//   // BILLING INFO
//   // ───────────────────────────
//   Widget _buildInvoiceDetails() {
//     return Wrap(
//       spacing: 20,
//       runSpacing: 10,
//       children: const [
//         SizedBox(
//           width: 280,
//           child: _InfoSection(
//             title: "Bill To",
//             lines: [
//               "John Smith",
//               "ABC Corporation",
//               "77 Market Street",
//               "San Francisco, CA 94103",
//             ],
//           ),
//         ),
//         SizedBox(
//           width: 260,
//           child: _InfoSection(
//             title: "Payment Info",
//             lines: [
//               "Bank: Chase",
//               "Account: **** 1234",
//               "SWIFT: CHASUS33",
//             ],
//           ),
//         )
//       ],
//     );
//   }

//   // ───────────────────────────
//   // TABLE (scrollable on small screens)
//   // ───────────────────────────
//   Widget _buildTableContainer() {
//     return SingleChildScrollView(
//       scrollDirection: Axis.horizontal,
//       child: SizedBox(
//         width: 600,
//         child: _buildTable(),
//       ),
//     );
//   }

//   Widget _buildTable() {
//     return Table(
//       border: TableBorder.all(color: Colors.black54, width: 0.5),
//       columnWidths: const {
//         0: FlexColumnWidth(4),
//         1: FlexColumnWidth(2),
//         2: FlexColumnWidth(2),
//         3: FlexColumnWidth(2),
//       },
//       children: [
//         _tableHeader(),
//         _tableRow("Website Design", 2, 250, 500),
//         _tableRow("App Development", 1, 1200, 1200),
//         _tableRow("Hosting (12 months)", 1, 180, 180),
//       ],
//     );
//   }

//   TableRow _tableHeader() {
//     return TableRow(
//       decoration: const BoxDecoration(color: Color(0xFFEFEFEF)),
//       children: const [
//         _TableCell("Description", isHeader: true),
//         _TableCell("Qty", isHeader: true),
//         _TableCell("Price", isHeader: true),
//         _TableCell("Total", isHeader: true),
//       ],
//     );
//   }

//   TableRow _tableRow(
//       String desc, int qty, double price, double total) {
//     return TableRow(
//       children: [
//         _TableCell(desc),
//         _TableCell(qty.toString()),
//         _TableCell("\$${price.toStringAsFixed(2)}"),
//         _TableCell("\$${total.toStringAsFixed(2)}"),
//       ],
//     );
//   }

//   // ───────────────────────────
//   // SUMMARY
//   // ───────────────────────────
//   Widget _buildSummary() {
//     return Align(
//       alignment: Alignment.centerRight,
//       child: SizedBox(
//         width: 260,
//         child: Column(
//           children: const [
//             _SummaryRow(label: "Subtotal", value: "\$1880.00"),
//             _SummaryRow(label: "Tax (10%)", value: "\$188.00"),
//             Divider(),
//             _SummaryRow(
//               label: "TOTAL",
//               value: "\$2068.00",
//               bold: true,
//               big: true,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // ───────────────────────────
// // REUSABLE WIDGETS
// // ───────────────────────────

// class _InfoSection extends StatelessWidget {
//   final String title;
//   final List<String> lines;

//   const _InfoSection({required this.title, required this.lines});

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           title,
//           style:
//               const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//         ),
//         const SizedBox(height: 4),
//         for (var line in lines) Text(line),
//       ],
//     );
//   }
// }

// class _TableCell extends StatelessWidget {
//   final String text;
//   final bool isHeader;

//   const _TableCell(this.text, {this.isHeader = false});

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(10),
//       child: Text(
//         text,
//         style: TextStyle(
//           fontWeight:
//               isHeader ? FontWeight.bold : FontWeight.normal,
//           fontSize: isHeader ? 16 : 15,
//         ),
//       ),
//     );
//   }
// }

// class _SummaryRow extends StatelessWidget {
//   final String label;
//   final String value;
//   final bool bold;
//   final bool big;

//   const _SummaryRow({
//     required this.label,
//     required this.value,
//     this.bold = false,
//     this.big = false,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 6),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(
//             label,
//             style: TextStyle(
//               fontWeight: bold ? FontWeight.bold : FontWeight.normal,
//               fontSize: big ? 18 : 16,
//             ),
//           ),
//           Text(
//             value,
//             style: TextStyle(
//               fontWeight: bold ? FontWeight.bold : FontWeight.normal,
//               fontSize: big ? 18 : 16,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }




import 'package:cyklze/screens/pickup_history.dart';
import 'package:flutter/material.dart';


class InvoicePage extends StatelessWidget {
  final RequestItem item;

  const InvoicePage({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
      elevation: 0,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
           colors: [Color(0xFF1D4D61), Color(0xFF163B4B)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
      title: const Text(
        "Payout Slip",
        style: TextStyle(color: Colors.white,  fontSize: 16,
                        fontWeight: FontWeight.w800,),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
        tooltip: 'Back',
      ),
    ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 650),
            child: _invoiceCard(),
          ),
        ),
      ),
    );
  }

  Widget _invoiceCard() {
    return Container(
      padding: const EdgeInsets.all(10),
   
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          _buildDetailsSection(),
          const SizedBox(height: 20),
          _buildServiceTable(),
          const SizedBox(height: 20),
          _buildSummary(),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.center,
            child: Expanded(
              child: Text(
                "Thank you for choosing Cyklze!",
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              ),
            ),
          )
        ],
      ),
    );
  }

  // HEADER
Widget _buildHeader() {
  return Wrap(
    alignment: WrapAlignment.spaceBetween,
    runSpacing: 12,
    children: [
    const  Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children:  [
          Text(
            "CYKLZE",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 6),
          Text("www.cyklze.com"),
        ],
      ),
      // Column(
      //   crossAxisAlignment: CrossAxisAlignment.end,
      //   children: [
      //     const Text(
      //       "INVOICE",
      //       style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
      //     ),
      //     const SizedBox(height: 6),
      //     Text("Date: ${DateTime.now().toString().substring(0, 10)}"),
      //     Text("Invoice #: ${item.code}"),
      //   ],
      // ),
    ],
  );
}

  // DETAILS
  Widget _buildDetailsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Pickup Details",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),

        _infoText("Pickup Type", item.pickupType),
        _infoText("Status", item.status),
        _infoText("Placed On", item.time),


        const SizedBox(height: 12),
        const Divider(),
        const SizedBox(height: 12),

        const Text("Additional Information",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),

        Text(
          item.details,
          style: const TextStyle(fontSize: 15, height: 1.5),
        ),
      ],
    );
  }

  Widget _infoText(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("$title:",
              style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }

  // TABLE
  Widget _buildServiceTable() {
    return Table(
      border: TableBorder.all(color: Colors.black26),
      columnWidths: const {
        0: FlexColumnWidth(4),
        1: FlexColumnWidth(2),
      },
      children: [
        _tableHeader(),
        _tableRow("Service Charge", "₹ 0.00"),
        _tableRow("Cash Paid to Customer",
            _extractValue(item.details, "Cash Received")),
      ],
    );
  }

  TableRow _tableHeader() {
    return const TableRow(
      decoration: BoxDecoration(color: Color(0xFFEFEFEF)),
      children: [
        _TableCell("Description", isHeader: true),
        _TableCell("Amount", isHeader: true),
      ],
    );
  }

  TableRow _tableRow(String left, String right) {
    return TableRow(
      children: [
        _TableCell(left),
        _TableCell(right),
      ],
    );
  }

  // Extract a field from details text
  String _extractValue(String details, String field) {
    try {
      final line = details.split("\n").firstWhere((l) => l.startsWith(field));
      return line.split(":")[1].trim();
    } catch (_) {
      return "N/A";
    }
  }

  // SUMMARY
// Widget _buildSummary() {
//   final cash = _extractValue(item.details, "Cash Received");

//   return Center(
//     child: Container(
//       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           const _SummaryRow(label: "Service Fee", value: "₹ 0.00", center: true),
//           _SummaryRow(label: "Cash Paid", value: cash, center: true),
//           const Divider(),
//           _SummaryRow(
//             label: "TOTAL PAYOUT",
//             value: cash,
//             bold: true,
//             big: true,
//             center: true,
//           ),
//         ],
//       ),
//     ),
//   );
// }
Widget _buildSummary() {
  final cash = _extractValue(item.details, "Cash Received");

  return Center(
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const _SummaryRow(label: "Service Fee", value: "₹ 0.00", center: true),
          _SummaryRow(label: "Cash Paid", value: cash, center: true),
          const Divider(),
          _SummaryRow(
            label: "TOTAL PAYOUT",
            value: cash,
            bold: true,
            big: true,
            center: true,
          ),
        ],
      ),
    ),
  );
}


}

class _TableCell extends StatelessWidget {
  final String text;
  final bool isHeader;

  const _TableCell(this.text, {this.isHeader = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
          fontSize: isHeader ? 16 : 15,
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;
  final bool big;
  final bool center;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.bold = false,
    this.big = false,
    this.center = false,
  });

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontWeight: bold ? FontWeight.bold : FontWeight.normal,
      fontSize: big ? 18 : 16,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment:
            center ? MainAxisAlignment.center : MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              textAlign: center ? TextAlign.center : TextAlign.left,
              style: style,
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: center ? TextAlign.center : TextAlign.right,
              style: style,
            ),
          ),
        ],
      ),
    );
  }
}

