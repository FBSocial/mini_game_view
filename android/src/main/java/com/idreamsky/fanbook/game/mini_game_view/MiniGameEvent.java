package com.idreamsky.fanbook.game.mini_game_view;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class MiniGameEvent {

    public static void sendNativeEvent(String action, Object data) {
        if (MiniGameViewPlugin.eventSink == null) return;
        Map<String, Object> event = new HashMap<>();
        event.put("action", action);
        event.put("data", data);
        MiniGameViewPlugin.eventSink.success(event);
    }

    public static void sendNativeEvent(String action) {
        sendNativeEvent(action, new HashMap<>());
    }

    public static void onGameContainerCreated() {
        sendNativeEvent("onGameContainerCreated");
    }

    public static void onExpireCode() {
        sendNativeEvent("onExpireCode");
    }

    public static void onGameSettleClose() {
        sendNativeEvent("onGameSettleClose");
    }

    public static void onGameSettleAgain() {
        sendNativeEvent("onGameSettleAgain");
    }

    public static void onGameSettleShow(List<Map> list) {
        sendNativeEvent("onGameSettleShow",list);
    }

    public static void onClickUser(String uid) {
        sendNativeEvent("onClickUser",uid);
    }


    public static void onGameMGCommonGameCreateOrder(Map<String, Object> order) {
        sendNativeEvent("onGameMGCommonGameCreateOrder", order);
    }
}
