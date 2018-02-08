#import "NSString+CoineyAdditions.h"

@implementation NSString (CoineyAdditions)

- (NSString *)cy_strippedString
{
    return [self stringByReplacingOccurrencesOfString:@"[\\n\\s]+"
                                           withString:@""
                                              options:NSRegularExpressionSearch
                                                range:(NSRange) { 0, [self length] }];
}

- (NSString *)cy_stringByStrippingAllButNumbers
{
    return [self stringByReplacingOccurrencesOfString:@"[^0-9]"
                                           withString:@""
                                              options:NSRegularExpressionSearch
                                                range:(NSRange) { 0, self.length }];
}

- (BOOL)cy_isNumeric
{
    NSRegularExpression * const regex = [NSRegularExpression regularExpressionWithPattern:@"[^0-9]+"
                                                                                  options:0
                                                                                    error:nil];
    return [regex numberOfMatchesInString:self
                                  options:0
                                    range:(NSRange) { 0, [self length] }] == 0;
}

@end
