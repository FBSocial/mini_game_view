package com.idreamsky.fanbook.game.mini_game_view.QuickStart;

import android.app.Activity;
import android.view.View;

import com.idreamsky.fanbook.game.mini_game_view.MiniGameEvent;
import com.idreamsky.fanbook.game.mini_game_view.SudMGPWrapper.model.GameConfigModel;
import com.idreamsky.fanbook.game.mini_game_view.SudMGPWrapper.model.GameViewInfoModel;
import com.idreamsky.fanbook.game.mini_game_view.SudMGPWrapper.state.MGStateResponse;
import com.idreamsky.fanbook.game.mini_game_view.SudMGPWrapper.state.SudMGPMGState;

import org.json.JSONObject;

import java.io.IOException;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.HashMap;
import java.util.ArrayList;

import okhttp3.Call;
import okhttp3.Callback;
import okhttp3.MediaType;
import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.RequestBody;
import okhttp3.Response;

import com.idreamsky.fanbook.game.mini_game_view.SudMGPWrapper.decorator.SudFSMMGListener;
import com.idreamsky.fanbook.game.mini_game_view.SudMGPWrapper.decorator.SudFSTAPPDecorator;
import com.idreamsky.fanbook.game.mini_game_view.SudMGPWrapper.utils.ISudFSMStateHandleUtils;

import tech.sud.mgp.core.ISudFSMMG;
import tech.sud.mgp.core.ISudFSMStateHandle;

/**
 * 游戏业务逻辑
 * 1.自定义ViewModel继承此类，实现对应方法。(注意：onAddGameView()与onRemoveGameView()与页面有交互)
 * 2.外部调用switchGame(activity,gameRoomId,gameId)方法启动游戏，参数定义可查看方法注释。
 * 3.页面销毁时调用onDestroy()
 * <p>
 * Game business logic
 * 1. Define a custom ViewModel that extends this class and implement the corresponding methods. (Note: onAddGameView() and onRemoveGameView() interact with the page)
 * 2. Externally call the switchGame(activity, gameRoomId, gameId) method to start the game. Refer to method comments for parameter definitions.
 * 3. Call onDestroy() when the page is destroyed.
 */
public class QuickStartGameViewModel extends BaseGameViewModel {

    // Sud平台申请的appId
    // The appId obtained from Sud platform application.
//    public static String SudMGP_APP_ID = "1461564080052506636";

    // Sud平台申请的appKey
    // The appKey obtained from Sud platform application.
//    public static String SudMGP_APP_KEY = "03pNxK2lEXsKiiwrBQ9GbH541Fk2Sfnc";

    // true 加载游戏时为测试环境 false 加载游戏时为生产环境
    // true for loading the game in the testing environment, false for loading the game in the production environment.
//    public static final boolean GAME_IS_TEST_ENV = true;

    // 使用的UserId。这里随机生成作演示，开发者将其修改为业务使用的唯一userId
    // Used UserId. Here it is randomly generated for demonstration purposes. Developers should modify it to the unique userId used for the business.
//    public static String userId = QuickStartUtils.genUserID();

    // 游戏自定义安全操作区域
    // Customized security operation zone for the game.
    public GameViewInfoModel.GameViewRectModel gameViewRectModel;

    // 游戏的语言代码
    // Language code for the game.
    public String languageCode = "zh-CN";


    public boolean checkGamePlaying = false;

    // 游戏View回调
    // Game View callback.
//    public final MutableLiveData<View> gameViewLiveData = new MutableLiveData<>();
    public GameViewChangeListener gameViewChangeListener;

    public void setGameViewChangeListener(GameViewChangeListener gameViewChangeListener) {
        this.gameViewChangeListener = gameViewChangeListener;
    }

    /**
     * 向接入方服务器获取code
     * Retrieve the code from the partner's server.
     */
    @Override
    public void getCode(Activity activity, String userId, String appId, GameGetCodeListener listener) {
        // TODO: 2022/6/10 注意，这里是演示使用OkHttpClient请求hello-sud服务
        // TODO: 2022/6/10 开发者在与后端联调时需将其改成自己的网络请求方式向自己的服务器获取code
        // TODO: 2023/10/26 每次回调此方法都去自己的后端拿最新的code，不要缓存code

        // TODO: 2022/6/10 Note that this is a demonstration using OkHttpClient to request the hello-sud service.
        // TODO: 2022/6/10 Developers should modify this to their own network request method to retrieve the code from their own server during backend integration.
        // TODO: 2023/10/26 Retrieve the latest code from your own backend every time this method is called, and avoid caching the code.
        OkHttpClient client = new OkHttpClient();
        String req;
        try {
            JSONObject reqJsonObj = new JSONObject();
            reqJsonObj.put("user_id", userId);
            req = reqJsonObj.toString();
        } catch (Exception e) {
            e.printStackTrace();
            req = "";
        }

        RequestBody body = RequestBody.create(req, MediaType.get("application/json; charset=utf-8"));
        Request request = new Request.Builder()
                .url("https://mgp-hello.sudden.ltd/login/v3")
                .post(body)
                .build();
        client.newCall(request).enqueue(new Callback() {
            @Override
            public void onFailure(Call call, IOException e) {
                handler.post(new Runnable() {
                    @Override
                    public void run() {
                        listener.onFailed();
                    }
                });
            }

            @Override
            public void onResponse(Call call, Response response) {
                try {
                    String dataJson = Objects.requireNonNull(response.body()).string();
                    JSONObject jsonObject = new JSONObject(dataJson);
                    int ret_code = jsonObject.getInt("ret_code");
                    JSONObject dataObject = jsonObject.getJSONObject("data");
                    String code = dataObject.getString("code");
                    handler.post(new Runnable() {
                        @Override
                        public void run() {
                            if (ret_code == MGStateResponse.SUCCESS) {
                                listener.onSuccess(code);
                            } else {
                                listener.onFailed();
                            }
                        }
                    });
                } catch (Exception e) {
                    e.printStackTrace();
                    handler.post(new Runnable() {
                        @Override
                        public void run() {
                            listener.onFailed();
                        }
                    });
                }
            }
        });
    }

