package com.example.rootencoder;

import static androidx.core.content.ContextCompat.getSystemService;

import android.annotation.SuppressLint;
import android.graphics.Rect;
import android.net.ConnectivityManager;
import android.net.Network;
import android.net.NetworkRequest;
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
import com.pedro.encoder.TimestampMode;
import com.pedro.encoder.input.gl.render.filters.object.ImageObjectFilterRender;
import com.pedro.encoder.input.gl.render.filters.object.TextObjectFilterRender;
import com.pedro.encoder.input.video.CameraHelper;
import com.pedro.encoder.input.video.CameraOpenException;
import com.pedro.encoder.input.video.facedetector.Face;
import com.pedro.encoder.input.video.facedetector.FaceDetectorCallback;
import com.pedro.encoder.utils.CodecUtil;
import com.pedro.encoder.utils.gl.AspectRatioMode;
import com.pedro.encoder.utils.gl.TranslateTo;
import com.pedro.encoder.utils.gl.SizeCalculator;
import com.pedro.library.rtmp.RtmpCamera1;
import com.pedro.library.rtmp.RtmpCamera2;
import com.pedro.library.view.OpenGlView;

import java.io.File;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.Arrays;
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
    private int exposure = 0;
    private int fps = 30;
    private String rtmpURL = null;

    @Override
    public void onFlutterViewAttached(@NonNull View flutterView) {
        PlatformView.super.onFlutterViewAttached(flutterView);
        openGlView.getHolder().addCallback(this);
        openGlView.setOnTouchListener(this);

    }

    Rootencoder(Context context, BinaryMessenger messenger, int id) {
        bitmap = BitmapFactory.decodeResource(context.getResources(), R.drawable.dev);
        openGlView = new OpenGlView(context);
        openGlView.setAspectRatioMode(AspectRatioMode.NONE);
        rtmpCamera1 = new RtmpCamera2(openGlView, this);
        methodChannel = new MethodChannel(messenger, "rootencoder");
        methodChannel.setMethodCallHandler(this);
        rtmpCamera1.setTimestampMode(TimestampMode.BUFFER, TimestampMode.BUFFER);

//        if (rtmpCamera1.isVideoStabilizationEnabled()) {
//            rtmpCamera1.enableVideoStabilization();
//        }

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

        ConnectivityManager connectivityManager = (ConnectivityManager) context.getSystemService(Context.CONNECTIVITY_SERVICE);

        connectivityManager.registerNetworkCallback(new NetworkRequest.Builder().build(), new ConnectivityManager.NetworkCallback() {
            @Override
            public void onAvailable(Network network) {
                Log.d("amar 2", network.toString());
                if (rtmpCamera1.isRecording() && !rtmpCamera1.isStreaming()) {
                    rtmpCamera1.startStream(rtmpURL);
                }
            }

            @Override
            public void onLost(Network network) {
                Log.d("amar lost", network.toString());
                rtmpCamera1.stopStream();
            }
        });
        rtmpCamera1.getStreamClient().setReTries(5000000);
    }

    private void setVideoCodecInit() {
        try {
            rtmpCamera1.setVideoCodec(VideoCodec.AV1);
        } catch (Exception e) {
            rtmpCamera1.setVideoCodec(VideoCodec.H264);
        }
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
        for (int i = 0; i < rtmpCamera1.getResolutionsBack().toArray().length; i++)
            Log.d("amar", String.valueOf(rtmpCamera1.getResolutionsBack().get(i).getWidth()) + "x" + String.valueOf(rtmpCamera1.getResolutionsBack().get(i).getHeight()));
        result.success("changed with stop stream and record");
    }

    private void startStream(MethodCall methodCall, Result result) {
        String url = (String) methodCall.arguments;
        rtmpURL = url;
        if (!rtmpCamera1.isStreaming()) {
            try {
                rtmpCamera1.startStream(url);
                rtmpCamera1.getGlInterface().setRotation(0);
//                rtmpCamera1.getGlInterface().setStreamRotation(0);
                result.success("connected");
            } catch (Exception e) {
                Log.d("amar", e.getMessage());
                result.success(e.getMessage());
            }
        } else {
            rtmpCamera1.stopStream();
            result.success(null);
        }
    }

    private void stopStream(MethodCall methodCall, Result result) {
        rtmpCamera1.stopStream();
        result.success(null);
    }

    int getAdjustedBitrate() {
        return height <= 480 ? 1250 * 1024 : height <= 540 ? 2500 * 1024 : height <= 720 ? 6500 * 1024 : 10000 * 1024;
    }

    private void startRecord(MethodCall methodCall, Result result) {
        String path = (String) methodCall.arguments;
        if (!rtmpCamera1.isRecording()) {
            try {
                if(rtmpCamera1.isOnPreview()) {
                    rtmpCamera1.stopPreview();
                }
                rtmpCamera1.startPreview(CameraHelper.Facing.BACK,width,height,fps, 0);
                rtmpCamera1.prepareAudio();
                rtmpCamera1.prepareVideo(width, height, fps, getAdjustedBitrate(), 0);
                rtmpCamera1.setExposure(exposure);
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
                if (!rtmpCamera1.isOnPreview()) {
                    rtmpCamera1.startPreview(CameraHelper.Facing.BACK,  width,height,fps, 0);
                }
            } catch (CameraOpenException e) {
                Log.d("Camera can't attached", "yes");
            }
        }
    }

    @Override
    public void surfaceChanged(@NonNull SurfaceHolder surfaceHolder, int i, int i1, int i2) {
        if (rtmpCamera1 != null) {
            if (rtmpCamera1.isOnPreview()) rtmpCamera1.stopPreview();
            try {
                if (!rtmpCamera1.isOnPreview())
                    rtmpCamera1.startPreview(CameraHelper.Facing.BACK,width,height, fps,0);
            } catch (Exception e) {
                Log.d("surfaceChanged", "can't preview");
            }
        }
    }

    @Override
    public void surfaceDestroyed(@NonNull SurfaceHolder surfaceHolder) {
        if (rtmpCamera1 != null && rtmpCamera1.isOnPreview()) {
            rtmpCamera1.stopPreview();
        }
    }


    void close() {
        Log.d("amar", "hello closing...");
        if (rtmpCamera1.isRecording()) {
            rtmpCamera1.stopRecord();
        }
        if (rtmpCamera1.isStreaming()) {
            rtmpCamera1.stopStream();
        }
        if (rtmpCamera1.isOnPreview()) rtmpCamera1.stopPreview();
        eventSink.endOfStream();
        eventSink2.endOfStream();
    }

    @Override
    public void onAuthError() {
        close();
    }

    @Override
    public void onAuthSuccess() {

    }

    @Override
    public void onFlutterViewDetached() {
        PlatformView.super.onFlutterViewDetached();
        rtmpCamera1.stopStream();
        rtmpCamera1.stopRecord();
        rtmpCamera1.stopPreview();
        rtmpCamera1.stopCamera();
        eventSink.endOfStream();
        eventSink2.endOfStream();
    }

    @Override
    public void onConnectionFailed(@NonNull String s) {
        Log.d("amar", "onConnectionFailed " + s);
        rtmpCamera1.getStreamClient().reTry(5000, s, null);
        if (eventSink != null) eventSink.success("Reconnecting");
    }

    @Override
    public void onConnectionStarted(@NonNull String s) {
        Log.d("amar", "onConnectionStarted " + s);
        if (eventSink != null) eventSink.success("Connecting");
    }

    @Override
    public void onConnectionSuccess() {
        Log.d("amar", "onConnectionSuccess");
        io.flutter.Log.d("amar", "hello onConnectionSuccess...");

        if (eventSink != null) eventSink.success("Connected");

    }

    @Override
    public void onDisconnect() {
        Log.d("amar", "onDisconnect");
        rtmpCamera1.getStreamClient().reTry(5000, "retry", null);
        if (eventSink != null) eventSink.success("Disconnected");
    }

    @Override
    public void onNewBitrate(long l) {
        if (eventSink2 != null) eventSink2.success(l);
    }

    private void setVideoBitrateOnFly(MethodCall methodCall, Result result) {
        int bitrate = (int) methodCall.arguments;
        rtmpCamera1.setVideoBitrateOnFly(bitrate);
        result.success(null);
    }

    private void setZoom(MethodCall methodCall, Result result) {
        double level = (double) methodCall.arguments;
        rtmpCamera1.setZoom((float) level);
        result.success(null);
    }

    private void setExposure(MethodCall methodCall, Result result) {
        int value = (int) methodCall.arguments;
        rtmpCamera1.setExposure(value);
        exposure = value;
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
        Log.d("amar 2", String.valueOf(action == MotionEvent.ACTION_MOVE));

        if (motionEvent.getPointerCount() > 1) {
            if (action == MotionEvent.ACTION_MOVE) {
                rtmpCamera1.setZoom(motionEvent, 0.05f);
                view.performClick();
                Log.d("amar", String.valueOf(action));

            }
        } else if (action == MotionEvent.ACTION_DOWN) {
            rtmpCamera1.tapToFocus(motionEvent);
            view.performClick();
        }
        return true;
    }


    void addTextToStream(MethodCall methodCall, Result result) {
        String value = (String) methodCall.arguments;
        TextObjectFilterRender textObjectFilterRender = new TextObjectFilterRender();
        rtmpCamera1.getGlInterface().addFilter(textObjectFilterRender);
        textObjectFilterRender.setText(value, 32, Color.RED);
        textObjectFilterRender.setDefaultScale(rtmpCamera1.getStreamWidth(), rtmpCamera1.getStreamHeight());
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

