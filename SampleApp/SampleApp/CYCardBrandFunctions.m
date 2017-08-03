// CoineyKit
// Copyright © Coiney Inc. All rights reserved.
// For licensing information, contact info@coiney.com.

#import "CYCardBrandFunctions.h"
#import "NSString+CoineyAdditions.h"

CYCardBrand CYCardBrandFromNumber(NSString * const aCardNumber)
{
    NSCParameterAssert(aCardNumber.length == 0 || [aCardNumber cy_isNumeric]);
    
    if (aCardNumber.length == 0) {
        return CYUnknownCardBrand;
    } else if ([aCardNumber hasPrefix:@"4"]) {
        return CYVisa;
    } else if ([aCardNumber length] < 2) {
        return CYUnknownCardBrand;
    }
    
    NSInteger const firstTwoDigits = [[aCardNumber substringToIndex:2] integerValue];
    if (INRANGE(firstTwoDigits, 50, 55)) {
        return CYMasterCard;
    } else if (firstTwoDigits == 34 || firstTwoDigits == 37) {
        return CYAmericanExpress;
    } else if (firstTwoDigits == 35) {
        return CYJCB;
    } else if (firstTwoDigits == 30 || firstTwoDigits == 36 || firstTwoDigits == 38 || firstTwoDigits == 39) {
        return CYDiners;
    } else if (firstTwoDigits == 65 || ([aCardNumber length] >= 4 && [[aCardNumber substringToIndex:4] integerValue] == 6011)) {
        return CYDiscover;
    } else {
        return CYUnknownCardBrand;
    }
}

NSUInteger NumberOfDigitsForCardBrand(CYCardBrand const aCardBrand)
{
    switch (aCardBrand) {
        case CYAmericanExpress:
            return 15;
        case CYDiners:
            return 14;
        default:
            return 16;
    }
}

NSUInteger CVCLengthForCardBrand(CYCardBrand const aCardBrand)
{
    return aCardBrand == CYAmericanExpress ? 4 : 3;
}

NSString * NSStringFromCYCardBrand(CYCardBrand const aCardBrand)
{
    switch (aCardBrand) {
        case CYVisa:
            return @"Visa";
        case CYMasterCard:
            return @"MasterCard";
        case CYAmericanExpress:
            return @"Amex";
        case CYJCB:
            return @"JCB";
        case CYDiners:
            return @"Diners";
        case CYDiscover:
            return @"Discover";
        case CYUnknownCardBrand:
            return @"Unknown";
    }
}

BOOL LuhnCheck(NSString * const aCardNumber)
{
    NSCParameterAssert([aCardNumber cy_isNumeric]);
    
    NSUInteger digit, sum = 0;
    for (NSUInteger i = 0; i < [aCardNumber length]; ++i) {
        digit = digittoint([aCardNumber characterAtIndex:i]);
        if ((aCardNumber.length - i) % 2 == 0) {
            sum += (digit * 2 / 10) + (digit * 2 % 10);
        } else {
            sum += digit;
        }
    }
    return sum % 10 == 0;
}

NSString *CYFormatCardNumber(NSString * aCardNumber)
{
    NSCParameterAssert([aCardNumber cy_isNumeric]);
    CYCardBrand const brand = CYCardBrandFromNumber(aCardNumber);
    
    if ([aCardNumber length] > NumberOfDigitsForCardBrand(brand)) {
        aCardNumber = [aCardNumber substringToIndex:NumberOfDigitsForCardBrand(brand)];
    }
    
    NSMutableString * const formatted = [aCardNumber mutableCopy];
    switch(brand) {
        case CYAmericanExpress:
        case CYDiners:
            // xxxx xxxxxx xxxxx
            if ([formatted length] >= 5)  [formatted insertString:@" " atIndex:4];
            if ([formatted length] >= 12) [formatted insertString:@" " atIndex:11];
            break;
        default:
            // xxxx xxxx xxxx xxxx
            if ([formatted length] >= 5)  [formatted insertString:@" " atIndex:4];
            if ([formatted length] >= 10) [formatted insertString:@" " atIndex:9];
            if ([formatted length] >= 15) [formatted insertString:@" " atIndex:14];
    }
    return formatted;
}
