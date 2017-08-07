// CoineyKit
// Copyright © Coiney Inc. All rights reserved.
// For licensing information, contact info@coiney.com.

#import "CYCardEntryView.h"
#import "NSString+CoineyAdditions.h"
#import "UIView+CoineyAdditions.h"

static UIImage * _CYImageForCardBrand(CYCardBrand aCardBrand);

@interface CYCardNumberField : UITextField
@property(nonatomic, readonly) CYCardEntryView *cardEntryView;
@property(nonatomic, readonly) NSString *cardNumber;
@property(nonatomic, readonly) NSUInteger maxLength;
@property(nonatomic, readonly) CYCardBrand cardBrand;
@property(nonatomic, readonly) BOOL textIsValidCardNumber;
@end

@interface CYCardExpiryField : UITextField <UIKeyInput>
@property(nonatomic, readonly) CYCardEntryView *cardEntryView;
@property(nonatomic, readonly) BOOL textIsValidExpiry;
@end

@interface CYCardCVCField : UITextField <UIKeyInput>
@property(nonatomic, readonly) CYCardEntryView *cardEntryView;
@property(nonatomic, readonly) BOOL textIsValidCVC;
@end

@interface CYCardEntryView () <UITextFieldDelegate> {
    UIImageView *_brandIconView;
    UIView *_clipView;
    
    CYCardNumberField *_numberField;
    CYCardExpiryField *_expiryField;
    CYCardCVCField *_cvcField;
}
@property(nonatomic, assign) BOOL numberCollapsed;

- (void)_deleteKeyPressedInField:(UITextField *)aField;
- (void)updateIcon;
- (void)updateHintLabel;
@end

@implementation CYCardNumberField
@dynamic cardNumber, cardBrand;

- (instancetype)init
{
    if ((self = [super init])) {
        self.keyboardType = UIKeyboardTypeNumberPad;
    }
    return self;
}

- (void)setCardNumber:(NSString * const)aText
{
    [super setText:CYFormatCardNumber(aText)];
    
    CYCardBrand const brand = self.cardBrand;
    BOOL partiallyValid = self.text.length < 2 || brand != CYUnknownCardBrand;
    
    if ([self.cardNumber length] == NumberOfDigitsForCardBrand(brand)) {
        self.textColor = LuhnCheck(self.cardNumber) && brand != CYUnknownCardBrand
                         ? [UIColor darkGrayColor]
                         : [UIColor redColor];
    } else {
        self.textColor = partiallyValid ? [UIColor darkGrayColor] : [UIColor redColor];
    }
}

- (NSString *)cardNumber
{
    return [self.text cy_strippedString];
}

- (BOOL)textIsValidCardNumber
{
    CYCardBrand const brand = self.cardBrand;
    if (brand == CYUnknownCardBrand) {
        return NO;
    }
    
    return [self.cardNumber length] == NumberOfDigitsForCardBrand(brand) &&
           LuhnCheck(self.cardNumber);
}

- (CYCardBrand)cardBrand
{
    return CYCardBrandFromNumber(self.cardNumber);
}

- (CYCardEntryView *)cardEntryView
{
    return (CYCardEntryView *)self.superview.superview;
}

- (NSUInteger)maxLength
{
    return NumberOfDigitsForCardBrand(self.cardBrand);
}

- (BOOL)becomeFirstResponder
{
    [super becomeFirstResponder];
    [self.cardEntryView updateIcon];
    [self.cardEntryView updateHintLabel];
    return YES;
}

- (CGRect)textRectForBounds:(CGRect)bounds
{
    UIEdgeInsets const edgeInsets = (UIEdgeInsets) { 0, -6, 0, 0 };
    return [super textRectForBounds:UIEdgeInsetsInsetRect(bounds, edgeInsets)];
}

- (CGRect)editingRectForBounds:(CGRect)bounds
{
    UIEdgeInsets const edgeInsets = (UIEdgeInsets) { 0, -6, 0, 0 };
    return [super editingRectForBounds:UIEdgeInsetsInsetRect(bounds, edgeInsets)];
}

@end

@implementation CYCardExpiryField

- (instancetype)init
{
    if ((self = [super init])) {
        self.keyboardType = UIKeyboardTypeNumberPad;
    }
    return self;
}

