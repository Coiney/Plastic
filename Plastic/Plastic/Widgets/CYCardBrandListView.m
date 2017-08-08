#import "CYCardBrandListView.h"
#import "UIImage+CoineyAdditions.h"

static const CGFloat kHorizontalSpacing = 12;

static NSArray *_BrandNames;

@interface CYCardBrandListView () {
    NSMutableDictionary *_iconViews;
    NSMutableArray *_constraints;
    UIView *_containerView;
}
- (void)_updateLayoutConstraints;
@end

@implementation CYCardBrandListView

+ (void)load
{
    _BrandNames = @[@"Visa", @"MasterCard", @"JCB", @"Amex", @"Diners", @"Discover"];
}

- (void)_init
{
    _brandMask = ~0;
    _iconViews = [[NSMutableDictionary alloc] initWithCapacity:[_BrandNames count]];
    
    _containerView = [UIView new];
    _containerView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self addSubview:_containerView];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_containerView
                                                     attribute:NSLayoutAttributeCenterX
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterX
                                                    multiplier:1
                                                      constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_containerView
                                                     attribute:NSLayoutAttributeCenterY
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterY
                                                    multiplier:1
                                                      constant:0]];

    for (NSString *brandName in _BrandNames) {
        UIImageView * const view = [UIImageView new];
        view.image = [UIImage cy_imageNamed:[NSString stringWithFormat:@"CardIssuer%@", brandName]];
        view.contentMode = UIViewContentModeCenter;
        view.clipsToBounds = YES;
        view.translatesAutoresizingMaskIntoConstraints = NO;
        _iconViews[brandName] = view;
        [_containerView addSubview:view];
    }
}

- (instancetype)init
{
    if (self = [super init]) {
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

- (instancetype)initWithCardBrands:(CYCardBrandMask const)aMask
{
    if (self = [super init]) {
        [self _init];
        self.brandMask = aMask;
    }
    return self;
}

- (void)setBrandMask:(CYCardBrandMask const)aMask
{
    _brandMask = aMask;
    [self _updateLayoutConstraints];
}

- (void)didMoveToSuperview
{
    [self _updateLayoutConstraints];
}

- (void)_updateLayoutConstraints
{
    if (_constraints) {
        [_containerView removeConstraints:_constraints];
    }
    _constraints = [NSMutableArray new];

    NSMutableString * const constraintsFormat  = [[NSMutableString alloc] initWithString:@"H:|-0-"];
    
    BOOL hidden;
    for (NSString *brandName in _BrandNames) {
        hidden = !(_brandMask & 1 << CYCardBrandFromString(brandName));
        UIImageView * const imageView = _iconViews[brandName];
        imageView.hidden = hidden;

        [constraintsFormat appendFormat:@"[%@(%li)]-0-", brandName,
            hidden ? 0l : (long)(imageView.image.size.width + kHorizontalSpacing)];
        
        [_constraints addObjectsFromArray:[NSLayoutConstraint
            constraintsWithVisualFormat:[NSString stringWithFormat:@"V:|-0-[%@(%li)]-0-|", brandName, (long)imageView.image.size.height]
                                options:0
                                metrics:nil
                                  views:_iconViews]];
    }
    [constraintsFormat appendString:@"|"];
    
    [_constraints addObjectsFromArray:[NSLayoutConstraint
        constraintsWithVisualFormat:constraintsFormat
                            options:NSLayoutFormatAlignAllCenterY
                            metrics:nil
                              views:_iconViews]];

    [_containerView addConstraints:_constraints];
    [_containerView layoutIfNeeded];
}
@end
