//
//  MyEventSink.h
//  mini_game_view
//
//  Created by 杨志豪 on 5/16/24.
//

#import <Foundation/Foundation.h>
#import <Flutter/Flutter.h>

NS_ASSUME_NONNULL_BEGIN

@interface MyEventSink : NSObject<FlutterStreamHandler>

+ (instancetype)sharedInstance;
- (void)sendDataToFlutter:(NSDictionary *)data;

- (void)test;

@end

NS_ASSUME_NONNULL_END
