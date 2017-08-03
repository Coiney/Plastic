// CoineyKit
// Copyright © Coiney Inc. All rights reserved.
// For licensing information, contact info@coiney.com.

#import "UIView+CoineyAdditions.h"

@implementation UIView (CYCardEntryAdditions)

- (BOOL)cy_enumerateSubviews:(void (^)(UIView *aView, BOOL *aoShouldStop))aBlock
                 recursively:(BOOL const)aRecursive
{
    // Breadth first
    BOOL shouldStop = NO;
    for (UIView *subview in self.subviews) {
        aBlock(subview, &shouldStop);
        if (shouldStop) {
            return NO;
        }
    }
    if (aRecursive) {
        for (UIView *subview in self.subviews) {
            if (![subview cy_enumerateSubviews:aBlock recursively:YES]) {
                return NO;
            }
        }
    }
    return YES;
}

- (UIView *)cy_subviewPassing:(BOOL (^)(UIView *aView))aBlock
{
    __block UIView *result = nil;
    [self cy_enumerateSubviews:^(UIView *aView, BOOL *aoShouldStop) {
        if (aBlock(aView)) {
            result = aView;
            *aoShouldStop = YES;
        }
    } recursively:YES];
    return result;
}

- (UIView *)cy_findFirstResponder
{
    return [self cy_subviewPassing:^BOOL(UIView *aView) {
        return aView.isFirstResponder;
    }];
}

@end
