import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:invoice_app/app/modules/global_widget/sub_totals.dart';
import 'package:invoice_app/app/modules/home/controllers/home_controller.dart';
import 'package:invoice_app/app/routes/app_pages.dart';

import '../../../utils/util.dart' as utils;

class ViewerView extends GetResponsiveView<HomeController> {
  ViewerView({super.key}) : super(alwaysUseBuilder: false);

  @override
  Widget? phone() => _scaffold(_invoiceCard());

  @override
  Widget? tablet() => _scaffold(
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: _invoiceCard(),
        ),
      );

  @override
  Widget? desktop() => _scaffold(
        Row(
          children: [
            const Expanded(child: SizedBox.shrink()),
            Expanded(
              flex: 3,
              child: _invoiceCard(),
            ),
            const Expanded(child: SizedBox.shrink()),
          ],
        ),
      );

  Widget _scaffold(Widget child) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Invoice',
          style: GoogleFonts.orbitron(
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          onPressed: () {
            controller.invoice = null;
            Get.toNamed(Routes.HOME);
          },
          icon: const Icon(Icons.close),
        ),
        actions: [
          IconButton(
            onPressed: () async {
              //TODO
            },
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: 'Generate PDF',
          ),
          IconButton(
            onPressed: () {
              controller.isNew = true;
              Get.toNamed(Routes.EDITOR);
            },
            icon: const Icon(Icons.edit),
            tooltip: 'Edit Invoice',
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: child,
          ),
        ),
      ),
    );
  }

  Widget _invoiceCard() {
    final invoice = controller.invoice!;
    final client = controller.clientById(invoice.clientId);

    const columnStyle = TextStyle(
      fontStyle: FontStyle.italic,
      fontWeight: FontWeight.bold,
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Row(
              children: [
                Expanded(
                  child: ListTile(
                    title: const Text('Invoice Number'),
                    subtitle: client == null
                        ? const SizedBox.shrink()
                        : Text(client.name),
                  ),
                ),
                Expanded(
                  child: ListTile(
                    title: const Text('Client'),
                    subtitle: Text('${client!.name}\n${client.address}'),
                    trailing: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(client.email),
                        Text(client.msisdn),
                      ],
                    ),
                    isThreeLine: true,
                  ),
                ),
              ],
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: ListTile(
                    title: const Text('Issued On'),
                    subtitle: Text(utils.formatDate(invoice.createdAt)),
                  ),
                ),
                Expanded(
                  child: ListTile(
                    title: const Text('Due Date'),
                    subtitle: Text(utils.formatDate(invoice.dueDate)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Padding(
              padding: const EdgeInsets.only(left: 12.0, bottom: 3.0),
              child: Text(
                'Invoice Items',
                style: GoogleFonts.orbitron(
                  fontSize: 16.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            DataTable(
              horizontalMargin: 3,
              //columnSpacing: 45,
              columns: const <DataColumn>[
                DataColumn(
                  label: Expanded(
                    flex: 3,
                    child: Text('Description', style: columnStyle),
                  ),
                ),
                DataColumn(
                  label: Expanded(
                    child: Text('Price', style: columnStyle),
                  ),
                ),
                DataColumn(
                  label: Expanded(
                    child: Text('VAT', style: columnStyle),
                  ),
                ),
                DataColumn(
                  label: Expanded(
                    child: Text('Qty', style: columnStyle),
                  ),
                ),
                DataColumn(
                  label: Expanded(
                    flex: 2,
                    child: Text('Total', style: columnStyle),
                  ),
                ),
              ],
              rows: List<DataRow>.generate(
                invoice.itemEntries.length,
                (index) {
                  final itemEntry = invoice.itemEntries[index];
                  final item = controller.itemById(itemEntry.itemId)!;

                  return DataRow(
                    cells: <DataCell>[
                      DataCell(
                        Text(
                          item.description,
                          //textScaler: const TextScaler.linear(0.9),
                        ),
                      ),
                      DataCell(
                        Text(
                          utils.twoDecimals(itemEntry.unitPrice),
                          textScaler: const TextScaler.linear(0.9),
                        ),
                      ),
                      DataCell(
                        Text(
                          '${itemEntry.vat.rate}%',
                          textScaler: const TextScaler.linear(0.9),
                        ),
                      ),
                      DataCell(
                        Text(
                          '${itemEntry.quantity}',
                          textScaler: const TextScaler.linear(0.9),
                        ),
                      ),
                      DataCell(
                        Text(
                          utils.twoDecimals(
                            utils.calculateItemSubTotal(
                              itemEntry.unitPrice,
                              itemEntry.vat.rate,
                              itemEntry.quantity,
                            ),
                          ),
                          textScaler: const TextScaler.linear(0.9),
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            Align(
              alignment: Alignment.topCenter,
              child: subTotals(controller.subTotals, controller.totalVat),
            ),
          ],
        ),
      ),
    );
  }
}
