# SCSlidingViewController

After seeing the following Dribbble shot, I figured it was probably the best solution for the sliding view controller on iOS7.

![Dribble](http://dribbble.s3.amazonaws.com/users/14827/screenshots/1193991/8.png "Dribble")

SCSlidingViewController allows you to set one (or two) view controllers to be full height on iOS7 so that the color behind the statusbar can be controlled, while the top view sits below the status bar as per iOS6.

## Usage

In your `RootViewController.m`, do the following to instantiate the left and right (either can be omitted) sides.

	#import "RootViewController.h"
	#import "TopViewController.h"
	#import "MenuViewController.h"
	
	@interface RootViewController () <SCSlidingViewControllerDelegate>
	
	@end
	
	@implementation RootViewController
	
	
	- (void)viewDidLoad
	{
	    // Initial view controller, setup the views to be used.
	    [super viewDidLoad];
	    self.topViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"Top"];
	    self.leftSideViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"Menu"];
	    self.rightSideViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"Context"];
	}
	
	@end

In your `RootViewController.h` file, make sure you subclass SCSlidingViewController

	#import <UIKit/UIKit.h>
	#import "SCSlidingViewController.h"
	
	@interface RootViewController : SCSlidingViewController
	
	@end

From any of your other view controllers, when you want to change the topViewController, simply call:

	[self.slidingViewController changeTopViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"YOUR VIEW CONTROLLER NAME"]];
	
### Customizing the top view

The following are exposed (and should be straight forward in terms of functionality).

	@property (nonatomic) int topViewOffsetY;
	@property (nonatomic) int peakAmount;
	@property (nonatomic) CGFloat cornerRadius;
	@property (nonatomic) CGFloat shadowOpacity;
	@property (nonatomic) CGFloat shadowOffsetX;
	@property (nonatomic) CGFloat shadowOffsetY;
	@property (retain, nonatomic) UIColor *shadowColor;
	@property (nonatomic) CGFloat animationDuration;

### Events

The following events are called when the top view is changed (but are not triggered via self.topViewController modifications).

	- (void)willChangeTopViewController;
	- (void)didChangeTopViewController;

	
## Todo

1. Be able to prevent the overswipe (displaying the left side, then swiping far enough to see the right and the reverse)
2. Be able to set the status bar text color prior to the relevant side view controller being shown.
3. Test on iOS6, though some small preliminary tests have been done and it seems to work.