package com.idreamsky.fanbook.game.mini_game_view;

import android.util.Log;

import androidx.annotation.NonNull;

import java.util.HashMap;
import java.util.Map;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

/**
 * MiniGameViewPlugin
 */
public class MiniGameViewPlugin implements FlutterPlugin, MethodCallHandler, ActivityAware {
    private FlutterPluginBinding flutterPluginBinding;

    public static MethodChannel methodChannel;

    public static EventChannel eventChannel;
    public static EventChannel.EventSink eventSink;

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        Log.d("onAttachedToActivity", "onAttachedToActivity: 22");

        this.flutterPluginBinding = flutterPluginBinding;

        methodChannel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "mini_game_view/method");
        eventChannel = new EventChannel(flutterPluginBinding.getBinaryMessenger(), "mini_game_view/event");

        eventChannel.setStreamHandler(new EventChannel.StreamHandler() {
            @Override
            public void onListen(Object arguments, EventChannel.EventSink events) {
                eventSink = events;
            }

            @Override
            public void onCancel(Object arguments) {
                eventSink = null;
            }
        });
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        if (call.method.equals("getPlatformVersion")) {
            result.success("Android " + android.os.Build.VERSION.RELEASE);
        } else {
            result.notImplemented();
        }
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        methodChannel.setMethodCallHandler(null);
        eventChannel.setStreamHandler(null);
        methodChannel = null;
        eventChannel = null;
        eventSink = null;
    }

    @Override
    public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
        flutterPluginBinding
                .getPlatformViewRegistry()
                .registerViewFactory("mini-game-view-type", new MiniGameNativeViewFactory(binding.getActivity(), flutterPluginBinding));
    }

    @Override
    public void onDetachedFromActivityForConfigChanges() {

    }

    @Override
    public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {

    }

    @Override
    public void onDetachedFromActivity() {

    }
}
