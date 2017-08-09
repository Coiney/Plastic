//
//  CYCardBrandListViewTests.m
//  PlasticTests
//
//  Created by Ken Myers on 2017/08/07.
//  Copyright © 2017 Coiney. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <Plastic/Plastic.h>

@interface CYCardBrandListViewTests : XCTestCase {
    CYCardBrandListView *_brandListView;
    UIView *_superview;
}
@end

@implementation CYCardBrandListViewTests

- (void)setUp
{
    [super setUp];
    _brandListView = [CYCardBrandListView new];
    _superview = [UIView new];
    [_superview addSubview:_brandListView];
}

- (void)tearDown
{
    [super tearDown];
    _brandListView = nil;
    _superview = nil;
}

- (void)testInitialBrands
{
    XCTAssertEqual(_brandListView.brandMask, CYCardBrandMaskAll);
    XCTAssertEqual(_brandListView.subviews.count, 1);
    
    UIView * const containerView = _brandListView.subviews[0];
    NSIndexSet * const visibleIcons =
        [containerView.subviews indexesOfObjectsPassingTest:
             ^BOOL(UIView * aObj, NSUInteger aIdx, BOOL * oStop) {
                 return !aObj.hidden;
        }];
    XCTAssertEqual(visibleIcons.count, 6);
}

- (void)test0Brands
{
    _brandListView.brandMask = 0;
    XCTAssertEqual(_brandListView.brandMask, 0);
    XCTAssertEqual(_brandListView.subviews.count, 1);
    
    UIView * const containerView = _brandListView.subviews[0];
    NSIndexSet * const visibleIcons =
        [containerView.subviews indexesOfObjectsPassingTest:
            ^BOOL(UIView * aObj, NSUInteger aIdx, BOOL * oStop) {
                return !aObj.hidden;
            }];
    XCTAssertEqual(visibleIcons.count, 0);
}

- (void)test1Brand
{
    _brandListView.brandMask = CYCardBrandMaskMasterCard;
    XCTAssertEqual(_brandListView.brandMask, CYCardBrandMaskMasterCard);
    XCTAssertEqual(_brandListView.subviews.count, 1);
    
    UIView * const containerView = _brandListView.subviews[0];
    NSIndexSet * const visibleIcons =
        [containerView.subviews indexesOfObjectsPassingTest:
            ^BOOL(UIView * aObj, NSUInteger aIdx, BOOL * oStop) {
                return !aObj.hidden;
            }];
    XCTAssertEqual(visibleIcons.count, 1);
}

- (void)test3Brands
{
    CYCardBrandMask const brands = CYCardBrandMaskAmericanExpress |
                                   CYCardBrandMaskDiners |
                                   CYCardBrandMaskDiscover;
    _brandListView.brandMask = brands;
    XCTAssertEqual(_brandListView.brandMask, brands);
    XCTAssertEqual(_brandListView.subviews.count, 1);
    
    UIView * const containerView = _brandListView.subviews[0];
    NSIndexSet * const visibleIcons =
        [containerView.subviews indexesOfObjectsPassingTest:
            ^BOOL(UIView * aObj, NSUInteger aIdx, BOOL * oStop) {
                return !aObj.hidden;
            }];
    XCTAssertEqual(visibleIcons.count, 3);
}

- (void)testAllBrands
{
    CYCardBrandMask const brands =
        CYCardBrandMaskVisa | CYCardBrandMaskMasterCard | CYCardBrandMaskAmericanExpress |
        CYCardBrandMaskJCB  | CYCardBrandMaskDiners     | CYCardBrandMaskDiscover;
    _brandListView.brandMask = brands;
    XCTAssertEqual(_brandListView.brandMask, brands);
    XCTAssertEqual(_brandListView.subviews.count, 1);
    
    UIView * const containerView = _brandListView.subviews[0];
    NSIndexSet * const visibleIcons =
        [containerView.subviews indexesOfObjectsPassingTest:
            ^BOOL(UIView * aObj, NSUInteger aIdx, BOOL * oStop) {
                return !aObj.hidden;
            }];
    XCTAssertEqual(visibleIcons.count, 6);
}

@end
