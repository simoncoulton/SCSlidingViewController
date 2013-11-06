//
//  SCSlidingViewController.m
//
//  Created by Simon Coulton on 11/10/13.
//  Copyright (c) 2013 Simon Coulton. All rights reserved.
//

#import "SCSlidingViewController.h"

@interface SCSlidingViewController () <UIGestureRecognizerDelegate>

@property (assign, nonatomic) BOOL showingLeft;
@property (assign, nonatomic) BOOL showingRight;
@property (assign, nonatomic) CGPoint previousVelocity;

@end

#pragma mark -
#pragma mark UIViewController Category

@implementation UIViewController(SlidingViewCategory)

- (SCSlidingViewController *)slidingViewController
{
    UIViewController *viewController = self.parentViewController;
    while (!(viewController == nil || [viewController isKindOfClass:[SCSlidingViewController class]])) {
        viewController = viewController.parentViewController;
    }

    return (SCSlidingViewController *)viewController;
}

- (void)viewHasShadow:(BOOL)hasShadow withColor:(UIColor *)color withCornerRadius:(CGFloat)cornerRadius withShadowOffsetX:(CGFloat)shadowOffsetX withShadowOffsetY:(CGFloat)shadowOffsetY andOpacity:(CGFloat)opacity
{
    self.view.layer.opaque = NO;
    self.view.layer.cornerRadius = cornerRadius;

    self.view.layer.shadowColor = color.CGColor;
    self.view.layer.shadowRadius = cornerRadius;
    self.view.layer.shadowOffset = CGSizeMake(shadowOffsetX, shadowOffsetY);
    self.view.layer.shadowOpacity = opacity;
}

@end

#pragma mark -
#pragma mark Initialization

@implementation SCSlidingViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setDefaults];
}

- (void)setDefaults
{
    if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1) {
        // iOS 7, offset it below the status bar
        self.topViewOffsetY = 20;
    } else {
        self.topViewOffsetY = 0;
    }
    self.allowOverswipe = NO;
    self.peakAmount = 140;
    self.peakThreshold = .5;
    self.shadowColor = [UIColor blackColor];
    self.shadowOpacity = 0.3f;
    self.shadowOffsetX = self.shadowOffsetY = 3.0f;
    self.cornerRadius = 4.0f;
    self.animationDuration = 0.5f;
}

#pragma mark -
#pragma mark Set the views

- (void)setTopViewController:(UIViewController *)topViewController
{
    [topViewController.view removeFromSuperview];
    [topViewController willMoveToParentViewController:nil];
    [topViewController removeFromParentViewController];

    self->_topViewController = topViewController;
    [self.view addSubview:topViewController.view];
    [self addChildViewController:topViewController];
    [topViewController didMoveToParentViewController:self];

    // Adjust the frame to sit below the status bar
    topViewController.view.frame = CGRectMake(0, self.topViewOffsetY, self.view.frame.size.width, self.view.frame.size.height - self.topViewOffsetY);
    [topViewController viewHasShadow:YES withColor:self.shadowColor withCornerRadius:self.cornerRadius withShadowOffsetX:self.shadowOffsetX withShadowOffsetY:self.shadowOffsetY andOpacity:self.shadowOpacity];
    [self addGestures];
}

- (void)setLeftSideViewController:(UIViewController *)leftSideViewController
{
    [leftSideViewController.view removeFromSuperview];
    [leftSideViewController willMoveToParentViewController:nil];
    [leftSideViewController removeFromParentViewController];

    self->_leftSideViewController = leftSideViewController;
    [self.view addSubview:leftSideViewController.view];
    [self.view sendSubviewToBack:leftSideViewController.view];
    [self addChildViewController:leftSideViewController];
    [leftSideViewController didMoveToParentViewController:self];
}

- (void)setRightSideViewController:(UIViewController *)rightSideViewController
{
    [rightSideViewController.view removeFromSuperview];
    [rightSideViewController willMoveToParentViewController:nil];
    [rightSideViewController removeFromParentViewController];

    self->_rightSideViewController = rightSideViewController;
    [self.view addSubview:rightSideViewController.view];
    [self.view sendSubviewToBack:rightSideViewController.view];
    [self addChildViewController:rightSideViewController];
    [rightSideViewController didMoveToParentViewController:self];
}

#pragma mark -
#pragma mark Animate to position

- (void)slideRight
{
    // Display the leftSide view controller
    if (self.rightSideViewController) {
        [self.view sendSubviewToBack:self.rightSideViewController.view];
        if ([self.rightSideViewController respondsToSelector:@selector(preferredStatusBarStyle)]) {
            [[UIApplication sharedApplication] setStatusBarStyle:[self.rightSideViewController preferredStatusBarStyle]];
        }
    }
    if (!self.leftSideViewController) {
        return;
    }
    [self.view bringSubviewToFront:self.topViewController.view];
    if (self.showingLeft && self.topViewController.view.frame.origin.x == self.peakAmount) {
        [self snapToOrigin];
    } else {
        CGFloat xPos = self.peakAmount;
        [UIView animateWithDuration:self.animationDuration delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            self.topViewController.view.frame = CGRectMake(xPos, self.topViewOffsetY, self.view.frame.size.width, self.view.frame.size.height - self.topViewOffsetY);
        } completion:^(BOOL finished) {
            self.showingLeft = YES;
        }];
    }
}

