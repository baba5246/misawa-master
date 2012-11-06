//
//  DetailViewController.m
//  Misawa
//
//  Created by Shinya Akiba on 12/11/06.
//  Copyright (c) 2012年 Shinya Akiba. All rights reserved.
//

#import "DetailViewController.h"

@interface DetailViewController ()

@end

@implementation DetailViewController

@synthesize detailImage;

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
    UIView *naviView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 45)];
    naviView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bar.png"]];
    [self.view addSubview:naviView];
    
    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancelBtn addTarget:self action:@selector(backToTable) forControlEvents:UIControlEventTouchUpInside];
    [cancelBtn setImage:[UIImage imageNamed:@"cancel.png"] forState:UIControlStateNormal];
    cancelBtn.frame = CGRectMake(10, 10, 70, 25);
    [naviView addSubview:cancelBtn];
    
	// Do any additional setup after loading the view.
    UIImageView *detailImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 60, 300, 300)];
    [detailImageView setImage:detailImage];
    [self.view addSubview:detailImageView];
    
    NSLog(@"DetailViewController_viewDidLoad");
}

- (void) backToTable {
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
