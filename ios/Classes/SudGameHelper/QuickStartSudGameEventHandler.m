//
//  QuickStartSudGameEventHandler.m
//  QuickStart
//
//  Created by kaniel on 2024/1/16.
//  Copyright © 2024 Sud.Tech (https://sud.tech). All rights reserved.
//

#import "QuickStartSudGameEventHandler.h"
#import "MyEventSink.h"
#import "SudFSMMGCache.h"

@implementation QuickStartSudGameEventHandler


- (nonnull GameCfgModel *)onGetGameCfg {
    GameCfgModel *gameCfgModel = [GameCfgModel defaultCfgModel];
    /// 可以在此根据自身应用需要配置游戏，例如配置声音
    /// You can configure the game according to your application needs here, such as configuring the sound
    gameCfgModel.gameSoundVolume = 100;
    
    gameCfgModel.ui.level.hide = YES;
    gameCfgModel.ui.lobby_rule.hide = YES;
    gameCfgModel.ui.lobby_help_btn.hide = YES;
    gameCfgModel.ui.lobby_players.hide = YES;
    gameCfgModel.ui.lobby_player_captain_icon.hide = YES;
    gameCfgModel.ui.lobby_player_kickout_icon.hide = YES;
    gameCfgModel.ui.lobby_game_setting.hide = YES;
    gameCfgModel.ui.lobby_setting_btn.hide = YES;
    gameCfgModel.ui.share_btn.hide = YES;
    gameCfgModel.ui.join_btn.hide = YES;
    gameCfgModel.ui.cancel_join_btn.hide = YES;
    gameCfgModel.ui.ready_btn.hide = YES;
    gameCfgModel.ui.cancel_ready_btn.hide = YES;
    gameCfgModel.ui.start_btn.hide = YES;
    
    gameCfgModel.ui.game_bg.hide = self.hiddenGameBg;
    gameCfgModel.ui.gameSettle.hide = YES;

    
    gameCfgModel.ui.game_settle_again_btn.custom = YES;
    gameCfgModel.ui.game_settle_close_btn.custom = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                                    selector:@selector(applicationWillEnterForeground:)
                                                        name:UIApplicationWillEnterForegroundNotification
                                                      object:nil];
    
    /// ...
    return gameCfgModel;
}

- (void)applicationWillEnterForeground:(NSNotification *)notification {

}

- (nonnull GameViewInfoModel *)onGetGameViewInfo {
    
    /// 应用根据自身布局需求在此配置游戏显示视图信息
    /// The application configures the game display view information here according to its layout requirements
    
    // 屏幕安全区
    // Screen Safety zone
    UIEdgeInsets safeArea = [self safeAreaInsets];
    // 状态栏高度
    // Status bar height
    CGFloat statusBarHeight = safeArea.top == 0 ? 20 : safeArea.top;
    
    GameViewInfoModel *m = [[GameViewInfoModel alloc] init];
    CGRect gameViewRect = self.loadConfigModel.gameView.bounds;

    // 游戏展示区域
    // Game display area
    m.view_size.width = gameViewRect.size.width;
    m.view_size.height = gameViewRect.size.height;
    // 游戏内容布局安全区域，根据自身业务调整顶部间距
    // Game content layout security area, adjust the top spacing according to their own business
    // 顶部间距
    // top spacing
    m.view_game_rect.top = (statusBarHeight + self.top);
    // 左边
    // Left
    m.view_game_rect.left = self.left;
    // 右边
    // Right
    m.view_game_rect.right = self.right;
    // 底部安全区域
    // Bottom safe area
    m.view_game_rect.bottom = (safeArea.bottom + self.bottom);
    return m;
}

- (void)onExpireCode:(nonnull id<ISudFSMStateHandle>)handle dataJson:(nonnull NSString *)dataJson {
    [self.delegate onExpireCode];
}

