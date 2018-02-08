#import <Foundation/Foundation.h>

#define LocalizedString(key) [[NSBundle plasticBundle] localizedStringForKey:(key) value:nil table:nil]

@interface NSBundle (CoineyAdditions)
+ (NSBundle *)plasticBundle;
@end
