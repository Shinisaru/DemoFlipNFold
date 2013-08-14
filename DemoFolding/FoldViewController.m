//
//  ViewController.m
//  DemoFolding
//
//  Created by Vladislav Sinitsyn on 30.07.13.
//  Copyright (c) 2013 Vladislav Sinitsyn. All rights reserved.
//

#import "FoldViewController.h"
#import <QuartzCore/QuartzCore.h>

#define EMPEROR 1
#define HORUS   2

static inline double to_rads (double degrees) {return degrees * M_PI/180;}

@interface FoldViewController ()

- (void)createLayers;

- (void)performFoldAnimation;

- (void)foldToValue:(float)progress;

- (UIImage *)renderFromView:(UIView *)view inRect:(CGRect)rect;

- (UIImage *)renderFromView:(UIView *)view inRect:(CGRect)rect withInsets:(UIEdgeInsets)insets;

- (void)imageViewClicked:(id)sender;

- (void)toggleFold:(id)sender;

@end

@implementation FoldViewController

@synthesize slider, toggle, imageView, horusView;

- (id)init {
    self = [super init];
    if (self) {
        self.tabBarItem.image = [UIImage imageNamed:@"um"];
        self.title = @"Fold Waaagh";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGRect bounds = [UIScreen mainScreen].applicationFrame;
    bounds.size.height -= CGRectGetHeight(self.tabBarController.tabBar.frame);
    
    self.view.frame = bounds;
    
    bounds.origin = CGPointZero;
    
    self.imageView = [[UIImageView alloc] initWithFrame:bounds];
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    self.imageView.image = [UIImage imageNamed:@"warhammer___emperor_of_mankind_by_genzoman-d4g9y0f.jpg"];
    self.imageView.tag = EMPEROR;
    
    [self.view insertSubview:self.imageView atIndex:1];
    
    self.horusView = [[UIImageView alloc] initWithFrame:bounds];
    self.horusView.contentMode = UIViewContentModeScaleAspectFill;
    self.horusView.image = [UIImage imageNamed:@"the_warmaster_horus_by_vanagandr-d5npasg.jpg"];
    self.horusView.tag = HORUS;
    
    self.imageView.userInteractionEnabled = YES;
    self.horusView.userInteractionEnabled = YES;
    
    [self.imageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageViewClicked:)]];
    [self.horusView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageViewClicked:)]];
    
    self.imageView.backgroundColor = [UIColor greenColor];
    self.horusView.backgroundColor = [UIColor magentaColor];
    
    [self.view insertSubview:self.horusView atIndex:0];
    
    self.slider = [[UISlider alloc] init];
    self.slider.value = 0;
    
    CGRect frame = self.slider.frame;
    frame.size.width = CGRectGetWidth(self.view.frame) - 20;
    self.slider.frame = frame;
    
    CGPoint center = self.view.center;
    center.y = CGRectGetMinY(self.tabBarController.tabBar.frame) - CGRectGetHeight(self.slider.frame) - 20;
    
    self.slider.center = center;
    
    [self.slider addTarget:self action:@selector(sliderChangedValue:) forControlEvents:UIControlEventValueChanged];
    
    [self.view insertSubview:self.slider atIndex:2];
    
    self.slider.alpha = 0;
    
    self.view.contentMode = UIViewContentModeScaleAspectFill;
    
    scale = 1;
    
    self.toggle = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.toggle.frame = CGRectMake(0, 0, 80, 30);
    [self.toggle setTitle:@"Fold" forState:UIControlStateNormal];
    [self.toggle addTarget:self
                    action:@selector(toggleFold:)
          forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.toggle];
    [self.view bringSubviewToFront:self.toggle];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self createLayers];
    shouldDispatch = YES;
}

- (UIImage *)renderFromView:(UIView *)view inRect:(CGRect)rect {
	return [self renderFromView:view inRect:rect withInsets:UIEdgeInsetsZero];
}

