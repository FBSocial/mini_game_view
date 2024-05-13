package com.idreamsky.fanbook.game.mini_game_view;

import android.app.Activity;
import android.content.Context;
import android.graphics.Color;
import android.util.Log;
import android.view.View;
import android.widget.FrameLayout;
import android.widget.TextView;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.idreamsky.fanbook.game.mini_game_view.QuickStart.BaseGameViewModel;
import com.idreamsky.fanbook.game.mini_game_view.QuickStart.QuickStartGameViewModel;
import com.idreamsky.fanbook.game.mini_game_view.SudMGPWrapper.decorator.SudFSMMGDecorator;
import com.idreamsky.fanbook.game.mini_game_view.SudMGPWrapper.decorator.SudFSMMGListener;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.platform.PlatformView;
import tech.sud.mgp.core.ISudFSMStateHandle;
import tech.sud.mgp.core.ISudFSTAPP;
import tech.sud.mgp.core.ISudListenerInitSDK;
import tech.sud.mgp.core.SudInitSDKParamModel;
import tech.sud.mgp.core.SudMGP;

import java.util.HashMap;
import java.util.Map;

class MiniGameNativeView implements SudFSMMGListener, PlatformView, MethodChannel.MethodCallHandler, ActivityAware {
    private static final String TAG = "MiniGameNativeView";
    @NonNull
    private FrameLayout containerView = null;
    private Context mContext;
    private Activity mActivity;

    private MethodChannel mMethodChannel;

    private int count = 0;
    private final SudFSMMGDecorator sudFSMMGDecorator = new SudFSMMGDecorator();
    private final QuickStartGameViewModel gameViewModel = new QuickStartGameViewModel();

    private String userId;

    private String gameId;
    private String roomId;

    private View mGameView;

    MiniGameNativeView(Activity activity, FlutterPlugin.FlutterPluginBinding binding, @NonNull Context context, int id, @Nullable Map<String, Object> creationParams) {
        init(activity, context, binding);
        initArguments(creationParams);
        containerView.setBackgroundColor(Color.GREEN);
        Log.d(TAG, "MiniGameNativeView: ");
    }

    void init(Activity activity, Context context, FlutterPlugin.FlutterPluginBinding binding) {
        mActivity = activity;
        mContext = context;
        mMethodChannel = new MethodChannel(binding.getBinaryMessenger(), "mini_game_view");
        mMethodChannel.setMethodCallHandler(this);
        containerView = new FrameLayout(context);
        containerView.setLayoutParams(new FrameLayout.LayoutParams(200, 100));
    }

    private void initArguments(Map<String, Object> creationParams) {
        userId = (String) creationParams.get("userId");
        roomId = (String) creationParams.get("roomId");
        gameId = (String) creationParams.get("gameId");
    }

    private void loginGame() {
        // 请求登录code
        // Request login code
        gameViewModel.getCode(null, userId, QuickStartGameViewModel.SudMGP_APP_ID, new BaseGameViewModel.GameGetCodeListener() {
            @Override
            public void onSuccess(String code) {
                initSdk(code);
            }

            @Override
            public void onFailed() {
//                delayLoadGame(activity, gameId);
            }
        });
    }

    private void initSdk(String code) {
        // 初始化sdk
        // Initialize the SDK
        SudInitSDKParamModel params = new SudInitSDKParamModel();
        params.context = mContext;
        params.appId = QuickStartGameViewModel.SudMGP_APP_ID;
        params.appKey = QuickStartGameViewModel.SudMGP_APP_KEY;
        params.isTestEnv = true;
        params.userId = userId;
        SudMGP.initSDK(params, new ISudListenerInitSDK() {
            @Override
            public void onSuccess() {
                loadGame(code);
            }

            @Override
            public void onFailure(int errCode, String errMsg) {
                Log.d(TAG, "onFailure: " + errCode + " " + errMsg);
//                // TODO: 2022/6/13 下面toast可以根据业务需要决定是否保留
//                // TODO: 2022/6/13 The following toast can be kept or removed based on business needs.
//                if (isTestEnv()) {
//                    Toast.makeText(activity, "initSDK onFailure:" + errMsg + "(" + errCode + ")", Toast.LENGTH_LONG).show();
//                }
//
//                delayLoadGame(activity, gameId);
            }
        });
    }

    private void loadGame(String code) {
        // 给装饰类设置回调
        // Set a callback for the decorator class.
        sudFSMMGDecorator.setSudFSMMGListener(this);

        // 调用游戏sdk加载游戏
        // Invoke the game SDK to load the game.
        ISudFSTAPP iSudFSTAPP = SudMGP.loadMG(mActivity, userId, roomId, code, Long.parseLong(gameId), "zh-CN", sudFSMMGDecorator);

        // 如果返回空，则代表参数问题或者非主线程
        // If null is returned, it indicates a parameter issue or a non-main thread.
        if (iSudFSTAPP == null) {
            Toast.makeText(mContext, "loadMG params error", Toast.LENGTH_LONG).show();
//            delayLoadGame(activity, gameId);
            return;
        }

        // APP调用游戏接口的装饰类设置
        // Decorator class setup for APP calling game interfaces.
//        sudFSTAPPDecorator.setISudFSTAPP(iSudFSTAPP);

        // 获取游戏视图，将其抛回Activity进行展示
        // Activity调用：gameContainer.addView(view, FrameLayout.LayoutParams.MATCH_PARENT, FrameLayout.LayoutParams.MATCH_PARENT);
        // Retrieve the game view and throw it back to the Activity for display.
        // Activity invocation：gameContainer.addView(view, FrameLayout.LayoutParams.MATCH_PARENT, FrameLayout.LayoutParams.MATCH_PARENT);
        mGameView = iSudFSTAPP.getGameView();
        containerView.addView(mGameView, FrameLayout.LayoutParams.MATCH_PARENT, FrameLayout.LayoutParams.MATCH_PARENT);
//        onAddGameView(gameView);
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
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        if (call.method.equals("getPlatformVersion")) {
//            testAddView();
            result.success("Android " + android.os.Build.VERSION.RELEASE);
        } else if (call.method.equals("loadGameView")) {
            HashMap<String, Object> arguments = (HashMap<String, Object>) call.arguments;
            loginGame();
            result.success(true);
        } else {
            result.notImplemented();
        }
    }

    @Override
    public void onGameStarted() {

    }

    @Override
    public void onGameDestroyed() {

    }

    @Override
    public void onExpireCode(ISudFSMStateHandle handle, String dataJson) {

    }

    @Override
    public void onGetGameViewInfo(ISudFSMStateHandle handle, String dataJson) {
        if (mGameView == null) return;
        gameViewModel.processOnGetGameViewInfo(mGameView, handle);
    }

    @Override
    public void onGetGameCfg(ISudFSMStateHandle handle, String dataJson) {
        gameViewModel.processOnGetGameCfg(handle, dataJson);
    }

    @Override
    public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
        Log.d(TAG, "onAttachedToActivity: ");
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

