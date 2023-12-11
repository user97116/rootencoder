
import 'rootencoder_platform_interface.dart';

class Rootencoder {
  Future<String?> getPlatformVersion() {
    return RootencoderPlatform.instance.getPlatformVersion();
  }
}
