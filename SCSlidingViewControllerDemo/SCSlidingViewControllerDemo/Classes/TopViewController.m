//
//  TopViewController.m
//  SCSlidingViewControllerDemo
//
//  Created by Simon Coulton on 6/11/2013.
//  Copyright (c) 2013 Simon Coulton. All rights reserved.
//

#import "TopViewController.h"

@implementation TopViewController

- (IBAction)toggleLeftButtonClicked:(id)sender
{
    [self.slidingViewController slideRight];
}

- (IBAction)toggleRightButtonClicked:(id)sender
{
    [self.slidingViewController slideLeft];
}

- (IBAction)peakAmountSliderChanged:(UISlider *)sender
{
    int intValue = roundl(sender.value);
    sender.value = intValue;
    self.slidingViewController.peakAmount = intValue;
}

- (IBAction)peakThresholdSliderChanged:(UISlider *)sender
{
    self.slidingViewController.peakThreshold = sender.value;
}

- (IBAction)allowOverswipeToggleChanged:(UISwitch *)sender
{
    self.slidingViewController.allowOverswipe = sender.isOn;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.peakAmountValue.continuous = NO;
    self.peakThresholdValue.continuous = NO;
}

- (void)viewDidAppear:(BOOL)animated
{
    self.peakAmountValue.value = self.slidingViewController.peakAmount;
    self.peakThresholdValue.value = self.slidingViewController.peakThreshold;
    self.allowOverswipeValue.on = self.slidingViewController.allowOverswipe;
    [super viewDidAppear:animated];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

@end
