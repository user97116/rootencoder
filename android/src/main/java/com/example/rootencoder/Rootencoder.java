package com.example.rootencoder;

import android.annotation.SuppressLint;
import android.graphics.Rect;
import android.util.Log;
import android.view.WindowManager;
import android.content.Context;
import android.content.res.AssetManager;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Color;
import android.graphics.Typeface;
import android.os.Build;
import android.util.AttributeSet;
import android.view.MotionEvent;
import android.view.SurfaceHolder;
import android.view.SurfaceView;
import android.view.View;
import android.widget.TextView;
import android.widget.Toast;

import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

import static io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import static io.flutter.plugin.common.MethodChannel.Result;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.pedro.common.ConnectChecker;
import com.pedro.common.VideoCodec;
import com.pedro.encoder.input.audio.MicrophoneMode;
import com.pedro.encoder.input.gl.render.filters.object.ImageObjectFilterRender;
import com.pedro.encoder.input.gl.render.filters.object.TextObjectFilterRender;
import com.pedro.encoder.input.video.CameraOpenException;
import com.pedro.encoder.input.video.facedetector.Face;
import com.pedro.encoder.input.video.facedetector.FaceDetectorCallback;
import com.pedro.encoder.utils.CodecUtil;
import com.pedro.encoder.utils.gl.AspectRatioMode;
import com.pedro.encoder.utils.gl.TranslateTo;
import com.pedro.library.rtmp.RtmpCamera1;
import com.pedro.library.rtmp.RtmpCamera2;
import com.pedro.library.view.OpenGlView;

import java.io.File;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;
import java.util.Locale;
import java.util.logging.Logger;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.platform.PlatformView;

public class Rootencoder implements PlatformView, MethodCallHandler, SurfaceHolder.Callback, ConnectChecker, View.OnTouchListener {
    private final RtmpCamera2 rtmpCamera1;
    private final MethodChannel methodChannel;
    private final EventChannel eventChannel;
    private final EventChannel eventChannel2;
    private EventChannel.EventSink eventSink;
    private EventChannel.EventSink eventSink2;
    private OpenGlView openGlView;
    private Bitmap bitmap;
    // Config
    private int width = 1280;
    private int height = 720;

    @Override
    public void onFlutterViewAttached(@NonNull View flutterView) {
        PlatformView.super.onFlutterViewAttached(flutterView);
        openGlView.getHolder().addCallback(this);
        openGlView.setOnTouchListener(this);

    }

    Rootencoder(Context context, BinaryMessenger messenger, int id) {
        bitmap = BitmapFactory.decodeResource(context.getResources(), R.drawable.dev);

        openGlView = new OpenGlView(context);
        openGlView.setAspectRatioMode(AspectRatioMode.Fill);
        rtmpCamera1 = new RtmpCamera2(openGlView, this);
        rtmpCamera1.setForce(CodecUtil.Force.SOFTWARE, CodecUtil.Force.FIRST_COMPATIBLE_FOUND);
        methodChannel = new MethodChannel(messenger, "rootencoder");
        methodChannel.setMethodCallHandler(this);

        eventChannel = new EventChannel(messenger, "connectionStream");
        eventChannel.setStreamHandler(new EventChannel.StreamHandler() {
            @Override
            public void onListen(Object o, EventChannel.EventSink event) {
                eventSink = event;
            }

            @Override
            public void onCancel(Object o) {
                eventSink = null;
            }
        });

        eventChannel2 = new EventChannel(messenger, "connection");
        eventChannel2.setStreamHandler(new EventChannel.StreamHandler() {
            @Override
            public void onListen(Object o, EventChannel.EventSink event) {
                eventSink2 = event;
            }

            @Override
            public void onCancel(Object o) {
                eventSink2 = null;
            }
        });
    }


    @Override
    public View getView() {
        return openGlView;
    }

