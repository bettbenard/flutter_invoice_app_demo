import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:invoice_app/app/data/models/model.dart';

class InvoiceProvider {
  final box = Get.find<Box<Invoice>>();

  add(Invoice invoice) => box.put(invoice.id, invoice);

  delete(String id) => box.delete(id);

  List<int> get keys => box.keys.map((e) => e as int).toList();

  Stream<BoxEvent> get stream => box.watch();
}
