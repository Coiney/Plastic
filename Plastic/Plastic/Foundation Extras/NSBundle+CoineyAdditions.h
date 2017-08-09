// CoineyKit
// Copyright © Coiney Inc. All rights reserved.
// For licensing information, contact info@coiney.com.

#import <Foundation/Foundation.h>

#define LocalizedString(key) [[NSBundle plasticBundle] localizedStringForKey:(key) value:nil table:nil]

@interface NSBundle (CoineyAdditions)
+ (NSBundle *)plasticBundle;
@end
