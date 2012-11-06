//
//  TimeLineViewController.m
//  misawa
//
//  Created by Shinya Akiba on 12/11/02.
//  Copyright (c) 2012年 Shinya Akiba. All rights reserved.
//

#import "TimeLineViewController.h"
#import "DetailViewController.h"

@interface TimeLineViewController ()

@end

@implementation TimeLineViewController

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
    NSLog(@"TimeLineViewController_viewDidLoad");

    table = [[TimeLineTableView alloc] initWithFrame:CGRectMake(0, 0, 320, 400) style:UITableViewStyleGrouped];
    table.timeLineDelegate = self;
    [self.view addSubview:table];
	// Do any additional setup after loading the view.
    [table mainTableLoad];
    
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSLog(@"TimeLineViewController_viewWillAppear");
}

- (void) pushToDetailView:(UIImage*)image
{
    DetailViewController *detailViewController = [[DetailViewController alloc] init];
    detailViewController.detailImage = image;
    [self.navigationController pushViewController:detailViewController animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end