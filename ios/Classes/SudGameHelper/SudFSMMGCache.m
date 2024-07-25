//
//  SudFSMMGCache.m
//  mini_game_view
//
//  Created by Leaf on 2024/7/16.
//

#import "SudFSMMGCache.h"

@interface SudFSMMGCache()
@end

@implementation SudFSMMGCache

static SudFSMMGCache *_sharedInstance = nil;

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[SudFSMMGCache alloc] init];
    });
    return _sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.userPosCache = [[NSMutableDictionary alloc] init];
    }
    return self;
}
@end
