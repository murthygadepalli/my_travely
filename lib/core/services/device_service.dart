import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';

class DeviceInfoHelper {
  static final DeviceInfoPlugin _deviceInfoPlugin = DeviceInfoPlugin();

  static Future<Map<String, dynamic>> getDeviceInfo() async {
    try {
      if (Platform.isAndroid) {
        final android = await _deviceInfoPlugin.androidInfo;
        return {
          "deviceModel": android.model ?? "",
          "deviceFingerprint": android.fingerprint ?? "",
          "deviceBrand": android.brand ?? "",
          "deviceId": android.id ?? "",
          "deviceName": android.device ?? "",
          "deviceManufacturer": android.manufacturer ?? "",
          "deviceProduct": android.product ?? "",
          "deviceSerialNumber": android.serialNumber ?? "unknown",
        };
      } else if (Platform.isIOS) {
        final ios = await _deviceInfoPlugin.iosInfo;
        return {
          "deviceModel": ios.utsname.machine ?? "",
          "deviceFingerprint": ios.identifierForVendor ?? "",
          "deviceBrand": "Apple",
          "deviceId": ios.identifierForVendor ?? "",
          "deviceName": ios.name ?? "",
          "deviceManufacturer": "Apple",
          "deviceProduct": ios.systemName ?? "",
          "deviceSerialNumber": ios.identifierForVendor ?? "unknown",
        };
      } else {
        return {};
      }
    } catch (e) {
      return {};
    }
  }
}
