// ignore_for_file: prefer_const_constructors, use_build_context_synchronously

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:developer' as developer show log;

class HomeController extends GetxController {
  late final WebViewController controller;
  RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    instantiateController();
  }

  instantiateController() {
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            CircularProgressIndicator(
              value: progress / 100,
              color: Colors.black,
            );
          },
          onPageStarted: (String url) {},
          onPageFinished: (String url) {
            isLoading.value = false;
          },
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith('tel:')) {
              makePhoneCall(request.url);
              return NavigationDecision.prevent;
            } else if (request.url.startsWith('https://wa.me/') ||
                request.url.startsWith('whatsapp://send/?phone') ||
                request.url.startsWith('https://api.whatsapp.com/')) {
              launchWhatsApp(request.url);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse('https://yavbd.org/'));
  }

  launchWhatsApp(String url) async {
    RegExp regex = RegExp(r'\d{13}');
    String? phoneNumber = regex.stringMatch(url);
    try {
      await launchUrl(Uri.parse('whatsapp://send?phone=$phoneNumber&text='));
    } on Exception {
      SnackBar(
        content: Text('WhatsApp is not installed'),
      );
    }
  }

  makePhoneCall(String phoneNumber) async {
    if (phoneNumber.contains('tel:')) {
      phoneNumber = phoneNumber.replaceAll('tel:', '');
    }
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    await launchUrl(launchUri);
  }

  Future<bool> goBack(BuildContext context) async {
    if (await controller.canGoBack()) {
      controller.goBack();
      return Future.value(false);
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Do you want to exit'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('No'),
            ),
            TextButton(
              onPressed: () {
                SystemNavigator.pop();
              },
              child: Text('Yes'),
            ),
          ],
        ),
      );
      return Future.value(true);
    }
  }
}
