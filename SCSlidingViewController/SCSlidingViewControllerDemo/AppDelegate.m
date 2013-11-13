//
//  AppDelegate.m
//  SCSlidingViewControllerDemo
//
//  Created by Simon Coulton on 5/11/2013.
//  Copyright (c) 2013 Simon Coulton. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    // Initialize the storyboard
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Storyboard" bundle:nil];
    // Set the rootViewController
    self.window.rootViewController = [storyboard instantiateInitialViewController];
    // Customise the statusbar text color
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}

@end
