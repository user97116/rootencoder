import Flutter
import UIKit
import AVFoundation
import RootEncoder
import SwiftUI

struct CameraUIView: UIViewRepresentable {
    
    //let view = UIView(frame: .zero)
    let view = MetalView(frame: .zero)
    
    public func makeUIView(context: Context) -> UIView {
        return view
    }

    public func updateUIView(_ uiView: UIView, context: Context) {}
}

class MyCustomUIView: UIView {
    init(frame: CGRect, viewId: Int64, args: Any?) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.red
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


class Rootencoder: NSObject, FlutterPlatformView, FlutterStreamHandler, ConnectChecker {
    private var genericCamera: GenericCamera?;
    private var cameraView: MetalView?
    
    private var messenger: FlutterBinaryMessenger;
    
    private var methodChannel: FlutterMethodChannel?
    private var eventChannel: FlutterEventChannel?
    private var eventChannel2: FlutterEventChannel?
    private var eventSink1: FlutterEventSink?
    private var eventSink2: FlutterEventSink?
    
    let _view: MyCustomUIView

    init(messenger: FlutterBinaryMessenger,frame: CGRect, viewId: Int64, args: Any?) {
        self.messenger = messenger
        _view = MyCustomUIView(frame: frame, viewId: viewId, args: args)
        super.init()
        //
        let camera = CameraUIView()
        cameraView = camera.view
        camera.onAppear {
            self.genericCamera = GenericCamera(view: self.cameraView!, connectChecker: self)
            self.genericCamera?.getStreamClient().setRetries(reTries: 10)
            self.genericCamera?.startPreview()
        }
        camera.onDisappear {
            if (self.genericCamera!.isStreaming()) {
                self.genericCamera?.stopStream()
            }
            if (self.genericCamera!.isOnPreview()) {
                self.genericCamera?.stopPreview()
            }
        }
        //
        methodChannel = FlutterMethodChannel(name: "rootencoder", binaryMessenger: messenger)
        eventChannel = FlutterEventChannel(name: "connectionStream", binaryMessenger: messenger)
        eventChannel2 = FlutterEventChannel(name: "connection", binaryMessenger: messenger)
        methodChannel?.setMethodCallHandler { [weak self] call, result in
            self?.handleMethodCall(call, result: result)
        }
        eventChannel?.setStreamHandler(self);
        eventChannel2?.setStreamHandler(self);
    }

    func view() -> UIView {
//        return _view
        return cameraView!
    }
    
    private func handleMethodCall(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
            case "getPlatformVersion":
                result("iOS" + UIDevice.current.model)
            case "switchCamera":
               switchCamera(call, result: result)
            case "startRecord":
               startRecord(call, result: result)
            case "startStream":
               startStream(call, result: result)
            case "stopRecord":
               stopRecord(call, result: result)
            case "stopStream":
               stopStream(call, result: result)
            case "close":
               closeRoot()
            case "setVideoBitrateOnFly":
               setVideoBitrateOnFly(call, result: result)
            case "setZoom":
               setZoom(call, result: result)
            case "setLimitFPSOnFly":
               setLimitFPSOnFly(call, result: result)
            case "setMicrophoneMode":
               setMicrophoneMode(call, result: result)
            case "setExposure":
               setExposure(call, result: result)
            case "setVideoCodec":
               setVideoCodec(call, result: result)
            case "disableVideoStabilization":
               disableVideoStabilization(call, result: result)
            case "enableVideoStabilization":
               enableVideoStabilization(call, result: result)
            case "enableAudio":
               enableAudio(call, result: result)
            case "disableAudio":
               disableAudio(call, result: result)
            case "disableAutoFocus":
               disableAutoFocus(call, result: result)
            case "enableAutoFocus":
               enableAutoFocus(call, result: result)
            case "resumeRecord":
               resumeRecord(call, result: result)
            case "pauseRecord":
               pauseRecord(call, result: result)
            case "isAudioMuted":
               isAudioMuted(call, result: result)
            case "isRecording":
               isRecording(call, result: result)
            case "isStreaming":
               isStreaming(call, result: result)
            case "getMaxZoom":
               getMaxZoom(call, result: result)
            case "getMaxExposure":
               getMaxExposure(call, result: result)
            case "getMinExposure":
               getMinExposure(call, result: result)
            case "getZoom":
               getZoom(call, result: result)
            case "getBitrate":
               getBitrate(call, result: result)
            case "getRecordStatus":
               getRecordStatus(call, result: result)
            case "getSupportedFps":
               getSupportedFps(call, result: result)
            case "getResolutionValue":
               getResolutionValue(call, result: result)
            case "isOnPreview":
               isOnPreview(call, result: result)
            case "addTextToStream":
               addTextToStream(call, result: result)
            case "clearFilterFromStream":
               clearFilterFromStream(call, result: result)
            case "addImageToStream":
               addImageToStream(call, result: result)
            default:
               result(FlutterMethodNotImplemented)
           }
    }
    
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        guard let eventType = arguments as? String else {
            return FlutterError(code: "INVALID_ARGUMENT", message: "Expected a String argument", details: nil)
        }
        switch eventType {
        case "connectionStream":
            self.eventSink1 = events
        case "connection":
            self.eventSink2 = events
        default:
            return FlutterError(code: "UNKNOWN_EVENT", message: "Unknown event type", details: nil)
        }