- (void)onGetCode:(NSString *)userId result:(void (^)(NSString * _Nonnull))result {
    
    /// 获取加载游戏的code,此处请求自己服务端接口获取code并回调返回即可
    /// Get the code of loading the game, here request your server interface to get the code and callback return
    
    if (userId.length == 0) {
        NSLog(@"用户ID不能为空");
        return;
    }
    
    /// 以下是当前demo向demo应用服务获取code的代码
    /// The following is the code that demo obtains the code from demo application service
    
    /// 此接口为QuickStart样例请求接口
    /// This interface is a QuickStart sample request interface
    NSString *getCodeUrl = @"https://mgp-hello.sudden.ltd/login/v3";
    NSDictionary *dicParam = @{@"user_id": userId};
    [self postHttpRequestWithURL:getCodeUrl param:dicParam success:^(NSDictionary *rootDict) {

        NSDictionary *dic = [rootDict objectForKey:@"data"];
        /// 这里的code用于登录游戏sdk服务器
        /// The code here is used to log in to the game sdk server
        NSString *code = [dic objectForKey:@"code"];
        int retCode = (int) [[dic objectForKey:@"ret_code"] longValue];
        result(code);

    }                    failure:^(NSError *error) {
        NSLog(@"login game server error:%@", error.debugDescription);
    }];
    
}

#pragma mark private

/// 设备安全区
/// Device safety zone
-(UIEdgeInsets)safeAreaInsets {
    if (@available(iOS 11.0, *)) {
        return [[[UIApplication sharedApplication] keyWindow] safeAreaInsets];
    } else {
        // Fallback on earlier versions
    }
    return UIEdgeInsetsZero;
}


/// 基础接口请求
/// Basic interface request
- (void)postHttpRequestWithURL:(NSString *)api
                         param:(NSDictionary *)param
                       success:(void (^)(NSDictionary *_Nonnull))success
                       failure:(void (^)(id _Nonnull))failure {
    
    NSURL *url = [NSURL URLWithString:api];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];

    if (param) {
        NSData *bodyData = [NSJSONSerialization dataWithJSONObject:param options:NSJSONReadingMutableContainers error:nil];
        request.HTTPBody = bodyData;
    }
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *_Nullable data, NSURLResponse *_Nullable response, NSError *_Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                if (failure) {
                    failure(error);
                }
                return;
            }
            NSError *error;
            NSMutableDictionary *responseObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
            if (error) {
                if (failure) {
                    failure(error);
                }
                return;
            }
            if (success) {
                success(responseObject);
            }
        });
    }];
    [dataTask resume];
}


#pragma mark 游戏生命周期回调 Game life cycle callback

/// 游戏开始
- (void)onGameStarted {
    /// 此时表明游戏加载成功
    /// The game is loaded successfully
    NSLog(@"Game load finished");
}

/// 游戏销毁
/// Game destruction
- (void)onGameDestroyed {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [SudFSMMGCache.sharedInstance.userPosCache removeAllObjects];
    NSLog(@"Game destroyed");
}


#pragma mark 游戏相关事件状态回调通知，以下回调指令根据业务需求实现相应与游戏交互功能,可选指令，根据自身应用需要实现与游戏交互 Game-related event status callback notification. The following callback commands can interact with the game according to business requirements. Optional commands can interact with the game according to their own application needs

/// 更多指令支持参阅 https://docs.sud.tech/zh-CN/app/Client/MGFSM/CommonStateGame.html
/// Support more instructions refer to https://docs.sud.tech/en-US/app/Client/MGFSM/CommonStateGame.html

/// 游戏: 准备按钮点击状态   MG_COMMON_SELF_CLICK_READY_BTN
/// Game: Ready button click status MG_COMMON_SELF_CLICK_READY_BTN
- (void)onGameMGCommonSelfClickReadyBtn:(nonnull id <ISudFSMStateHandle>)handle model:(MGCommonSelfClickReadyBtn *)model {
    [handle success:[self.sudFSMMGDecorator handleMGSuccess]];
}

/// Game: Settlement interface again to a button click status MG_COMMON_SELF_CLICK_GAME_SETTLE_AGAIN_BTN
- (void)onGameMGCommonSelfClickGameSettleAgainBtn:(nonnull id <ISudFSMStateHandle>)handle model:(MGCommonSelfClickGameSettleAgainBtn *)model {
    [[MyEventSink sharedInstance] sendDataToFlutter:@{@"action":@"onGameSettleAgain"}];
    [handle success:[self.sudFSMMGDecorator handleMGSuccess]];
}

- (void)onGameMGCommonSelfClickGameSettleCloseBtn:(nonnull id <ISudFSMStateHandle>)handle model:(MGCommonSelfClickGameSettleCloseBtn *)model {
    [[MyEventSink sharedInstance] sendDataToFlutter:@{@"action":@"onGameSettleClose"}];
    [handle success:[self.sudFSMMGDecorator handleMGSuccess]];
}

