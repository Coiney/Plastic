// CoineyKit
// Copyright © Coiney Inc. All rights reserved.
// For licensing information, contact info@coiney.com.

#import <UIKit/UIKit.h>
#import <Plastic/CYCardBrandFunctions.h>

@class CYCardEntryView;

@protocol CYCardEntryViewDelegate <NSObject>
- (void)cardEntryView:(CYCardEntryView * const)aView validityDidChange:(BOOL)aFlag;
@end

@interface CYCardEntryView : UIView
@property(nonatomic, readonly) NSString *cardNumber;
@property(nonatomic, readonly) CYCardBrand cardBrand;
@property(nonatomic, readonly) NSDate   *expiryDate;
@property(nonatomic, readonly) NSString *cvc;

@property(nonatomic, strong) NSString *cardNumberPlaceholder, *expiryPlaceholder, *cvcPlaceholder;
@property(nonatomic, assign) BOOL collapsesCardNumberField;
@property(nonatomic, weak) UILabel *hintLabel;

// Appearance
@property UIColor *borderColor;
@property CGFloat borderWidth;
@property CGFloat cornerRadius;

@property(nonatomic, weak) id<CYCardEntryViewDelegate> delegate;

- (instancetype)initWithFrame:(CGRect)aFrame;
- (instancetype)initWithCoder:(NSCoder *)aDecoder;

- (void)setUsesSystemKeyboard:(BOOL)aFlag;  // YES by default

// Use with a custom keypad widget, i.e., when not using the system keyboard
- (void)insertText:(NSString *)aText;
- (void)backspace;
- (void)clear;

- (void)updateHintLabel;

@end
