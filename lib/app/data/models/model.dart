import 'package:hive/hive.dart';

import '../../utils/util.dart' as utils;

part 'model.g.dart';

const String vatBox = 'vatBox';
const String clientBox = 'clientBox';
const String itemBox = 'itemBox';
const String invoiceBox = 'invoiceBox';

const vatTypeId = 0;
const clientTypeId = 1;
const itemTypeId = 2;
const itemEntryTypeId = 3;
const invoiceTypeId = 4;

@HiveType(typeId: vatTypeId)
enum Vat {
  @HiveField(0, defaultValue: true)
  standard,

  @HiveField(1)
  zeroRated;

  double get rate => this == Vat.standard ? 16.0 : 0.0;
}

@HiveType(typeId: clientTypeId)
class Client extends HiveObject {
  @HiveField(0)
  String pin;

  @HiveField(1)
  String name;

  @HiveField(2)
  String email;

  @HiveField(3)
  String msisdn;

  @HiveField(4)
  String address;

  Client(this.pin, this.name, this.email, this.msisdn, this.address);

  @override
  String toString() {
    return 'Client[pin: $pin, name: $name, email: $email, msisdn: $msisdn, address: $address]';
  }
}

@HiveType(typeId: itemTypeId)
class Item extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String description;

  @HiveField(2)
  double unitPrice;

  @HiveField(3)
  Vat vat;

  Item(this.id, this.description, this.unitPrice, this.vat);

  @override
  String toString() {
    return 'Item[id: $id, desc: $description, unitPrice: $unitPrice, vat: ${vat.name}]';
  }
}

@HiveType(typeId: itemEntryTypeId)
class ItemEntry extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String itemId;

  @HiveField(2)
  int quantity;

  @HiveField(3)
  double unitPrice;

  @HiveField(4)
  Vat vat;

  ItemEntry(this.id, this.itemId, this.quantity, this.unitPrice, this.vat);

  factory ItemEntry.fromItem(Item item) =>
      ItemEntry(utils.uid, item.id, 1, item.unitPrice, item.vat);

  ItemEntry copyWithQty(int quantity) =>
      ItemEntry(id, itemId, quantity, unitPrice, vat);

  double get totalNet => quantity * unitPrice;

  @override
  String toString() =>
      'ItemEntry [id: $id, itemId: $itemId, quantity: $quantity, unitPrice: $unitPrice, vat: ${vat.name}]';
}

@HiveType(typeId: invoiceTypeId)
class Invoice extends HiveObject {
  @HiveField(0)
  int id;

  @HiveField(1)
  String clientId;

  @HiveField(2, defaultValue: <ItemEntry>[])
  List<ItemEntry> itemEntries;

  @HiveField(3)
  DateTime dueDate;

  @HiveField(4)
  DateTime createdAt;

  Invoice(
    this.id,
    this.clientId,
    this.itemEntries,
    this.dueDate,
    this.createdAt,
  );

  Invoice copyWithEntries(List<ItemEntry> entries) =>
      Invoice(id, clientId, entries, dueDate, createdAt);

  Invoice copyWithRemovedItemEntry(String itemEntryId) {
    itemEntries.removeWhere((e) => e.id == itemEntryId);
    return Invoice(id, clientId, itemEntries, dueDate, createdAt);
  }

  Invoice copyWithClientId(String clientId) =>
      Invoice(id, clientId, itemEntries, dueDate, createdAt);

  Invoice copyWithDueDate(DateTime dueDate) =>
      Invoice(id, clientId, itemEntries, dueDate, createdAt);

  @override
  String toString() {
    return 'Invoice [id: $id, clientId: $clientId, issueDate: $createdAt, dueDate: $dueDate, entries: $itemEntries]';
  }
}
