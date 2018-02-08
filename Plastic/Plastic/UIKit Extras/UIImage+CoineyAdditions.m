#import "NSBundle+CoineyAdditions.h"
#import "UIImage+CoineyAdditions.h"

@implementation UIImage (CoineyAdditions)

+ (UIImage *)cy_imageNamed:(NSString * const)aName
{
          return [self imageNamed:aName
                         inBundle:[NSBundle plasticBundle]
    compatibleWithTraitCollection:nil];
}

@end
