import Flutter
import UIKit
import RootEncoder

public class RootencoderPlugin: NSObject, FlutterPlugin {
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        print(Acknowledgement().description)
        let channel = FlutterMethodChannel(name: "rootencoder", binaryMessenger: registrar.messenger())
        let instance = RootencoderPlugin()
        
        registrar.addMethodCallDelegate(instance, channel: channel)
        
        let factory = RootencoderViewFactory(messenger: registrar.messenger())
        registrar.register(factory, withId: "com.amar/rootencoder")
    }
  
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if call.method == "getPlatformVersion" {
            result("iOS" + UIDevice.current.model)
        } else {
            result(FlutterMethodNotImplemented)
        }
    }
}

