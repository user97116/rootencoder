import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rootencoder/rootencoder.dart';
import 'package:rootencoder/text_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _rootencoderPlugin = Rootencoder();
  MethodChannel methodChannel = const MethodChannel('rootencoder');
  @override
  void initState() {
    super.initState();
    permsi();
  }

  Future<void> permsi() async {
    await Permission.camera.request();
    await Permission.microphone.request();
    await Permission.storage.request();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    // try {
    //   platformVersion = await _rootencoderPlugin.getPlatformVersion() ??
    //       'Unknown platform version';
    // } on PlatformException {
    //   platformVersion = 'Failed to get platform version.';
    // }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {});
  }

  final TextEditingController urlController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Column(
            children: [
              const SizedBox(
                width: 300,
                height: 300,
                child: TextView(),
              ),
              TextField(
                controller: urlController,
                decoration: const InputDecoration(hintText: "RTMP"),
              ),
              TextButton(
                onPressed: () {
                  methodChannel.invokeMethod("switchCamera");
                },
                child: const Text("Switch camera"),
              ),
              TextButton(
                onPressed: () {
                  methodChannel.invokeMethod("startStream", urlController.text);
                },
                child: const Text("Start stream"),
              ),
              TextButton(
                onPressed: () {
                  methodChannel.invokeMethod("stopStream");
                },
                child: const Text("Stop stream"),
              ),
              TextButton(
                onPressed: () {
                  methodChannel.invokeMethod("startRecord");
                },
                child: const Text("Start record"),
              ),
              TextButton(
                onPressed: () {
                  methodChannel.invokeMethod("stopRecord");
                },
                child: const Text("Stop record"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
