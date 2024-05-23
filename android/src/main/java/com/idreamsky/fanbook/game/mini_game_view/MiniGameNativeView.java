package com.idreamsky.fanbook.game.mini_game_view;

import android.app.Activity;
import android.content.Context;
import android.graphics.Color;
import android.util.Log;
import android.view.View;
import android.widget.FrameLayout;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.idreamsky.fanbook.game.mini_game_view.QuickStart.GameViewChangeListener;
import com.idreamsky.fanbook.game.mini_game_view.QuickStart.QuickStartGameViewModel;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.BasicMessageChannel;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.platform.PlatformView;

import java.util.HashMap;
import java.util.Map;

class MiniGameNativeView implements PlatformView, MethodChannel.MethodCallHandler {
    private static final String TAG = "MiniGameNativeView";
    @NonNull
    private FrameLayout containerView = null;
    private Context mContext;
    private Activity mActivity;

    private final QuickStartGameViewModel gameViewModel = new QuickStartGameViewModel();

    MiniGameNativeView(Activity activity, FlutterPlugin.FlutterPluginBinding binding, @NonNull Context context, int id, @Nullable Map<String, Object> creationParams) {
        init(activity, context, binding);
        assert creationParams != null;
        gameViewModel.destroyMG();
        gameViewModel.initGame(mActivity, creationParams);
        onGameContainerCreated();
    }

    void init(Activity activity, Context context, FlutterPlugin.FlutterPluginBinding binding) {
        mActivity = activity;
        mContext = context;

        containerView = new FrameLayout(context);
        containerView.setLayoutParams(new FrameLayout.LayoutParams(FrameLayout.LayoutParams.MATCH_PARENT, FrameLayout.LayoutParams.MATCH_PARENT));
        gameViewModel.setGameViewChangeListener(new GameViewChangeListener() {
            @Override
            public void onChanged(View view) {
                if (view == null) { // 在关闭游戏时，把游戏View给移除 English: When closing the game, remove the game view.
                    containerView.removeAllViews();
                } else { // 把游戏View添加到容器内 English: Add the game view to the container.
                    containerView.addView(view, FrameLayout.LayoutParams.MATCH_PARENT, FrameLayout.LayoutParams.MATCH_PARENT);
                }
            }
        });
        MiniGameViewPlugin.methodChannel.setMethodCallHandler(this);
    }

    @NonNull
    @Override
    public View getView() {
        return containerView;
    }

    @Override
    public void onFlutterViewAttached(@NonNull View flutterView) {
        PlatformView.super.onFlutterViewAttached(flutterView);
    }

    @Override
    public void onFlutterViewDetached() {
        gameViewModel.destroyMG();
        PlatformView.super.onFlutterViewDetached();
    }

    @Override
    public void dispose() {
        gameViewModel.destroyMG();
        gameViewModel.setGameViewChangeListener(null);
        MiniGameViewPlugin.methodChannel.setMethodCallHandler(null);
    }

    private void onGameContainerCreated() {
        MiniGameEvent.onGameContainerCreated();
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        if (call.method.equals("loginGame")) {
            String loginCode = (String) call.arguments;
            gameViewModel.login(mActivity, loginCode);
            result.success(true);
        } else if (call.method.equals("updateCode")) {
            String loginCode = (String) call.arguments;
            gameViewModel.updateCode(loginCode);
            result.success(true);
        } else {
            result.notImplemented();
        }
    }
}

