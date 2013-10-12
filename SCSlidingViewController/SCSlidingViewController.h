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
@property (nonatomic) int topViewOffsetY;
@property (nonatomic) int peakAmount;
@property (nonatomic) CGFloat cornerRadius;
@property (nonatomic) CGFloat shadowOpacity;
@property (nonatomic) CGFloat shadowOffsetX;
@property (nonatomic) CGFloat shadowOffsetY;
@property (retain, nonatomic) UIColor *shadowColor;
@property (nonatomic) CGFloat animationDuration;

#pragma mark Animations
- (void)slideRight;
- (void)slideLeft;
- (void)snapToOrigin;

#pragma mark Change view
- (void)changeTopViewController:(UIViewController *)viewController;

#pragma mark Change view events
- (void)willChangeTopViewController;
- (void)didChangeTopViewController;


@end


@interface UIViewController(SlidingViewCategory)

- (SCSlidingViewController *)slidingViewController;
- (void)viewHasShadow:(BOOL)hasShadow withColor:(UIColor *)color withCornerRadius:(CGFloat)cornerRadius withShadowOffsetX:(CGFloat)shadowOffsetX withShadowOffsetY:(CGFloat)shadowOffsetY andOpacity:(CGFloat)opacity;

@end
