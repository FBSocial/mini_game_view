package com.idreamsky.fanbook.game.mini_game_view.QuickStart;

import android.app.Activity;
import android.content.Context;
import android.os.Handler;
import android.os.Looper;
import android.text.TextUtils;
import android.util.DisplayMetrics;
import android.util.Log;
import android.view.View;
import android.view.ViewTreeObserver;
import android.view.WindowManager;
import android.widget.Toast;

import com.idreamsky.fanbook.game.mini_game_view.MiniGameEvent;
import com.idreamsky.fanbook.game.mini_game_view.SudMGPWrapper.decorator.SudFSMMGCache;
import com.idreamsky.fanbook.game.mini_game_view.SudMGPWrapper.decorator.SudFSMMGDecorator;
import com.idreamsky.fanbook.game.mini_game_view.SudMGPWrapper.decorator.SudFSMMGListener;
import com.idreamsky.fanbook.game.mini_game_view.SudMGPWrapper.decorator.SudFSTAPPDecorator;
import com.idreamsky.fanbook.game.mini_game_view.SudMGPWrapper.model.GameConfigModel;
import com.idreamsky.fanbook.game.mini_game_view.SudMGPWrapper.model.GameViewInfoModel;
import com.idreamsky.fanbook.game.mini_game_view.SudMGPWrapper.state.MGStateResponse;
import com.idreamsky.fanbook.game.mini_game_view.SudMGPWrapper.state.SudMGPMGState;
import com.idreamsky.fanbook.game.mini_game_view.SudMGPWrapper.utils.HSTextUtils;
import com.idreamsky.fanbook.game.mini_game_view.SudMGPWrapper.utils.SudJsonUtils;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;

import tech.sud.mgp.core.ISudFSMStateHandle;
import tech.sud.mgp.core.ISudFSTAPP;
import tech.sud.mgp.core.ISudListenerInitSDK;
import tech.sud.mgp.core.SudInitSDKParamModel;
import tech.sud.mgp.core.SudMGP;

/**
 * 游戏业务逻辑抽象类
 * 1.自定义ViewModel继承此类，实现对应方法。(注意：onAddGameView()与onRemoveGameView()与页面有交互)
 * 2.外部调用switchGame()方法启动游戏
 * 3.页面销毁时调用onDestroy()
 * <p>
 * Game business logic abstract class
 * 1. Define a custom ViewModel that extends this class and implement the corresponding methods. (Note: onAddGameView() and onRemoveGameView() interact with the page)
 * 2. Call the switchGame() method externally to start the game.
 * 3. Call onDestroy() when the page is destroyed.
 */
public abstract class BaseGameViewModel implements SudFSMMGListener {
    private static final String TAG = "BaseGameViewModel";
    public String userId;
    public String appId;
    public String appKey;
    public boolean isTestEnv;
    private String gameRoomId;

    private long playingGameId;

    private final GameViewInfoModel.GameViewRectModel rectModel = new GameViewInfoModel.GameViewRectModel();


    /**
     * app调用sdk的封装类
     * The app's wrapper class for calling the SDK.
     */
    public final SudFSTAPPDecorator sudFSTAPPDecorator = new SudFSTAPPDecorator();

    /**
     * 用于处理游戏SDK部分回调业务
     * Used to handle game SDK callback business.
     */
    private final SudFSMMGDecorator sudFSMMGDecorator = new SudFSMMGDecorator();

    /**
     * 游戏View
     * Game view
     */
    public View gameView;

    /**
     * 游戏配置
     * Game configuration
     */
    public GameConfigModel gameConfigModel = new GameConfigModel();
    protected final Handler handler = new Handler(Looper.getMainLooper());
    private ISudFSMStateHandle iSudFSMStateHandle;

    private Activity mActivity;

    public void initGame(Activity activity, Map<String, Object> creationParams) {
        initGameInfo(creationParams);

        initGameConfig(creationParams);

        initGameView(activity, creationParams);
    }

    private void initGameInfo(Map<String, Object> creationParams) {
        userId = (String) creationParams.get("userId");
        String gameIdString = (String) creationParams.get("gameId");
        assert gameIdString != null;
        playingGameId = Long.parseLong(gameIdString);
        gameRoomId = (String) creationParams.get("roomId");
    }

