import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:invoice_app/app/data/models/model.dart';
import 'package:invoice_app/app/modules/home/bindings/home_binding.dart';

import 'app/routes/app_pages.dart';

void main() async {
  // initialize Flutter
  await Hive.initFlutter();

  // register Hive adapters
  _registerHiveAdapters();

  // open hive boxes
  await _openHiveBoxes();

  runApp(
    GetMaterialApp(
      title: "Invoice App",
      debugShowCheckedModeBanner: false,
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
      initialBinding: HomeBinding(),
    ),
  );
}

_registerHiveAdapters() {
  Hive.registerAdapter(VatAdapter());
  Hive.registerAdapter(ClientAdapter());
  Hive.registerAdapter(ItemAdapter());
  Hive.registerAdapter(ItemEntryAdapter());
  Hive.registerAdapter(InvoiceAdapter());
}

_openHiveBoxes() async {
  Get.put<Box<Client>>(
    await Hive.openBox<Client>(clientBox),
    permanent: true,
  );
  Get.put<Box<Item>>(
    await Hive.openBox<Item>(itemBox),
    permanent: true,
  );
  Get.put<Box<Invoice>>(
    await Hive.openBox<Invoice>(invoiceBox),
    permanent: true,
  );
}