/// 游戏: 开始游戏按钮点击状态   MG_COMMON_SELF_CLICK_START_BTN
/// Game: Start game button by clicking status MG_COMMON_SELF_CLI   CK_START_BTN
- (void)onGameMGCommonSelfClickStartBtn:(nonnull id <ISudFSMStateHandle>)handle model:(MGCommonSelfClickStartBtn *)model {
    [handle success:[self.sudFSMMGDecorator handleMGSuccess]];
}

/// 游戏: 游戏结算状态     MG_COMMON_GAME_SETTLE
- (void)onGameMGCommonGameSettle:(nonnull id <ISudFSMStateHandle>)handle model:(MGCommonGameSettleModel *)model {
    NSMutableArray * list = [NSMutableArray new];
    for (MGCommonGameSettleResults *result in model.results) {
        NSLog(@"用户id:%@，排名%ld,奖励%ld",result.uid,result.rank,result.award);
        NSDictionary *dic = @{
            @"uid":result.uid,
            @"award":[NSString stringWithFormat:@"%@", @(result.award)],
            @"rank":[NSString stringWithFormat:@"%@", @(result.rank)],
            @"gameRoundId": model.gameRoundId,
        };
        [list addObject:dic];
    }
    [[MyEventSink sharedInstance] sendDataToFlutter:@{@"action":@"onGameSettleShow",@"data":list}];
    NSLog(@"调用结算完成");
    [handle success:[self.sudFSMMGDecorator handleMGSuccess]];
}

- (void)onPlayerMGCommonSelfClickGamePlayerIcon:(id<ISudFSMStateHandle>)handle userId:(NSString *)userId model:(MGCommonSelfClickGamePlayerIconModel *)model {
    [[MyEventSink sharedInstance] sendDataToFlutter:@{@"action":@"onClickUser",@"data":model.uid}];
    [handle success:[self.sudFSMMGDecorator handleMGSuccess]];
}

/// 通用状态-游戏
/// 游戏: 公屏消息状态    MG_COMMON_PUBLIC_MESSAGE
/// General status - Game
/// Game: public screen message status MG_COMMON_PUBLIC_MESSAGE
- (void)onGameMGCommonPublicMessage:(id <ISudFSMStateHandle>)handle model:(MGCommonPublicMessageModel *)model {
    [handle success:[self.sudFSMMGDecorator handleMGSuccess]];
}

/// 游戏: 关键词状态    MG_COMMON_KEY_WORD_TO_HIT
/// Game: Keyword status MG_COMMON_KEY_WORD_TO_HIT
- (void)onGameMGCommonKeyWordToHit:(id <ISudFSMStateHandle>)handle model:(MGCommonKeyWrodToHitModel *)model {

    [handle success:[self.sudFSMMGDecorator handleMGSuccess]];
}

/// 游戏: 游戏状态   MG_COMMON_GAME_STATE
/// Game: Game state MG_COMMON_GAME_STATE
- (void)onGameMGCommonGameState:(id <ISudFSMStateHandle>)handle model:(MGCommonGameState *)model {
   if (self.checkGamePlaying && model.gameState == 0) {
        self.checkGamePlaying = NO;
       [[MyEventSink sharedInstance] sendDataToFlutter:@{@"action":@"onGameSettleClose"}];
   } else {
       self.checkGamePlaying = NO;
   }
    [handle success:[self.sudFSMMGDecorator handleMGSuccess]];
}

/// 游戏: ASR状态(开启和关闭语音识别状态   MG_COMMON_GAME_ASR
/// Game: ASR status (On and off speech recognition status MG_COMMON_GAME_ASR
- (void)onGameMGCommonGameASR:(id <ISudFSMStateHandle>)handle model:(MGCommonGameASRModel *)model {
    /// 语音采集 || 停止采集
    [handle success:[self.sudFSMMGDecorator handleMGSuccess]];
}

/// 玩家状态变化
/// 玩家: 加入状态  MG_COMMON_PLAYER_IN
/// Player status changes
/// Player: Adds status MG_COMMON_PLAYER_IN
- (void)onPlayerMGCommonPlayerIn:(id <ISudFSMStateHandle>)handle userId:(NSString *)userId model:(MGCommonPlayerInModel *)model {

    [handle success:[self.sudFSMMGDecorator handleMGSuccess]];
}