    private void initGameConfig(Map<String, Object> creationParams) {
        appId = (String) creationParams.get("appId");
        appKey = (String) creationParams.get("appKey");
        isTestEnv = creationParams.get("isTestEnv") == null || (Boolean) (creationParams.get("isTestEnv"));

        gameConfigModel.ui.game_bg.hide = creationParams.get("hideGameBg") == null || (Boolean) (creationParams.get("hideGameBg"));

        Boolean hideLoadingGameBg = creationParams.get("hideLoadingGameBg") == null || (Boolean) (creationParams.get("hideLoadingGameBg"));
        SudMGP.getCfg().setShowLoadingGameBg(!hideLoadingGameBg);

        // https://docs.sud.tech/zh-CN/app/Client/API/ISudFSMMG/onGetGameCfg.html
//        gameConfigModel.ui.ping.hide = true;
        gameConfigModel.ui.level.hide = true;
        gameConfigModel.ui.lobby_help_btn.hide = true;
        gameConfigModel.ui.lobby_setting_btn.hide = true;
        gameConfigModel.ui.lobby_rule.hide = true;
        gameConfigModel.ui.lobby_players.hide = true;
        gameConfigModel.ui.lobby_player_captain_icon.hide = true;
        gameConfigModel.ui.lobby_player_kickout_icon.hide = true;
        gameConfigModel.ui.lobby_game_setting.hide = true;
        gameConfigModel.ui.share_btn.hide = true;
//        gameConfigModel.ui.version.hide = true;
        gameConfigModel.ui.join_btn.hide = true;
        gameConfigModel.ui.cancel_join_btn.hide = true;
        gameConfigModel.ui.ready_btn.hide = true;
        gameConfigModel.ui.cancel_ready_btn.hide = true;
        gameConfigModel.ui.start_btn.hide = true;

        gameConfigModel.ui.gameSettle.hide = true;

        // 结束弹窗 再来一局
        gameConfigModel.ui.game_settle_again_btn.custom = true;
        // 结束弹窗 关闭
        gameConfigModel.ui.game_settle_close_btn.custom = true;

    }

    /**
     * 外部调用切换游戏，传不同的gameId即可加载不同的游戏
     * gameId传0 等同于关闭游戏
     * <p>
     * External call to switch games, pass a different gameId to load different games.
     * Passing 0 as gameId is equivalent to closing the game.
     *
     * @param activity 游戏所在页面，用作于生命周期判断
     *                 The page where the game is located, used for lifecycle judgment.
     */
    public void initGameView(Activity activity, Map<String, Object> creationParams) {
        if (TextUtils.isEmpty(gameRoomId)) {
            Toast.makeText(activity, "gameRoomId can not be empty", Toast.LENGTH_LONG).show();
            return;
        }
        int topDp = creationParams.get("top") == null ? 0 : (int) (creationParams.get("top"));
        int leftDp = creationParams.get("left") == null ? 0 : (int) (creationParams.get("left"));
        int rightDp = creationParams.get("right") == null ? 0 : (int) (creationParams.get("right"));
        int bottomDp = creationParams.get("bottom") == null ? 0 : (int) (creationParams.get("bottom"));
        rectModel.top = dpToPx(activity, topDp);
        rectModel.left = dpToPx(activity, leftDp);
        rectModel.right = dpToPx(activity, rightDp);
        rectModel.bottom = dpToPx(activity, bottomDp);
    }

    private int dpToPx(Context context, float dp) {
        DisplayMetrics displayMetrics = context.getResources().getDisplayMetrics();
        return Math.round(dp * (displayMetrics.xdpi / DisplayMetrics.DENSITY_DEFAULT));
    }

