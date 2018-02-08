#import "NSString+CoineyAdditions.h"

@interface CYBundleAnchorClass : NSObject @end
@implementation CYBundleAnchorClass @end

@implementation NSBundle (CoineyAdditions)

+ (NSBundle *)plasticBundle
{
    return [NSBundle bundleForClass:[CYBundleAnchorClass class]];
}

@end