- (UIImage *)renderFromView:(UIView *)view inRect:(CGRect)rect withInsets:(UIEdgeInsets)insets {
    
	CGSize padded = CGSizeMake(rect.size.width + insets.left + insets.right, rect.size.height + insets.top + insets.bottom);
    
	UIGraphicsBeginImageContextWithOptions(padded, UIEdgeInsetsEqualToEdgeInsets(insets, UIEdgeInsetsZero), 3);
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	CGContextClipToRect(context, (CGRect){{insets.left, insets.top}, rect.size});
    CGContextTranslateCTM(context, -rect.origin.x + insets.left, -rect.origin.y + insets.top);
    [view.layer renderInContext:context];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return image;
}

- (void)createLayers {
    scale = [[UIScreen mainScreen] scale];
    
    CGRect bounds = self.imageView.bounds;
    
    UIEdgeInsets insets = UIEdgeInsetsMake(1, 0, 1, 0);
    
    CGRect leftRect, rightRect;
    
    leftRect = bounds;
    leftRect.size.width /= 2;
    
    rightRect = bounds;
    
    rightRect.origin.x += leftRect.size.width;
    rightRect.size.width /= 2;
    
    self.horusView.bounds = (CGRect) {CGPointZero, bounds.size};
    
	CGRect dLeftRect = CGRectOffset(leftRect, -leftRect.origin.x, -leftRect.origin.y);
	CGRect dRightRect = CGRectOffset(rightRect, -leftRect.origin.x, -leftRect.origin.y);
    
    foldLeft  = [self renderFromView:self.imageView inRect:leftRect withInsets:insets];
    foldRight = [self renderFromView:self.imageView inRect:rightRect withInsets:insets];
     
    slideLeft  = [self renderFromView:self.horusView inRect:dLeftRect];
    slideRight = [self renderFromView:self.horusView inRect:dRightRect];
        
	CGFloat height = CGRectGetHeight(bounds);
	CGFloat width  = CGRectGetWidth(bounds) * .5;
    
	CGFloat leftWidth = roundf(width * scale) / scale; // round widths to integer for odd width
	CGFloat rightWidth = (width * 2) - leftWidth;
    
    containerView = [self.imageView superview];
    
    CGRect mainRect = [containerView convertRect:bounds fromView:self.imageView];
    
	CGPoint center = (CGPoint) {CGRectGetMidX(mainRect), CGRectGetMidY(mainRect)};
    
    BOOL isWindow = [containerView isKindOfClass:[UIWindow class]];
    
	if (isWindow) {
		mainRect = [self.imageView convertRect:mainRect fromView:nil];
    }
    
	workerView = [[UIView alloc] initWithFrame:mainRect];
	workerView.backgroundColor = [UIColor clearColor];
	workerView.transform = self.imageView.transform;
    
	if (isWindow) {
		workerView.layer.position = center;
	}
    
	perspectiveLayer = [CALayer layer];
	perspectiveLayer.frame = CGRectMake(0, 0, width * 2, height);
	[workerView.layer addSublayer:perspectiveLayer];
	
	jointLayer1 = [CATransformLayer layer];
	jointLayer1.frame = workerView.bounds;
	[perspectiveLayer addSublayer:jointLayer1];
	
	leftSleeve = [CALayer layer];
	leftSleeve.frame = CGRectMake(0, 0, leftWidth, height);
	leftSleeve.anchorPoint = CGPointMake(1, .5);
	leftSleeve.position = CGPointMake(0, height * .5);
	leftSleeve.contents = (id)slideLeft.CGImage;
	[jointLayer1 addSublayer:leftSleeve];
	
	leftFold = [CALayer layer];
	leftFold.frame = CGRectMake(0, 0, leftWidth + insets.left +  insets.right, height + insets.top + insets.bottom);
	leftFold.anchorPoint = CGPointMake(0, .5);
	leftFold.position = CGPointMake(0, height * .5);
	leftFold.contents = (id)foldLeft.CGImage;
	[jointLayer1 addSublayer:leftFold];
	
	jointLayer2 = [CATransformLayer layer];
	jointLayer2.frame = workerView.bounds;
	jointLayer2.frame = CGRectMake(0, 0, width * 2, height);
	jointLayer2.anchorPoint = CGPointMake(0, .5);
	jointLayer2.position = CGPointMake(leftWidth, height * .5);
	[jointLayer1 addSublayer:jointLayer2];
	
	rightFold = [CALayer layer];
	rightFold.frame = CGRectMake(0, 0, rightWidth + insets.left +  insets.right, height + insets.top + insets.bottom);
	rightFold.anchorPoint = CGPointMake(0, 0.5);
	rightFold.position = CGPointMake(0, height * .5);
	rightFold.contents = (id)foldRight.CGImage;
	[jointLayer2 addSublayer:rightFold];
	
	rightSleeve = [CALayer layer];
	rightSleeve.frame = CGRectMake(0, 0, leftWidth, height);
    rightSleeve.anchorPoint = CGPointMake(0, .5);
	rightSleeve.position = CGPointMake(rightWidth, height * .5);
	rightSleeve.contents = (id)slideRight.CGImage;
	[jointLayer2 addSublayer:rightSleeve];
    
	jointLayer1.anchorPoint = CGPointMake(0, .5);
	jointLayer1.position = CGPointMake(0, height * .5);
    
    CGColorRef clear = [UIColor clearColor].CGColor;
    
    CGColorRef black = [UIColor blackColor].CGColor;
    
    leftFoldShadow = [CAGradientLayer layer];
	leftFoldShadow.frame = leftFold.frame;
	leftFoldShadow.colors = [NSArray arrayWithObjects:(__bridge id)black, (__bridge id)clear, nil];
	leftFoldShadow.startPoint = CGPointMake(0, 0.5);
	leftFoldShadow.endPoint = CGPointMake(1, 0.5);
	leftFoldShadow.opacity = 0;
    [leftFold addSublayer:leftFoldShadow];
    
    rightFoldShadow = [CAGradientLayer layer];
	rightFoldShadow.frame = leftFold.frame;
	rightFoldShadow.colors = [NSArray arrayWithObjects:(__bridge id)clear, (__bridge id)black, nil];
	rightFoldShadow.startPoint = CGPointMake(0, 0.5);
	rightFoldShadow.endPoint = CGPointMake(1, 0.5);
	rightFoldShadow.opacity = 0;
    [rightFold addSublayer:rightFoldShadow];
    
    transform = CATransform3DIdentity;
    transform.m34 = -1.0/(height * 4.667);

    perspectiveLayer.sublayerTransform = transform;
}

