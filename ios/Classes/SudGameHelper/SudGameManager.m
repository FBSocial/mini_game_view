//
//  SudGameManager.m
//  QuickStart
//
//  Created by kaniel on 2024/1/12.
//  Copyright © 2024 Sud.Tech (https://sud.tech). All rights reserved.
//

#import "SudGameManager.h"
#import <SudMGP/SudInitSDKParamModel.h>
#import <SudMGP/SudLoadMGParamModel.h>

@interface SudGameManager()
/// 游戏事件处理对象
/// Game event handling object
@property(nonatomic, weak)SudGameBaseEventHandler *sudGameEventHandler;
@end

@implementation SudGameManager

- (void)dealloc {
    NSLog(@"SudGameManager dealloc");
}

#pragma mark --- public

- (void)registerGameEventHandler:(SudGameBaseEventHandler *)eventHandler {
    self.sudGameEventHandler = eventHandler;
    [self.sudGameEventHandler.sudFSMMGDecorator setEventListener:eventHandler];
}

- (void)loadGame:(nonnull SudGameLoadConfigModel *)configModel code:(NSString * )code {
    NSAssert(self.sudGameEventHandler, @"Must registerGameEventHandler before!");
    if (self.sudGameEventHandler) {
        [self initSudMGPSDK:configModel code:code];
    }
}

- (void)destroyGame {
    NSAssert(self.sudGameEventHandler, @"Must registerGameEventHandler before!");
    [self.sudGameEventHandler.sudFSMMGDecorator clearAllStates];
    [self.sudGameEventHandler.sudFSTAPPDecorator destroyMG];
}

#pragma mark --- private

/// 初始化游戏SudMDP SDK
- (void)initSudMGPSDK:(SudGameLoadConfigModel *)configModel code:(NSString *)code {

    __weak typeof(self) weakSelf = self;
    if (configModel.gameId <= 0) {
        NSLog(@"Game id is empty can not load the game:%@, currentRoomID:%@", @(configModel.gameId), configModel.roomId);
        return;
    }
    // 2. 初始化SudMGP SDK<SudMGP initSDK>
    // 2. Initialize the SudMGP SDK <SudMGP initSDK>
    SudInitSDKParamModel *paramModel = SudInitSDKParamModel.new;
    paramModel.appId = configModel.appId;
    paramModel.appKey = configModel.appKey;
    paramModel.isTestEnv = configModel.isTestEnv;
    [SudMGP initSDK:paramModel listener:^(int retCode, const NSString * _Nonnull retMsg) {
        [[SudMGP getCfg] setShowLoadingGameBg:!weakSelf.hiddenloadingBg];
        if (retCode != 0) {
            NSLog(@"ISudFSMMG:initGameSDKWithAppID init sdk failed :%@(%@)", retMsg, @(retCode));
            return;
        }
        NSLog(@"ISudFSMMG:initGameSDKWithAppID: init sdk successfully");
        // Load the game
        [weakSelf loadMG:configModel code:code];
    }];
}

/// 加载游戏MG
/// Initialize the SudMDP SDK for the game
/// @param configModel 配置model
- (void)loadMG:(SudGameLoadConfigModel *)configModel code:(NSString *)code {
    NSAssert(self.sudGameEventHandler, @"Must registerGameEventHandler before!");
    [self.sudGameEventHandler setupLoadConfigModel:configModel];
    // 确保初始化前不存在已加载的游戏 保证SudMGP initSDK前，销毁SudMGP
    // Ensure that there are no loaded games before initialization. Ensure SudMGP is destroyed before initSDK
    [self destroyGame];
    NSLog(@"loadMG:userId:%@, gameRoomId:%@, gameId:%@", configModel.userId, configModel.roomId, @(configModel.gameId));
    if (configModel.userId.length == 0 ||
            configModel.roomId.length == 0 ||
            code.length == 0 ||
            configModel.language.length == 0 ||
            configModel.gameId <= 0) {

        NSLog(@"loadGame: param has some one empty");
        return;
    }
    // 必须配置当前登录用户
    // The current login user must be configured
    [self.sudGameEventHandler.sudFSMMGDecorator setCurrentUserId:configModel.userId];
    // 3. 加载SudMGP SDK<SudMGP loadMG>，注：客户端必须持有iSudFSTAPP实例
    // 3. Load SudMGP SDK<SudMGP loadMG>. Note: The client must hold the iSudFSTAPP instance
    SudLoadMGParamModel *paramModel = SudLoadMGParamModel.new;
    paramModel.userId = configModel.userId;
    paramModel.roomId = configModel.roomId;
    paramModel.code = code;
    paramModel.mgId = configModel.gameId;
    paramModel.language = configModel.language;
    paramModel.gameViewContainer = configModel.gameView;
    
    // 加载本地游戏资源
    NSDictionary *resDic = @{
        @"1739914495960793090": @"EightBall1.1.9.77",     //美式8球
        @"1676069429630722049": @"gobangpro1.0.0.64",     //五子棋
        @"1680881367829176322": @"jumpjump1.0.0.193",      //跳一跳
        @"1734504890293981185": @"matchpairs1.0.0.98",      //连连看
    };
    NSString *gid = [NSString stringWithFormat:@"%lld", configModel.gameId];
    if([resDic.allKeys containsObject:gid]){
        NSString *path = [resDic objectForKey:gid];
        
        NSBundle *bundle= [NSBundle bundleForClass:[self class]];
        NSURL *url = [bundle URLForResource:@"mini_game_view" withExtension:@"bundle"];
        bundle = [NSBundle bundleWithURL:url];
        NSString *spPath = [bundle pathForResource:path ofType:@"sp"];
        
        [[SudMGP getCfg] addEmbeddedMGPkg:configModel.gameId mgPath:spPath];
        NSLog(@"使用本地资源包加载游戏：%lld --> %@",configModel.gameId, spPath);
    }
    
    id <ISudFSTAPP> iSudFSTAPP = [SudMGP loadMG:paramModel fsmMG:self.sudGameEventHandler.sudFSMMGDecorator];
    [self.sudGameEventHandler.sudFSTAPPDecorator setISudFSTAPP:iSudFSTAPP];
}


@end
