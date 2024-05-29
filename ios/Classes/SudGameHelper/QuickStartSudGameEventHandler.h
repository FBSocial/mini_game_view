//
//  QuickStartSudGameEventHandler.h
//  QuickStart
//
//  Created by kaniel on 2024/1/16.
//  Copyright © 2024 Sud.Tech (https://sud.tech). All rights reserved.
//

#import "SudGameBaseEventHandler.h"

NS_ASSUME_NONNULL_BEGIN

@protocol QuickStartSudGameEventHandlerDelegate <NSObject>
- (void)onExpireCode;
@end

/// QuickStart demo实现游戏事件处理模块，接入方可以参照次处理模块，将QuickStartSudGameEventHandler改个名称并实现自己应用的即可
/// QuickStart demo game event processing module, access can consult the processing module, the QuickStartSudGameEventHandler change a name and realize their own application
@interface QuickStartSudGameEventHandler : SudGameBaseEventHandler

@property (nonatomic, weak) id<QuickStartSudGameEventHandlerDelegate> delegate;


@property(nonatomic,assign) NSInteger top;
@property(nonatomic,assign) NSInteger left;
@property(nonatomic,assign) NSInteger right;
@property(nonatomic,assign) NSInteger bottom;

@property(nonatomic, assign)bool hiddenGameBg;
@property(nonatomic, assign)bool checkGamePlaying;

@end

NS_ASSUME_NONNULL_END
