import 'dart:async';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const HomePage());
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
  Map<String, dynamic> _deviceData = <String, dynamic>{};

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    var deviceData = <String, dynamic>{};

    try {
      if (Platform.isAndroid) {
        deviceData = _readAndroidBuildData(await deviceInfoPlugin.androidInfo);
      } else if (Platform.isIOS) {
        deviceData = _readIosDeviceInfo(await deviceInfoPlugin.iosInfo);
      }
    } on PlatformException {
      deviceData = <String, dynamic>{
        'Error:': 'Failed to get platform version.'
      };
    }

    if (!mounted) return;

    setState(() {
      _deviceData = deviceData;
    });
  }

  Map<String, dynamic> _readAndroidBuildData(AndroidDeviceInfo build) {
    return <String, dynamic>{
      'Security patch date: ': build.version.securityPatch,
      'SDK version: ': build.version.sdkInt,
      'Release version: ': build.version.release,
      'OS name: ': build.version.baseOS,
      'Brand name: ': build.brand,
      'Device: ': build.device,
      'Display: ': build.display,
      'Hardware name: ': build.hardware,
      'Hostname: ': build.host,
      'Model: ': build.model,
      'Product: ': build.product,
    };
  }

  Map<String, dynamic> _readIosDeviceInfo(IosDeviceInfo data) {
    return <String, dynamic>{
      'Device name: ': data.name,
      'OS name: ': data.systemName,
      'OS version: ': data.systemVersion,
      'Device model: ': data.model,
      'Localized model name: ': data.localizedModel,
      'UUID: ': data.identifierForVendor,
      'Network nodename: ': data.utsname.nodename,
      'Version level: ': data.utsname.version,
      'Hardware type: ': data.utsname.machine,
    };
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text(
            Platform.isAndroid
                ? 'Android Device Info'
                : Platform.isIOS
                    ? 'iOS Device Info'
                    : '',
          ),
            backgroundColor: Colors.redAccent,
        ),
        body: ListView(
          children: _deviceData.keys.map(
            (String property) {
              return Row(
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.all(10.0),
                    child: Text(
                      property,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                      child: Container(
                    padding: const EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 10.0),
                    child: Text(
                      '${_deviceData[property]}',
                      maxLines: 10,
                      overflow: TextOverflow.ellipsis,
                    ),
                  )),
                ],
              );
            },
          ).toList(),
        ),
      ),
    );
  }
}