- (void)slideLeft
{
    // Display the rightSide view controller
    if (self.leftSideViewController) {
        [self.view sendSubviewToBack:self.leftSideViewController.view];
        if ([self.leftSideViewController respondsToSelector:@selector(preferredStatusBarStyle)]) {
            [[UIApplication sharedApplication] setStatusBarStyle:[self.leftSideViewController preferredStatusBarStyle]];
        }
    }
    if (!self.rightSideViewController) {
        return;
    }
    [self.view bringSubviewToFront:self.topViewController.view];
    if (self.showingRight && self.topViewController.view.frame.origin.x == 0 - self.peakAmount) {
        [self snapToOrigin];
    } else {
        CGFloat xPos = 0 - self.peakAmount;
        [UIView animateWithDuration:self.animationDuration delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            self.topViewController.view.frame = CGRectMake(xPos, self.topViewOffsetY, self.view.frame.size.width, self.view.frame.size.height - self.topViewOffsetY);
        } completion:^(BOOL finished) {
            self.showingRight = YES;
        }];
    }
}

- (void)snapToOrigin
{
    self.showingLeft = NO;
    self.showingRight = NO;
    [UIView animateWithDuration:self.animationDuration / 2 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        self.topViewController.view.frame = CGRectMake(0, self.topViewOffsetY, self.view.frame.size.width, self.view.frame.size.height - self.topViewOffsetY);
    } completion:^(BOOL finished) {}];
}

#pragma mark -
#pragma mark UIGestureRecognizers

- (void)addGestures
{
    self.panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(dragView:)];
	[self.topViewController.view addGestureRecognizer:self.panGesture];

    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapClose:)];
    [self.topViewController.view addGestureRecognizer:tapRecognizer];
}

- (void)dragView:(id)sender
{
    [[[(UITapGestureRecognizer*)sender view] layer] removeAllAnimations];
    UIView *senderView = [sender view];
	CGPoint translatedPoint = [(UIPanGestureRecognizer*)sender translationInView:self.view];
	CGPoint velocity = [(UIPanGestureRecognizer*)sender velocityInView:senderView];
    CGFloat topLeftX = senderView.frame.origin.x;

	if ([(UIPanGestureRecognizer*)sender state] == UIGestureRecognizerStateBegan) {
        // Determine which view to bring to the top
        UIViewController *viewToShow = nil;

        if (velocity.x > 0) {
            if (!self.showingRight && self.rightSideViewController) {
                viewToShow = self.rightSideViewController;
            } else {
                return;
            }
        } else {
            if (!self.showingLeft && self.leftSideViewController) {
                viewToShow = self.leftSideViewController;
            } else {
                return;
            }

        }
        if ([viewToShow respondsToSelector:@selector(preferredStatusBarStyle)]) {
            [[UIApplication sharedApplication] setStatusBarStyle:[viewToShow preferredStatusBarStyle]];
        }
        [self.view sendSubviewToBack:viewToShow.view];
        [senderView bringSubviewToFront:[(UIPanGestureRecognizer*)sender view]];
	}

	if ([(UIPanGestureRecognizer*)sender state] == UIGestureRecognizerStateEnded) {
        CGFloat frameWidth = senderView.frame.size.width;
        CGFloat widthVisibleAfterPeak = frameWidth - self.peakAmount;
        CGFloat thresholdCenter = (frameWidth - widthVisibleAfterPeak) * self.peakThreshold;
        if (self.showingLeft) {
            if (topLeftX < thresholdCenter) {
                [self snapToOrigin];
            } else {
                [self slideRight];
            }
        } else if (self.showingRight) {
            if (topLeftX < 0 - thresholdCenter) {
                [self slideLeft];
            } else {
                [self snapToOrigin];
            }
        } else {
            [self snapToOrigin];
        }
	}

	if ([(UIPanGestureRecognizer*)sender state] == UIGestureRecognizerStateChanged) {
        CGFloat centerX = senderView.center.x;
        CGFloat centerY = senderView.center.y;
        CGPoint newCenter = CGPointMake(centerX + translatedPoint.x, centerY);
        CGFloat frameCenter = senderView.frame.size.width / 2;
        
        // Sliding to the left
        if ((velocity.x < 0 && !self.rightSideViewController && newCenter.x < frameCenter)
            || (velocity.x > 0 && !self.leftSideViewController && newCenter.x > frameCenter)
            || (self.showingLeft && newCenter.x < frameCenter && !self.allowOverswipe)
            || (self.showingRight && newCenter.x > frameCenter && !self.allowOverswipe)) {
            return;
        }
        
        senderView.center = newCenter;
        [(UIPanGestureRecognizer*)sender setTranslation:CGPointMake(0,0) inView:self.view];
        
        if (newCenter.x < frameCenter) {
            self.showingRight = YES;
            self.showingLeft = NO;
        } else if (newCenter.x > frameCenter) {
            self.showingLeft = YES;
            self.showingRight = NO;
        } else {
            self.showingRight = NO;
            self.showingLeft = NO;
        }
        _previousVelocity = velocity;
	}
}

- (void)tapClose:(id)sender
{
    [self snapToOrigin];
}

#pragma mark -
#pragma mark Change view controller

- (void)changeTopViewController:(UIViewController *)viewController
{
    [self willChangeTopViewController];

    CGFloat xPos = self.view.frame.size.width + 10;
    if (self.showingRight) {
        xPos = xPos * -1;
    }
    CGRect frame = CGRectMake(xPos, self.topViewOffsetY, self.view.frame.size.width, self.view.frame.size.height - self.topViewOffsetY);
    [UIView animateWithDuration:self.animationDuration delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        self.topViewController.view.frame = frame;
    } completion:^(BOOL finished) {
        [self.topViewController.view removeFromSuperview];
        [self.topViewController willMoveToParentViewController:nil];
        [self.topViewController removeFromParentViewController];
        self.topViewController = viewController;
        self.topViewController.view.frame = frame;
        [self snapToOrigin];
        [self didChangeTopViewController];
    }];
}

#pragma mark -
#pragma mark Events
- (void)didChangeTopViewController
{}

- (void)willChangeTopViewController
{}

@end
