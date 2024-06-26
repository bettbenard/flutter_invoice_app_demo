import 'package:get/get.dart';
import 'package:invoice_app/app/data/provider/client_provider.dart';
import 'package:invoice_app/app/data/provider/invoice_provider.dart';
import 'package:invoice_app/app/data/provider/item_provider.dart';
import 'package:invoice_app/app/data/repository/client_repo.dart';
import 'package:invoice_app/app/data/repository/invoice_repo.dart';
import 'package:invoice_app/app/data/repository/item_repo.dart';

import '../controllers/home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<HomeController>(
      HomeController(
        clientRepo: ClientRepo(provider: ClientProvider()),
        itemRepo: ItemRepo(provider: ItemProvider()),
        invoiceRepo: InvoiceRepo(provider: InvoiceProvider()),
      ),
      permanent: true,
    );
  }
}
