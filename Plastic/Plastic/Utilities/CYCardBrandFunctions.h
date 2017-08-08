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

typedef NS_OPTIONS(int64_t, CYCardBrandMask) {
    CYCardBrandMaskMasterCard      = 1 << CYMasterCard,
    CYCardBrandMaskVisa            = 1 << CYVisa,
    CYCardBrandMaskAmericanExpress = 1 << CYAmericanExpress,
    CYCardBrandMaskJCB             = 1 << CYJCB,
    CYCardBrandMaskDiners          = 1 << CYDiners,
    CYCardBrandMaskDiscover        = 1 << CYDiscover,
    CYCardBrandMaskAll             = ~0
};

CYCardBrand CYCardBrandFromNumber(NSString * aCardNumber);
NSUInteger NumberOfDigitsForCardBrand(CYCardBrand aCardBrand);
NSUInteger CVCLengthForCardBrand(CYCardBrand aCardBrand);
NSString * NSStringFromCardBrand(CYCardBrand aCardBrand);
CYCardBrand CYCardBrandFromString(NSString * aBrandName);
BOOL LuhnCheck(NSString * aCardNumber);
NSString * CYFormatCardNumber(NSString * aCardNumber);
