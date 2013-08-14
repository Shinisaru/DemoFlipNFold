//
//  ViewController.h
//  DemoFolding
//
//  Created by Vladislav Sinitsyn on 30.07.13.
//  Copyright (c) 2013 Vladislav Sinitsyn. All rights reserved.
//
@class CATransformLayer;
@class CAGradientLayer;

#import <UIKit/UIKit.h>

@interface FoldViewController : UIViewController {
    float foldRatio;
    float oldFoldRatio;
    
    CGFloat scale;
    
    UIImage *foldLeft, *foldRight;
    UIImage *slideLeft, *slideRight;
    
    CALayer *leftSleeve, *rightSleeve;
    CALayer *leftFold, *rightFold;
    
    CAGradientLayer *leftFoldShadow,
                    *rightFoldShadow;
    
    CATransformLayer *jointLayer1, *jointLayer2;
    CALayer *perspectiveLayer;
    
    CATransform3D transform;
    
    __weak UIView *containerView;
    UIView *workerView;
    
    bool shouldDispatch;
    
    float duration;
}

@property (nonatomic, retain) UIImageView *imageView;
@property (nonatomic, retain) UIImageView *horusView;
@property (nonatomic, retain) UISlider *slider;
@property (nonatomic, retain) UIButton *toggle;

- (void)sliderChangedValue:(id)sender;

@end
