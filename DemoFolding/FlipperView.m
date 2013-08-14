//
//  FlipperView.m
//  DemoFolding
//
//  Created by Vladislav Sinitsyn on 11.08.13.
//  Copyright (c) 2013 Vladislav Sinitsyn. All rights reserved.
//

#import "FlipperView.h"
#import <QuartzCore/QuartzCore.h>

static inline double to_rads (double degrees) {return degrees * M_PI/180;}

@interface FlipperView()
- (void)flipUpper;
- (void)flipLower;
@end

@implementation FlipperView
@synthesize topFront = _topFront, topBack = _topBack, bottomFront = _bottomFront, bottomBack = _bottomBack;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        mayFlip = YES;
        
        CGRect bounds = (CGRect) {CGPointZero, frame.size};
        bounds.size.height /= 2;
        
        CGFloat height = CGRectGetHeight(bounds);

        _topBack  = [CALayer layer];
        _topFront = [CALayer layer];
        _bottomBack = [CALayer layer];
        _bottomFront = [CALayer layer];

        _topFront.bounds = _topBack.frame = bounds;
        
        bounds.origin.y = height;
        
        _bottomFront.frame = _bottomBack.frame = bounds;
        
        _topFront.anchorPoint = CGPointMake(0, 1);
        _topFront.position = CGPointMake(-1, height);
        
        _bottomFront.anchorPoint = CGPointMake(0, 0);
        _bottomFront.position = CGPointMake(-1, height);
        
        _topBack.anchorPoint = CGPointMake(0, 0);
        _topBack.position = CGPointMake(-1, 0);
        
        _bottomBack.anchorPoint = CGPointMake(0, 0);
        _bottomBack.position = CGPointMake(-1, height);

        [self.layer addSublayer:_topBack];
        [self.layer addSublayer:_bottomBack];
        [self.layer addSublayer:_topFront];
        [self.layer addSublayer:_bottomFront];
        
        CGSize size = frame.size;
        
        CGFloat padding;
        
        if (size.width > size.height) {
            padding = ceilf(size.width  * .015);
        } else {
            padding = ceilf(size.height * .015);
        }
        
        size = CGSizeMake(
            CGRectGetWidth(bounds) - 3 * padding,
            CGRectGetHeight(bounds) - padding + 4 * padding
        );
        
        CGColorRef black = [UIColor blackColor].CGColor;

        shadowTop = [CALayer layer];
        shadowTop.bounds = (CGRect) {CGPointZero, size};
        shadowTop.backgroundColor = black;
        shadowTop.anchorPoint = CGPointMake(0, 1);
        shadowTop.position = CGPointMake(2 * padding - 1, height + 4 * padding);
        shadowTop.cornerRadius = padding * 4;
        shadowTop.opacity = .35;

        [_topBack addSublayer:shadowTop];
        [_topBack setMasksToBounds:YES];
        
        shadowBottom = [CALayer layer];
        shadowBottom.bounds = (CGRect) {CGPointZero, size};
        shadowBottom.backgroundColor = black;
        shadowBottom.anchorPoint = CGPointMake(0, 0);
        shadowBottom.position = CGPointMake(2 * padding - 1, -4 * padding);
        shadowBottom.cornerRadius = padding * 4;
        shadowBottom.opacity = .35;
        
        shadowBottom.transform = CATransform3DMakeScale(0, -1, 0);
        
        [_bottomBack addSublayer:shadowBottom];
        [_bottomBack setMasksToBounds:YES];
        
        _bottomFront.transform = CATransform3DMakeRotation(to_rads(90), 1, 0, 0);
        
        CATransform3D transform = CATransform3DIdentity;
        transform.m34 = -1.0/(CGRectGetWidth(bounds) * 4.667);
        
        self.layer.sublayerTransform = transform;
    }
    return self;
}

- (void)renderBack {
    UIEdgeInsets insets = UIEdgeInsetsMake(0, 1, 0, 1);
    
    CGRect bounds = (CGRect) {CGPointZero, self.topBack.frame.size};
    self.topBack.contents = (__bridge id)[[self renderImageInRect:bounds
                                                       withInsets:insets] CGImage];
    
    bounds.origin.y = bounds.size.height;
    self.bottomFront.contents = (__bridge id)[[self renderImageInRect:bounds
                                           withInsets:insets] CGImage];
}

- (void)renderFront {
    UIEdgeInsets insets = UIEdgeInsetsMake(0, 1, 0, 1);
    
    CGRect bounds = (CGRect) {CGPointZero, self.topFront.frame.size};
    self.topFront.contents = (__bridge id)[[self renderImageInRect:bounds
                                                        withInsets:insets] CGImage];
    
    bounds.origin.y = bounds.size.height;
    self.bottomFront.contents = (__bridge id)[[self renderImageInRect:bounds
                                                           withInsets:insets] CGImage];
    self.bottomBack.contents = self.bottomFront.contents;
}

- (UIImage *)renderImageInRect:(CGRect)rect {
	return [self renderImageInRect:rect withInsets:UIEdgeInsetsZero];
}

