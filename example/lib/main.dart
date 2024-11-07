import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rootencoder_android/rootencoder_method_channel.dart';
import 'package:rootencoder_android/text_view.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // final _rootencoderPlugin = Rootencoder();
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
    String? v = await MethodChannelRootencoder().getPlatformVersion();
    print(v);
    urlController.text = v!;
    MethodChannelRootencoder().connection().listen((c) {
      print("sdsd $c");
    });
    MethodChannelRootencoder().connectionStream().listen((c) {
      print("sds2sd $c");
    });
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
    print(urlController.text);
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Plugin example app'),
        ),
        body: Center(
          child: Column(
            children: [
              AspectRatio(
                aspectRatio: 16 / 9,
                child: TextView(),
              ),
              TextField(
                controller: urlController,
                decoration: const InputDecoration(hintText: "RTMP"),
              ),
              TextButton(
                onPressed: () {
                  methodChannel.invokeMethod("changeResolution",
                      {"width": 100, "height": 200}).then((v) {
                    print("switchCamera: " + v);
                  });
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
                onPressed: () async {
                  await [
                    Permission.manageExternalStorage,
                    Permission.storage,
                  ].request();
                  var path = Directory("storage/emulated/0/DevDham");
                  if (!path.existsSync()) {
                    path.createSync();
                  }
                  final file = path.path + "/abc.mp4";
                  print(file);
                  methodChannel.invokeMethod("startRecord", file);
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
