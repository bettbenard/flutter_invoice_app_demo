import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:invoice_app/app/modules/home/controllers/home_controller.dart';

class ViewerView extends GetView<HomeController> {
  const ViewerView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ViewerView'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'ViewerView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
