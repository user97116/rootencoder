import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TextView extends StatefulWidget {
  const TextView({
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _TextViewState();
}

class _TextViewState extends State<TextView> {
  @override
  Widget build(BuildContext context) {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return AndroidView(
        viewType: 'com.amar/rootencoder',
        onPlatformViewCreated: _onPlatformViewCreated,
      );
    }
    return Text(
        '$defaultTargetPlatform is not yet supported by the text_view plugin');
  }

  void _onPlatformViewCreated(int id) {
    print("id $id");
    // widget.onTextViewCreated!(TextViewController._(id));
  }
}

class TextViewController {
  TextViewController._(int id)
      : _channel = MethodChannel('plugins.felix.angelov/textview_$id');

  final MethodChannel _channel;

  Future<void> setText(String text) async {
    return _channel.invokeMethod('setText', text);
  }
}