- (BOOL)textIsValidExpiry
{
    if (self.text.length != 5) {
        return NO;
    }
    
    static NSCalendar *calendar;
    if (calendar == nil) {
        calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    }
    NSDateComponents * const today = [calendar components:NSCalendarUnitMonth | NSCalendarUnitYear
                                                 fromDate:[NSDate date]];
    
    NSInteger const month = [[self.text substringToIndex:2] integerValue];
    NSInteger const year  = [[self.text substringFromIndex:3] integerValue] + today.year / 100 * 100;
    
    if (year == today.year) {
        return month >= today.month && INRANGE(month, 1, 12);
    } else {
        return year > today.year && INRANGE(month, 1, 12);
    }
}

- (void)setText:(NSString *)aText
{
    aText = [aText stringByReplacingOccurrencesOfString:@"[^0-9]+"
                                             withString:@""
                                                options:NSRegularExpressionSearch
                                                  range:(NSRange) { 0, aText.length }];
    
    // Add a 0 prefix for months 2-9
    if (aText.length == 1 && INRANGE([aText integerValue], 2, 9)) {
        [super setText:[NSString stringWithFormat:@"0%@/", aText]];
    }
    // Insert a slash between the month and year
    else if (aText.length == 2) {
        [super setText:[NSString stringWithFormat:@"%@/", aText]];
    }
    else if (INRANGE([aText length], 3, 5) && [aText characterAtIndex:2] != '/') {
        [super setText:[NSString stringWithFormat:@"%@/%@",
                        [aText substringToIndex:2],
                        [aText substringFromIndex:2]]];
    }
    else if ([aText length] > 5) {
        [super setText:[[aText substringToIndex:4] stringByReplacingCharactersInRange:(NSRange) { 2, 0 }
                                                                           withString:@"/"]];
    }
    else {
        [super setText:aText];
    }
    
    BOOL partiallyValid = self.text.length < 2
                        || (   INRANGE(self.text.length, 2, 4)
                            && INRANGE([[self.text substringToIndex:2] integerValue], 1, 12))
                        || (self.text.length == 5 && self.textIsValidExpiry);
    
    self.textColor = partiallyValid
                     ? [UIColor darkGrayColor]
                     : [UIColor redColor];
}

- (void)deleteBackward
{
    [super deleteBackward];
    [self.cardEntryView _deleteKeyPressedInField:self];
}

- (CYCardEntryView *)cardEntryView
{
    return (CYCardEntryView *)self.superview.superview;
}

- (NSUInteger)maxLength
{
    return 4;
}

- (BOOL)becomeFirstResponder
{
    [super becomeFirstResponder];
    [self.cardEntryView updateIcon];
    [self.cardEntryView updateHintLabel];
    return YES;
}

@end

@implementation CYCardCVCField

- (instancetype)init
{
    if ((self = [super init])) {
        self.keyboardType = UIKeyboardTypeNumberPad;
        self.enabled = NO;
        self.textColor = [UIColor darkGrayColor];
    }
    return self;
}

- (BOOL)textIsValidCVC
{
    return [self.text length] == CVCLengthForCardBrand(self.cardEntryView.cardBrand);
}

- (void)setText:(NSString *)aText
{
    NSUInteger const maxLength = CVCLengthForCardBrand(self.cardEntryView.cardBrand);
    [super setText:(aText.length <= maxLength ? aText : [aText substringToIndex:maxLength])];
}

- (void)deleteBackward
{
    [super deleteBackward];
    [self.cardEntryView _deleteKeyPressedInField:self];
}

- (CYCardEntryView *)cardEntryView
{
    return (CYCardEntryView *)self.superview.superview;
}

- (NSUInteger)maxLength
{
    return CVCLengthForCardBrand(self.cardEntryView.cardBrand);
}

- (BOOL)becomeFirstResponder
{
    [super becomeFirstResponder];
    [self.cardEntryView updateIcon];
    [self.cardEntryView updateHintLabel];
    return YES;
}

@end

@implementation CYCardEntryView

