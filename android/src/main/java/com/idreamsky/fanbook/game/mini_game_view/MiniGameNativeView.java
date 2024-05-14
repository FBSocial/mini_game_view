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
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.platform.PlatformView;

import java.util.Map;

class MiniGameNativeView implements PlatformView, MethodChannel.MethodCallHandler {
    private static final String TAG = "MiniGameNativeView";
    @NonNull
    private FrameLayout containerView = null;
    private Context mContext;
    private Activity mActivity;

    private MethodChannel mMethodChannel;

    private final QuickStartGameViewModel gameViewModel = new QuickStartGameViewModel();

    MiniGameNativeView(Activity activity, FlutterPlugin.FlutterPluginBinding binding, @NonNull Context context, int id, @Nullable Map<String, Object> creationParams) {
        init(activity, context, binding);
        assert creationParams != null;
        containerView.setBackgroundColor(Color.GREEN);
        gameViewModel.destroyMG();
        gameViewModel.initGameInfo(creationParams);
        gameViewModel.initGameView(mActivity, creationParams);
        Log.d(TAG, "MiniGameNativeView: ");
    }

    void init(Activity activity, Context context, FlutterPlugin.FlutterPluginBinding binding) {
        mActivity = activity;
        mContext = context;
        mMethodChannel = new MethodChannel(binding.getBinaryMessenger(), "mini_game_view");
        mMethodChannel.setMethodCallHandler(this);
        containerView = new FrameLayout(context);
        containerView.setLayoutParams(new FrameLayout.LayoutParams(200, 100));
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
    }

    @NonNull
    @Override
    public View getView() {
        return containerView;
    }

    @Override
    public void onFlutterViewAttached(@NonNull View flutterView) {
        PlatformView.super.onFlutterViewAttached(flutterView);
        Log.d(TAG, "onFlutterViewAttached: ");
    }

    @Override
    public void onFlutterViewDetached() {
        PlatformView.super.onFlutterViewDetached();
        Log.d(TAG, "onFlutterViewAttached: ");
    }

    @Override
    public void dispose() {
        mMethodChannel.setMethodCallHandler(null);
        gameViewModel.setGameViewChangeListener(null);
        gameViewModel.destroyMG();
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        if (call.method.equals("loadGameView")) {
            result.success(true);
        } else {
            result.notImplemented();
        }
    }
}

