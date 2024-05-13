//
//  MyCustomView.m
//  mini_game_view
//
//  Created by 杨志豪 on 5/13/24.
//

#import "MyCustomView.h"
#import "SudGameManager.h"
#import "QuickStartSudGameEventHandler.h"
#import <Masonry/Masonry.h>


// TODO: 替换由SudMGP提供的appId 及 appKey
// TODO: Replace the appId and appKey provided by SudMGP
#define SUDMGP_APP_ID   @"1461564080052506636"
#define SUDMGP_APP_KEY  @"03pNxK2lEXsKiiwrBQ9GbH541Fk2Sfnc"
// TODO: 是否是测试环境,生产环境必须设置为NO
// TODO: Set SUD_GAME_TEST_ENV to NO for production environment.
#if DEBUG
#define SUD_GAME_TEST_ENV    YES
#else
#define SUD_GAME_TEST_ENV    NO
#endif

@interface MyCustomView ()

@property(nonatomic, strong) UIView *gameView;
/// SUD 游戏管理模块
@property(nonatomic, strong)SudGameManager *sudGameManager;
/// 游戏事件处理实例
@property(nonatomic, strong)QuickStartSudGameEventHandler *gameEventHandler;

@property(nonatomic, strong)NSString *gameId;

@property(nonatomic, strong)NSString *userId;

@property(nonatomic, strong)NSString *roomId;

@end


@implementation MyCustomView {
  int64_t _viewId;
  FlutterMethodChannel* _methodChannel;
    
}


- (instancetype)initWithFrame:(CGRect)frame
               viewIdentifier:(int64_t)viewId
                    arguments:(id _Nullable)args
              binaryMessenger:(NSObject<FlutterBinaryMessenger>*)messenger {
  self = [super initWithFrame:frame];
  if (self) {
    _viewId = viewId;
      self.gameId = args[@"gameId"];
      self.userId = args[@"userId"];
      self.roomId = args[@"roomId"];
    NSString* channelName = [NSString stringWithFormat:@"my_custom_view_%" PRId64, viewId];
    _methodChannel = [FlutterMethodChannel methodChannelWithName:channelName binaryMessenger:messenger];
      [self addSubview:self.gameView];
      /// 1. step
      [self.gameView mas_makeConstraints:^(MASConstraintMaker *make) {
          make.edges.equalTo(self);
      }];
      
      // 创建游戏管理实例
      // Create a game management instance
      self.sudGameManager = SudGameManager.new;
      // 创建游戏事件处理对象实例
      // Create an instance of the game event handler object
      self.gameEventHandler = QuickStartSudGameEventHandler.new;
      // 将游戏事件处理对象实例注册进游戏管理对象实例中
      // Register the game event processing object instance into the game management object instance
      [self.sudGameManager registerGameEventHandler:self.gameEventHandler];
      /// 2. step
      // 加载游戏
      // Load the game
      if (self.gameId != nil) {
          [self loadGame:[self.gameId integerValue]];
      }
      
      UIButton * button = [[UIButton alloc] initWithFrame:CGRectMake(10, 10, 40, 40)];
      button.backgroundColor = [UIColor redColor];
      [button setTitle:@"准备" forState:UIControlStateNormal];
      [button addTarget:self action:@selector(actionButton) forControlEvents:UIControlEventTouchUpInside];
      [self addSubview:button];
  }
  return self;
}

- (void)actionButton {
    [self.gameEventHandler.sudFSTAPPDecorator notifyAppCommonSelfReady:YES];
}

- (UIView *)gameView {
    if (_gameView == nil) {
        _gameView = [[UIView alloc]init];
    }
    return _gameView;
}


/// 加载游戏
/// Load game
- (void)loadGame:(int64_t)gameId {
    // 配置加载SudMGP必须参数
    // Set the required parameters for loading SudMGP
    SudGameLoadConfigModel *sudGameConfigModel = [[SudGameLoadConfigModel alloc] init];
    // 申请的应用ID
    // Application ID
    sudGameConfigModel.appId = SUDMGP_APP_ID;
    // 申请的应用key
    // Application key
    sudGameConfigModel.appKey = SUDMGP_APP_KEY;
    // 是否测试环境，测试时为YES, 发布上线设置为NO
    // Set to YES during the test and NO when publishing online
    sudGameConfigModel.isTestEnv = SUD_GAME_TEST_ENV;
    // 待加载游戏ID
    // ID of the game to be loaded
    sudGameConfigModel.gameId = gameId;
    // 指定游戏房间，相同房间号的人在同一游戏大厅中
    // Assign a game room, and people with the same room number are in the same game hall
    sudGameConfigModel.roomId = self.roomId;
    // 配置游戏内显示语言
    // Configure the in-game display language
    sudGameConfigModel.language = @"zh-CN";
    // 游戏显示的视图
    // Game display view
    sudGameConfigModel.gameView = self.gameView;
    // 当前用户ID
    // Current user id
    sudGameConfigModel.userId = self.userId;

    [self.sudGameManager loadGame:sudGameConfigModel];
}

/// 销毁游戏
/// Destroy game
- (void)destroyGame {
    [self.sudGameManager destroyGame];
}

- (UIView*)view {
  return self;
}

@end
