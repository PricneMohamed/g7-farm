import 'package:farm/screens/dashboard.dart';
import 'package:farm/servise/Global.dart';
import 'package:farm/servise/SensorProvider.dart';
import 'package:farm/utils/constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:farm/utils/permissions.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

class Bodyconnection extends StatefulWidget {
  const Bodyconnection({super.key});

  @override
  State<Bodyconnection> createState() => _BodyconnectionState();
}

class _BodyconnectionState extends State<Bodyconnection> {
  BluetoothDevice? targetDevice;
  BluetoothCharacteristic? targetCharacteristic;

  final String serviceUuid = "4fafc201-1fb5-459e-8fcc-c5c9c331914b";
  final String charUuid = "beb5483e-36e1-4688-b7f5-ea07361b26a8";

  void startScan() async {
    print("🔍 Start Scan...");

    FlutterBluePlus.scanResults.listen((results) async {
      for (ScanResult r in results) {
        print("📡 Found: ${r.device.platformName}");

        if (r.device.platformName == "ESP32_BLE") {
          print("✅ ESP32 Found!");

          targetDevice = r.device;

          await FlutterBluePlus.stopScan();

          connectToDevice();
          break;
        }
      }
    });

    await FlutterBluePlus.startScan(timeout: const Duration(seconds: 10));
  }

  void connectToDevice() async {
    if (targetDevice == null) return;

    try {
      await targetDevice!.connect(
        timeout: const Duration(seconds: 10),
        autoConnect: false,
        license: License.free,
      );
      BluetoothManager.device = targetDevice;

      print("🔗 Connected");

      Fluttertoast.showToast(
        msg: "تم الاتصال بالمزرعة المضحكة ✅",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      if (!mounted) return;
      Navigator.of(context).pushNamed(Dashboard.DashBoardRoute);
      discoverServices();
    } catch (e) {
      print("❌ Connection Error: $e");
      Fluttertoast.showToast(
        msg:
            "بتعمل إيه يسطا؟ بالله عليك أعقل \nللأسف فشل الاتصال بالمزرعة الذكية ❌",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  void discoverServices() async {
    List<BluetoothService> services = await targetDevice!.discoverServices();

    for (var service in services) {
      if (service.uuid.toString() == serviceUuid) {
        for (var c in service.characteristics) {
          if (c.uuid.toString() == charUuid) {
            targetCharacteristic = c;

            print("✅ Characteristic Found");
            BluetoothManager.characteristic = targetCharacteristic;

            readData();
            listenToNotify();
          }
        }
      }
    }
  }

  void readData() async {
    if (targetCharacteristic == null) return;

    var value = await targetCharacteristic!.read();
    print("📥 Read: ${String.fromCharCodes(value)}");
  }

  void listenToNotify() async {
    if (targetCharacteristic == null) return;

    final sensorProvider = context.read<SensorProvider>();

    await targetCharacteristic!.setNotifyValue(true);

    targetCharacteristic!.value.listen((value) {
      String data = String.fromCharCodes(value);
      print("data => ${data.split(",")[5].split("W:")[1]}");
      sensorProvider.updateData(
        double.parse(data.split(",")[0].split("T:")[1]),
        double.parse(data.split(",")[1].split("H:")[1]),
        int.parse(data.split(",")[2].split("G:")[1]),
        int.parse(data.split(",")[3].split("S:")[1]),
        int.parse((data.split(",")[5].split("W:")[1])),
      );
      print("📡 Notify: $data");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(child: Image.asset('images/light_logo.png')),

        ElevatedButton(
          onPressed: () async {
            bool granted = await AppPermissions.requestBluetoothPermissions();

            if (!granted) {
              print("❌ مفيش صلاحيات");
              Fluttertoast.showToast(
                msg: "ليه موافقتش انت خسران ايه؟",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.CENTER,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.red,
                textColor: Colors.white,
                fontSize: 16.0,
              );
              return;
            }

            var state = await FlutterBluePlus.adapterState.first;
            if (state != BluetoothAdapterState.on) {
              print("❌ Bluetooth OFF");
              Fluttertoast.showToast(
                msg: "ليه موافقتش انت خسران ايه؟",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.CENTER,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.red,
                textColor: Colors.white,
                fontSize: 16.0,
              );
              return;
            }

            startScan();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: green,
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
          ),
          child: Text(
            "ازرع الان",
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
      ],
    );
  }
}
