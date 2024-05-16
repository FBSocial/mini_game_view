//
//  MyEventSink.m
//  mini_game_view
//
//  Created by 杨志豪 on 5/16/24.
//

#import "MyEventSink.h"

@implementation MyEventSink {
    FlutterEventSink _eventSink;
}

+ (instancetype)sharedInstance {
    static MyEventSink *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[MyEventSink alloc] init];
    });
    return sharedInstance;
}

- (FlutterError * _Nullable)onCancelWithArguments:(id _Nullable)arguments {
    _eventSink = nil;
    return nil;
}

- (FlutterError * _Nullable)onListenWithArguments:(id _Nullable)arguments eventSink:(nonnull FlutterEventSink)events {
    _eventSink = events;
    return nil;
}

- (void)sendDataToFlutter:(NSDictionary *)data {
    if (_eventSink) {
        _eventSink(data);
    }
}

- (void)test {
    NSLog(@"测试一下");
}
@end


