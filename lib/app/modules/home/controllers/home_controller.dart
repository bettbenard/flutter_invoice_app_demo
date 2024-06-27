import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:invoice_app/app/data/models/model.dart';
import 'package:invoice_app/app/data/repository/client_repo.dart';
import 'package:invoice_app/app/data/repository/invoice_repo.dart';
import 'package:invoice_app/app/data/repository/item_repo.dart';
import 'package:invoice_app/app/routes/app_pages.dart';

import '../../../utils/util.dart' as utils;

class HomeController extends GetxController {
  HomeController({
    required this.clientRepo,
    required this.itemRepo,
    required this.invoiceRepo,
  });

  final ClientRepo clientRepo;
  final ItemRepo itemRepo;
  final InvoiceRepo invoiceRepo;

  final _clients = <Client>[].obs;
  final _items = <Item>[].obs;
  final _invoices = <Invoice>[].obs;

  final _invoice = Rxn<Invoice>();
  final _selectedInvoice = Rxn<Invoice>();
  final _vat = Rxn<Vat>();
  final _isNew = true.obs;

  final formKey = GlobalKey<FormState>();
  final formKeySec = GlobalKey<FormState>();
  final priCtl = TextEditingController();
  final secCtl = TextEditingController();
  final terCtl = TextEditingController();
  final quaCtl = TextEditingController();
  final addressCtl = TextEditingController();
  final dueDateCtl = TextEditingController();

  final _totalVat = 0.0.obs;
  final _subTotals = 0.0.obs;

  @override
  void onInit() {
    super.onInit();

    ever(_invoice, (value) {
      if (value == null) {
        _clearCtls(true);
        _initInvoice();
        //_invoice.refresh();
      } else {
        dueDateCtl.text = utils.formatDate(value.dueDate);
        _calculateTotals();
      }
    });

    clientRepo.stream.listen((event) {
      final index = _clients.indexWhere((e) => e.pin == event.key);
      if (index == -1) {
        _clients.add(event);
      } else {
        _clients[index] = event;
      }
    });

    itemRepo.stream.listen((event) {
      final index = _items.indexWhere((e) => e.id == event.key);
      if (index == -1) {
        _items.add(event);
      } else {
        _items[index] = event;
      }
    });

    invoiceRepo.stream.listen((event) {
      if (!event.deleted) {
        final index = _invoices.indexWhere((e) => e.id == event.key);
        if (index == -1) {
          _invoices.add(event.value);
        } else {
          _invoices[index] = event.value;
        }
      } else {
        _invoices.removeWhere((e) => e.key == event.key);
      }
    });
  }

  _initInvoice() {
    _isNew.value = true;
    _invoice.value = Invoice(
      generateInvoiceNumber(),
      '',
      <ItemEntry>[],
      DateTime.now(),
      DateTime.now(),
    );
    _resetSubTotals();
  }

  _calculateTotals() {
    if (invoice != null) {
      _resetSubTotals();
      for (var e in invoice!.itemEntries) {
        _totalVat.value +=
            utils.calculateTaxAmount(e.unitPrice, e.vat.rate) * e.quantity;
        _subTotals.value += e.unitPrice * e.quantity;
      }
    }
  }

  _resetSubTotals() {
    _subTotals.value = 0.0;
    _totalVat.value = 0.0;
  }

  /// Generate a unique invoice number in the range of 100k & 1M
  int generateInvoiceNumber() {
    int id = utils.generateRandomNumber();
    if (invoiceRepo.keys.contains(id)) {
      return generateInvoiceNumber();
    }
    return id;
  }

  updateInvoiceClient(String pin) {
    _invoice.update((value) {
      value!.clientId = pin;
    });
    //_invoice.refresh();
  }

  addItemEntry(ItemEntry itemEntry) {
    final index = invoice!.itemEntries.indexWhere((e) => e.id == itemEntry.id);
    if (index == -1) {
      invoice!.itemEntries.add(itemEntry);
    } else {
      invoice!.itemEntries[index] = itemEntry;
    }
    _calculateTotals();
    _invoice.refresh();
  }

  updateQty(ItemEntry entry, int qty) {
    final updated = entry.copyWithQty(qty);
    invoice!.itemEntries[
        invoice!.itemEntries.indexWhere((e) => e.id == entry.id)] = updated;
    _calculateTotals();
    _invoice.refresh();
  }

  removeItemEntry(String itemEntryId) {
    invoice!.itemEntries.removeWhere((e) => e.id == itemEntryId);
    _calculateTotals();
    _invoice.refresh();
  }

  canCreateInvoice() {
    return invoice != null &&
        invoice!.itemEntries.isNotEmpty &&
        invoice!.clientId.isNotEmpty;
  }

  canUpdateInvoice() {
    return !isNew &&
        invoice != null &&
        selectedInvoice != null &&
        ((invoice!.clientId != selectedInvoice!.clientId) ||
            (invoice!.dueDate != selectedInvoice!.dueDate) ||
            (invoice!.itemEntries != selectedInvoice!.itemEntries));
  }

  String createInvoiceWarning() {
    var fields = <String>[];
    if (invoice!.clientId.isEmpty) fields.add('Client');
    if (dueDateCtl.text.isEmpty) fields.add('Due Date');
    if (invoice!.itemEntries.isEmpty) fields.add('Items');
    return '$fields required to create the invoice!';
  }

  saveInvoice() {
    if (invoice != null) {
      invoiceRepo.add(invoice!);
      invoice = null;
      Get.offNamed(Routes.HOME);
    }
  }

  updateInvoice() {
    invoiceRepo.add(invoice!);
  }

  saveClient() async {
    final client = Client(
      priCtl.text.trim(),
      secCtl.text.trim(),
      terCtl.text.trim(),
      quaCtl.text.trim(),
      addressCtl.text.trim(),
    );
    await clientRepo.add(client);
    _clearCtls(false);
  }

  saveItem() {
    final item = Item(
      utils.uid,
      priCtl.text.trim(),
      double.parse(secCtl.text.trim()),
      vat!,
    );
    itemRepo.add(item);
    _clearCtls(false);
  }

  _clearCtls(bool includeDueDate) {
    priCtl.clear();
    secCtl.clear();
    terCtl.clear();
    quaCtl.clear();
    addressCtl.clear();
    if (includeDueDate) dueDateCtl.clear();
  }

  bool get isNew => _isNew.value;

  set isNew(bool value) => _isNew.value = value;

  Invoice? get invoice => _invoice.value;

  set invoice(Invoice? value) => _invoice.value = value;

  Invoice? get selectedInvoice => _selectedInvoice.value;

  set selectedInvoice(Invoice? value) => _selectedInvoice.value = value;

  List<Client> get clients => _clients;

  List<Item> get items => _items;

  List<Invoice> get invoices => _invoices;

  Vat? get vat => _vat.value;

  set vat(Vat? value) => _vat.value = value;

  Client? clientById(String pin) => _clients.firstWhere((e) => e.pin == pin);

  Item? itemById(String id) => _items.firstWhere((e) => e.id == id);

  double get subTotals => _subTotals.value;

  double get totalVat => _totalVat.value;
}