    /**
     * 第1步，获取短期令牌code，用于换取游戏Server访问APP Server的长期ssToken
     * 接入方客户端 调用 接入方服务端 login 获取 短期令牌code
     * 参考文档时序图：sud-mgp-doc(https://docs.sud.tech/zh-CN/app/Client/StartUp-Android.html)
     * <p>
     * Step 1, obtain a short-term token code for exchanging a long-term ssToken to access the APP Server from the game Server.
     * The client of the integration party calls the login endpoint on the integration party server to obtain a short-term token code.
     * Refer to the sequence diagram in the documentation: sud-mgp-doc (https://docs.sud.tech/en-US/app/Client/StartUp-Android.html)
     *
     * @param activity 游戏所在页面
     *                 The page where the game is located.
     */
    public void login(Activity activity, String loginCode) {
        if (activity.isDestroyed() || playingGameId <= 0) {
            return;
        }
        mActivity = activity;
        initSdk(activity, loginCode);
    }

    /**
     * 第2步，初始化SudMGP sdk
     * <p>
     * Step 2, initialize the SudMGP SDK.
     *
     * @param activity 游戏所在页面
     *                 The page where the game is located.
     * @param code     令牌
     *                 Token.
     */
    private void initSdk(Activity activity, String code) {
        SudInitSDKParamModel params = new SudInitSDKParamModel();
        params.context = activity;
        params.appId = appId;
        params.appKey = appKey;
        params.isTestEnv = isTestEnv();
        params.userId = getUserId();
        SudMGP.initSDK(params, new ISudListenerInitSDK() {
            @Override
            public void onSuccess() {
                loadGame(activity, code);
            }

            @Override
            public void onFailure(int errCode, String errMsg) {
                if (isTestEnv()) {
                    Log.d(TAG, "initSDK onFailure:" + errMsg + "(" + errCode + ")");
                }
            }
        });
    }

    /**
     * 第3步，加载游戏
     * APP和游戏的相互调用
     * ISudFSTAPP：APP调用游戏的接口
     * ISudFSMMG：游戏调APP的响应回调
     * <p>
     * Step 3, load the game.
     * Interaction between the APP and the game.
     * ISudFSTAPP: Interface for the APP to call the game.
     * ISudFSMMG: Callback for the game to call back to the APP.
     *
     * @param activity 游戏所在页面
     *                 The page where the game is located.
     * @param code     登录令牌
     *                 Login token.
     */
    private void loadGame(Activity activity, String code) {
        if (activity.isDestroyed()) {
            return;
        }

        // 给装饰类设置回调
        // Set a callback for the decorator class.
        sudFSMMGDecorator.setSudFSMMGListener(this);

        // 调用游戏sdk加载游戏
        // Invoke the game SDK to load the game.
        ISudFSTAPP iSudFSTAPP = SudMGP.loadMG(activity, getUserId(), gameRoomId, code, playingGameId, getLanguageCode(), sudFSMMGDecorator);

        // 如果返回空，则代表参数问题或者非主线程
        // If null is returned, it indicates a parameter issue or a non-main thread.
        if (iSudFSTAPP == null) {
            Toast.makeText(activity, "loadMG params error", Toast.LENGTH_LONG).show();
            return;
        }

        // APP调用游戏接口的装饰类设置
        // Decorator class setup for APP calling game interfaces.
        sudFSTAPPDecorator.setISudFSTAPP(iSudFSTAPP);

        // 获取游戏视图，将其抛回Activity进行展示
        // Activity调用：gameContainer.addView(view, FrameLayout.LayoutParams.MATCH_PARENT, FrameLayout.LayoutParams.MATCH_PARENT);
        // Retrieve the game view and throw it back to the Activity for display.
        // Activity invocation：gameContainer.addView(view, FrameLayout.LayoutParams.MATCH_PARENT, FrameLayout.LayoutParams.MATCH_PARENT);
        gameView = iSudFSTAPP.getGameView();
        onAddGameView(gameView);
        new Handler().postDelayed(new Runnable() {
            @Override
            public void run() {
                setInputMode(activity);
            }
        }, 500);
        new Handler().postDelayed(new Runnable() {
            @Override
            public void run() {
                setInputMode(activity);
            }
        }, 3000);
    }

    private void setInputMode(Activity activity) {
        if (activity == null || activity.isDestroyed()) return;
        activity.getWindow().setSoftInputMode(WindowManager.LayoutParams.SOFT_INPUT_ADJUST_RESIZE | WindowManager.LayoutParams.SOFT_INPUT_STATE_ALWAYS_HIDDEN);
    }