    @Override
    public void onMethodCall(MethodCall methodCall, MethodChannel.Result result) {
        switch (methodCall.method) {
            case "changeResolution":
                changeResolution(methodCall, result);
                break;
            case "switchCamera":
                switchCamera(methodCall, result);
                break;

            case "startRecord":
                startRecord(methodCall, result);
                break;

            case "startStream":
                startStream(methodCall, result);
                break;

            case "stopRecord":
                stopRecord(methodCall, result);
                break;

            case "stopStream":
                stopStream(methodCall, result);
                break;

            case "close":
                close();
                break;

            case "setVideoBitrateOnFly":
                setVideoBitrateOnFly(methodCall, result);
                break;

            case "setZoom":
                setZoom(methodCall, result);
                break;

            case "setLimitFPSOnFly":
                setLimitFPSOnFly(methodCall, result);
                break;

            case "setMicrophoneMode":
                setMicrophoneMode(methodCall, result);
                break;

            case "setExposure":
                setExposure(methodCall, result);
                break;

            case "setVideoCodec":
                setVideoCodec(methodCall, result);
                break;

            case "disableVideoStabilization":
                disableVideoStabilization(methodCall, result);
                break;

            case "enableVideoStabilization":
                enableVideoStabilization(methodCall, result);
                break;

            case "enableAudio":
                enableAudio(methodCall, result);
                break;

            case "disableAudio":
                disableAudio(methodCall, result);
                break;

            case "disableAutoFocus":
                disableAutoFocus(methodCall, result);
                break;

            case "enableAutoFocus":
                enableAutoFocus(methodCall, result);
                break;

            case "resumeRecord":
                resumeRecord(methodCall, result);
                break;

            case "pauseRecord":
                pauseRecord(methodCall, result);
                break;

            case "isAudioMuted":
                isAudioMuted(methodCall, result);
                break;

            case "isRecording":
                isRecording(methodCall, result);
                break;

            case "isStreaming":
                isStreaming(methodCall, result);
                break;

            case "getMaxZoom":
                getMaxZoom(methodCall, result);
                break;

            case "getMaxExposure":
                getMaxExposure(methodCall, result);
                break;

            case "getMinExposure":
                getMinExposure(methodCall, result);
                break;

            case "getZoom":
                getZoom(methodCall, result);
                break;

            case "getBitrate":
                getBitrate(methodCall, result);
                break;

            case "getRecordStatus":
                getRecordStatus(methodCall, result);
                break;

            case "getSupportedFps":
                getSupportedFps(methodCall, result);
                break;

            case "getResolutionValue":
                getResolutionValue(methodCall, result);
                break;

            case "isOnPreview":
                isOnPreview(methodCall, result);
                break;

            case "addTextToStream":
                addTextToStream(methodCall, result);
                break;
            case "clearFilterFromStream":
                clearFilterFromStream(methodCall, result);
                break;
            case "addImageToStream":
                addImageToStream(methodCall, result);
                break;
            default:
                result.notImplemented();
        }

    }

    private void switchCamera(MethodCall methodCall, Result result) {
        try {
            rtmpCamera1.switchCamera();
        } catch (Exception e) {
            Log.d("ERROR", e.getMessage());
        }
        result.success(null);
    }

    private void changeResolution(MethodCall methodCall, Result result) {
        width = (int) methodCall.argument("width");
        height = (int) methodCall.argument("height");
        for (int i = 0;i <rtmpCamera1.getResolutionsBack().toArray().length; i++)
            Log.d("amar",String.valueOf(rtmpCamera1.getResolutionsBack().get(i).getWidth())+"x"+String.valueOf(rtmpCamera1.getResolutionsBack().get(i).getHeight()));
//        Log.d("amar",String.valueOf(rtmpCamera1.prepareVideo(width,height,1200 * 1024)));
        result.success("changed with stop stream and record");
    }

    private void startStream(MethodCall methodCall, Result result) {
        String url = (String) methodCall.arguments;
        if (!rtmpCamera1.isStreaming()) {
            if (rtmpCamera1.isRecording()
                    || rtmpCamera1.prepareAudio() && rtmpCamera1.prepareVideo(
                    width, height, 60, 1200 * 1024, 0
            )) {
                rtmpCamera1.startStream(url);
            }
        } else {
            rtmpCamera1.stopStream();
        }
        result.success(null);
    }

    private void stopStream(MethodCall methodCall, Result result) {
        rtmpCamera1.stopStream();
        result.success(null);
    }

    private void startRecord(MethodCall methodCall, Result result) {
        String path = (String) methodCall.arguments;
        if (!rtmpCamera1.isRecording()) {
            try {
                rtmpCamera1.prepareAudio();
                rtmpCamera1.prepareVideo(width, height, 60, 1200 * 1024, 0);
                rtmpCamera1.startRecord(path);
                result.success(path);
            } catch (IOException e) {
                rtmpCamera1.stopRecord();
                result.success(e.getMessage());
            }
        } else {
            result.success(null);
        }
    }

