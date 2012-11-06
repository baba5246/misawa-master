//
//  TabBarController.m
//  Misawa
//
//  Created by Shinya Akiba on 12/11/02.
//  Copyright (c) 2012年 Shinya Akiba. All rights reserved.
//

#import "TabBarController.h"
#import "MyPageViewController.h"
#import "TimeLineViewController.h"
#import "CameraViewController.h"
#import "PickerController.h"

@interface TabBarController ()
{
    CameraViewController *cameraViewController;
    BOOL isPicked;
}
@end

@implementation TabBarController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        isPicked = NO;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.

    TimeLineViewController *timeLineViewController = [[TimeLineViewController alloc] init];
    timeLineViewController.tabBarItem = [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemTopRated tag:0];
    timeLineViewController.tabBarItem.title = @"Time Line";
    
    cameraViewController = [[CameraViewController alloc] init];
    cameraViewController.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"camera" image:[UIImage imageNamed:@"camera.png"] tag:1];

    MyPageViewController *myPageViewController = [[MyPageViewController alloc] init];
    myPageViewController.tabBarItem = [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemMore tag:2];

    NSArray *views = [NSArray arrayWithObjects:timeLineViewController, cameraViewController, myPageViewController ,nil];
    [self setViewControllers:views animated:NO];
    self.tabBarItem.title = @"ttt";
}

- (void) isPicked {
    isPicked = YES;
    if (isPicked) {
        NSLog(@"yes");
    } else {
        NSLog(@"no");
    }
}

- (void) push:(UIViewController*)controller {
    [self.navigationController pushViewController:controller animated:YES];
}

-(void)tabBarController:(UITabBarController*)tabBarController didSelectViewController:(UIViewController*)viewController
{
    NSLog(@"tab:%@", tabBarController);
    NSLog(@"view:%@", viewController);
}

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
    NSLog(@"tabBar:%@", item.title);
    NSLog(@"item:%d", item.tag);
    if (item.tag == 1 && !isPicked) {
        cameraViewController.cameraViewDelegate = self;
        [cameraViewController showCameraView];
    } else if (item.tag == 1 && isPicked) {

    } else if (isPicked){
        [self confirmAlert:@"写真を破棄しますか？"];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSLog(@"ok:%d", buttonIndex);
    cameraViewController = nil;
//  [cameraViewController removeFromParentViewController];
    isPicked = NO;
}

// Called when we cancel a view (eg. the user clicks the Home button). This is not called when the user clicks the cancel button.
// If not defined in the delegate, we simulate a click in the cancel button
- (void)alertViewCancel:(UIAlertView *)alertView{
    NSLog(@"cancel:%@", alertView);
}

- (void) confirmAlert:(NSString*)string {
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:@""
                          message:string
                          delegate:self
                          cancelButtonTitle:@"Cancel"
                          otherButtonTitles:@"OK", nil];
    [alert show];
}

- (void)tabBar:(UITabBar *)tabBar willBeginCustomizingItems:(NSArray *)items{
    NSLog(@"begin");
}

- (void)tabBar:(UITabBar *)tabBar willEndCustomizingItems:(NSArray *)items changed:(BOOL)changed{
    NSLog(@"end");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
