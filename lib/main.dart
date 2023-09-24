import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';
import 'package:flutter_joystick/flutter_joystick.dart';
import 'websocket_data.dart';
import 'controller_page.dart';

void main() {
  runApp(const MainApp());
}

@immutable
class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: MainPage());
  }
}

@immutable
class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final Uri _uri = Uri.parse('ws://localhost:8080');
  WebSocketChannel? channel;
  String _address = '192.168.0.216';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
          children: [
            TextField(
              onChanged: (value) {
                _address = value;
              },
            ),
            ElevatedButton(
              onPressed: () async {
                channel?.sink.close();

                channel = IOWebSocketChannel.connect(
                    Uri.parse('ws://$_address:8080'));

                if (channel == null) return;
                await channel!.ready;
                if (mounted) {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => ControllerPage(
                            send: channel!.sink.add,
                            receive: channel!.stream,
                          )));
                }
              },
              child: const Text("Connect"),
            ),
            ElevatedButton(
                onPressed: () {
                  if (channel == null) {
                    print("Channel is null");
                  } else {
                    channel?.sink.add("Hello${DateTime.now()}");
                  }
                },
                child: const Text("Send"))
          ],
        ),
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.refresh),
          onPressed: () {
            channel?.sink.close();
            channel = WebSocketChannel.connect(_uri);
            setState(() {});
          },
        ));
  }
}
