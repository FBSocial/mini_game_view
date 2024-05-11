/*
 * Copyright © Sud.Tech
 * https://sud.tech
 */

package com.idreamsky.fanbook.game.mini_game_view.SudMGPWrapper.utils;

import com.idreamsky.fanbook.game.mini_game_view.SudMGPWrapper.state.MGStateResponse;

import tech.sud.mgp.core.ISudFSMStateHandle;

public class ISudFSMStateHandleUtils {

    /**
     * 回调游戏，成功
     *
     * @param handle
     */
    public static void handleSuccess(ISudFSMStateHandle handle) {
        MGStateResponse response = new MGStateResponse();
        response.ret_code = MGStateResponse.SUCCESS;
        response.ret_msg = "success";
        handle.success(SudJsonUtils.toJson(response));
    }

}
