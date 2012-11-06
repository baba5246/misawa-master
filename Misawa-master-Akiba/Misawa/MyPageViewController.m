//
//  MyPageViewController.m
//  misawa
//
//  Created by Shinya Akiba on 12/11/02.
//  Copyright (c) 2012年 Shinya Akiba. All rights reserved.
//

#import "MyPageViewController.h"
#import "LoginViewController.h"

@interface MyPageViewController ()

@end

@implementation MyPageViewController

@synthesize MyPageDelegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIButton *btnLogout = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [btnLogout setTitle:@"logout" forState:UIControlStateNormal];
    [btnLogout addTarget:self action:@selector(logout) forControlEvents:UIControlEventTouchUpInside];
    btnLogout.frame = CGRectMake(40, 150, 200, 50);
    [self.view addSubview:btnLogout];
	// Do any additional setup after loading the view.
    
    
    NSLog(@"MyPageViewController_viewDidLoad");
}

- (void)logout {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:@"user_name"];
    [defaults removeObjectForKey:@"uuID"];
    [defaults setObject:@"NO" forKey:@"isLogined"];
    [defaults synchronize];
    
    LoginViewController *loginViewController = [[LoginViewController alloc] init];
    [UIApplication sharedApplication].keyWindow.rootViewController = loginViewController;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
