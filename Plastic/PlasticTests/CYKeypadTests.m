//
//  CYKeypadTests.m
//  PlasticTests
//
//  Created by Ken Myers on 2017/08/07.
//  Copyright © 2017 Coiney. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <Plastic/Plastic.h>

@interface CYKeypadTests : XCTestCase <CYKeypadDelegate> {
    UIWindow *_window;
    CYKeypad *_keypad;
    CYKeypadKey _typeOfKeyPressed;
}
@end

@implementation CYKeypadTests

- (void)setUp
{
    [super setUp];
    _window = [UIWindow new];
    _typeOfKeyPressed = -1;
}

- (void)tearDown
{
    [super tearDown];
    _keypad = nil;
    _window = nil;
}

- (void)testKeyCount
{
    _keypad = [[CYKeypad alloc] init];
    ;
    XCTAssertEqual(_keypad.subviews.count, 11);
}

- (void)testInitWithFrame
{
    CGRect const frame = (CGRect) { CGPointZero, 100, 200 };
    _keypad = [[CYKeypad alloc] initWithFrame:frame];
    XCTAssert(CGRectEqualToRect(_keypad.frame, frame));
}

- (void)testBackspace
{
    _keypad = [CYKeypad new];
    _keypad.delegate = self;
    [_window addSubview:_keypad];
    UIControl * const backspaceButton = [_keypad viewWithTag:kCYKeypadDelete];
    XCTAssertNotNil(backspaceButton);
    [backspaceButton sendActionsForControlEvents:UIControlEventTouchUpInside];
    XCTAssertEqual(_typeOfKeyPressed, kCYKeypadDelete);
}

- (void)testNumericalKeys
{
    _keypad = [CYKeypad new];
    _keypad.delegate = self;
    // 1
    [[_keypad viewWithTag:1] sendActionsForControlEvents:UIControlEventTouchUpInside];
    XCTAssertEqual(_typeOfKeyPressed, 1);
    // 2
    [[_keypad viewWithTag:2] sendActionsForControlEvents:UIControlEventTouchUpInside];
    XCTAssertEqual(_typeOfKeyPressed, 2);
    // 3
    [[_keypad viewWithTag:3] sendActionsForControlEvents:UIControlEventTouchUpInside];
    XCTAssertEqual(_typeOfKeyPressed, 3);
    // 4
    [[_keypad viewWithTag:4] sendActionsForControlEvents:UIControlEventTouchUpInside];
    XCTAssertEqual(_typeOfKeyPressed, 4);
    // 5
    [[_keypad viewWithTag:5] sendActionsForControlEvents:UIControlEventTouchUpInside];
    XCTAssertEqual(_typeOfKeyPressed, 5);
    // 6
    [[_keypad viewWithTag:6] sendActionsForControlEvents:UIControlEventTouchUpInside];
    XCTAssertEqual(_typeOfKeyPressed, 6);
    // 7
    [[_keypad viewWithTag:7] sendActionsForControlEvents:UIControlEventTouchUpInside];
    XCTAssertEqual(_typeOfKeyPressed, 7);
    // 8
    [[_keypad viewWithTag:8] sendActionsForControlEvents:UIControlEventTouchUpInside];
    XCTAssertEqual(_typeOfKeyPressed, 8);
    // 9
    [[_keypad viewWithTag:9] sendActionsForControlEvents:UIControlEventTouchUpInside];
    XCTAssertEqual(_typeOfKeyPressed, 9);
    // 0
    [[_keypad viewWithTag:kCYKeypadZero] sendActionsForControlEvents:UIControlEventTouchUpInside];
    XCTAssertEqual(_typeOfKeyPressed, kCYKeypadZero);
}

- (void)keypadDidPressBackspace:(CYKeypad * const)aView
{
    _typeOfKeyPressed = kCYKeypadDelete;
}

- (void)keypad:(CYKeypad * const)aView didPressNumericalKey:(NSUInteger const)aKey
{
    _typeOfKeyPressed = aKey;
}

@end
