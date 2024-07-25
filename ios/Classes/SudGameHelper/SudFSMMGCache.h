//
//  SudFSMMGCache.h
//  mini_game_view
//
//  Created by Leaf on 2024/7/16.
//

#import <Foundation/Foundation.h>
#import <SudMGPWrapper_Lite/SudMGPWrapper.h>
NS_ASSUME_NONNULL_BEGIN

@interface SudFSMMGCache : NSObject

+ (instancetype)sharedInstance;

@property(nonatomic,strong) NSMutableDictionary *userPosCache;
@end

NS_ASSUME_NONNULL_END
