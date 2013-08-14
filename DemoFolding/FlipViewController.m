//
//  FlipViewController.m
//  DemoFolding
//
//  Created by Vladislav Sinitsyn on 10.08.13.
//  Copyright (c) 2013 Vladislav Sinitsyn. All rights reserved.
//

#import "FlipViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface FlipViewController ()

@end

static inline BOOL dec_changed(int old, int actual) {
    return 0 == actual || (floor (.1 * actual) > floor(.1 * old));
}

@implementation FlipViewController

- (id)init {
    self = [super init];
    if (self) {
        self.title = @"Flip clock";
        self.tabBarItem.image = [UIImage imageNamed:@"clock_icon"];
    }
    return self;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithWhite:.95 alpha:1];
    
    CGRect appFrame = [UIScreen mainScreen].applicationFrame;
    
    CGFloat dWidth = ceilf(.05 * CGRectGetWidth(appFrame));
    
    CGFloat fieldWidth = floorf(.25 * (appFrame.size.width - 5 * dWidth));
    
    CGSize size = CGSizeMake(fieldWidth, floorf(1.618 * fieldWidth));
    
    CGFloat topOffset = floorf(.5 * (CGRectGetHeight(appFrame) - 2 * dWidth - 2 * size.height));
    
    CGRect pFrame = (CGRect) {CGPointMake(dWidth, topOffset), size};
    
    hoursLeft    = [[FlipperView alloc] initWithFrame:pFrame];
    pFrame.origin.x += fieldWidth + .5 * dWidth;
    hoursRight   = [[FlipperView alloc] initWithFrame:pFrame];
    
    pFrame.origin.x = CGRectGetWidth(appFrame) - dWidth - fieldWidth;
    minutesLeft  = [[FlipperView alloc] initWithFrame:pFrame];
    pFrame.origin.x -= .5 * dWidth + fieldWidth;
    minutesRight = [[FlipperView alloc] initWithFrame:pFrame];

    pFrame.origin = CGPointZero;
    renderLabel = [self createBlankNumberLabel:pFrame];
    
    pFrame.origin.x = -CGRectGetWidth(appFrame);
    renderView  = [self createBlankBackgroundView:pFrame
                                        withLabel:renderLabel];
    
    hoursLeft.source = hoursRight.source =
    minutesLeft.source = minutesRight.source = renderView;
    
    pFrame.size.width  = floorf(.75 * CGRectGetWidth(pFrame));
    pFrame.size.height = floorf(.75 * CGRectGetHeight(pFrame));
    
    pFrame.origin.y = topOffset + 2 * dWidth + size.height;
    pFrame.origin.x = CGRectGetWidth(appFrame) * .5 - .25 * dWidth - CGRectGetWidth(pFrame);
    
    secondsLeft  = [[FlipperView alloc] initWithFrame:pFrame];
    
    pFrame.origin.x += CGRectGetWidth(pFrame) + .5 * dWidth;
    secondsRight = [[FlipperView alloc] initWithFrame:pFrame];
    
    pFrame.origin = CGPointZero;
    renderLabelSeconds = [self createBlankNumberLabel:pFrame];
    
    pFrame.origin.x = -.5 * CGRectGetWidth(appFrame);
    renderViewSeconds  = [self createBlankBackgroundView:pFrame
                                               withLabel:renderLabelSeconds];
    
    secondsLeft.source = secondsRight.source = renderViewSeconds;
    
    CGSize shadowSize = CGSizeMake(floorf(1.1 * dWidth), floorf(1.1 * dWidth));
    CGSize dotSize    = CGSizeMake(floorf(.80 * dWidth), floorf(.80 * dWidth));
    CGRect dotFrame = (CGRect) {CGPointZero, dotSize};
    
    topOffset += floorf(.5 * size.height) - 1.618 * dotSize.height;
    dotFrame.origin.y = topOffset;
    dotFrame.origin.x = self.view.center.x - .5 * dotSize.width;
    
    CGFloat deltaX = -.6 * (shadowSize.width - dotSize.width);
    
    CALayer *dot = [CALayer layer];
    dot.frame = dotFrame;
    dot.backgroundColor = [UIColor whiteColor].CGColor;
    dot.borderColor = [UIColor colorWithWhite:.6 alpha:1].CGColor;
    dot.borderWidth = 1;
    [self addShadowToLayer:dot withSize:shadowSize];
    dot.shadowOffset = CGSizeMake(deltaX, deltaX);

    [self.view.layer addSublayer:dot];
    
    dotFrame.origin.y += 2 * 1.618 * dotSize.height - dotSize.height;

    dot = [CALayer layer];
    dot.frame = dotFrame;
    dot.backgroundColor = [UIColor whiteColor].CGColor;
    dot.borderColor = [UIColor colorWithWhite:.6 alpha:1].CGColor;
    dot.borderWidth = 1;
    [self addShadowToLayer:dot withSize:shadowSize];
    dot.shadowOffset = CGSizeMake(deltaX, deltaX);
    
    [self.view.layer addSublayer:dot];
    
    [self.view addSubview:renderView];
    [self.view addSubview:renderViewSeconds];

    [self addShadowToView:hoursLeft];
    [self addShadowToView:hoursRight];
    [self addShadowToView:minutesLeft];
    [self addShadowToView:minutesRight];
    [self addShadowToView:secondsLeft];
    [self addShadowToView:secondsRight];

    [self.view addSubview:hoursLeft];
    [self.view addSubview:hoursRight];
    [self.view addSubview:minutesLeft];
    [self.view addSubview:minutesRight];
    [self.view addSubview:secondsLeft];
    [self.view addSubview:secondsRight];
}

