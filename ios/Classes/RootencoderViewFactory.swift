import Flutter
import UIKit

class RootencoderViewFactory: NSObject, FlutterPlatformViewFactory {
    private var messenger: FlutterBinaryMessenger;
    
    init(messenger: FlutterBinaryMessenger) {
        self.messenger = messenger
    }
    
    func create(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?) -> FlutterPlatformView {
        return Rootencoder(messenger:messenger, frame: frame, viewId: viewId, args: args)
    }
}
