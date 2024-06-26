import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:invoice_app/app/data/models/model.dart';

class ClientProvider {
  final box = Get.find<Box<Client>>();

  add(Client client) => box.put(client.pin, client);

  delete(String id) => box.delete(id);

  Stream<Client> get stream async* {
    await for (final event in box.watch()) {
      yield event.value as Client;
    }
  }
}
