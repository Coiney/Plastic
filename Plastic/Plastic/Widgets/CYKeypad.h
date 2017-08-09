// CoineyKit
// Copyright © Coiney Inc. All rights reserved.
// For licensing information, contact info@coiney.com.

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, CYKeypadKey) {
    kCYKeypadZero = 1000,
    kCYKeypadDelete
};

@class CYKeypad;

@protocol CYKeypadDelegate <NSObject>
@required
- (void)keypadDidPressBackspace:(CYKeypad *)aView;
- (void)keypad:(CYKeypad *)aView didPressNumericalKey:(NSUInteger)aKey;
@end

@interface CYKeypad : UIControl
@property(nonatomic, weak) id<CYKeypadDelegate> delegate;

- (instancetype)init;
- (instancetype)initWithCoder:(NSCoder *)aDecoder;
- (instancetype)initWithFrame:(CGRect)aFrame;

- (void)sizeToFit;
@end
