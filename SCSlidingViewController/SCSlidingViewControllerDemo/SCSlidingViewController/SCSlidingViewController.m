//
//  SCSlidingViewController.m
//
//  Created by Simon Coulton on 11/10/13.
//  Copyright (c) 2013 Simon Coulton. All rights reserved.
//

#import "SCSlidingViewController.h"

@interface SCSlidingViewController () <UIGestureRecognizerDelegate>

@property (strong, nonatomic) UIView *containerView;
@property (strong, nonatomic) UIView *overlayView;
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
    self.animateOnClose = NO;
    self.peakAmount = 140;
    self.peakThreshold = .5;
    self.shadowColor = [UIColor blackColor];
    self.shadowOpacity = 0.5f;
    self.shadowOffsetX = self.shadowOffsetY = 3.0f;
    self.cornerRadius = 4.0f;
    self.animationDuration = 0.5f;
    self.enabled = YES;
}

#pragma mark -
#pragma mark Set the views

- (UIView *)containerView
{
    // The view that the top view controller will be added to
    if (_containerView) {
        return _containerView;
    }
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectOffset(self.view.frame, 0, 0)];
    _containerView = view;
    view.backgroundColor = [UIColor clearColor];
    view.frame = CGRectMake(0, self.topViewOffsetY, view.frame.size.width, view.frame.size.height - self.topViewOffsetY);
    [self.view addSubview:_containerView];
    
    return view;
}

- (UIView *)overlayView
{
    // Sits ontop of the top view controller while the view controller is panning
    // and prevents other ui elements from triggering gestures
    if (_overlayView) {
        return _overlayView;
    }
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectOffset(self.view.frame, 0, 0)];
    _overlayView = view;
    view.backgroundColor = [UIColor clearColor];
    view.frame = CGRectMake(0, 0, view.frame.size.width, view.frame.size.height - self.topViewOffsetY);
    [self.containerView addSubview:_overlayView];
    [self.containerView sendSubviewToBack:_overlayView];
    
    return view;
}

- (void)setTopViewController:(UIViewController *)topViewController
{
    CGRect frame = self.containerView.frame;
    [topViewController.view removeFromSuperview];
    [topViewController willMoveToParentViewController:nil];
    [topViewController removeFromParentViewController];
    
    self->_topViewController = topViewController;
    [self.containerView addSubview:topViewController.view];
    [self addChildViewController:topViewController];
    [topViewController didMoveToParentViewController:self];
    
    topViewController.view.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
    [self viewHasShadow:(self.shadowOpacity == 0 ? NO : YES) withColor:self.shadowColor withCornerRadius:self.cornerRadius withShadowOffsetX:self.shadowOffsetX withShadowOffsetY:self.shadowOffsetY andOpacity:self.shadowOpacity];
    [self addGestures];
    [self.view endEditing:YES];
}

- (void)viewHasShadow:(BOOL)hasShadow withColor:(UIColor *)color withCornerRadius:(CGFloat)cornerRadius withShadowOffsetX:(CGFloat)shadowOffsetX withShadowOffsetY:(CGFloat)shadowOffsetY andOpacity:(CGFloat)opacity
{
    self.topViewController.view.layer.opaque = NO;
    self.topViewController.view.layer.cornerRadius = cornerRadius;
    
    if (hasShadow) {
        self.containerView.layer.shouldRasterize = YES;
        self.containerView.layer.rasterizationScale = [[UIScreen mainScreen] scale];
        self.containerView.layer.shadowOpacity = opacity;
        self.containerView.layer.shadowOffset = CGSizeMake(shadowOffsetX, shadowOffsetY);
        self.containerView.layer.shadowColor = color.CGColor;
        self.containerView.layer.shadowRadius = cornerRadius;
        self.containerView.alpha = 1;
    } else {
        self.containerView.alpha = 0;
    }
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
    [self.view bringSubviewToFront:self.containerView];
    if (self.showingLeft && self.containerView.frame.origin.x == self.peakAmount) {
        [self snapToOrigin];
    } else {
        CGFloat xPos = self.peakAmount;
        [UIView animateWithDuration:self.animationDuration delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            self.containerView.frame = CGRectMake(xPos, self.topViewOffsetY, self.view.frame.size.width, self.view.frame.size.height - self.topViewOffsetY);
        } completion:^(BOOL finished) {
            self.showingLeft = YES;
            [self switchGestureTargetFromView:self.topViewController.view toView:self.overlayView];
            [self didFinishSliding];
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
    [self.view bringSubviewToFront:self.containerView];
    if (self.showingRight && self.containerView.frame.origin.x == 0 - self.peakAmount) {
        [self snapToOrigin];
    } else {
        CGFloat xPos = 0 - self.peakAmount;
        [UIView animateWithDuration:self.animationDuration delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            self.containerView.frame = CGRectMake(xPos, self.topViewOffsetY, self.view.frame.size.width, self.view.frame.size.height - self.topViewOffsetY);
        } completion:^(BOOL finished) {
            self.showingRight = YES;
            [self switchGestureTargetFromView:self.topViewController.view toView:self.overlayView];
            [self didFinishSliding];
        }];
    }
}

- (void)switchGestureTargetFromView:(UIView *)fromView toView:(UIView *)toView
{
    [fromView removeGestureRecognizer:self.panGesture];
    [toView removeGestureRecognizer:self.panGesture];
    [fromView removeGestureRecognizer:self.tapGesture];
    [toView removeGestureRecognizer:self.tapGesture];
    if (toView == self.overlayView) {
        [toView addGestureRecognizer:self.tapGesture];
        [self.containerView bringSubviewToFront:self.overlayView];
    } else {
        [self.containerView sendSubviewToBack:self.overlayView];
    }
    [toView addGestureRecognizer:self.panGesture];
}

- (void)snapToOrigin
{
    self.showingLeft = NO;
    self.showingRight = NO;
    [UIView animateWithDuration:self.animationDuration / 2 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        CGRect frame = CGRectMake(0, self.topViewOffsetY, self.view.frame.size.width, self.view.frame.size.height - self.topViewOffsetY);
        self.containerView.frame = frame;
    } completion:^(BOOL finished) {
        [self switchGestureTargetFromView:self.overlayView toView:self.topViewController.view];
        [self removeTapGestures];
        [self didFinishSliding];
    }];
}