- (void)toggleFold:(id)sender {
    if (foldRatio == 0) {
        [self.toggle setTitle:@"Unfold" forState:UIControlStateNormal];
        foldRatio = 1;
        oldFoldRatio = 0;
    } else {
        [self.toggle setTitle:@"Fold" forState:UIControlStateNormal];
        foldRatio = 0;
        oldFoldRatio = 1;
    }
    
    self.toggle.enabled = NO;
    duration = 1;
    [self performFoldAnimation];
}

- (void)imageViewClicked:(id)sender {
    if (nil != sender && [sender isKindOfClass:[UITapGestureRecognizer class]]) {
        UITapGestureRecognizer *tap = (UITapGestureRecognizer *) sender;
        if (tap.view.tag == EMPEROR) {
            foldRatio = 1;
            oldFoldRatio = 0;
            [self.toggle setTitle:@"Unfold" forState:UIControlStateNormal];
        } else {
            foldRatio = 0;
            oldFoldRatio = 1;
            [self.toggle setTitle:@"Fold" forState:UIControlStateNormal];
        }
        
        self.toggle.enabled = NO;
        duration = 1;
        [self performFoldAnimation];
    }
}

- (void)sliderChangedValue:(id)sender {
    oldFoldRatio = foldRatio;
    foldRatio = .01 * round(self.slider.value * 100);
    [self foldToValue:foldRatio];
}

