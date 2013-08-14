//
//  FlipperView.h
//  DemoFolding
//
//  Created by Vladislav Sinitsyn on 11.08.13.
//  Copyright (c) 2013 Vladislav Sinitsyn. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CAGradientLayer;

@interface FlipperView : UIView {
    BOOL mayFlip;
    CALayer *shadowTop, *shadowBottom;
    id _contents;
}

@property (nonatomic, retain) CALayer *topFront;
@property (nonatomic, retain) CALayer *topBack;
@property (nonatomic, retain) CALayer *bottomFront;
@property (nonatomic, retain) CALayer *bottomBack;
@property (nonatomic, weak) UIView *source;

- (void)renderFront;
- (void)renderBack;

- (UIImage *)renderImageInRect:(CGRect)rect;
- (UIImage *)renderImageInRect:(CGRect)rect withInsets:(UIEdgeInsets)insets;

- (void)flip;

- (void)resetTransformations;

@end
