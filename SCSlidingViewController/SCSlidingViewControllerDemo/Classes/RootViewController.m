//
//  RootViewController.m
//  SCSlidingViewControllerDemo
//
//  Created by Simon Coulton on 6/11/2013.
//  Copyright (c) 2013 Simon Coulton. All rights reserved.
//

#import "RootViewController.h"

@implementation RootViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.peakAmount = 250;
    self.topViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"TopViewController"];
    self.leftSideViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"LeftViewController"];
    self.rightSideViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"RightViewController"];
}

@end