    private void stopRecord(MethodCall methodCall, Result result) {
        rtmpCamera1.stopRecord();
        result.success(null);
    }

    @Override
    public void dispose() {
        close();
    }

    @Override
    public void surfaceCreated(@NonNull SurfaceHolder surfaceHolder) {
        Log.d("STATUS", String.valueOf(surfaceHolder.getSurface().isValid()));
        if (surfaceHolder.getSurface().isValid() && !rtmpCamera1.isOnPreview()) {
            Log.d("Valid", "yes");
            try {
                rtmpCamera1.startPreview();
                rtmpCamera1.getStreamClient().setReTries(10);
            } catch (CameraOpenException e) {
                Log.d("Camera can't attached", "yes");
            }
        }
    }

    @Override
    public void surfaceChanged(@NonNull SurfaceHolder surfaceHolder, int i, int i1, int i2) {
        if (rtmpCamera1 != null) {
            if (rtmpCamera1.isOnPreview())
                rtmpCamera1.stopPreview();
            try {
                if (!rtmpCamera1.isOnPreview())
                    rtmpCamera1.startPreview();
            } catch (Exception e) {
                Log.d("surfaceChanged", "can't preview");
            }
        }
    }

    @Override
    public void surfaceDestroyed(@NonNull SurfaceHolder surfaceHolder) {
        if (rtmpCamera1 != null && rtmpCamera1.isOnPreview()
        ) {
            rtmpCamera1.stopPreview();
        }
    }


    void close() {
        if (rtmpCamera1.isRecording()) {
            rtmpCamera1.stopRecord();
        }
        if (rtmpCamera1.isStreaming()) {
            rtmpCamera1.stopStream();
        }
        if(rtmpCamera1.isOnPreview())
            rtmpCamera1.stopPreview();
    }

    @Override
    public void onAuthError() {
        close();
    }

    @Override
    public void onAuthSuccess() {

    }

    @Override
    public void onConnectionFailed(@NonNull String s) {
        if (rtmpCamera1.getStreamClient().reTry(5000, s, null)) {
        } else {
            rtmpCamera1.stopStream();
        }
        if (eventSink != null)
            eventSink.success("Reconnecting");

    }

    @Override
    public void onConnectionStarted(@NonNull String s) {
        if (eventSink != null)
            eventSink.success("Connecting");
    }

    @Override
    public void onConnectionSuccess() {
        if (eventSink != null)
            eventSink.success("Connected");

    }

    @Override
    public void onDisconnect() {
        if (eventSink != null)
            eventSink.success("Disconnected");
    }

    @Override
    public void onNewBitrate(long l) {
        eventSink2.success(l);
    }

    private void setVideoBitrateOnFly(MethodCall methodCall, Result result) {
        int bitrate = (int) methodCall.arguments;
        rtmpCamera1.setVideoBitrateOnFly(bitrate);
        result.success(null);
    }

    private void setZoom(MethodCall methodCall, Result result) {
        int level = (int) methodCall.arguments;
        rtmpCamera1.setZoom(level);
        result.success(null);
    }

    private void setLimitFPSOnFly(MethodCall methodCall, Result result) {
        int fps = (int) methodCall.arguments;
        rtmpCamera1.setLimitFPSOnFly(fps);
        result.success(null);
    }

    private void setMicrophoneMode(MethodCall methodCall, Result result) {
        int mode = (int) methodCall.arguments;
        rtmpCamera1.setMicrophoneMode(MicrophoneMode.getEntries().get(mode));
        result.success(null);
    }

    private void setExposure(MethodCall methodCall, Result result) {
        int value = (int) methodCall.arguments;
        rtmpCamera1.setExposure(value);
        result.success(null);
    }

    private void setVideoCodec(MethodCall methodCall, Result result) {
        int mode = (int) methodCall.arguments;
        rtmpCamera1.setVideoCodec(VideoCodec.getEntries().get(mode));
        result.success(null);
    }

    private void disableVideoStabilization(MethodCall methodCall, Result result) {
        rtmpCamera1.disableVideoStabilization();
        result.success(null);
    }

    private void enableVideoStabilization(MethodCall methodCall, Result result) {
        rtmpCamera1.enableVideoStabilization();
        result.success(null);
    }

    private void enableAudio(MethodCall methodCall, Result result) {
        rtmpCamera1.enableAudio();
        result.success(null);
    }

