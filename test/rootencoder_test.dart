import 'package:flutter_test/flutter_test.dart';
import 'package:rootencoder/rootencoder.dart';
import 'package:rootencoder/rootencoder_platform_interface.dart';
import 'package:rootencoder/rootencoder_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockRootencoderPlatform
    with MockPlatformInterfaceMixin
    implements RootencoderPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final RootencoderPlatform initialPlatform = RootencoderPlatform.instance;

  test('$MethodChannelRootencoder is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelRootencoder>());
  });

  test('getPlatformVersion', () async {
    Rootencoder rootencoderPlugin = Rootencoder();
    MockRootencoderPlatform fakePlatform = MockRootencoderPlatform();
    RootencoderPlatform.instance = fakePlatform;

    expect(await rootencoderPlugin.getPlatformVersion(), '42');
  });
}