#pragma mark -
#pragma mark UIGestureRecognizers

- (void)addGestures
{
    if (!self->_panGesture) {
        self.panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(dragView:)];
        self.panGesture.delegate = self;
    }
    if (!self->_tapGesture) {
        self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapClose:)];
    }
    [self switchGestureTargetFromView:self.overlayView toView:self.topViewController.view];
}

- (void)attachTapGesture
{
    [self removeTapGestures];
    [self.topViewController.view addGestureRecognizer:self.tapGesture];
}

- (void)removeTapGestures
{
    [self.topViewController.view removeGestureRecognizer:self.tapGesture];
}

- (void)dragView:(id)sender
{
    if (!self.enabled) {
        return;
    }
    [[[(UITapGestureRecognizer*)sender view] layer] removeAllAnimations];
    UIView *senderView = self.containerView;
    CGPoint translatedPoint = [(UIPanGestureRecognizer*)sender translationInView:self.view];
    CGPoint velocity = [(UIPanGestureRecognizer*)sender velocityInView:senderView];
    CGFloat topLeftX = senderView.frame.origin.x;
    
    if ([(UIPanGestureRecognizer*)sender state] == UIGestureRecognizerStateBegan) {
        [self.topViewController.view endEditing:YES];
        
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
        //        self.overlayView.center = newCenter;
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

- (void)changeTopViewControllerFromStoryboard:(NSString *)identifier
{
    [self changeTopViewControllerFromStoryboard:identifier forceReload:NO];
}

- (void)changeTopViewControllerFromStoryboard:(NSString *)identifier forceReload:(BOOL)forceReload
{
    [self changeTopViewController:[self.storyboard instantiateViewControllerWithIdentifier:identifier] forceReload:forceReload];
}

- (void)changeTopViewController:(UIViewController *)viewController
{
    [self changeTopViewController:viewController forceReload:NO];
}

- (void)changeTopViewController:(UIViewController *)viewController forceReload:(BOOL)forceReload
{
    BOOL replaceView = YES;
    if (viewController.storyboard && [viewController.restorationIdentifier isEqualToString:self.topViewController.restorationIdentifier] && !forceReload) {
        replaceView = NO;
        if (!self.animateOnClose) {
            [self snapToOrigin];
            return;
        }
    }
    if (replaceView) {
        [self willChangeTopViewController];
    }
    
    CGFloat xPos = self.view.frame.size.width + 10;
    if (self.showingRight) {
        xPos = xPos * -1;
    }
    
    CGRect frame = CGRectMake(xPos, self.topViewOffsetY, self.view.frame.size.width, self.view.frame.size.height - self.topViewOffsetY);
    [UIView animateWithDuration:self.animationDuration delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        self.containerView.frame = frame;
    } completion:^(BOOL finished) {
        if (replaceView) {
            // Remove existing top view controller from view
            [self.topViewController.view removeFromSuperview];
            [self.topViewController willMoveToParentViewController:nil];
            [self.topViewController removeFromParentViewController];
            
            // Replace with new view controller
            self.topViewController = viewController;
            self.topViewController.view.frame = CGRectMake(0, 0, self.containerView.frame.size.width, self.containerView.frame.size.height);
            [self didChangeTopViewController];
        }
        [self snapToOrigin];
    }];
}

#pragma mark -
#pragma mark Events
- (void)didChangeTopViewController
{}

- (void)willChangeTopViewController
{}

- (void)didFinishSliding
{}

@end