    /**
     * 销毁游戏
     * Destroy the game.
     */
    public void destroyMG() {
        if (playingGameId > 0) {
            sudFSTAPPDecorator.destroyMG();
            sudFSMMGDecorator.destroyMG();
            gameRoomId = null;
            playingGameId = 0;
            gameView = null;
            onRemoveGameView();
        }
    }

    /**
     * 获取当前游戏房id
     * Retrieve the current game room ID.
     */
    public String getGameRoomId() {
        return gameRoomId;
    }

    // region 子类需要实现的方法 English:Methods to be implemented by subclasses.

    /**
     * 向接入方服务器获取code
     * Get the code from the integration party server.
     */
    public abstract void getCode(Activity activity, String userId, String appId, GameGetCodeListener listener);

    /**
     * 设置当前用户id(接入方定义)
     * Set the current user ID (defined by the integration party).
     *
     * @return 返回用户id
     * Returns the user ID.
     */
    protected abstract String getUserId();

    /**
     * 设置游戏所用的appId
     * Set the appId used by the game.
     *
     * @return 返回游戏服务appId
     * Returns the game service appId.
     */
    protected abstract String getAppId();

    /**
     * 设置游戏所用的appKey
     * Set the appKey used by the game.
     *
     * @return 返回游戏服务appKey
     * Returns the game service appKey.
     */
    protected abstract String getAppKey();

    /**
     * 设置游戏的语言代码
     * 参考文档：https://docs.sud.tech/zh-CN/app/Client/Languages/
     * <p>
     * Set the language code for the game.
     * Refer to the documentation: https://docs.sud.tech/en-US/app/Client/Languages/
     *
     * @return 返回语言代码
     * Returns the language code.
     */
    protected abstract String getLanguageCode();

    /**
     * 设置游戏的安全操作区域
     * Set the secure operation area for the game.
     *
     * @param gameViewInfoModel 游戏视图大小
     *                          gameViewInfoModel Game view size.
     */
    protected abstract void getGameRect(GameViewInfoModel gameViewInfoModel);

    /**
     * true 加载游戏时为测试环境
     * false 加载游戏时为生产环境
     * <p>
     * true for the testing environment when loading the game.
     * false for the production environment when loading the game.
     */
    protected abstract boolean isTestEnv();

    /**
     * 将游戏View添加到页面中
     * Add the game view to the page.
     */
    protected abstract void onAddGameView(View gameView);

    /**
     * 将页面中的游戏View移除
     * Remove the game view from the page.
     */
    protected abstract void onRemoveGameView();

    // endregion 子类需要实现的方法 English：Methods that need to be implemented by subclasses.

    // region 游戏侧回调 English：Callback from the game side

    /**
     * 游戏日志
     * 最低版本：v1.1.30.xx
     * <p>
     * Game log
     * Minimum version: v1.1.30.xx
     */
    @Override
    public void onGameLog(String str) {
        SudFSMMGListener.super.onGameLog(str);
    }

    /**
     * 游戏开始
     * 最低版本：v1.1.30.xx
     * <p>
     * Game start
     * Minimum version: v1.1.30.xx
     */
    @Override
    public void onGameStarted() {
        setInputMode(mActivity);
    }

    /**
     * 游戏销毁
     * 最低版本：v1.1.30.xx
     * <p>
     * Game destruction
     * Minimum version: v1.1.30.xx
     */
    @Override
    public void onGameDestroyed() {
    }

    /**
     * Code过期，需要实现
     * APP接入方需要调用handle.success或handle.fail
     * <p>
     * Code expired, needs to be implemented.
     * The APP integration party needs to call handle.success or handle.fail.
     *
     * @param dataJson {"code":"value"}
     */
    @Override
    public void onExpireCode(ISudFSMStateHandle handle, String dataJson) {
        MiniGameEvent.onExpireCode();
        iSudFSMStateHandle = handle;
//        processOnExpireCode(sudFSTAPPDecorator, handle);
    }

