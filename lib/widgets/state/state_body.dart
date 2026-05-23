import 'package:farm/servise/SensorProvider.dart';
import 'package:farm/servise/data_sending.dart';
import 'package:farm/utils/constant.dart';
import 'package:flutter/material.dart';
import 'package:farm/servise/getData.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:farm/servise/Global.dart';
import 'package:provider/provider.dart';

class StateBody extends StatefulWidget {
  const StateBody({super.key});

  @override
  State<StateBody> createState() => _StateBodyState();
}

class _StateBodyState extends State<StateBody> {
  // @override
  // // late Stream<int> gasStream;

  // @override
  // // void initState() {
  // //   super.initState();
  // //   gasStream = getGasSensorStream(BluetoothManager.characteristic!);
  // // }

  @override
  late bool pumpState1 = false;
  late bool pumpState2 = false;
  late bool lampState = false;
  Widget build(BuildContext context) {
    final sensors = context.watch<SensorProvider>();

    print("temp ${sensors.temp}");
    print("humidity ${sensors.humidity}");
    print("gas ${sensors.gas}");
    print("ultra sonic ${sensors.ultra}");

    final int gas = sensors.gas;
    final double temp = sensors.temp;
    final double humidity = sensors.humidity;
    final int ultra = sensors.ultra;
    final int normalGas = 600;

    print("sensors.ultra ${sensors.ultra}");

    return SingleChildScrollView(
      child: Center(
        child: Column(
          children: [
            SizedBox(height: 40),
            mysensorpicture("images/devise/gas_sensor.jpg"),
            gassensor(gas, normalGas, context),
            SizedBox(height: 120),
            mysensorpicture("images/devise/dht22.jpg"),
            dht22(temp, context, humidity),
            SizedBox(height: 120),
            mysensorpicture("images/devise/soil.jpg"),
            solisensor(sensors, context),
            SizedBox(height: 120),
            mysensorpicture("images/devise/ultra.jpg"),
            detectedWater(ultra, context),
            SizedBox(height: 120),
            mysensorpicture("images/devise/lamp.jpg"),
            SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.light, color: Colors.orange, size: 50),
                Text(
                  "لمبة الحرارة",
                  style: Theme.of(
                    context,
                  ).textTheme.displayLarge!.copyWith(color: Colors.orange),
                ),
              ],
            ),
            SizedBox(height: 30),
            Material(
              borderRadius: BorderRadius.circular(20),
              type: MaterialType.card,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: MaterialButton(
                  elevation: 5,
                  mouseCursor: MouseCursor.defer,
                  textColor: Colors.white,
                  height: 50,
                  color: !lampState ? green : Colors.red,
                  onPressed: () {
                    setState(() {
                      lampState = !lampState;
                      sendDataToESP32(lampState ? "LAMP_ON" : "LAMP_OFF");
                      print("lampState => $lampState");
                    });
                  },
                  child: !lampState
                      ? Text(
                          "افتح الاضاءة",
                          style: Theme.of(context).textTheme.titleMedium,
                        )
                      : Text(
                          "اقفل الاضاءة",
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                ),
              ),
            ),
            SizedBox(height: 70),
            mysensorpicture("images/devise/pumb.jpg"),
            SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.plumbing, color: Colors.white70, size: 50),
                Text(
                  "المضخة الداخلية",
                  style: Theme.of(
                    context,
                  ).textTheme.displayLarge!.copyWith(color: Colors.white70),
                ),
              ],
            ),
            SizedBox(height: 30),
            Material(
              borderRadius: BorderRadius.circular(20),
              type: MaterialType.card,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: MaterialButton(
                  elevation: 5,
                  mouseCursor: MouseCursor.defer,
                  textColor: Colors.white,
                  height: 50,
                  color: !pumpState1 ? green : Colors.red,
                  onPressed: () {
                    setState(() {
                      pumpState1 = !pumpState1;
                      sendDataToESP32(pumpState1 ? "PUMP1_ON" : "PUMP1_OFF");
                      print("pumpState1 => $pumpState1");
                    });
                  },
                  child: !pumpState1
                      ? Text(
                          "افتح الماية",
                          style: Theme.of(context).textTheme.titleMedium,
                        )
                      : Text(
                          "اقفل الماية",
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                ),
              ),
            ),
            SizedBox(height: 70),
            mysensorpicture("images/devise/pumb.jpg"),
            SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.plumbing, color: Colors.white70, size: 50),
                Text(
                  "المضخة الخارجية",
                  style: Theme.of(
                    context,
                  ).textTheme.displayLarge!.copyWith(color: Colors.white70),
                ),
              ],
            ),
            SizedBox(height: 30),
            Material(
              borderRadius: BorderRadius.circular(20),
              type: MaterialType.card,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: MaterialButton(
                  elevation: 5,
                  mouseCursor: MouseCursor.defer,
                  textColor: Colors.white,
                  height: 50,
                  color: !pumpState2 ? green : Colors.red,
                  onPressed: () {
                    setState(() {
                      pumpState2 = !pumpState2;
                      sendDataToESP32(pumpState2 ? "PUMP2_ON" : "PUMP2_OFF");
                      print("pumpState2 => $pumpState2");
                    });
                  },
                  child: !pumpState2
                      ? Text(
                          "افتح الماية",
                          style: Theme.of(context).textTheme.titleMedium,
                        )
                      : Text(
                          "اقفل الماية",
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                ),
              ),
            ),
            SizedBox(height: 70),
          ],
        ),
      ),
    );
  }

  Container solisensor(SensorProvider sensors, BuildContext context) {
    return Container(
      margin: EdgeInsets.all(30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 20,
        children: [
          Icon(Icons.grass, size: 50, color: Colors.green[400]),
          Text(
            "رطوبة التربة: ${sensors.soil}%",
            style: Theme.of(
              context,
            ).textTheme.displayMedium?.copyWith(color: Colors.green[400]),
          ),
        ],
      ),
    );
  }

  Container dht22(double temp, BuildContext context, double humidity) {
    return Container(
      child: Padding(
        padding: EdgeInsetsGeometry.all(20),
        child: Column(
          spacing: 40,
          children: [
            Row(
              spacing: 10,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.thermostat_auto,
                  color: temp > 30 ? Colors.red : Colors.orange,
                  size: 50,
                ),
                Text(
                  "درجة الحرارة: ${temp.toStringAsFixed(1)}°C",
                  style: Theme.of(context).textTheme.displayLarge,
                ),
              ],
            ),

            Row(
              spacing: 10,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.water_drop, color: Colors.blue[400], size: 50),
                Text(
                  "درجة الرطوبة: ${humidity.toStringAsFixed(1)}%",
                  style: TextStyle(
                    fontSize: 30,
                    color: Colors.blue[400],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Container gassensor(int gas, int normalGas, BuildContext context) {
    return Container(
      child: gas > normalGas
          ? Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 20,
                children: [
                  Icon(Icons.warning, color: Colors.red, size: 50),
                  Expanded(
                    child: Text(
                      "فيه دخان او غاز ${gas}",
                      textAlign: TextAlign.center,
                      style: Theme.of(
                        context,
                      ).textTheme.displayLarge?.copyWith(color: Colors.red),
                    ),
                  ),
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 20,
                children: [
                  Icon(Icons.fire_hydrant, color: Colors.orange, size: 50),
                  Text(
                    " كل حاجة تمام ${gas}",
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.displayLarge,
                  ),
                ],
              ),
            ),
    );
  }

  Container mysensorpicture(imageUrl) {
    return Container(
      decoration: BoxDecoration(shape: BoxShape.circle, color: green),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(100),
        child: Image.asset(
          imageUrl,
          width: 200,
          height: 200,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  detectedWater(int ultra, BuildContext context) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 20,
          children: [
            Icon(Icons.takeout_dining, color: Colors.blue, size: 50),
            Expanded(
              child: Column(
                children: [
                  Text(
                    "بالفعل تم الكشف عن وجود ماء و النسبة ",
                    textAlign: TextAlign.center,
                    style: Theme.of(
                      context,
                    ).textTheme.displayLarge?.copyWith(color: Colors.white70),
                  ),
                  Text(
                    "${ultra} %",
                    textAlign: TextAlign.center,
                    style: Theme.of(
                      context,
                    ).textTheme.displayLarge?.copyWith(color: ultra>50?Colors.green:Colors.red),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      // : Padding(
      //     padding: const EdgeInsets.all(20),
      //     child: Row(
      //       mainAxisAlignment: MainAxisAlignment.center,
      //       spacing: 20,
      //       children: [
      //         Icon(Icons.person, color: Colors.green, size: 50),
      //         Text(
      //           "مفيش حد في المزرعة",
      //           textAlign: TextAlign.center,
      //           style: Theme.of(
      //             context,
      //           ).textTheme.displayLarge!.copyWith(color: Colors.green),
      //         ),
      //       ],
      //     ),
      //   ),
    );
  }
}
