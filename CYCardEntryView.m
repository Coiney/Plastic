#import "CYCardEntryView.h"

#if !defined(INRANGE)
#   define __INRANGE(val, low, high, c) ({ \
        __typeof(val) const __val##c = (val); \
        __val##c >= (low) && __val##c <= (high); \
    })
#   define INRANGE(val, low, high) __INRANGE((val), (low), (high), __COUNTER__)
#endif

@interface CYCardNumberField : UITextField
@property(nonatomic, readonly) CYCardEntryView *cardEntryView;
@property(nonatomic) NSString *cardNumber;
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
    UIView      *_clipView;
    
    CYCardNumberField *_numberField;
    CYCardExpiryField *_expiryField;
    CYCardCVCField    *_cvcField;
}
@property(nonatomic, weak) IBOutlet UILabel *hintLabel;
@property(nonatomic, assign) BOOL numberCollapsed;

- (void)_deleteKeyPressedInField:(UITextField *)aField;
- (void)updateIcon;
- (void)updateHintLabel;
@end

static CYCardBrand _CYCardBrandFromNumber(NSString * aCardNumber);
static NSUInteger _CYNumberOfDigitsForCardBrand(CYCardBrand aCardBrand);
static NSUInteger _CYCVCLengthForCardBrand(CYCardBrand aCardBrand);
static NSString * _NSStringFromCYCardbrand(CYCardBrand aCardBrand);
static BOOL _CYLuhnCheck(NSString * aCardNumber);
static NSString * _CYFormatCardNumber(NSString * aCardNumber);
static UIImage * _CYImageForCardBrand(CYCardBrand aCardBrand);

@interface NSString (CYCardEntryAdditions)
- (NSString *)cy_strippedString;
- (NSString *)cy_stringByStrippingAllButNumbers;
- (BOOL)cy_isNumeric;
@end

@interface UIView (CYCardEntryAdditions)
- (BOOL)cy_enumerateSubviews:(void (^)(UIView *aView, BOOL *aoShouldStop))aBlock
                 recursively:(BOOL)aRecursive;
- (UIView *)cy_subviewPassing:(BOOL (^)(UIView *aView))aBlock;
- (UIView *)cy_findFirstResponder;
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
    [super setText:_CYFormatCardNumber(aText)];
    
    CYCardBrand const brand = self.cardBrand;
    BOOL partiallyValid = self.text.length < 2 || brand != CYUnknownCardBrand;
    
    if ([self.cardNumber length] == _CYNumberOfDigitsForCardBrand(brand)) {
        self.textColor = _CYLuhnCheck(self.cardNumber) && brand != CYUnknownCardBrand
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
    
    return [self.cardNumber length] == _CYNumberOfDigitsForCardBrand(brand) &&
           _CYLuhnCheck(self.cardNumber);
}

- (CYCardBrand)cardBrand
{
    return _CYCardBrandFromNumber(self.cardNumber);
}

- (CYCardEntryView *)cardEntryView
{
    return (CYCardEntryView *)self.superview.superview;
}

- (NSUInteger)maxLength
{
    return _CYNumberOfDigitsForCardBrand(self.cardBrand);
}

- (BOOL)becomeFirstResponder
{
    [super becomeFirstResponder];
    [self.cardEntryView updateIcon];
    //[self.cardEntryView updateHintLabel];
    return YES;
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
                     ? [UIColor blackColor]
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
    //[self.cardEntryView updateHintLabel];
    return YES;
}

@end

@implementation CYCardCVCField

- (instancetype)init
{
    if ((self = [super init])) {
        self.keyboardType = UIKeyboardTypeNumberPad;
        self.enabled      = NO;
    }
    return self;
}

- (BOOL)textIsValidCVC
{
    return [self.text length] == _CYCVCLengthForCardBrand(self.cardEntryView.cardBrand);
}

- (void)setText:(NSString *)aText
{
    NSUInteger const maxLength = _CYCVCLengthForCardBrand(self.cardEntryView.cardBrand);
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
    return _CYCVCLengthForCardBrand(self.cardEntryView.cardBrand);
}

- (BOOL)becomeFirstResponder
{
    [super becomeFirstResponder];
    [self.cardEntryView updateIcon];
    //[self.cardEntryView updateHintLabel];
    return YES;
}

@end

@implementation CYCardEntryView

