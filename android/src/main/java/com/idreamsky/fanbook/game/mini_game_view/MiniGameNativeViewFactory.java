package com.idreamsky.fanbook.game.mini_game_view;


import android.app.Activity;
import android.content.Context;

import androidx.annotation.Nullable;
import androidx.annotation.NonNull;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.StandardMessageCodec;
import io.flutter.plugin.platform.PlatformView;
import io.flutter.plugin.platform.PlatformViewFactory;

import java.util.Map;

class MiniGameNativeViewFactory extends PlatformViewFactory {

    private FlutterPlugin.FlutterPluginBinding binding;
    private Activity activity;

    MiniGameNativeViewFactory(Activity activity, FlutterPlugin.FlutterPluginBinding binding) {
        super(StandardMessageCodec.INSTANCE);
        this.binding = binding;
        this.activity = activity;
    }

    @NonNull
    @Override
    public PlatformView create(@NonNull Context context, int id, @Nullable Object args) {
        final Map<String, Object> creationParams = (Map<String, Object>) args;
        return new MiniGameNativeView(activity, binding, context, id, creationParams);
    }
}