// method concluded to be buggy due to strange behavior of layers combination
// while resizing perspectiveLayer bounds width

- (void)foldToValue:(float)progress {
    if (!shouldDispatch) return;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        shouldDispatch = NO;
        
        if (oldFoldRatio == 0 || oldFoldRatio == 1) {
            [containerView addSubview:workerView];
            self.horusView.alpha = self.imageView.alpha = 0;
        }
        
        self.imageView.alpha = 0;
        self.horusView.alpha = 0;
        
        [containerView bringSubviewToFront:workerView];
        [self.view bringSubviewToFront:self.slider];
        [self.view bringSubviewToFront:self.toggle];
        
        jointLayer1.transform = CATransform3DMakeRotation( progress * to_rads(90), 0, 1, 0);
        jointLayer2.transform = CATransform3DMakeRotation(-progress * to_rads(180), 0, 1, 0);
        rightSleeve.transform = CATransform3DMakeRotation( progress * to_rads(90), 0, 1, 0);
        leftSleeve.transform = CATransform3DMakeRotation(-progress * to_rads(90), 0, 1, 0);
        
        leftFoldShadow.opacity = rightFoldShadow.opacity = progress;
                
        CGRect bounds = perspectiveLayer.bounds;
        bounds.size.width = (1 - progress) * CGRectGetWidth(self.view.frame);
        perspectiveLayer.bounds = bounds;
        
        if (progress == 1) {
            [self.view bringSubviewToFront:self.horusView];
        } else if (progress == 0) {
            [self.view bringSubviewToFront:self.imageView];
        }
        
        if (progress == 1 || progress == 0) {
            self.horusView.alpha = 1;
            self.imageView.alpha = 1;
            [workerView removeFromSuperview];
            [self createLayers];
        }
        
        [self.view bringSubviewToFront:self.slider];
        
        shouldDispatch = YES;
    });
}

