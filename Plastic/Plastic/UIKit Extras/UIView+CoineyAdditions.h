// CoineyKit
// Copyright © Coiney Inc. All rights reserved.
// For licensing information, contact info@coiney.com.

#import <UIKit/UIKit.h>

@interface UIView (CoineyAdditions)
- (BOOL)cy_enumerateSubviews:(void (^)(UIView *aView, BOOL *aoShouldStop))aBlock
                 recursively:(BOOL)aRecursive;
- (UIView *)cy_subviewPassing:(BOOL (^)(UIView *aView))aBlock;
- (UIView *)cy_findFirstResponder;
@end
