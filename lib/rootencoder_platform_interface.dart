import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'rootencoder_method_channel.dart';

abstract class RootencoderPlatform extends PlatformInterface {
  /// Constructs a RootencoderPlatform.
  RootencoderPlatform() : super(token: _token);

  static final Object _token = Object();

  static RootencoderPlatform _instance = MethodChannelRootencoder();

  /// The default instance of [RootencoderPlatform] to use.
  ///
  /// Defaults to [MethodChannelRootencoder].
  static RootencoderPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [RootencoderPlatform] when
  /// they register themselves.
  static set instance(RootencoderPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
  Stream connectionStream() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
   Stream connection() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<void> switchCamera() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<void> startRecord() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<void> startStream(String url) {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<void> stopRecord() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<void> stopStream() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<void> close() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<void> setVideoBitrateOnFly(int level) {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<void> setZoom(int level) {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<void> setLimitFPSOnFly(int fps) {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<void> setMicrophoneMode(MicrophoneMode microphoneMode) {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<void> setExposure(int level) {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<void> setVideoCodec(VideoCodec videoCodec) {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<void> disableVideoStabilization() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<void> enableVideoStabilization() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<void> enableAudio() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<void> disableAudio() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<void> disableAutoFocus() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<void> enableAutoFocus() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<void> resumeRecord() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<void> pauseRecord() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<bool> isAudioMuted() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<bool> isRecording() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<bool> isStreaming() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<int> getMaxZoom() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<int> getMaxExposure() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<int> getMinExposure() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<double> getZoom() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<double> getBitrate() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<String> getRecordStatus() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<List> getSupportedFps() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<int> getResolutionValue() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<bool> isOnPreview() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
