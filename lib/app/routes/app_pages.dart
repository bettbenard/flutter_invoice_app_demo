import 'package:get/get.dart';

import '../modules/editor/views/editor_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/viewer/views/viewer_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.HOME;

  static final routes = [
    GetPage(
      name: _Paths.HOME,
      page: () => HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.EDITOR,
      page: () => EditorView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.VIEWER,
      page: () => ViewerView(),
      binding: HomeBinding(),
    ),
  ];
}