/// 玩家: 准备状态  MG_COMMON_PLAYER_READY
/// Player: Ready status MG_COMMON_PLAYER_READY
- (void)onPlayerMGCommonPlayerReady:(id <ISudFSMStateHandle>)handle userId:(NSString *)userId model:(MGCommonPlayerReadyModel *)model {

    [handle success:[self.sudFSMMGDecorator handleMGSuccess]];
}

/// 玩家: 队长状态  MG_COMMON_PLAYER_CAPTAIN
/// Player: Captain status MG_COMMON_PLAYER_CAPTAIN
- (void)onPlayerMGCommonPlayerCaptain:(id <ISudFSMStateHandle>)handle userId:(NSString *)userId model:(MGCommonPlayerCaptainModel *)model {

    [handle success:[self.sudFSMMGDecorator handleMGSuccess]];
}

/// 玩家: 游戏状态  MG_COMMON_PLAYER_PLAYING
/// Player: Game status MG_COMMON_PLAYER_PLAYING
- (void)onPlayerMGCommonPlayerPlaying:(id <ISudFSMStateHandle>)handle userId:(NSString *)userId model:(MGCommonPlayerPlayingModel *)model {
    [handle success:[self.sudFSMMGDecorator handleMGSuccess]];
}

- (void)onGameMGCommonGameNetworkState:(id<ISudFSMStateHandle>)handle model:(MGCommonGameNetworkStateModel *)model {
    if (model.state == 0) {
        self.checkGamePlaying = YES;
    }
    [handle success:[self.sudFSMMGDecorator handleMGSuccess]];
}

/// 你画我猜: 作画中状态  MG_DG_PAINTING
/// You paint me guess: painting state MG_DG_PAINTING
- (void)onPlayerMGDGPainting:(nonnull id <ISudFSMStateHandle>)handle userId:(nonnull NSString *)userId model:(MGDGPaintingModel *)model {

    [handle success:[self.sudFSMMGDecorator handleMGSuccess]];
}

/// 游戏: 麦克风状态   MG_COMMON_GAME_SELF_MICROPHONE
/// Game: Microphone status MG_COMMON_GAME_SELF_MICROPHONE
- (void)onGameMGCommonGameSelfMicrophone:(nonnull id <ISudFSMStateHandle>)handle model:(MGCommonGameSelfMicrophone *)model {

    [handle success:[self.sudFSMMGDecorator handleMGSuccess]];
}

/// 游戏: 耳机（听筒，扬声器）状态   MG_COMMON_GAME_SELF_HEADEPHONE
/// Game: Headset (handset, speaker) status MG_COMMON_GAME_SELF_HEADEPHONE
- (void)onGameMGCommonGameSelfHeadphone:(nonnull id <ISudFSMStateHandle>)handle model:(MGCommonGameSelfHeadphone *)model {

    [handle success:[self.sudFSMMGDecorator handleMGSuccess]];
}

/// 游戏通知 app 玩家头像的坐标（支持 ludo, 飞镖, umo, 多米诺, teenpatti, texasholdem）MG_COMMON_GAME_PLAYER_ICON_POSITION
- (void)onGameMgCommonGamePlayerIconPosition:(nonnull id <ISudFSMStateHandle>)handle model:(MgCommonGamePlayerIconPositionModel *)model{
//    NSLog(@"Game onGameMgCommonGamePlayerIconPosition");
    [SudFSMMGCache.sharedInstance.userPosCache setValue:model.position forKey:model.uid];
}

- (void)onGameMGCommonGameCreateOrder:(nonnull id <ISudFSMStateHandle>)handle model:(MgCommonGameCreateOrderModel *)model {
//    NSLog(@"Game onGameMGCommonGameCreateOrder");
    NSDictionary *dicParam = @{
        @"cmd": model.cmd,
        @"fromUid": model.fromUid,
        @"toUid": model.toUid,
        @"value": [NSNumber numberWithInt: model.value],
        @"payload": model.payload
    };
    [[MyEventSink sharedInstance] sendDataToFlutter:@{@"action":@"onGameMGCommonGameCreateOrder",@"data":dicParam}];
}

@end
