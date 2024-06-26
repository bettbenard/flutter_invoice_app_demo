import 'package:hive/hive.dart';
import 'package:invoice_app/app/data/models/model.dart';
import 'package:invoice_app/app/data/provider/invoice_provider.dart';

class InvoiceRepo {
  const InvoiceRepo({required this.provider});

  final InvoiceProvider provider;

  add(Invoice invoice) => provider.add(invoice);

  delete(String id) => provider.delete(id);

  List<int> get keys => provider.keys;

  Stream<BoxEvent> get stream => provider.stream;
}