- (void)performFoldAnimation {
    if (!shouldDispatch) return;
    
    if (oldFoldRatio == foldRatio) return;
    
    float ratio = foldRatio;
    
    BOOL fold = ratio > oldFoldRatio;
    
    self.imageView.alpha = 0;
    self.horusView.alpha = 0;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        shouldDispatch = NO;
        
        [CATransaction begin];
        
        [CATransaction setValue:[NSNumber numberWithFloat:duration]
                         forKey:kCATransactionAnimationDuration];
        
        [CATransaction setValue:[CAMediaTimingFunction functionWithName:fold? kCAMediaTimingFunctionEaseIn : kCAMediaTimingFunctionEaseOut]
                         forKey:kCATransactionAnimationTimingFunction];
        
        [CATransaction setCompletionBlock:^{
            if (ratio == 1) {
                [self.view bringSubviewToFront:self.horusView];
            } else if (ratio == 0) {
                [self.view bringSubviewToFront:self.imageView];
            }
            
            [self.view bringSubviewToFront:self.slider];
            [self.view bringSubviewToFront:self.toggle];
            
            self.imageView.alpha = 1;
            self.horusView.alpha = 1;
            
            [workerView removeFromSuperview];
            
            [self createLayers];
            
            shouldDispatch = YES;
            oldFoldRatio = ratio;
            
            [self.slider setValue:ratio animated:YES];
            
            self.toggle.enabled = YES;
        }];
        
        [containerView insertSubview:workerView atIndex:0];
        [self.view bringSubviewToFront:self.slider];
        [self.view bringSubviewToFront:self.toggle];
        
        NSString *rotationKey =  @"transform.rotation.y";
        
        // fold first joint layer away from viever
        
        CABasicAnimation* animation = [CABasicAnimation animationWithKeyPath:rotationKey];
        [animation setFromValue:[NSNumber numberWithDouble:fold ? 0 : to_rads(90)]];
        [animation setToValue:[NSNumber numberWithDouble:fold ? to_rads(90) : 0]];
        [animation setFillMode:kCAFillModeForwards];
        [animation setRemovedOnCompletion:NO];
        
        [jointLayer1 addAnimation:animation forKey:nil];
        
        // fold second joint layer towards viewer -- twice the angle of first joint layer rotation
        animation = [CABasicAnimation animationWithKeyPath:rotationKey];
        [animation setFromValue:[NSNumber numberWithDouble:fold ? 0 : to_rads(-180)]];
        [animation setToValue:[NSNumber numberWithDouble:fold ? to_rads(-180) : 0]];
        [animation setFillMode:kCAFillModeForwards];
        [animation setRemovedOnCompletion:NO];
        
        [jointLayer2 addAnimation:animation forKey:nil];
        
        // fold right sleeve (3rd joint) away from viewer
        
        animation = [CABasicAnimation animationWithKeyPath:rotationKey];
        [animation setFromValue:[NSNumber numberWithDouble:fold ? 0 : to_rads(90)]];
        [animation setToValue:[NSNumber numberWithDouble:fold ? to_rads(90) : 0]];
        [animation setFillMode:kCAFillModeForwards];
        [animation setRemovedOnCompletion:NO];
        
        [rightSleeve addAnimation:animation forKey:nil];
        
        // fold left sleeve towards viewer
        
        animation = [CABasicAnimation animationWithKeyPath:rotationKey];
        [animation setFromValue:[NSNumber numberWithDouble:fold ? 0 : to_rads(-90)]];
        [animation setToValue:[NSNumber numberWithDouble:fold ? to_rads(-90) : 0]];
        [animation setFillMode:kCAFillModeForwards];
        [animation setRemovedOnCompletion:NO];
    
        [leftSleeve addAnimation:animation forKey:nil];
        
        // compute widths for animation of perspectiveView width change
        // for (duration * 60) ~ 60 fps animation (smooth, yea)
        
        // also compute shadow opacities
        
        CGFloat width = CGRectGetWidth(workerView.bounds);
        
        float frameCount = ceil(duration * 60);
        
        NSMutableArray *widths = [NSMutableArray arrayWithCapacity:frameCount + 1];
        NSMutableArray *opacities = [NSMutableArray arrayWithCapacity:frameCount + 1];
        CGFloat angle;
        CGFloat fn;
        
        for (int i = 0; i <= frameCount; i++) {
            angle = to_rads(90 * (i / frameCount));
            
            fn = fold ? cos(angle) : sin(angle);
            
            if ((fold && i == frameCount) || (!fold && i == 0)) {
                fn = 0;
            }
                
            [opacities addObject:[NSNumber numberWithFloat:1 - fn]];
            
            [widths addObject:[NSNumber numberWithFloat:fn * width]];
        }
        
        // resize height of the 2 folding panels along a cosine or sine curve.  This is necessary to maintain the 2nd joint in the center
        CAKeyframeAnimation *keyAnimation = [CAKeyframeAnimation animationWithKeyPath: @"bounds.size.width"];
        [keyAnimation setValues:[NSArray arrayWithArray:widths]];
        [keyAnimation setFillMode:kCAFillModeForwards];
        [keyAnimation setRemovedOnCompletion:NO];
        [perspectiveLayer addAnimation:keyAnimation forKey:nil];
        
        keyAnimation = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
        [keyAnimation setValues:[NSArray arrayWithArray:opacities]];
        [keyAnimation setFillMode:kCAFillModeForwards];
        [keyAnimation setRemovedOnCompletion:NO];
        [leftFoldShadow addAnimation:keyAnimation forKey:nil];
        
        keyAnimation = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
        [keyAnimation setValues:[NSArray arrayWithArray:opacities]];
        [keyAnimation setFillMode:kCAFillModeForwards];
        [keyAnimation setRemovedOnCompletion:NO];
        [rightFoldShadow addAnimation:keyAnimation forKey:nil];
        
        [CATransaction commit];
    });
}

@end
