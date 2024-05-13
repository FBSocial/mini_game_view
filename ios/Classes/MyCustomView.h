//
//  MyCustomView.h
//  mini_game_view
//
//  Created by 杨志豪 on 5/13/24.
//

#import <UIKit/UIKit.h>
#import <Flutter/Flutter.h>

NS_ASSUME_NONNULL_BEGIN

@interface MyCustomView : UIView <FlutterPlatformView>

- (instancetype)initWithFrame:(CGRect)frame
               viewIdentifier:(int64_t)viewId
                    arguments:(id _Nullable)args
              binaryMessenger:(NSObject<FlutterBinaryMessenger>*)messenger;

@end
NS_ASSUME_NONNULL_END
