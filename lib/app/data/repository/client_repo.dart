import 'package:invoice_app/app/data/models/model.dart';
import 'package:invoice_app/app/data/provider/client_provider.dart';

class ClientRepo {
  const ClientRepo({required this.provider});

  final ClientProvider provider;

  add(Client client) => provider.add(client);

  delete(String id) => provider.delete(id);

  Stream<Client> get stream => provider.stream;
}
