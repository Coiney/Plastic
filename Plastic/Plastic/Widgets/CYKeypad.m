// CoineyKit
// Copyright © Coiney Inc. All rights reserved.
// For licensing information, contact info@coiney.com.

#import "CYKeypad.h"

static float const kCYKeypadButtonBorderThickness = 0.5;
static NSInteger const kRowCount = 4;
static NSInteger const kColumnCount = 3;

@interface CYKeypadButton : UIControl
@property(nonatomic, strong) UILabel *label;

+ (instancetype)buttonWithText:(NSString * const)aText
                           tag:(NSInteger const)aTag;
@end

@interface CYKeypad () {
    NSMutableArray *_lineItems;
    NSTimer *_longPressTimer, *_repeatTimer;
}

- (void)_keyPressed:(id)aSender;
@end

@implementation CYKeypad

- (UIControl *)_buttonWithText:(NSString * const)aText
                           tag:(NSInteger const)aTag
{
    UIControl *btn = [CYKeypadButton buttonWithText:aText tag:aTag];

    [btn addTarget:self
            action:@selector(_keyPressed:)
  forControlEvents:UIControlEventTouchUpInside];
    
    return btn;
}

- (void)_init
{
    for (int n = 1; n <= 9; ++n) {
        [self addSubview:[self _buttonWithText:[NSString stringWithFormat:@"%d", n] tag:n]];
    }
    [self addSubview:[self _buttonWithText:@"delete" tag:kCYKeypadDelete]];
    [self addSubview:[self _buttonWithText:@"0" tag:kCYKeypadZero]];

#define Btn(tag) [self viewWithTag:(tag)]
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:Btn(7)
                                                     attribute:NSLayoutAttributeWidth
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeWidth
                                                    multiplier:1.0/(float)kColumnCount
                                                      constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:Btn(7)
                                                     attribute:NSLayoutAttributeHeight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeHeight
                                                    multiplier:1.0/(float)kRowCount
                                                      constant:0]];
    
    NSDictionary * const views = @{ @"_1": Btn(1), @"_2": Btn(2), @"_3": Btn(3), @"_4": Btn(4),
                                    @"_5": Btn(5), @"_6": Btn(6), @"_7": Btn(7), @"_8": Btn(8),
                                    @"_9": Btn(9), @"_0": Btn(kCYKeypadZero),
                                    @"del": Btn(kCYKeypadDelete) };

    [self addConstraints:
     [NSLayoutConstraint
      constraintsWithVisualFormat:@"H:|-(-1)-[_7]-0-[_8(==_7)]-0-[_9]-(-1)-|"
      options:0 metrics:0 views:views]];
    [self addConstraints:
     [NSLayoutConstraint
      constraintsWithVisualFormat:@"H:|-(-1)-[_4(==_7)]-0-[_5(==_7)]-0-[_6]-(-1)-|"
      options:0 metrics:0 views:views]];
    [self addConstraints:
     [NSLayoutConstraint
      constraintsWithVisualFormat:@"H:|-(-1)-[_1(==_7)]-0-[_2(==_7)]-0-[_3]-(-1)-|"
      options:0 metrics:0 views:views]];
    [self addConstraints:
     [NSLayoutConstraint
      constraintsWithVisualFormat:@"H:|-(-1)-[del]-0-[_0(==_3)]-(-1)-|"
      options:0 metrics:0 views:views]];
    
    [self addConstraints:
     [NSLayoutConstraint
      constraintsWithVisualFormat:@"V:|-(-1)-[_7]-0-[_4(==_7)]-0-[_1(==_7)]-0-[del]-(-1)-|"
      options:0 metrics:0 views:views]];
    [self addConstraints:
     [NSLayoutConstraint
      constraintsWithVisualFormat:@"V:|-(-1)-[_8(==_7)]-0-[_5(==_7)]-0-[_2(==_7)]-0-[del]-(-1)-|"
      options:0 metrics:0 views:views]];
    [self addConstraints:
     [NSLayoutConstraint
      constraintsWithVisualFormat:@"V:|-(-1)-[_9(==_7)]-0-[_6(==_7)]-0-[_3(==_7)]-0-[_0]-(-1)-|"
      options:0 metrics:0 views:views]];

#undef Btn
}

- (instancetype)initWithFrame:(CGRect const)aFrame
{
    if (self = [super initWithFrame:aFrame]) {
        [self _init];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder * const)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        [self _init];
    }
    return self;
}

#pragma mark -

- (UIControl *)_buttonAtPoint:(CGPoint const)aPoint
{
    for (UIView *view in self.subviews) {
        if ([view isKindOfClass:[UIControl class]] && CGRectContainsPoint(view.frame, aPoint)) {
            return (UIControl *)view;
        }
    }
    return nil;
}

