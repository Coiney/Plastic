// CoineyKit
// Copyright © Coiney Inc. All rights reserved.
// For licensing information, contact info@coiney.com.

#import "UIImage+CoineyAdditions.h"

@interface PTDummyClass : NSObject  @end
@implementation PTDummyClass @end

@implementation UIImage (CoineyAdditions)

+ (UIImage *)cy_imageNamed:(NSString * const)aName
{
          return [self imageNamed:aName
                         inBundle:[NSBundle bundleForClass:[PTDummyClass class]]
    compatibleWithTraitCollection:nil];
}

@end
