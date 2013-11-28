//
//  SCSlidingViewController.h
//
//  Created by Simon Coulton on 11/10/13.
//  Copyright (c) 2013 Simon Coulton. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SCSlidingViewControllerDelegate <NSObject>

@end

@interface SCSlidingViewController : UIViewController

#pragma mark View Controllers
@property (strong, nonatomic) UIViewController *topViewController;
@property (strong, nonatomic) UIViewController *leftSideViewController;
@property (strong, nonatomic) UIViewController *rightSideViewController;

#pragma mark Settings
@property (nonatomic) BOOL allowOverswipe;
@property (nonatomic) BOOL animateOnClose;
@property (nonatomic) int topViewOffsetY;
@property (nonatomic) int peakAmount;
@property (nonatomic) CGFloat peakThreshold;
@property (nonatomic) CGFloat cornerRadius;
@property (nonatomic) CGFloat shadowOpacity;
@property (nonatomic) CGFloat shadowOffsetX;
@property (nonatomic) CGFloat shadowOffsetY;
@property (retain, nonatomic) UIColor *shadowColor;
@property (nonatomic) CGFloat animationDuration;
@property (nonatomic) BOOL enabled;

#pragma mark Visibility
@property (assign, nonatomic) BOOL showingLeft;
@property (assign, nonatomic) BOOL showingRight;

#pragma mark Gestures
@property (strong, nonatomic) UIGestureRecognizer *panGesture;
@property (strong, nonatomic) UIGestureRecognizer *tapGesture;

#pragma mark Animations
- (void)slideRight;
- (void)slideLeft;
- (void)snapToOrigin;

#pragma mark Change view
- (void)changeTopViewController:(UIViewController *)viewController;
- (void)changeTopViewController:(UIViewController *)viewController forceReload:(BOOL)forceReload;
- (void)changeTopViewControllerFromStoryboard:(NSString *)identifier;
- (void)changeTopViewControllerFromStoryboard:(NSString *)identifier forceReload:(BOOL)forceReload;

#pragma mark Change view events
- (void)willChangeTopViewController;
- (void)didChangeTopViewController;

#pragma mark Slide events
- (void)didFinishSliding;

#pragma mark Shadow
- (void)viewHasShadow:(BOOL)hasShadow withColor:(UIColor *)color withCornerRadius:(CGFloat)cornerRadius withShadowOffsetX:(CGFloat)shadowOffsetX withShadowOffsetY:(CGFloat)shadowOffsetY andOpacity:(CGFloat)opacity;

@end


@interface UIViewController(SlidingViewCategory)

- (SCSlidingViewController *)slidingViewController;

@end
