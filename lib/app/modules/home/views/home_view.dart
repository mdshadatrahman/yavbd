import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return controller.goBack(context);
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Obx(
            () => controller.isLoading.value
                ? Container(
                    height: Get.height,
                    width: Get.width,
                    color: Colors.black,
                    child: const Center(
                      child: SpinKitSpinningLines(
                        color: Colors.white,
                      ),
                    ),
                  )
                : WebViewWidget(controller: controller.controller),
          ),
        ),
      ),
    );
  }
}