- (void)_init
{
    _brandIconView = [[UIImageView alloc] initWithImage:_CYImageForCardBrand(CYUnknownCardBrand)];
    _brandIconView.contentMode = UIViewContentModeCenter;
    _brandIconView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_brandIconView];
    
    _clipView = [UIView new];
    _clipView.clipsToBounds = YES;
    _clipView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_clipView];
    
    _numberField = [CYCardNumberField new];
    _numberField.delegate = self;
    _numberField.translatesAutoresizingMaskIntoConstraints = NO;
    [_clipView addSubview:_numberField];
    
    _expiryField = [CYCardExpiryField new];
    _expiryField.delegate = self;
    _expiryField.translatesAutoresizingMaskIntoConstraints = NO;
    [_clipView addSubview:_expiryField];
    
    _cvcField = [CYCardCVCField new];
    _cvcField.delegate = self;
    _cvcField.translatesAutoresizingMaskIntoConstraints = NO;
    [_clipView addSubview:_cvcField];
    
    NSDictionary * const views = @{
        @"brandIconView": _brandIconView,
        @"numberField": _numberField,
        @"expiryField": _expiryField,
        @"cvcField": _cvcField,
        @"clipView": _clipView
    };
    [_clipView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[numberField(192)]-(4)-[expiryField(68)]-(4)-[cvcField(48)]-|" options:0 metrics:nil views:views]];
    [_clipView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[numberField]-|" options:0 metrics:nil views:views]];
    [_clipView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[expiryField]-|" options:0 metrics:nil views:views]];
    [_clipView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[cvcField]-|" options:0 metrics:nil views:views]];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(12)-[brandIconView]-(8)-[clipView]" options:0 metrics:nil views:views]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_brandIconView
                                                     attribute:NSLayoutAttributeCenterY
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterY
                                                    multiplier:1
                                                      constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_clipView
                                                     attribute:NSLayoutAttributeCenterY
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterY
                                                    multiplier:1
                                                      constant:0]];
}

- (instancetype)initWithFrame:(CGRect)aFrame
{
    if ((self = [super initWithFrame:aFrame])) {
        [self _init];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder])) {
        [self _init];
    }
    return self;
}

- (instancetype)init
{
    if ((self = [super init])) {
        [self _init];
    }
    return self;
}

#pragma mark - Drawing

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self layoutSubviewsAnimated:NO];
    self.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.layer.borderWidth = 1;
    self.layer.cornerRadius = 10;
}

- (void)layoutSubviewsAnimated:(BOOL)aAnimated
{
    if (_collapsesCardNumberField) {
        CGAffineTransform const moveLeft =
            CGAffineTransformMakeTranslation(
                self.bounds.size.width - _clipView.bounds.size.width - _clipView.frame.origin.x, 0
            );
        CGAffineTransform const transform = _numberCollapsed ? moveLeft : CGAffineTransformIdentity;
        
        [UIView animateWithDuration:(aAnimated ? 0.3 : 0)
                         animations:^{
                             _numberField.transform = transform;
                             _expiryField.transform = transform;
                             _cvcField.transform = transform;
                         }];
    }
}

#pragma mark - Input

