import 'package:invoice_app/app/data/models/model.dart';
import 'package:invoice_app/app/data/provider/item_provider.dart';

class ItemRepo {
  const ItemRepo({required this.provider});

  final ItemProvider provider;

  add(Item item) => provider.add(item);

  delete(String id) => provider.delete(id);

  Stream<Item> get stream => provider.stream;
}
