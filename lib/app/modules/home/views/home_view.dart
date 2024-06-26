import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:invoice_app/app/data/models/model.dart';
import 'package:invoice_app/app/routes/app_pages.dart';

import '../controllers/home_controller.dart';

import '../../../utils/util.dart' as utils;

class HomeView extends GetResponsiveView<HomeController> {
  HomeView({super.key}) : super(alwaysUseBuilder: false);

  @override
  Widget? phone() {
    return _scaffold(controller.invoices.isEmpty
        ? _noDisplay(Alignment.center)
        : _showInvoices());
  }

  @override
  Widget? tablet() {
    return _scaffold(
      controller.invoices.isEmpty
          ? _noDisplay(Alignment.center)
          : Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.all(18.0),
                child: _showInvoices(),
              ),
            ),
    );
  }

  @override
  Widget? desktop() {
    return _scaffold(
      controller.invoices.isEmpty
          ? _noDisplay(Alignment.center)
          : Row(
              children: [
                const Expanded(child: SizedBox.shrink()),
                Expanded(
                  flex: 2,
                  child: _showInvoices(),
                ),
                const Expanded(child: SizedBox.shrink()),
              ],
            ),
    );
  }

  Widget _scaffold(Widget child) {
    return Scaffold(
      appBar: AppBar(
        elevation: 9,
        leading: const Icon(Icons.receipt),
        title: Text(
          'Invoices',
          style: GoogleFonts.orbitron(
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        //centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: FilledButton.icon(
              onPressed: () {
                controller.invoice = null;
                Get.toNamed(Routes.EDITOR, arguments: null);
              },
              label: Text('Create${Get.context!.isPhone ? '' : ' Invoice'}'),
              icon: const Icon(Icons.add),
            ),
          ),
        ],
      ),
      body: child,
    );
  }

  Widget _noDisplay(Alignment alignment) {
    return Align(
      alignment: alignment,
      child: Text(
        'There are no invoices to be viewed.',
        style: GoogleFonts.orbitron(
          fontSize: 21.0,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _showInvoices() {
    final columnStyle = GoogleFonts.orbitron(
      fontWeight: FontWeight.bold,
      fontStyle: FontStyle.italic,
      fontSize: 15,
    );

    goToInvoice(Invoice invoice) {
      controller.invoice = invoice;
      Get.toNamed(Routes.VIEWER);
    }

    return DataTable(
      columns: <DataColumn>[
        DataColumn(
          label: Expanded(
            child: Text('Client', style: columnStyle),
          ),
        ),
        DataColumn(
            label: Text(
          'Invoice Date',
          style: columnStyle,
        )),
        DataColumn(
            label: Text(
          'Total',
          style: columnStyle,
        )),
      ],
      rows: controller.invoices.map((e) {
        final client = controller.clientById(e.clientId);

        return DataRow(
          cells: <DataCell>[
            DataCell(Text(client!.name), onTap: () => goToInvoice(e)),
            DataCell(
              Text(utils.formatDate(e.createdAt)),
              onTap: () => goToInvoice(e),
            ),
            DataCell(
              Text('${utils.calculateInvoiceTotal(e.itemEntries)}'),
              onTap: () => goToInvoice(e),
            ),
          ],
        );
      }).toList(),
    );
  }
}