- (BOOL)            textField:(UITextField *)aField
shouldChangeCharactersInRange:(NSRange)aRange
            replacementString:(NSString *)aReplacement
{
    BOOL const wasValid = _numberField.textIsValidCardNumber
                       && _expiryField.textIsValidExpiry
                       && _cvcField.textIsValidCVC;
    
    // Remove non-numeric characters
    aReplacement = [aReplacement cy_stringByStrippingAllButNumbers];
    if (![aReplacement cy_isNumeric]) {
        return NO;
    }
    
    // If the user is *deleting* and there are no numeric characters in the range being deleted
    // then we need to shift the range to delete the first number before said range
    if ([aReplacement length] == 0 &&
        [[[aField.text substringWithRange:aRange] cy_stringByStrippingAllButNumbers] length] == 0) {
        // In our case we never have more than one non-numeric character in a row so we just shift left by one
        aRange.location = MAX(0, (NSInteger)aRange.location-1);
    }
    
    UITextRange * const oldSelection = aField.selectedTextRange;
    NSString * const oldValue = aField.text;
    NSString * newValue = [[aField.text stringByReplacingCharactersInRange:aRange
                                                                withString:aReplacement]
                           cy_stringByStrippingAllButNumbers];
    // Truncate/ignore edits that make the value too long
    NSUInteger const maxLength = [(id)aField maxLength];
    if ([newValue length] > maxLength) {
        aReplacement = [aReplacement substringToIndex:[aReplacement length] - ([newValue length] - maxLength)];
        newValue = [[aField.text stringByReplacingCharactersInRange:aRange
                                                         withString:aReplacement] cy_stringByStrippingAllButNumbers];
    }
    
    if (aField == _numberField) {
        _numberField.cardNumber = newValue;
        _cvcField.enabled       = self.cardBrand != CYUnknownCardBrand;
        [self updateIcon];
        if (_numberField.textIsValidCardNumber) {
            self.numberCollapsed = YES;
        } else {
            self.numberCollapsed = NO;
        }
    }
    
    else if (aField == _expiryField) {
        if ([aReplacement isEqualToString:@""] &&
            [newValue length] > 0 &&
            [newValue characterAtIndex:[newValue length] - 1] == '/') {
            newValue = [newValue substringToIndex:[newValue length] - 1];
        }
        _expiryField.text = newValue;
        if (_expiryField.textIsValidExpiry) {
            [_cvcField becomeFirstResponder];
        }
    }
    else if (aField == _cvcField) {
        _cvcField.text = newValue;
    }
    BOOL const isValid = _numberField.textIsValidCardNumber
                      && _expiryField.textIsValidExpiry
                      && _cvcField.textIsValidCVC;
    if (wasValid != isValid &&
        [_delegate respondsToSelector:@selector(cardEntryView:validityDidChange:)]) {
        [_delegate cardEntryView:self validityDidChange:isValid];
    }
    
    // Move cursor to the end of the inserted string
    UITextPosition * const caretLoc = [aField positionFromPosition:oldSelection.end
                                                            offset:([aField.text length] - [oldValue length])];
    if (caretLoc) {
        aField.selectedTextRange = [aField textRangeFromPosition:caretLoc toPosition:caretLoc];
    }
    return NO;
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (BOOL)becomeFirstResponder
{
    if (_cvcField.text.length > 0) {
        return [_cvcField becomeFirstResponder];
    }
    else if (_expiryField.text.length > 0) {
        return [_expiryField becomeFirstResponder];
    }
    else {
        return [_numberField becomeFirstResponder];
    }
}

- (void)insertText:(NSString * const)aText
{
    UITextField *field = (UITextField *)[self cy_findFirstResponder];
    if (!field) {
        field = _numberField;
        [_numberField becomeFirstResponder];
    }
    
    UITextRange * const selection = [field selectedTextRange];
    NSRange const selectedRange = {
        [field offsetFromPosition:[field beginningOfDocument]
                       toPosition:selection.start],
        [field offsetFromPosition:selection.start
                       toPosition:selection.end]
    };
    [self textField:field shouldChangeCharactersInRange:selectedRange replacementString:aText];
}

- (void)backspace
{
    id const field = [self cy_findFirstResponder];
    if (![field isKindOfClass:[UITextField class]]) {
        return;
    }
    
    if ([[field text] length] == 0) {
        [self _deleteKeyPressedInField:field];
        return;
    }
    
    UITextRange * const selection = [field selectedTextRange];
    NSUInteger const selectionStart = [field offsetFromPosition:[field beginningOfDocument]
                                                     toPosition:selection.start];
    NSRange const range = !selection.isEmpty
                        ? (NSRange) { selectionStart, [field offsetFromPosition:selection.start
                                                                     toPosition:selection.end] }
                        : (NSRange) { selectionStart-1, 1 };
    
    if (selectionStart > 0 || !selection.isEmpty) {
        [self textField:field shouldChangeCharactersInRange:range replacementString:@""];
    }
}

- (void)clear
{
    _numberField.text    = @"";
    _expiryField.text    = @"";
    _cvcField.text       = @"";
    self.numberCollapsed = NO;
}

#pragma mark - Accessors

- (NSString *)cardNumber
{
    return _numberField.cardNumber;
}

- (CYCardBrand)cardBrand
{
    return _numberField.cardBrand;
}

- (NSString *)expiry
{
    return _expiryField.text;
}

- (NSDate *)expiryDate
{
    if (_expiryField.text.length < 5) {
        return nil;
    }
    static NSCalendar * calendar;
    if (calendar == nil) {
        calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    }
    NSDateComponents * const today = [calendar components:NSCalendarUnitYear fromDate:[NSDate date]];
    
    NSInteger const month = [[_expiryField.text substringToIndex:2] integerValue];
    NSInteger const year  = [[_expiryField.text substringFromIndex:3] integerValue] + today.year / 100 * 100;
    
    NSDateComponents * const components = [NSDateComponents new];
    components.month = month;
    components.year  = year;
    return [calendar dateFromComponents:components];
}

- (NSString *)cvc
{
    return _cvcField.text;
}

- (void)setCardNumberPlaceholder:(NSString * const)aText
{
    _numberField.placeholder = aText;
}

- (void)setExpiryPlaceholder:(NSString * const)aText
{
    _expiryField.placeholder = aText;
}

- (void)setCvcPlaceholder:(NSString * const)aText
{
    _cvcField.placeholder = aText;
}

- (void)setNumberCollapsed:(BOOL)aFlag
{
    if (_numberCollapsed == aFlag) {
        return;
    }
    _numberCollapsed = aFlag;
    [self layoutSubviewsAnimated:YES];
    if (_numberCollapsed) {
        [_expiryField becomeFirstResponder];
    } else {
        [_numberField becomeFirstResponder];
    }
}

- (void)setUsesSystemKeyboard:(BOOL)aFlag
{
    if (aFlag) {
        _numberField.inputView = nil;
        _expiryField.inputView = nil;
        _cvcField.inputView    = nil;
    }
    else {
        UIView * const placeholderView = [UIView new];
        _numberField.inputView = placeholderView;
        _expiryField.inputView = placeholderView;
        _cvcField.inputView    = placeholderView;
    }
}

#pragma mark -

- (void)_deleteKeyPressedInField:(UITextField * const)aField
{
    if (aField == _expiryField && aField.text.length == 0) {
        self.numberCollapsed = NO;
        [_numberField becomeFirstResponder];
        if ([_numberField.cardNumber length] > 0) {
            _numberField.cardNumber = [_numberField.cardNumber substringToIndex:[_numberField.cardNumber length]-1];
        }
    }
    else if (aField == _cvcField && aField.text.length == 0) {
        [_expiryField becomeFirstResponder];
        if ([_expiryField.text length] > 0) {
            _expiryField.text = [_expiryField.text substringToIndex:[_expiryField.text length]-1];
        }
    }
}

- (void)updateIcon
{
    static UIImage * cvcIcon, * cvcIconAmex;
    if (cvcIcon == nil) {
        cvcIcon = [UIImage imageNamed:@"CVCHint"];
    }
    if (cvcIconAmex == nil) {
        cvcIconAmex = [UIImage imageNamed:@"CVCHintAmex"];
    }
    
    if ([[self cy_findFirstResponder] isEqual:_cvcField]) {
        UIImage * const icon = self.cardBrand == CYAmericanExpress ? cvcIconAmex : cvcIcon;
        if (_brandIconView.image == icon) {
            return;
        }
        if (self.cardBrand == CYAmericanExpress) {
            [UIView animateWithDuration:0.3
                                  delay:0
                                options:UIViewAnimationOptionCurveEaseIn
                             animations:^{
                                 _brandIconView.layer.transform = CATransform3DMakeScale(1.8, 1.8, 1.0);
                             }
                             completion:nil];
        }
        
        UIViewAnimationOptions const animation = self.cardBrand == CYAmericanExpress
                                                 ? UIViewAnimationOptionTransitionCrossDissolve
                                                 : UIViewAnimationOptionTransitionFlipFromRight;
        [UIView transitionWithView:_brandIconView
                          duration:0.2
                           options:animation
                        animations:^{
                            _brandIconView.image = icon;
                            _brandIconView.layer.transform = CATransform3DIdentity;
                        }
                        completion:nil];
    }
    else {
        UIImage * const icon = _CYImageForCardBrand(self.cardBrand);
        if (_brandIconView.image == icon) {
            return;
        }
    
        UIViewAnimationOptions const animation = _brandIconView.image == cvcIcon
                                                 ? UIViewAnimationOptionTransitionFlipFromLeft
                                                 : UIViewAnimationOptionTransitionCrossDissolve;
        [UIView transitionWithView:_brandIconView
                          duration:0.25
                           options:animation
                        animations:^{
                            _brandIconView.image = icon;
                        }
                        completion:nil];
    }
}

- (void)updateHintLabel
{
    if ([self cy_findFirstResponder] == _numberField) {
        _hintLabel.text = @"Enter card number";
    } else if ([self cy_findFirstResponder] == _expiryField) {
        _hintLabel.text = @"Enter four-digit expiration";
    } else {
        _hintLabel.text = self.cardBrand == CYAmericanExpress
                          ? @"Enter four-digit security code on front of card"
                          : @"Enter three-digit security code on back of card";
    }
}

@end

UIImage * _CYImageForCardBrand(CYCardBrand const aCardBrand)
{
    static NSCache *icons;
    if (!icons) {
        icons = [NSCache new];
    }
    
    @synchronized(icons) {
        UIImage * icon = [icons objectForKey:@(aCardBrand)];
        if (!icon) {
            NSString * const imageName =
                [NSString stringWithFormat:@"CardIssuer%@", NSStringFromCYCardBrand(aCardBrand)];
            icon = [UIImage imageNamed:imageName];
            if (icon) {
                [icons setObject:icon forKey:@(aCardBrand)];
            }
        }
        return icon;
    }
}
