import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:yalla_now_delivery/features/splash/controllers/splash_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NetworkInfoHelper {
  final Connectivity connectivity;
  NetworkInfoHelper(this.connectivity);

  Future<bool> get isConnected async {
    ConnectivityResult result = await connectivity.checkConnectivity();
    return result != ConnectivityResult.none;
  }

  static void checkConnectivity(BuildContext context) {
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      if (Get.find<SplashController>().firstTimeConnectionCheck) {
        Get.find<SplashController>().setFirstTimeConnectionCheck(false);
      } else {
        bool isNotConnected = result == ConnectivityResult.none;
        isNotConnected
            ? const SizedBox()
            : ScaffoldMessenger.of(Get.context!).hideCurrentSnackBar();
        ScaffoldMessenger.of(Get.context!).showSnackBar(SnackBar(
          backgroundColor: isNotConnected ? Colors.red : Colors.green,
          duration: Duration(seconds: isNotConnected ? 6000 : 3),
          content: Text(
            isNotConnected ? 'no_connection' : 'connected',
            textAlign: TextAlign.center,
          ),
        ));
      }
    });
  }

  static Future<Uint8List> compressImage(XFile file) async {
    final inputBytes = await file.readAsBytes();
    final inputSizeMB = inputBytes.length / 1048576;
    final quality = inputSizeMB < 2
        ? 90
        : inputSizeMB < 5
            ? 50
            : inputSizeMB < 10
                ? 10
                : 1;

    final result = await FlutterImageCompress.compressWithList(
      inputBytes,
      quality: quality,
      format: CompressFormat.webp,
    );

    if (kDebugMode) {
      print('Input size : $inputSizeMB');
      print('Output size : ${result.length / 1048576}');
    }
    return result;
  }
}
