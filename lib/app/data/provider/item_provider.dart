import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:invoice_app/app/data/models/model.dart';

class ItemProvider {
  final box = Get.find<Box<Item>>();

  add(Item item) => box.put(item.id, item);

  delete(String id) => box.delete(id);

  Item? getById(String id) => box.get(id);

  Stream<Item> get stream async* {
    await for (final event in box.watch()) {
      yield event.value as Item;
    }
  }
}