        return nil
    }
    
    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        guard let eventType = arguments as? String else {
            return FlutterError(code: "INVALID_ARGUMENT", message: "Expected a String argument", details: nil)
        }
        
        switch eventType {
        case "connectionStream":
            self.eventSink1 = nil
        case "connection":
            self.eventSink2 = nil
        default:
            return FlutterError(code: "UNKNOWN_EVENT", message: "Unknown event type", details: nil)
        }
        
        return nil
    }
    // Flutter
    deinit {
        closeRoot()
    }
    // ConnectChecker
    func onNewBitrate(bitrate: UInt64) {
        eventSink2?(bitrate)
    }
    func onDisconnect() {
        if(eventSink1 != nil) {
            eventSink1?("Disconnected")
        }
    }
    func onConnectionSuccess() {
        if(eventSink1 != nil) {
            eventSink1?("Connected")
        }
    }
    func onAuthError() {
        closeRoot()
    }
    func onAuthSuccess() {}
    func onConnectionFailed(reason: String) {
        if(eventSink1 != nil) {
            eventSink1?("Reconnecting")
        }
    }
    // Methods
    private func switchCamera(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        genericCamera!.switchCamera();
        result(nil);
    }

    private func startRecord(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let currentDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let fileName = "\(dateFormatter.string(from: currentDate)).mp4"
        let outputURL = PathUtils.getRecordPath()?.appendingPathComponent(fileName);
        
        if (!genericCamera!.isRecording()) {
            if (!genericCamera!.isStreaming()) {
                if (genericCamera!.prepareAudio() && genericCamera!.prepareVideo(width: 1280, height: 720, fps: 60, bitrate:  1200 * 1024)) {
                    genericCamera!.startRecord(path: outputURL!)
                }
            } else {
                genericCamera!.startRecord(path: outputURL!);
            }
        }
        result(nil);
    }

    private func startStream(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let url: String? = call.arguments as? String;
        if (!genericCamera!.isStreaming()) {
            if (genericCamera!.isRecording()
                    || genericCamera!.prepareAudio() && genericCamera!.prepareVideo()) {
                genericCamera!.startStream(endpoint: url!);
            }
        } else {
            genericCamera!.stopStream();
        }
        result(nil);
    }

    private func stopRecord(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        genericCamera!.stopRecord();
        result(nil);
    }

    private func stopStream(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        genericCamera!.stopStream();
        result(nil);
    }

    private func closeRoot() {
        if (genericCamera!.isRecording()) {
            genericCamera!.stopRecord();
        }
        if (genericCamera!.isStreaming()) {
            genericCamera!.stopStream();
        }
        genericCamera!.stopPreview();
    }

    private func setVideoBitrateOnFly(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let bitrate: Int? = call.arguments as? Int;
        genericCamera!.setVideoBitrateOnFly(bitrate: bitrate ?? 0);
        result(nil);
    }

    private func setZoom(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let level: CGFloat? = call.arguments as? CGFloat;
        genericCamera!.setZoom(level: level ?? 1);
        result(nil);
    }

    private func setLimitFPSOnFly(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        // Your implementation here
    }

    private func setMicrophoneMode(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        // Your implementation here
    }

    private func setExposure(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        // Your implementation here
    }

    private func setVideoCodec(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let mode: Int? = call.arguments as? Int;
        genericCamera!.setVideoCodec(codec: VideoCodec.H265);
        result(nil);
    }

    private func disableVideoStabilization(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        // Your implementation here
    }

    private func enableVideoStabilization(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        // Your implementation here
    }

    private func enableAudio(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        // Your implementation here
    }

    private func disableAudio(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        // Your implementation here
    }

    private func disableAutoFocus(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        // Your implementation here
    }

    private func enableAutoFocus(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        // Your implementation here
    }

    private func resumeRecord(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        // Your implementation here
    }

    private func pauseRecord(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        // Your implementation here
    }

    private func isAudioMuted(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let isMuted: Bool = genericCamera!.isMuted();
        result(isMuted);
    }

    private func isRecording(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let isRecording: Bool = genericCamera!.isRecording();
        result(isRecording);
    }

    private func isStreaming(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let isStreaming: Bool = genericCamera!.isStreaming();
        result(isStreaming);  
    }

    private func getMaxZoom(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let maxZoom: CGFloat  = genericCamera!.getMaxZoom();
        result(maxZoom);
    }

    private func getMaxExposure(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        // Your implementation here
    }

    private func getMinExposure(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        // Your implementation here
    }

    private func getZoom(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let zoom: CGFloat = genericCamera!.getZoom()
        result(zoom)
    }

    private func getBitrate(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        // Your implementation here
    }

    private func getRecordStatus(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        // Your implementation here
    }

    private func getSupportedFps(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        // Your implementation here
    }

    private func getResolutionValue(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        // Your implementation here
    }

    private func isOnPreview(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let isOnPreview:Bool = genericCamera!.isOnPreview();
        result(isOnPreview)
    }

    private func addTextToStream(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        // Your implementation here
    }

    private func clearFilterFromStream(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        // Your implementation here
    }

    private func addImageToStream(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        // Your implementation here
    }

}

