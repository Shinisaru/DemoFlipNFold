//
//  FlipViewController.h
//  DemoFolding
//
//  Created by Vladislav Sinitsyn on 10.08.13.
//  Copyright (c) 2013 Vladislav Sinitsyn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FlipperView.h"

@interface FlipViewController : UIViewController {
    FlipperView *hoursLeft,   *hoursRight,
                *minutesLeft, *minutesRight,
                *secondsLeft, *secondsRight;

    UIView *renderView;
    UIView *renderViewSeconds;
    
    UILabel *renderLabel;
    UILabel *renderLabelSeconds;
    
    NSInteger hours, minutes, seconds;
    
    NSTimer *timer;
}

- (void)renderLeft:(FlipperView *)left andRight:(FlipperView *)right withValue:(NSInteger)value front:(BOOL)front;


- (NSDateComponents *)now;

- (UIView *)createBlankBackgroundView:(CGRect)frame withLabel:(UILabel *)label;

- (UILabel *)createBlankNumberLabel:(CGRect)viewFrame;

- (void)timerCallback;

- (void)addShadowToView:(UIView *)theView;

@end