- (UIImage *)renderImageInRect:(CGRect)rect withInsets:(UIEdgeInsets)insets {
    
	CGSize padded = CGSizeMake(rect.size.width + insets.left + insets.right, rect.size.height + insets.top + insets.bottom);
    
	UIGraphicsBeginImageContextWithOptions(padded, NO, 3);
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	CGContextClipToRect(context, (CGRect){{insets.left, insets.top}, rect.size});
    CGContextTranslateCTM(context, -rect.origin.x + insets.left, -rect.origin.y + insets.top);
    [self.source.layer renderInContext:context];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return image;
}

- (void)flip {
    if (!mayFlip) return;
    mayFlip = NO;
    
    [self flipUpper];
}

- (void)flipUpper {
    NSString *rotationKey =  @"transform.rotation.x";
    
    [CATransaction begin];
    
    [CATransaction setValue:[NSNumber numberWithFloat:.30]
                     forKey:kCATransactionAnimationDuration];
    
    [CATransaction setValue:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]
                     forKey:kCATransactionAnimationTimingFunction];
    
    [CATransaction setCompletionBlock:^{
        _topFront.contents = _topBack.contents;
        [self flipLower];
    }];
    
    CABasicAnimation* animation = [CABasicAnimation animationWithKeyPath:rotationKey];
    [animation setFromValue:[NSNumber numberWithDouble:0]];
    [animation setToValue:[NSNumber numberWithDouble:to_rads(-90)]];
    [animation setFillMode:kCAFillModeForwards];
    [animation setRemovedOnCompletion:NO];
    
    [_topFront addAnimation:animation forKey:nil];
    
    //animate shadows
    
    float frameCount = ceil(.35 * 60);
    CGFloat height = CGRectGetHeight(shadowTop.frame);
    
    NSMutableArray *heights = [NSMutableArray arrayWithCapacity:frameCount + 1];
    CGFloat angle;
    CGFloat fn;
    
    for (int i = 0; i <= frameCount; i++) {
        angle = to_rads(90 * (i / frameCount));
        
        fn = cosf(angle);
        fn *= 1.45;
        
        if (i == frameCount) {
            fn = 0;
        } else if (fn > 1) {
            fn = 1;
        }
        
        [heights addObject:[NSNumber numberWithFloat:fn * height]];
    }
    
    // resize height of the 2 folding panels along a cosine or sine curve.  This is necessary to maintain the 2nd joint in the center
    CAKeyframeAnimation *keyAnimation = [CAKeyframeAnimation animationWithKeyPath: @"bounds.size.height"];
    [keyAnimation setValues:[NSArray arrayWithArray:heights]];
    [keyAnimation setFillMode:kCAFillModeForwards];
    [keyAnimation setRemovedOnCompletion:NO];
    [shadowTop addAnimation:keyAnimation forKey:nil];
    
    [CATransaction commit];
}

- (void)flipLower {
    NSString *rotationKey =  @"transform.rotation.x";
    
    [CATransaction begin];
    
    [CATransaction setValue:[NSNumber numberWithFloat:.30]
                     forKey:kCATransactionAnimationDuration];
    
    [CATransaction setValue:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]
                     forKey:kCATransactionAnimationTimingFunction];
    
    [CATransaction setCompletionBlock:^{
        [_topFront removeAllAnimations];
        _topFront.transform = CATransform3DMakeRotation(0, 1, 0, 0);
        _bottomBack.contents = _bottomFront.contents;
        
        double delayInSeconds = .3;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [_bottomFront removeAllAnimations];
            _bottomFront.transform = CATransform3DMakeRotation(to_rads(90), 1, 0, 0);
        });
        
        mayFlip = YES;
    }];
        
    CABasicAnimation* animation = [CABasicAnimation animationWithKeyPath:rotationKey];
    [animation setFromValue:[NSNumber numberWithDouble:to_rads(90)]];
    [animation setToValue:[NSNumber numberWithDouble:0]];
    [animation setFillMode:kCAFillModeForwards];
    [animation setRemovedOnCompletion:NO];
    
    [_bottomFront addAnimation:animation forKey:nil];
    
    float frameCount = ceil(.35 * 60);
    CGFloat height = CGRectGetHeight(shadowBottom.frame);
    
    NSMutableArray *heights = [NSMutableArray arrayWithCapacity:frameCount + 1];
    CGFloat angle;
    CGFloat fn;
    
    for (int i = 0; i <= frameCount; i++) {
        angle = to_rads(90 * (i / frameCount));
        
        fn = sinf(angle);
        fn *= 1.45;
        
        if (i == 0) {
            fn = 0;
        } else if (fn > 1) {
            fn = 1;
        }
        
        [heights addObject:[NSNumber numberWithFloat:fn * height]];
    }
    
    CAKeyframeAnimation *keyAnimation = [CAKeyframeAnimation animationWithKeyPath: @"bounds.size.height"];
    [keyAnimation setValues:[NSArray arrayWithArray:heights]];
    [keyAnimation setFillMode:kCAFillModeForwards];
    [keyAnimation setRemovedOnCompletion:NO];
    [shadowBottom addAnimation:keyAnimation forKey:nil];
    
    [CATransaction commit];
}

- (void)resetTransformations {
    double delayInSeconds = 1.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [_topFront removeAllAnimations];
        [_bottomFront removeAllAnimations];
        
        mayFlip = YES;
        
        _topFront.transform = CATransform3DMakeRotation(to_rads(0), 1, 0, 0);
        _bottomFront.transform = CATransform3DMakeRotation(to_rads(90), 1, 0, 0);
    });
}

@end
