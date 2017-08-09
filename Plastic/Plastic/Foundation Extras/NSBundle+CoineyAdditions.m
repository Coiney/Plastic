// CoineyKit
// Copyright © Coiney Inc. All rights reserved.
// For licensing information, contact info@coiney.com.

#import "NSString+CoineyAdditions.h"

@interface CYBundleAnchorClass : NSObject @end
@implementation CYBundleAnchorClass @end

@implementation NSBundle (CoineyAdditions)

+ (NSBundle *)plasticBundle
{
    return [NSBundle bundleForClass:[CYBundleAnchorClass class]];
}

@end
