import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter_joystick/flutter_joystick.dart';
import 'websocket_data.dart';

class ControllerPage extends StatefulWidget {
  const ControllerPage({super.key, required this.receive, required this.send});
  final Stream<dynamic> receive;
  final void Function(dynamic) send;
  @override
  State<ControllerPage> createState() => _ControllerPageState();
}

class _ControllerPageState extends State<ControllerPage> {
  late Timer _motorTimer;
  bool _isActivated = false;
  Point<double> carriageMove = const Point(0, 0);
  double carriageRotate = 0;
  final double carriageRotateScale = 20000;
  final double carriageSpeedScale = 35000;
  double lastLifeHeight = 0;
  Point<double> liftMove = const Point(0, 0);
  final double liftSpeedScale = 20000;
  double servoAngle = 500;
  List<double> motorPositions = List.filled(6, 0);

  @override
  void initState() {
    super.initState();
    widget.receive.listen((event) {});
    _motorTimer = Timer.periodic(const Duration(milliseconds: 10), (timer) {
      if (carriageMove.x == 0 &&
          carriageMove.y == 0 &&
          carriageRotate == 0 &&
          liftMove.x == 0 &&
          liftMove.y == 0) {
        return;
      }
      //mecanum wheel calculation
      var x = carriageMove.x * carriageSpeedScale;
      var y = carriageMove.y * carriageSpeedScale;
      var r = carriageRotate * carriageRotateScale;
      // print("$motorPositions[2]");
      //Front Left
      motorPositions[0] += x - y + r;
      //Front Right
      motorPositions[1] += x + y + r;
      //Rear Left
      motorPositions[2] += x + y - r;
      //Rear Right
      motorPositions[3] += x - y - r;

      carriageMove = const Point(0, 0);
      carriageRotate = 0;

      //mecanum wheel calculation
      var lift_x = liftMove.x * liftSpeedScale;
      var lift_y = -liftMove.y * liftSpeedScale;

      //Lift 1
      motorPositions[4] += lift_x + lift_y;
      //Lift 2
      motorPositions[5] += lift_x - lift_y;
      liftMove = const Point(0, 0);

      widget.send(jsonEncode(
          getFormattedData(DataTypes.motorRotation, motorPositions)));
    });
  }

  @override
  Widget build(BuildContext context) {
    final margin = MediaQuery.of(context).size.width / 30;
    return Material(
      child: Column(
        children: [
          Row(
            children: [
              ButtonBar(
                alignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      widget.send(jsonEncode(
                          getFormattedData(DataTypes.buttons, "StopAll")));
                      _isActivated = false;
                    },
                    child: const Text("Emergency Stop"),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _isActivated = true;
                      widget.send(jsonEncode(
                          getFormattedData(DataTypes.buttons, "ActivateAll")));
                      motorPositions = List.filled(6, 0);
                    },
                    child: const Text("Activate All"),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      motorPositions[4] = 0;
                      motorPositions[5] = 0;
                      widget.send(jsonEncode(
                          getFormattedData(DataTypes.buttons, "LiftReset")));
                    },
                    child: const Text("Reset Lift"),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      widget.send(jsonEncode(getFormattedData(
                          DataTypes.buttons, "ConnectionReflesh")));
                    },
                    child: const Text("Connection Reflesh"),
                  ),
                ],
              ),
              const Spacer(),
              Joystick(
                  listener: (details) {
                    carriageRotate = details.x;
                  },
                  mode: JoystickMode.horizontal),
            ],
          ),
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                Positioned(
                  top: margin,
                  child: SizedBox(
                    width: 100,
                    height: 30,
                    child: Center(
                      child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text("Back")),
                    ),
                  ),
                ),
                Slider(
                  value: servoAngle,
                  onChanged: (value) {
                    setState(() {
                      servoAngle = value;
                    });
                    widget.send(jsonEncode(
                        getFormattedData(DataTypes.servoRotation, servoAngle)));
                  },
                  min: 400,
                  max: 1200,
                ),
                Positioned(
                  bottom: margin,
                  left: margin,
                  child: Joystick(
                    listener: (details) {
                      carriageMove = Point(details.x, details.y);
                    },
                  ),
                ),
                Positioned(
                  bottom: margin,
                  right: margin,
                  child: Joystick(
                    listener: (details) {
                      liftMove = Point(details.x, details.y);
                    },
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
