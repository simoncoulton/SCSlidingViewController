//
//  MenuViewController.m
//  SCSlidingViewControllerDemo
//
//  Created by Simon Coulton on 6/11/2013.
//  Copyright (c) 2013 Simon Coulton. All rights reserved.
//

#import "MenuViewController.h"

@implementation MenuViewController

- (IBAction)showViewControllerButtonClicked:(id)sender
{
    NSString *viewControllerName = ((UIButton *)sender).titleLabel.text;
    [self.slidingViewController changeTopViewController:[self.storyboard instantiateViewControllerWithIdentifier:viewControllerName]];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleDefault;
}

@end