- (void)renderLeft:(FlipperView *)left andRight:(FlipperView *)right withValue:(NSInteger)value front:(BOOL)front {
    NSString *repr = [NSString stringWithFormat:@"%d", value];
    
    renderLabel.text = (repr.length > 1) ? [repr substringToIndex:1] : @"0";
    renderLabelSeconds.text = renderLabel.text;
    
    if (front) {
        [left renderFront];
    } else {
        [left renderBack];
    }
    
    renderLabel.text = [repr substringFromIndex:repr.length - 1];
    renderLabelSeconds.text = renderLabel.text;
    
    if (front) {
        [right renderFront];
    } else {
        [right renderBack];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSDateComponents *now = [self now];
    
    hours = now.hour;
    minutes = now.minute;
    seconds = now.second;
    
    [self renderLeft:hoursLeft   andRight:hoursRight   withValue:hours   front:YES];
    [self renderLeft:minutesLeft andRight:minutesRight withValue:minutes front:YES];
    [self renderLeft:secondsLeft andRight:secondsRight withValue:seconds front:YES];
    
    [self renderLeft:hoursLeft   andRight:hoursRight   withValue:hours   front:NO];
    [self renderLeft:minutesLeft andRight:minutesRight withValue:minutes front:NO];
    [self renderLeft:secondsLeft andRight:secondsRight withValue:seconds front:NO];
    
    // render images for last known time
    timer = [NSTimer scheduledTimerWithTimeInterval:.33
                                             target:self
                                           selector:@selector(timerCallback)
                                           userInfo:nil
                                            repeats:YES];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [timer invalidate];
    timer = nil;
    
    [hoursRight resetTransformations];
    [hoursLeft resetTransformations];
    [minutesRight resetTransformations];
    [minutesLeft resetTransformations];
    [secondsRight resetTransformations];
    [secondsLeft resetTransformations];
}

- (void)addShadowToView:(UIView *)theView {
    [self addShadowToLayer:theView.layer withSize:theView.frame.size];
}

- (void)addShadowToLayer:(CALayer *)layer withSize:(CGSize)size {
    CGFloat padding;
    
    if (size.width > size.height) {
        padding = ceilf(size.width  * .015);
    } else {
        padding = ceilf(size.height * .015);
    }
    
    layer.shadowColor = [UIColor blackColor].CGColor;
    layer.shadowRadius = padding;
    layer.shadowOffset = CGSizeMake(-padding, -padding);
    
    CGRect layerFrame = CGRectMake(
        2 * padding, 2 * padding,
        size.width - 2 * padding, size.height - 2 * padding
    );
    
    UIBezierPath *roundedRect = [UIBezierPath bezierPathWithRoundedRect:layerFrame
                                                           cornerRadius:4 * padding];
    layer.shadowPath = roundedRect.CGPath;
    layer.shadowOpacity = 0.5;
}

- (UIView *)createBlankBackgroundView:(CGRect)frame withLabel:(UILabel *)label {
    UIView *blank = [[UIView alloc] initWithFrame:frame];
    
    CGSize size = frame.size;
    
    CGFloat padding;
    
    if (size.width > size.height) {
        padding = ceilf(size.width  * .015);
    } else {
        padding = ceilf(size.height * .015);
    }
    
    CALayer *backgroundLayer = [CALayer layer];
    
    CGRect layerFrame = CGRectMake(
        padding, padding,
        size.width - 2 * padding, size.height - 2 * padding
    );
    backgroundLayer.frame = layerFrame;
    
    backgroundLayer.backgroundColor = [UIColor whiteColor].CGColor;
    backgroundLayer.cornerRadius = 4 * padding;
    
    backgroundLayer.borderColor = [UIColor colorWithWhite:.6 alpha:1].CGColor;
    backgroundLayer.borderWidth = 1;
    
    [blank.layer addSublayer:backgroundLayer];
     
    UIView *lines = [[UIView alloc] initWithFrame: CGRectMake(
        padding, size.height / 2 - 1,
        size.width - 2 * padding, 2
    )];
    
    lines.layer.backgroundColor = [UIColor colorWithWhite:.6 alpha:1].CGColor;
    
    CALayer *line2 = [CALayer layer];
    line2.frame = CGRectMake(0, 1, lines.frame.size.width, 1);
    line2.backgroundColor = [UIColor colorWithWhite:.3 alpha:1].CGColor;
    
    [lines.layer addSublayer:line2];
    
    [blank addSubview:label];
    [blank insertSubview:lines aboveSubview:label];
    
    return blank;
}

- (UILabel *)createBlankNumberLabel:(CGRect)viewFrame {
    CGSize size = viewFrame.size;
    
    CGFloat padding;
    
    if (size.width > size.height) {
        padding = ceilf(size.width  * .015);
    } else {
        padding = ceilf(size.height * .015);
    }
    
    CGRect lblFrame = CGRectMake(padding, padding, size.width - 2 * padding, size.height - 2 * padding);
    
    UILabel *label = [[UILabel alloc] initWithFrame:lblFrame];
    label.font = [UIFont boldSystemFontOfSize:size.height - 4 * padding];
    label.textAlignment = NSTextAlignmentCenter;
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor darkGrayColor];
    
    return label;
}

