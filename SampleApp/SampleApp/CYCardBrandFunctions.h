// CoineyKit
// Copyright © Coiney Inc. All rights reserved.
// For licensing information, contact info@coiney.com.

#import <Foundation/Foundation.h>

#if !defined(INRANGE)
#   define __INRANGE(val, low, high, c) ({ \
        __typeof(val) const __val##c = (val); \
        __val##c >= (low) && __val##c <= (high); \
    })
#   define INRANGE(val, low, high) __INRANGE((val), (low), (high), __COUNTER__)
#endif

typedef NS_ENUM(NSInteger, CYCardBrand) {
    CYUnknownCardBrand,
    CYMasterCard,
    CYVisa,
    CYAmericanExpress,
    CYJCB,
    CYDiners,
    CYDiscover
};

CYCardBrand CYCardBrandFromNumber(NSString * aCardNumber);
NSUInteger NumberOfDigitsForCardBrand(CYCardBrand aCardBrand);
NSUInteger CVCLengthForCardBrand(CYCardBrand aCardBrand);
NSString * NSStringFromCYCardBrand(CYCardBrand aCardBrand);
BOOL LuhnCheck(NSString * aCardNumber);
NSString * CYFormatCardNumber(NSString * aCardNumber);
