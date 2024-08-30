import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'rootencoder_platform_interface.dart';

enum VideoCodec { H264, H265 }

enum MicrophoneMode { SYNC, ASYNC, BUFFER }

/// An implementation of [RootencoderPlatform] that uses method channels.
class MethodChannelRootencoder implements RootencoderPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('rootencoder');

  @override
  Future<String?> getPlatformVersion() async {
    final version =
        await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  @override
  Future<void> close() async {
    await methodChannel.invokeMethod('close');
  }

  @override
  Future<void> disableAudio() async {
    await methodChannel.invokeMethod('disableAudio');
  }

  @override
  Future<void> disableAutoFocus() async {
    await methodChannel.invokeMethod('disableAutoFocus');
  }

  @override
  Future<void> disableVideoStabilization() async {
    await methodChannel.invokeMethod('disableVideoStabilization');
  }

  @override
  Future<void> enableAudio() async {
    await methodChannel.invokeMethod('enableAudio');
  }

  @override
  Future<void> enableAutoFocus() async {
    await methodChannel.invokeMethod('enableAutoFocus');
  }

  @override
  Future<void> enableVideoStabilization() async {
    await methodChannel.invokeMethod('enableVideoStabilization');
  }

  @override
  Future<double> getBitrate() async {
    return await methodChannel.invokeMethod('getBitrate');
  }

  @override
  Future<int> getMaxExposure() async {
    return await methodChannel.invokeMethod('getMaxExposure');
  }

  @override
  Future<int> getMaxZoom() async {
    return await methodChannel.invokeMethod('getMaxZoom');
  }

  @override
  Future<int> getMinExposure() async {
    return await methodChannel.invokeMethod('getMinExposure');
  }

  @override
  Future<String> getRecordStatus() async {
    return await methodChannel.invokeMethod('getRecordStatus');
  }

  @override
  Future<int> getResolutionValue() async {
    return await methodChannel.invokeMethod('getResolutionValue');
  }

  @override
  Future<List> getSupportedFps() async {
    return await methodChannel.invokeMethod('getSupportedFps');
  }

  @override
  Future<bool> isOnPreview() async {
    return await methodChannel.invokeMethod('isOnPreview');
  }

  @override
  Future<double> getZoom() async {
    return await methodChannel.invokeMethod('getZoom');
  }

  @override
  Future<bool> isAudioMuted() async {
    return await methodChannel.invokeMethod('isAudioMuted');
  }

  @override
  Future<bool> isRecording() async {
    return await methodChannel.invokeMethod('isRecording');
  }

  @override
  Future<bool> isStreaming() async {
    return await methodChannel.invokeMethod('isStreaming');
  }

  @override
  Future<void> pauseRecord() async {
    await methodChannel.invokeMethod('pauseRecord');
  }

  @override
  Future<void> resumeRecord() async {
    await methodChannel.invokeMethod('resumeRecord');
  }

  @override
  Future<void> setExposure(int level) async {
    await methodChannel.invokeMethod('setExposure', level);
  }

  @override
  Future<void> setLimitFPSOnFly(int fps) async {
    await methodChannel.invokeMethod('setLimitFPSOnFly', fps);
  }

  @override
  Future<void> setMicrophoneMode(MicrophoneMode microphoneMode) async {
    await methodChannel.invokeMethod('setMicrophoneMode', microphoneMode.index);
  }

  @override
  Future<void> setVideoBitrateOnFly(int level) async {
    await methodChannel.invokeMethod('setVideoBitrateOnFly', level);
  }

  @override
  Future<void> setVideoCodec(VideoCodec videoCodec) async {
    await methodChannel.invokeMethod('setVideoCodec', videoCodec.index);
  }

  @override
  Future<void> setZoom(int level) async {
    await methodChannel.invokeMethod('setZoom', level);
  }

  @override
  Future<void> startRecord() async {
    await methodChannel.invokeMethod('startRecord');
  }

  @override
  Future<void> startStream(String url) async {
    await methodChannel.invokeMethod('startStream', url);
  }

  @override
  Future<void> stopRecord() async {
    await methodChannel.invokeMethod('stopRecord');
  }

  @override
  Future<void> stopStream() async {
    await methodChannel.invokeMethod('stopStream');
  }

  @override
  Future<void> switchCamera() async {
    await methodChannel.invokeMethod('switchCamera');
  }
  
  @override
  Stream connectionStream() {
     if (defaultTargetPlatform == TargetPlatform.android)
      return const EventChannel('connectionStream').receiveBroadcastStream();
    else
      return const EventChannel('connectionStream').receiveBroadcastStream("connectionStream");
  }

  @override
  Stream connection() {
   if (defaultTargetPlatform == TargetPlatform.android)
      return const EventChannel('connection').receiveBroadcastStream();
    else 
      return const EventChannel('connection').receiveBroadcastStream("connection");
  }
}