- (void)timerCallback {
    NSDateComponents *nowtm = [self now];
    NSInteger csec  = nowtm.second;
    NSInteger cmin  = nowtm.minute;
    NSInteger chour = nowtm.hour;
    
    if (seconds != csec){
        [self renderLeft:secondsLeft andRight:secondsRight withValue:csec front:NO];
        
        if (dec_changed(seconds, csec)) [secondsLeft flip];
        
        [secondsRight flip];
        
        seconds = csec;
    }
    
    if (minutes != cmin){
        [self renderLeft:minutesLeft andRight:minutesRight withValue:cmin front:NO];
        
        if (dec_changed(minutes, cmin)) [minutesLeft flip];
        
        [minutesRight flip];
        
        minutes = cmin;
    }
    
    if (hours != chour){
        [self renderLeft:hoursLeft andRight:hoursRight withValue:hours front:NO];
        
        if (dec_changed(hours, chour)) [hoursLeft flip];
        
        [hoursRight flip];

        hours = chour;
    }

}

- (NSDateComponents *)now {
    NSDate *date = [NSDate date];
    NSCalendar *calendar = [[NSCalendar alloc]
                             initWithCalendarIdentifier:NSGregorianCalendar];
    
    return [calendar components:(NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit)
                       fromDate:date];
}

@end