    public void updateCode(String code) {
        if (playingGameId <= 0 || iSudFSMStateHandle == null) return;
        MGStateResponse mgStateResponse = new MGStateResponse();
        if (code.isEmpty()) {
            mgStateResponse.ret_code = -1;
            iSudFSMStateHandle.failure(SudJsonUtils.toJson(mgStateResponse));
        } else {
            mgStateResponse.ret_code = MGStateResponse.SUCCESS;
            sudFSTAPPDecorator.updateCode(code, null);
            iSudFSMStateHandle.success(SudJsonUtils.toJson(mgStateResponse));
        }
    }

    /**
     * 获取游戏View信息，需要实现
     * APP接入方需要调用handle.success或handle.fail
     *
     * @param handle   handle
     * @param dataJson {}
     */
    @Override
    public void onGetGameViewInfo(ISudFSMStateHandle handle, String dataJson) {
        processOnGetGameViewInfo(gameView, handle);
    }

    /**
     * 获取游戏Config，需要实现
     * APP接入方需要调用handle.success或handle.fail
     * <p>
     * Obtain game configuration, needs to be implemented.
     * The APP integration party needs to call handle.success or handle.fail.
     *
     * @param handle   handle
     * @param dataJson {}
     *                 最低版本：v1.1.30.xx
     */
    @Override
    public void onGetGameCfg(ISudFSMStateHandle handle, String dataJson) {
        processOnGetGameCfg(handle, dataJson);
    }
    // endregion 游戏侧回调 English：Callback from the game side


    /**
     * 处理code过期
     * Handle code expiration
     */
    public void processOnExpireCode(SudFSTAPPDecorator sudFSTAPPDecorator, ISudFSMStateHandle handle) {
        // code过期，刷新code
        // Code expired, refresh code
        getCode(null, getUserId(), getAppId(), new GameGetCodeListener() {
            @Override
            public void onSuccess(String code) {
                if (playingGameId <= 0) return;
                MGStateResponse mgStateResponse = new MGStateResponse();
                mgStateResponse.ret_code = MGStateResponse.SUCCESS;
                sudFSTAPPDecorator.updateCode(code, null);
                handle.success(SudJsonUtils.toJson(mgStateResponse));
            }

            @Override
            public void onFailed() {
                MGStateResponse mgStateResponse = new MGStateResponse();
                mgStateResponse.ret_code = -1;
                handle.failure(SudJsonUtils.toJson(mgStateResponse));
            }
        });
    }

    /**
     * 处理游戏视图信息(游戏安全区)
     * 文档：https://docs.sud.tech/zh-CN/app/Client/API/ISudFSMMG/onGetGameViewInfo.html
     * <p>
     * Handle game view information (game safe area).
     * Documentation: https://docs.sud.tech/en-US/app/Client/API/ISudFSMMG/onGetGameViewInfo.html
     */
    public void processOnGetGameViewInfo(View gameView, ISudFSMStateHandle handle) {
        // 拿到游戏View的宽高
        // Get the width and height of the game view.
        int gameViewWidth = gameView.getMeasuredWidth();
        int gameViewHeight = gameView.getMeasuredHeight();
        if (gameViewWidth > 0 && gameViewHeight > 0) {
            notifyGameViewInfo(handle, gameViewWidth, gameViewHeight);
            return;
        }

        // 如果游戏View未加载完成，则监听加载完成时回调
        // If the game view is not loaded completely, listen for a callback when it finishes loading.
        gameView.getViewTreeObserver().addOnGlobalLayoutListener(new ViewTreeObserver.OnGlobalLayoutListener() {
            @Override
            public void onGlobalLayout() {
                gameView.getViewTreeObserver().removeOnGlobalLayoutListener(this);
                int width = gameView.getMeasuredWidth();
                int height = gameView.getMeasuredHeight();
                notifyGameViewInfo(handle, width, height);
            }
        });
    }

