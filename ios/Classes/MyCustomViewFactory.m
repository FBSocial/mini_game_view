//
//  MyCustomViewFactory.m
//  mini_game_view
//
//  Created by 杨志豪 on 5/13/24.
//

#import "MyCustomViewFactory.h"
#import "MyCustomView.h"

@implementation MyCustomViewFactory {
  NSObject<FlutterBinaryMessenger>* _messenger;
}

- (instancetype)initWithMessenger:(NSObject<FlutterBinaryMessenger>*)messenger {
  self = [super init];
  if (self) {
    _messenger = messenger;
  }
  return self;
}

- (NSObject<FlutterMessageCodec>*)createArgsCodec {
  return [FlutterStandardMessageCodec sharedInstance];
}

- (NSObject<FlutterPlatformView>*)createWithFrame:(CGRect)frame
                                     viewIdentifier:(int64_t)viewId
                                          arguments:(id _Nullable)args {
  MyCustomView* customView = [[MyCustomView alloc] initWithFrame:frame
                                                 viewIdentifier:viewId
                                                      arguments:args
                                                binaryMessenger:_messenger];
  return customView;
}

@end