- (void)_highlightButton:(UIControl * const)aButton
{
    [CATransaction begin];
    for (UIView *view in self.subviews) {
        if ([view isKindOfClass:[UIControl class]]) {
            BOOL const highlighted = (view == aButton && [aButton isEnabled]);
            [(UIControl *)view setHighlighted:highlighted];
            
            if (highlighted) {
                view.backgroundColor = [UIColor colorWithWhite:0 alpha:0.05];
                view.layer.sublayerTransform = CATransform3DMakeScale(0.96, 0.96, 1);
            } else {
                [UIView animateWithDuration:0.2
                                      delay:0
                                    options:UIViewAnimationOptionAllowUserInteraction |
                                            UIViewAnimationOptionBeginFromCurrentState
                                 animations:^{
                                     view.backgroundColor = [UIColor clearColor];
                                     view.layer.sublayerTransform = CATransform3DIdentity;
                                 }
                                 completion:nil];
            }
        }
    }
    [CATransaction commit];
}

- (void)touchesBegan:(NSSet * const)aTouches withEvent:(UIEvent * const)aEvent
{
    UIControl *btn = ([aTouches count] == 1)
                     ? [self _buttonAtPoint:[[aTouches anyObject] locationInView:self]]
                     : nil;
    [self _highlightButton:btn];
    [self becomeFirstResponder];
    if (btn.tag == kCYKeypadDelete) {
        _longPressTimer = [NSTimer scheduledTimerWithTimeInterval:0.7
                                                           target:self
                                                         selector:@selector(_handleLongPressOnDeleteKey:)
                                                         userInfo:nil
                                                          repeats:NO];
    }
}

- (void)touchesMoved:(NSSet * const)aTouches withEvent:(UIEvent * const)aEvent
{
    UIControl *btn = ([aTouches count] == 1)
                     ? [self _buttonAtPoint:[[aTouches anyObject] locationInView:self]]
                     : nil;
    [self _highlightButton:btn];
    if (btn.tag != kCYKeypadDelete) {
        [_longPressTimer invalidate];
        [_repeatTimer invalidate];
    }
}

- (void)touchesCancelled:(NSSet * const)touches withEvent:(UIEvent * const)event
{
    [self _highlightButton:nil];
    [_longPressTimer invalidate];
    [_repeatTimer invalidate];
}

- (void)touchesEnded:(NSSet * const)aTouches withEvent:(UIEvent * const)aEvent
{
    UIControl *btn = ([aTouches count] == 1)
                     ? [self _buttonAtPoint:[[aTouches anyObject] locationInView:self]]
                     : nil;
    if (btn) {
        [btn sendActionsForControlEvents:UIControlEventTouchUpInside];
    }
    [self _highlightButton:nil];
    [_longPressTimer invalidate];
    [_repeatTimer invalidate];
}

#pragma mark -

- (void)_keyPressed:(CYKeypadButton * const)aKey
{
    if (aKey.tag == kCYKeypadDelete) {
        [_delegate keypadDidPressBackspace:self];
    }
    else {
        [_delegate keypad:self didPressNumericalKey:aKey.tag];
    }
}

- (void)sizeToFit
{
    self.bounds = (CGRect) {
        CGPointZero,
        floorf(self.frame.size.width / (float)kColumnCount) * kColumnCount - 1,
        floorf(self.frame.size.height / (float)kRowCount) * kRowCount - 1
    };
}

#pragma mark -

- (void)setEnabled:(BOOL const)aFlag forKey:(CYKeypadKey const)aKey
{
    [(CYKeypadButton *)[self viewWithTag:aKey] setEnabled:aFlag];
}

#pragma mark - Long Press

- (void)_handleLongPressOnDeleteKey:(NSTimer * const)aTimer
{
    _repeatTimer = [NSTimer scheduledTimerWithTimeInterval:0.1
                                                    target:self
                                                  selector:@selector(_deleteKeyPressed:)
                                                  userInfo:nil
                                                   repeats:YES];
}

- (void)_deleteKeyPressed:(NSTimer * const)aTimer
{
    [_delegate keypadDidPressBackspace:self];
}

@end

@implementation CYKeypadButton

+ (instancetype)buttonWithText:(NSString * const)aText
                           tag:(NSInteger const)aTag
{
    CYKeypadButton * const btn = [self new];
    btn.tag = aTag;
    btn.backgroundColor = [UIColor clearColor];
    btn.userInteractionEnabled = NO;
    btn.translatesAutoresizingMaskIntoConstraints = NO;
    btn.contentMode =  UIViewContentModeCenter;
    btn.layer.borderWidth = kCYKeypadButtonBorderThickness;
    btn.layer.borderColor = btn.contentScaleFactor == 1 ? [UIColor colorWithWhite:0.8 alpha:1].CGColor
                                                        : [UIColor colorWithWhite:0.7 alpha:1].CGColor;
    
    btn.label = [UILabel new];
    btn.label.text = aText;
    btn.label.font = [UIFont systemFontOfSize:30];
    btn.label.textColor = [UIColor grayColor];
    btn.label.textAlignment = NSTextAlignmentCenter;
    [btn addSubview:btn.label];
    return btn;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.label.frame = (CGRect) { CGPointZero, self.bounds.size.width, self.bounds.size.height };
}

@end