    /**
     * 通知游戏，游戏视图信息
     * Notify the game about the game view information.
     */
    private void notifyGameViewInfo(ISudFSMStateHandle handle, int gameViewWidth, int gameViewHeight) {
        GameViewInfoModel gameViewInfoModel = new GameViewInfoModel();
        gameViewInfoModel.ret_code = 0;
        // 游戏View大小
        // Game view size
        gameViewInfoModel.view_size.width = gameViewWidth;
        gameViewInfoModel.view_size.height = gameViewHeight;
        gameViewInfoModel.view_game_rect = rectModel;

        // 游戏安全操作区域
        // Game secure operation area
        getGameRect(gameViewInfoModel);

        // 给游戏侧进行返回
        // Return to the game side.
        String json = SudJsonUtils.toJson(gameViewInfoModel);
        // 如果设置安全区有疑问，可将下面的日志打印出来，分析json数据
        // 正确的格式为：{"ret_code":0,"view_game_rect":{"bottom":156,"left":0,"right":0,"top":196},"view_size":{"height":1920,"width":1080}}
        // 如果发生debug版本游戏正常，release版本游戏不正常，请检查是否混淆了GameViewInfoModel类，导致json序列化类的成员发生了变化
        // Log.d("SudBaseGameViewModel", "notifyGameViewInfo:" + json);

        // If there are questions about setting the secure area, you can print the following log to analyze the JSON data.
        // The correct format is: {"ret_code":0,"view_game_rect":{"bottom":156,"left":0,"right":0,"top":196},"view_size":{"height":1920,"width":1080}}
        // If the game works normally in the debug version but not in the release version, check if the GameViewInfoModel class is obfuscated, causing changes in the serialized members of the JSON.
        // Log.d("SudBaseGameViewModel", "notifyGameViewInfo:" + json);

        handle.success(json);
    }

    public void onPause() {
        // playMG和pauseMG要配对
        // playMG and pauseMG should be paired.
        sudFSTAPPDecorator.pauseMG();
    }

    public void onResume() {
        // playMG和pauseMG要配对
        // playMG and pauseMG should be paired.
        sudFSTAPPDecorator.playMG();
    }

    /**
     * 处理游戏配置
     * 文档：https://docs.sud.tech/zh-CN/app/Client/API/ISudFSMMG/onGetGameCfg.html
     * <p>
     * Handle game configuration.
     * Documentation: https://docs.sud.tech/en-US/app/Client/API/ISudFSMMG/onGetGameCfg.html
     */
    public void processOnGetGameCfg(ISudFSMStateHandle handle, String dataJson) {
        handle.success(SudJsonUtils.toJson(gameConfigModel));
    }

    /**
     * 游戏login(getCode)监听
     * Game login (getCode) listener
     */
    public interface GameGetCodeListener {
        void onSuccess(String code);

        void onFailed();
    }

    /**
     * 获取游戏状态缓存
     * Retrieve game state cache.
     */
    public SudFSMMGCache getSudFSMMGCache() {
        return sudFSMMGDecorator.getSudFSMMGCache();
    }


    public void messageHitState(String message) {
        // 数字炸弹
        if (sudFSMMGDecorator.isHitBomb() && HSTextUtils.isInteger(message)) {
            sudFSTAPPDecorator.notifyAPPCommonSelfTextHitState(false, null, message);
        }
    }

    public ArrayList<String> getPlayingUserIds() {
        SudFSMMGCache sudFSMMGCache = sudFSMMGDecorator.getSudFSMMGCache();
        HashSet<String> playerReadySet = sudFSMMGCache.getPlayerReadySet();
        ArrayList<String> list = new ArrayList<>();
        if (playerReadySet == null) {
            return list;
        }
        for (String userId : playerReadySet) {
            try {
                list.add(userId);
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
        return list;
    }

    public HashMap<String, Object> getPlayerIconPosition(String playerId) {
        SudFSMMGCache sudFSMMGCache = sudFSMMGDecorator.getSudFSMMGCache();
        HashMap<String, SudMGPMGState.MGCommonGamePlayerIconPosition> playerIconPositionMap = sudFSMMGCache.getPlayerIconPositionMap();
        if (playerIconPositionMap.isEmpty() || playerId.isEmpty()) return null;
        SudMGPMGState.MGCommonGamePlayerIconPosition playerIconPosition = playerIconPositionMap.get(playerId);
        if (playerIconPosition == null) return null;
        HashMap<String, Object> position = new HashMap<>();
        position.put("x", playerIconPosition.position.x);
        position.put("y", playerIconPosition.position.y);
        position.put("width", playerIconPosition.position.width);
        position.put("height", playerIconPosition.position.height);
        return position;
    }
}