    private void disableAudio(MethodCall methodCall, Result result) {
        rtmpCamera1.disableAudio();
        result.success(null);
    }

    private void disableAutoFocus(MethodCall methodCall, Result result) {
        rtmpCamera1.disableAutoFocus();
        result.success(null);
    }

    private void enableAutoFocus(MethodCall methodCall, Result result) {
        rtmpCamera1.enableAutoFocus();
        result.success(null);
    }

    private void resumeRecord(MethodCall methodCall, Result result) {
        rtmpCamera1.resumeRecord();
        result.success(null);
    }

    private void pauseRecord(MethodCall methodCall, Result result) {
        rtmpCamera1.pauseRecord();
        result.success(null);
    }

    private void isAudioMuted(MethodCall methodCall, Result result) {
        boolean isMuted = rtmpCamera1.isAudioMuted();
        result.success(isMuted);
    }

    private void isRecording(MethodCall methodCall, Result result) {
        boolean isRecording = rtmpCamera1.isRecording();
        result.success(isRecording);
    }

    private void isStreaming(MethodCall methodCall, Result result) {
        boolean isStreaming = rtmpCamera1.isStreaming();
        result.success(isStreaming);
    }

    private void getMaxZoom(MethodCall methodCall, Result result) {
        float maxZoom = rtmpCamera1.getZoom();
        result.success(maxZoom);
    }

    private void getMaxExposure(MethodCall methodCall, Result result) {
        int maxExposure = rtmpCamera1.getMaxExposure();
        result.success(maxExposure);
    }

    private void getMinExposure(MethodCall methodCall, Result result) {
        int minExposure = rtmpCamera1.getMinExposure();
        result.success(minExposure);
    }

    private void getZoom(MethodCall methodCall, Result result) {
        float zoom = rtmpCamera1.getZoom();
        result.success(zoom);
    }

    private void getBitrate(MethodCall methodCall, Result result) {
        float bitrate = rtmpCamera1.getBitrate();
        result.success(bitrate);
    }

    private void getRecordStatus(MethodCall methodCall, Result result) {
        String stutus = rtmpCamera1.getRecordStatus().name();
        result.success(stutus);
    }

    private void getSupportedFps(MethodCall methodCall, Result result) {
        List supportedFps = rtmpCamera1.getSupportedFps();
        result.success(supportedFps);
    }

    private void getResolutionValue(MethodCall methodCall, Result result) {
        int resolutionValue = rtmpCamera1.getResolutionValue();
        result.success(resolutionValue);
    }

    private void isOnPreview(MethodCall methodCall, Result result) {
        boolean onPreview = rtmpCamera1.isOnPreview();
        result.success(onPreview);
    }

    @Override
    public boolean onTouch(View view, MotionEvent motionEvent) {
        int action = motionEvent.getAction();
        if (motionEvent.getPointerCount() > 1) {
            if (action == MotionEvent.ACTION_MOVE) {
                rtmpCamera1.setZoom(motionEvent);
            }
        } else if (action == MotionEvent.ACTION_DOWN) {
            rtmpCamera1.tapToFocus( motionEvent);
        }
        return true;
    }

    void addTextToStream(MethodCall methodCall, Result result) {
        String value = (String) methodCall.arguments;
        TextObjectFilterRender textObjectFilterRender = new TextObjectFilterRender();
        rtmpCamera1.getGlInterface().addFilter(textObjectFilterRender);
        textObjectFilterRender.setText(value, 32, Color.RED);
        textObjectFilterRender.setDefaultScale(rtmpCamera1.getStreamWidth(),
                rtmpCamera1.getStreamHeight());
        textObjectFilterRender.setPosition(TranslateTo.BOTTOM);
    }

    void addImageToStream(MethodCall methodCall, Result result) {
        ImageObjectFilterRender imageObjectFilterRender = new ImageObjectFilterRender();
        rtmpCamera1.getGlInterface().addFilter(imageObjectFilterRender);
        imageObjectFilterRender.setImage(bitmap);
        imageObjectFilterRender.setDefaultScale(rtmpCamera1.getStreamWidth(), rtmpCamera1.getStreamHeight());
        imageObjectFilterRender.setPosition(TranslateTo.TOP_RIGHT);
    }

    void clearFilterFromStream(MethodCall methodCall, Result result) {
        rtmpCamera1.getGlInterface().clearFilters();
    }
}

