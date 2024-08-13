import 'package:flutter_test/flutter_test.dart';
import 'package:rootencoder_android/rootencoder.dart';
import 'package:rootencoder_android/rootencoder_platform_interface.dart';
import 'package:rootencoder_android/rootencoder_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockRootencoderPlatform
    with MockPlatformInterfaceMixin
    implements RootencoderPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');

  @override
  Future<void> close() {
    // TODO: implement close
    throw UnimplementedError();
  }

  @override
  Stream connection() {
    // TODO: implement connection
    throw UnimplementedError();
  }

  @override
  Stream connectionStream() {
    // TODO: implement connectionStream
    throw UnimplementedError();
  }

  @override
  Future<void> disableAudio() {
    // TODO: implement disableAudio
    throw UnimplementedError();
  }

  @override
  Future<void> disableAutoFocus() {
    // TODO: implement disableAutoFocus
    throw UnimplementedError();
  }

  @override
  Future<void> disableVideoStabilization() {
    // TODO: implement disableVideoStabilization
    throw UnimplementedError();
  }

  @override
  Future<void> enableAudio() {
    // TODO: implement enableAudio
    throw UnimplementedError();
  }

  @override
  Future<void> enableAutoFocus() {
    // TODO: implement enableAutoFocus
    throw UnimplementedError();
  }

  @override
  Future<void> enableVideoStabilization() {
    // TODO: implement enableVideoStabilization
    throw UnimplementedError();
  }

  @override
  Future<double> getBitrate() {
    // TODO: implement getBitrate
    throw UnimplementedError();
  }

  @override
  Future<int> getMaxExposure() {
    // TODO: implement getMaxExposure
    throw UnimplementedError();
  }

  @override
  Future<int> getMaxZoom() {
    // TODO: implement getMaxZoom
    throw UnimplementedError();
  }

  @override
  Future<int> getMinExposure() {
    // TODO: implement getMinExposure
    throw UnimplementedError();
  }

  @override
  Future<String> getRecordStatus() {
    // TODO: implement getRecordStatus
    throw UnimplementedError();
  }

  @override
  Future<int> getResolutionValue() {
    // TODO: implement getResolutionValue
    throw UnimplementedError();
  }

  @override
  Future<List> getSupportedFps() {
    // TODO: implement getSupportedFps
    throw UnimplementedError();
  }

  @override
  Future<double> getZoom() {
    // TODO: implement getZoom
    throw UnimplementedError();
  }

  @override
  Future<bool> isAudioMuted() {
    // TODO: implement isAudioMuted
    throw UnimplementedError();
  }

  @override
  Future<bool> isOnPreview() {
    // TODO: implement isOnPreview
    throw UnimplementedError();
  }

  @override
  Future<bool> isRecording() {
    // TODO: implement isRecording
    throw UnimplementedError();
  }

  @override
  Future<bool> isStreaming() {
    // TODO: implement isStreaming
    throw UnimplementedError();
  }

  @override
  Future<void> pauseRecord() {
    // TODO: implement pauseRecord
    throw UnimplementedError();
  }

  @override
  Future<void> resumeRecord() {
    // TODO: implement resumeRecord
    throw UnimplementedError();
  }

  @override
  Future<void> setExposure(int level) {
    // TODO: implement setExposure
    throw UnimplementedError();
  }

  @override
  Future<void> setLimitFPSOnFly(int fps) {
    // TODO: implement setLimitFPSOnFly
    throw UnimplementedError();
  }

  @override
  Future<void> setMicrophoneMode(MicrophoneMode microphoneMode) {
    // TODO: implement setMicrophoneMode
    throw UnimplementedError();
  }

  @override
  Future<void> setVideoBitrateOnFly(int level) {
    // TODO: implement setVideoBitrateOnFly
    throw UnimplementedError();
  }

  @override
  Future<void> setVideoCodec(VideoCodec videoCodec) {
    // TODO: implement setVideoCodec
    throw UnimplementedError();
  }

  @override
  Future<void> setZoom(int level) {
    // TODO: implement setZoom
    throw UnimplementedError();
  }

  @override
  Future<void> startRecord() {
    // TODO: implement startRecord
    throw UnimplementedError();
  }

  @override
  Future<void> startStream(String url) {
    // TODO: implement startStream
    throw UnimplementedError();
  }

  @override
  Future<void> stopRecord() {
    // TODO: implement stopRecord
    throw UnimplementedError();
  }

  @override
  Future<void> stopStream() {
    // TODO: implement stopStream
    throw UnimplementedError();
  }

  @override
  Future<void> switchCamera() {
    // TODO: implement switchCamera
    throw UnimplementedError();
  }
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