    /**
     * 设置当前用户id(接入方定义)
     * Set the current user ID (defined by the partner).
     */
    @Override
    protected String getUserId() {
        return userId;
    }

    /**
     * 设置Sud平台申请的appId
     * Set the appId obtained from the Sud platform.
     */
    @Override
    protected String getAppId() {
        return appId;
    }

    /**
     * 设置Sud平台申请的appKey
     * Set the appKey obtained from the Sud platform.
     */
    @Override
    protected String getAppKey() {
        return appKey;
    }

    /**
     * 设置游戏的语言代码
     * Set the language code for the game.
     */
    @Override
    protected String getLanguageCode() {
        return languageCode;
    }

    /**
     * 设置游戏的安全操作区域，{@link ISudFSMMG}.onGetGameViewInfo()的实现。
     * 参考文档：https://docs.sud.tech/zh-CN/app/Client/API/ISudFSMMG/onGetGameViewInfo.html
     * <p>
     * Set the secure operation area for the game, implementation of {@link ISudFSMMG}.onGetGameViewInfo().
     * Reference documentation: https://docs.sud.tech/en-US/app/Client/API/ISudFSMMG/onGetGameViewInfo.html
     *
     * @param gameViewInfoModel 游戏视图模型
     *                          Game view model
     */
    @Override
    protected void getGameRect(GameViewInfoModel gameViewInfoModel) {
        // 相对于view_size（左、上、右、下）边框偏移（单位像素）
        // 开发者可自定义gameViewRectModel来控制安全区域

        // Border offset relative to view_size (left, top, right, bottom) in pixels
        // Developers can customize the gameViewRectModel to control the safe area
        if (gameViewRectModel != null) {
            gameViewInfoModel.view_game_rect = gameViewRectModel;
        }
    }

    /**
     * 获取游戏配置对象，{@link ISudFSMMG}.onGetGameCfg()的实现。
     * 参考文档：https://docs.sud.tech/zh-CN/app/Client/API/ISudFSMMG/onGetGameCfg.html
     * 开发者拿到此对象之后，可修改自己需要的配置
     * 注意：在加载游戏之前配置才有效
     * <p>
     * Get the game configuration object, implementation of {@link ISudFSMMG}.onGetGameCfg().
     * Reference documentation: https://docs.sud.tech/en-US/app/Client/API/ISudFSMMG/onGetGameCfg.html
     * Once developers obtain this object, they can modify the desired configurations.
     * Note: The configurations are only effective before loading the game.
     *
     * @return 游戏配置对象
     * Game configuration object
     */
    public GameConfigModel getGameConfigModel() {
        return gameConfigModel;
    }

    /**
     * true 加载游戏时为测试环境
     * false 加载游戏时为生产环境
     * <p>
     * true for loading the game in the testing environment
     * false for loading the game in the production environment.
     */
    @Override
    protected boolean isTestEnv() {
        return isTestEnv;
    }

    /**
     * 将游戏View添加到页面中
     * Add the game View to the page.
     */
    @Override
    protected void onAddGameView(View gameView) {
//        gameViewLiveData.setValue(gameView);
        gameViewChangeListener.onChanged(gameView);
    }

    /**
     * 将页面中的游戏View移除
     * Remove the game View from the page.
     */
    @Override
    protected void onRemoveGameView() {
//        gameViewLiveData.setValue(null);
        gameViewChangeListener.onChanged(null);
    }

    // ************ 上面是基础能力以及必要配置，下面讲解状态交互
    // ************ 主要有：1.App向游戏发送状态；2.游戏向App回调状态

    // ************ Above are the basic capabilities and necessary configurations, below we explain state interactions
    // ************ Mainly include: 1. App sending states to the game; 2. Game callback states to the App

