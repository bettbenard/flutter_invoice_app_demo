import 'package:data_table_2/data_table_2.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:input_quantity/input_quantity.dart';
import 'package:invoice_app/app/data/models/model.dart';
import 'package:invoice_app/app/modules/home/controllers/home_controller.dart';
import 'package:invoice_app/app/routes/app_pages.dart';
import 'package:phone_numbers_parser/phone_numbers_parser.dart';

import './../../../utils/util.dart' as utils;

class EditorView extends GetResponsiveView<HomeController> {
  EditorView({super.key}) : super(alwaysUseBuilder: false) {
    //controller.invoice = Get.arguments;
    print(Get.arguments);
  }

  @override
  Widget phone() => _scaffold(_form());

  @override
  Widget tablet() => _scaffold(
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: _form(),
          ),
        ),
      );

  @override
  Widget desktop() => _scaffold(
        Row(
          children: [
            const Expanded(child: SizedBox.shrink()),
            Expanded(
              flex: 3,
              child: Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: _form(),
                    ),
                  ),
                ),
              ),
            ),
            const Expanded(child: SizedBox.shrink()),
          ],
        ),
      );

  Widget _scaffold(Widget child) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          controller.isNew ? 'New Invoice' : 'Edit Invoice',
          style: GoogleFonts.orbitron(
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          onPressed: () {
            controller.invoice = null;
            Get.offAndToNamed(Routes.HOME);
          },
          icon: const Icon(Icons.close),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: child,
          ),
        ),
      ),
    );
  }

  Widget _form() {
    return Obx(
      () => Form(
        key: controller.formKey,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  flex: 2,
                  child: ListTile(
                    title: const Text('Invoice Number'),
                    subtitle: Text('${controller.invoice!.id}'),
                  ),
                ),
                Expanded(
                  child: ListTile(
                    title: const Text('Invoice Date'),
                    subtitle: Text(
                      utils.formatDate(
                        controller.isNew
                            ? DateTime.now()
                            : controller.invoice!.createdAt,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const Padding(
              padding:
                  EdgeInsets.only(left: 3.0, right: 3.0, top: 3.0, bottom: 9.0),
              child: Divider(),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: SearchAnchor(
                    isFullScreen: false,
                    builder: (BuildContext context,
                        SearchController searchController) {
                      if (!controller.isNew &&
                          controller.invoice != null &&
                          controller.invoice!.clientId.isNotEmpty) {
                        final client =
                            controller.clientById(controller.invoice!.clientId);
                        searchController.text = client!.name;
                      }

                      return SearchBar(
                        controller: searchController,
                        hintText: 'Search Client',
                        padding: const WidgetStatePropertyAll<EdgeInsets>(
                          EdgeInsets.symmetric(horizontal: 16.0),
                        ),
                        onTap: () {
                          searchController.openView();
                        },
                        onChanged: (_) {
                          searchController.openView();
                        },
                        leading: const Icon(Icons.search),
                        trailing: [
                          IconButton(
                            onPressed: () async {
                              await _addClient();
                            },
                            tooltip: 'Add Client',
                            icon: const Icon(Icons.add),
                          ),
                        ],
                      );
                    },
                    suggestionsBuilder: (BuildContext context,
                        SearchController searchController) {
                      return controller.clients.isEmpty
                          ? List<ListTile>.generate(
                              1,
                              (index) => const ListTile(
                                title: Text('No Registered clients'),
                                subtitle: Text(
                                    'Click on the (+) button to add a new client'),
                              ),
                            )
                          : List<ListTile>.generate(
                              controller.clients.length,
                              (index) {
                                final client = controller.clients[index];
                                return ListTile(
                                  title: Text(client.name),
                                  subtitle: Text(client.pin),
                                  onTap: () {
                                    controller.updateInvoiceClient(client.pin);
                                    searchController.closeView(client.name);
                                  },
                                );
                              },
                            );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 180,
                  child: TextFormField(
                    controller: controller.dueDateCtl,
                    readOnly: true,
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      labelText: 'Due Date',
                      suffixIcon: IconButton(
                        onPressed: () async {
                          await _pickDueDate();
                        },
                        icon: const Icon(Icons.date_range),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Item Entries',
                  style: GoogleFonts.orbitron(
                    fontSize: 21.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(
                  width: 240,
                  child: _itemSearchWidget(),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 180,
              child: _itemEntryDataTable(),
            ),
            const SizedBox(height: 9),
            if (controller.subTotals != 0.0) _subTotals(),
            const SizedBox(height: 24),
            Align(
              alignment: Alignment.center,
              child: FilledButton.icon(
                onPressed: () {
                  if (controller.isNew
                      ? controller.canCreateInvoice()
                      : controller.canUpdateInvoice()) {
                    controller.isNew
                        ? controller.saveInvoice()
                        : controller.updateInvoice();
                  } else {
                    Get.snackbar('Cannot create invoice',
                        controller.createInvoiceWarning());
                  }
                },
                label: const Text('Save Invoice'),
                icon: const Icon(Icons.add),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _itemEntryDataTable() {
    final columnStyle = GoogleFonts.orbitron(
      fontWeight: FontWeight.bold,
      fontStyle: FontStyle.italic,
      fontSize: 15,
    );

    return LayoutBuilder(builder: (context, constraints) {
      return ConstrainedBox(
        constraints: BoxConstraints(minWidth: constraints.maxWidth),
        child: DataTable2(
          columnSpacing: 12,
          horizontalMargin: 12,
          //minWidth: 900,
          dataRowHeight: 60,
          columns: <DataColumn>[
            DataColumn2(
              label: Text(' Description  ', style: columnStyle),
              size: ColumnSize.L,
              fixedWidth: 180,
            ),
            DataColumn(
              label: Text('Price', style: columnStyle),
            ),
            DataColumn(
              label: Text('VAT', style: columnStyle),
            ),
            DataColumn(
              label: Text('Quantity', style: columnStyle),
            ),
            DataColumn2(
              label: Text('Total', style: columnStyle),
              size: ColumnSize.L,
            ),
            // const DataColumn2(label: Text(''), size: ColumnSize.M),
          ],
          rows: controller.invoice!.itemEntries.map((e) {
            final item = controller.itemById(e.itemId);
            final vatRate = item!.vat.rate;
            return DataRow(
              cells: <DataCell>[
                DataCell(
                  Text(item.description),
                  onTap: () {},
                ),
                DataCell(
                  Text('${e.unitPrice}'),
                  onTap: () {},
                ),
                DataCell(
                  Text('$vatRate'),
                  onTap: () {},
                ),
                DataCell(
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: InputQty(
                      maxVal: 100,
                      initVal: e.quantity,
                      minVal: 1,
                      onQtyChanged: (val) {
                        controller.updateQty(e, val);
                      },
                    ),
                  ),
                ),
                DataCell(
                  Row(
                    children: [
                      Text(
                        utils.twoDecimals(
                          utils.calculateItemSubTotal(
                              e.unitPrice, vatRate, e.quantity),
                        ),
                      ),
                      const SizedBox(width: 6),
                      IconButton(
                        onPressed: () => controller.removeItemEntry(e.id),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  onTap: () {},
                ),
                // DataCell(
                //   IconButton(
                //     onPressed: () => controller.removeItemEntry(e.id),
                //     icon: const Icon(Icons.close),
                //   ),
                // ),
              ],
            );
          }).toList(),
        ),
      );
    });
  }

  _addClient() async {
    controller.priCtl.text = 'P${controller.generateInvoiceNumber()}';
    showModalBottomSheet<void>(
      context: Get.context!,
      isDismissible: false,
      builder: (BuildContext context) {
        return _createClientWidget();
      },
    );
  }

  _pickDueDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: Get.context!,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(
        const Duration(days: 30),
      ),
      initialDate: DateTime.now(),
    );
    if (pickedDate == null) return;
    controller.dueDateCtl.text = utils.formatDate(pickedDate);
  }

  Widget _itemSearchWidget() {
    return SearchAnchor(
      isFullScreen: false,
      builder: (cntx, searchCtl) => SearchBar(
        controller: searchCtl,
        hintText: 'Add Item',
        padding: const WidgetStatePropertyAll<EdgeInsets>(
          EdgeInsets.symmetric(horizontal: 16.0),
        ),
        onTap: () => searchCtl.openView(),
        onChanged: (_) => searchCtl.openView(),
        trailing: [
          IconButton(
            onPressed: () {
              showModalBottomSheet(
                context: Get.context!,
                isDismissible: false,
                builder: (BuildContext context) {
                  return _createItemWidget();
                },
              );
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      suggestionsBuilder: (cntx, searchCtl) {
        final selectedItemIds =
            controller.invoice!.itemEntries.map((e) => e.itemId).toSet();
        final unselectedItems = controller.items
            .where((e) => !selectedItemIds.contains(e.id))
            .toList();

        return unselectedItems.isEmpty
            ? List<ListTile>.generate(
                1,
                (index) => const ListTile(
                  title: Text('No items to select'),
                  subtitle: Text('Click on the add (+) icon to add more items'),
                ),
              )
            : List<ListTile>.generate(
                unselectedItems.length,
                (index) {
                  final item = unselectedItems[index];
                  return ListTile(
                    title: Text(item.description),
                    subtitle: Text('${utils.currency} ${item.unitPrice}'),
                    dense: true,
                    onTap: () {
                      controller.addItemEntry(ItemEntry.fromItem(item));
                      searchCtl.closeView(null);
                    },
                  );
                },
              );
      },
    );
  }

  Widget _createItemWidget() {
    return Container(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(40.0),
          topRight: Radius.circular(40.0),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Obx(
          () => Form(
            key: controller.formKeySec,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    IconButton(
                      onPressed: () => Get.back(),
                      tooltip: 'Cancel Item Registration',
                      icon: const Icon(Icons.close),
                    ),
                    const SizedBox(width: 30.0),
                    Text(
                      'New Item',
                      style: GoogleFonts.orbitron(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: controller.priCtl,
                        decoration: const InputDecoration(
                          labelText: 'Item Description',
                          icon: Icon(Icons.inventory_outlined),
                        ),
                      ),
                    ),
                    const SizedBox(width: 18),
                    SizedBox(
                      width: 180,
                      child: TextFormField(
                        controller: controller.secCtl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Unit Price',
                          icon: Icon(Icons.payments_outlined),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: 360,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: SwitchListTile(
                      controlAffinity: ListTileControlAffinity.leading,
                      title: Text(controller.vat == Vat.standard
                          ? 'Standard Tax'
                          : 'Zero-Rated'),
                      value: controller.vat == Vat.standard,
                      onChanged: (value) =>
                          controller.vat = value ? Vat.standard : Vat.zeroRated,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Align(
                  alignment: Alignment.center,
                  child: FilledButton.icon(
                    onPressed: () {
                      if (controller.formKeySec.currentState!.validate()) {
                        controller.saveItem();
                        Get.back();
                      }
                    },
                    label: const Text('\t\t\tSubmit\t\t\t'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _createClientWidget() {
    return Container(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(40.0),
          topRight: Radius.circular(40.0),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Form(
          key: controller.formKeySec,
          child: Column(
            //mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  IconButton(
                    onPressed: () => Get.back(),
                    tooltip: 'Cancel Client Registration',
                    icon: const Icon(Icons.close),
                  ),
                  const SizedBox(width: 30.0),
                  Text(
                    'New Client',
                    style: GoogleFonts.orbitron(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: controller.priCtl,
                      readOnly: true,
                      decoration: const InputDecoration(
                        //border: OutlineInputBorder(),
                        labelText: 'PIN',
                        icon: Icon(Icons.wallet),
                      ),
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            value == '0' ||
                            value.length < 3) {
                          return 'Valid PIN is required!';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 18),
                  Expanded(
                    child: TextFormField(
                      controller: controller.secCtl,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        //border: OutlineInputBorder(),
                        labelText: 'Name',
                        icon: Icon(Icons.store),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Client name is required!';
                        }
                        if (value.length < 2) {
                          return 'Should be atleast 3 characters';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: controller.terCtl,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        //border: OutlineInputBorder(),
                        labelText: 'Email',
                        icon: Icon(Icons.email_outlined),
                      ),
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            !EmailValidator.validate(value.trim())) {
                          return 'Valid email required';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: TextFormField(
                      controller: controller.quaCtl,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        //border: OutlineInputBorder(),
                        labelText: 'Phone Number',
                        icon: Icon(Icons.phone),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Phone number required!';
                        }
                        final phone = PhoneNumber.parse(
                          value.trim(),
                          callerCountry: IsoCode.KE,
                        );
                        if (!phone.isValid()) {
                          return 'Valid number required!';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  maxLength: 60,
                  controller: controller.addressCtl,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Physical Address',
                    icon: Icon(Icons.business_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Required field!';
                    }
                    if (value.trim().length < 3) {
                      return 'Provide a more elaborative address!';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 24),
              Align(
                alignment: Alignment.center,
                child: FilledButton.icon(
                  onPressed: () {
                    // returns true if valid
                    if (controller.formKeySec.currentState!.validate()) {
                      controller.saveClient();
                      Get.back();
                    }
                  },
                  label: const Text('\t\t\tSubmit\t\t\t'),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _subTotals() {
    const style = TextStyle(fontWeight: FontWeight.bold);
    return Align(
      alignment: Alignment.topRight,
      child: SizedBox(
        width: 300,
        child: ListView(
          shrinkWrap: true,
          children: [
            ListTile(
              title: const Text(
                'Sub Total',
                style: style,
              ),
              trailing: Text(
                utils.twoDecimals(controller.subTotals),
                style: style,
              ),
              dense: true,
            ),
            ListTile(
              title: const Text(
                'VAT',
                style: style,
              ),
              trailing: Text(
                utils.twoDecimals(controller.totalVat),
                style: style,
              ),
              dense: true,
            ),
            ListTile(
              title: const Text(
                'Total Amount',
                style: style,
              ),
              trailing: Text(
                utils.twoDecimals(controller.subTotals + controller.totalVat),
                style: style,
              ),
              dense: true,
            ),
          ],
        ),
      ),
    );
  }
}
