#import <Foundation/Foundation.h>

@interface NSString (CoineyAdditions)
- (NSString *)cy_strippedString;
- (NSString *)cy_stringByStrippingAllButNumbers;
- (BOOL)cy_isNumeric;
@end
