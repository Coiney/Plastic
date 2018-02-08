#import <Plastic/CYCardBrandFunctions.h>
#import <UIKit/UIKit.h>

@interface CYCardBrandListView : UIView
@property(nonatomic) CYCardBrandMask brandMask;

- (instancetype)initWithFrame:(CGRect)aFrame;
- (instancetype)initWithCoder:(NSCoder *)aDecoder;
@end
