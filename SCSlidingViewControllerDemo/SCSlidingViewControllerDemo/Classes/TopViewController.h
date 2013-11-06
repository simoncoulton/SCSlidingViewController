//
//  TopViewController.h
//  SCSlidingViewControllerDemo
//
//  Created by Simon Coulton on 6/11/2013.
//  Copyright (c) 2013 Simon Coulton. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SCSlidingViewController.h"

@interface TopViewController : UIViewController

@property (nonatomic, strong) IBOutlet UISlider *peakThresholdValue;
@property (nonatomic, strong) IBOutlet UISlider *peakAmountValue;
@property (nonatomic, strong) IBOutlet UISwitch *allowOverswipeValue;

- (IBAction)toggleLeftButtonClicked:(id)sender;
- (IBAction)toggleRightButtonClicked:(id)sender;
- (IBAction)peakAmountSliderChanged:(UISlider *)sender;
- (IBAction)peakThresholdSliderChanged:(UISlider *)sender;
- (IBAction)allowOverswipeToggleChanged:(UISwitch *)sender;

@end