- (void)_init
{
    //_brandIconView = [[UIImageView alloc] initWithImage:[UIImage cy_imageForCardBrand:CYUnknownCardBrand]];
    _brandIconView.backgroundColor = [UIColor clearColor];
    _brandIconView.contentMode     = UIViewContentModeCenter;
    [self addSubview:_brandIconView];
    
    _clipView = [UIView new];
    _clipView.clipsToBounds = YES;
    [self addSubview:_clipView];
    
    _numberField = [CYCardNumberField new];
    _numberField.delegate = self;
    [_clipView addSubview:_numberField];
    
    _expiryField = [CYCardExpiryField new];
    _expiryField.delegate = self;
    [_clipView addSubview:_expiryField];
    
    _cvcField = [CYCardCVCField new];
    _cvcField.delegate = self;
    [_clipView addSubview:_cvcField];
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
    _brandIconView.frame = (CGRect) { 12, 0, 35, self.bounds.size.height };
    _clipView.frame = (CGRect) { 55, (self.bounds.size.height - 28) / 2, self.bounds.size.width - 70, 28 };
    
    if (!_collapsesCardNumberField) {
        _numberField.frame = (CGRect) { 3, 2, 200, 24 };
        _expiryField.frame = (CGRect) { 205, 2, 75, 24 };
        _cvcField.frame    = (CGRect) { 280, 2, 60, 24 };
        _cvcField.placeholder = @"CVC";
    } else if (_numberCollapsed) {
        [UIView animateWithDuration:(aAnimated ? 0.3 : 0) animations:^{
            _numberField.frame = (CGRect) { -144, 2, 200, 24 };
            _expiryField.frame = (CGRect) { 63, 2, 75, 24 };
            _cvcField.frame    = (CGRect) { 144, 2, 60, 24 };
        }];
        _cvcField.placeholder = @"CVC";
    } else {
        [UIView animateWithDuration:(aAnimated ? 0.3 : 0) animations:^{
            _numberField.frame = (CGRect) { 5, 2, 200, 24 };
            _expiryField.frame = (CGRect) { 216, 2, 75, 24 };
            _cvcField.frame    = (CGRect) { 297, 2, 60, 24 };
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
                          ? @"Enter four-digit security code on\nfront of card"
                          : @"Enter three-digit security code on\nback of card";
    }
}

@end

@implementation NSString (CYCardEntryAdditions)

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

@implementation UIView (CYCardEntryAdditions)

- (BOOL)cy_enumerateSubviews:(void (^)(UIView *aView, BOOL *aoShouldStop))aBlock
                 recursively:(BOOL const)aRecursive
{
    // Breadth first
    BOOL shouldStop = NO;
    for (UIView *subview in self.subviews) {
        aBlock(subview, &shouldStop);
        if (shouldStop) {
            return NO;
        }
    }
    if (aRecursive) {
        for (UIView *subview in self.subviews) {
            if (![subview cy_enumerateSubviews:aBlock recursively:YES]) {
                return NO;
            }
        }
    }
    return YES;
}

- (UIView *)cy_subviewPassing:(BOOL (^)(UIView *aView))aBlock
{
    __block UIView *result = nil;
    [self cy_enumerateSubviews:^(UIView *aView, BOOL *aoShouldStop) {
        if (aBlock(aView)) {
            result = aView;
            *aoShouldStop = YES;
        }
    } recursively:YES];
    return result;
}

- (UIView *)cy_findFirstResponder
{
    return [self cy_subviewPassing:^BOOL(UIView *aView) {
        return aView.isFirstResponder;
    }];
}

@end

CYCardBrand _CYCardBrandFromNumber(NSString * const aCardNumber)
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

NSUInteger _CYNumberOfDigitsForCardBrand(CYCardBrand const aCardBrand)
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

NSUInteger _CYCVCLengthForCardBrand(CYCardBrand const aCardBrand)
{
    return aCardBrand == CYAmericanExpress ? 4 : 3;
}

NSString * _NSStringFromCYCardbrand(CYCardBrand const aCardBrand)
{
    switch (aCardBrand) {
        case CYVisa:            return @"Visa";
        case CYMasterCard:      return @"MasterCard";
        case CYAmericanExpress: return @"AmericanExpress";
        case CYJCB:             return @"JCB";
        case CYDiners:          return @"Diners";
        case CYDiscover:        return @"Discover";
        case CYUnknownCardBrand:
            return @"Unknown";
    }
}

BOOL _CYLuhnCheck(NSString * const aCardNumber)
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

NSString *_CYFormatCardNumber(NSString * aCardNumber)
{
    NSCParameterAssert([aCardNumber cy_isNumeric]);
    CYCardBrand const brand = _CYCardBrandFromNumber(aCardNumber);
    
    if ([aCardNumber length] > _CYNumberOfDigitsForCardBrand(brand)) {
        aCardNumber = [aCardNumber substringToIndex:_CYNumberOfDigitsForCardBrand(brand)];
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
                [NSString stringWithFormat:@"CardIssuer%@", _NSStringFromCYCardbrand(aCardBrand)];
            icon = [UIImage imageNamed:imageName];
            if (icon) {
                [icons setObject:icon forKey:@(aCardBrand)];
            }
        }
        return icon;
    }
}
