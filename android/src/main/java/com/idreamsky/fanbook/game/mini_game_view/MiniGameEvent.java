package com.idreamsky.fanbook.game.mini_game_view;

import java.util.HashMap;
import java.util.Map;

public class MiniGameEvent {

    public static void sendNativeEvent(String action, Map<String, Object> data) {
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
}