    /**
     * 1.App向游戏发送状态
     * 这里演示的是发送：1. 加入状态；
     * 开发者可自由定义方法，能发送的状态都封装在{@link SudFSTAPPDecorator}
     * 参考文档：https://docs.sud.tech/zh-CN/app/Client/APPFST/
     * 注意：
     * 1，App向游戏发送状态，因为需要走网络，所以向游戏发送状态之后，不能马上销毁游戏或者finish Activity，否则状态无法发送成功。
     * 2，要保证状态能到达，可以发送之后，delay 500ms再销毁游戏或者finish Activity。
     *
     * <p> English
     * App sending states to the game
     * Here, we demonstrate sending the "join" state.
     * Developers can freely define methods to send different states, all encapsulated in {@link SudFSTAPPDecorator}.
     * Reference documentation: https://docs.sud.tech/en-US/app/Client/APPFST/
     * Note:
     * When sending states from the App to the game, as it involves network communication, the game should not be immediately destroyed or the Activity finished after sending the state; otherwise, the state may not be successfully sent.
     * To ensure the state reaches the game, it is recommended to delay the destruction of the game or finishing the Activity by 500ms after sending the state.
     */
    public void notifyAPPCommonSelfIn(boolean isIn, int seatIndex, boolean isSeatRandom, int teamId) {
        sudFSTAPPDecorator.notifyAPPCommonSelfIn(isIn, seatIndex, isSeatRandom, teamId);
    }

    /**
     * 2.游戏向App回调状态
     * 这里演示的是接收游戏回调状态：10. 游戏状态 mg_common_game_state
     * 游戏回调的每个状态都对应着一个方法，方法定义在：{@link SudFSMMGListener}
     * 在文档(https://docs.sud.tech/zh-CN/app/Client/MGFSM/)里面定义的都是游戏向APP回调状态的定义
     * 其中又细分为通过两个不同接口进行回调，分别是：onGameStateChange和onPlayerStateChange，但是都已封装好，只需关心SudFSMMGListener对应回调即可
     *
     * <p> English
     * 2. Game callback states to the App
     * Here, we demonstrate receiving the game callback state: 10. Game state mg_common_game_state
     * Each callback state from the game corresponds to a method defined in {@link SudFSMMGListener}.
     * The definitions for game callback states are provided in the documentation (https://docs.sud.tech/en-US/app/Client/MGFSM/).
     * These states are further divided into two different interfaces for callbacks: onGameStateChange and onPlayerStateChange. However, they are already encapsulated, and you only need to focus on the corresponding callbacks in SudFSMMGListener.
     */
    @Override
    public void onGameMGCommonGameState(ISudFSMStateHandle handle, SudMGPMGState.MGCommonGameState model) {
        if (checkGamePlaying && model.gameState == 0) {
            checkGamePlaying = false;
            MiniGameEvent.onGameSettleClose();
        } else {
            checkGamePlaying = false;
        }
        super.onGameMGCommonGameState(handle, model);
    }


    @Override
    public void onGameMGCommonSelfClickGameSettleCloseBtn(ISudFSMStateHandle handle, SudMGPMGState.MGCommonSelfClickGameSettleCloseBtn model) {
        super.onGameMGCommonSelfClickGameSettleCloseBtn(handle, model);
        MiniGameEvent.onGameSettleClose();
    }

    @Override
    public void onGameMGCommonGameNetworkState(ISudFSMStateHandle handle, SudMGPMGState.MGCommonGameNetworkState model) {
        super.onGameMGCommonGameNetworkState(handle, model);
        if (model.state == 0) {
            checkGamePlaying = true;
        }
    }

    /**
     * 12. 结算界面再来一局按钮点击状态（2021-12-27新增）
     * 12. Tapping the Play Again button on the post-game screen (added on December 27, 2021)
     * mg_common_self_click_game_settle_again_btn
     */
    @Override
    public void onGameMGCommonSelfClickGameSettleAgainBtn(ISudFSMStateHandle handle, SudMGPMGState.MGCommonSelfClickGameSettleAgainBtn model) {
        super.onGameMGCommonSelfClickGameSettleAgainBtn(handle, model);
        MiniGameEvent.onGameSettleAgain();
    }

    @Override
    public void onGameMGCommonGameSettle(ISudFSMStateHandle handle, SudMGPMGState.MGCommonGameSettle model) {
        super.onGameMGCommonGameSettle(handle, model);
        List<Map> myList = new ArrayList<>();
        for (SudMGPMGState.MGCommonGameSettle.PlayerResult result : model.results) {
            // 在这里处理每个 PlayerResult 对象
            Map<String, Object> data = new HashMap<>();
            data.put("uid",result.uid);
            data.put("award",String.valueOf(result.award));
            data.put("rank",String.valueOf(result.rank));
            myList.add(data);
        }
        MiniGameEvent.onGameSettleShow(myList);
    }

    @Override
    public void onPlayerMGCommonSelfClickGamePlayerIcon(ISudFSMStateHandle handle, String userId, SudMGPMGState.MGCommonSelfClickGamePlayerIcon model) {
        super.onPlayerMGCommonSelfClickGamePlayerIcon(handle, userId, model);
        MiniGameEvent.onClickUser(model.uid);
    }
}
