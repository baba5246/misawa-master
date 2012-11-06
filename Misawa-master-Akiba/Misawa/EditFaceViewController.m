//
//  EditFaceViewController.m
//  Misawa
//
//  Created by cyberagent on 2012/11/02.
//  Copyright (c) 2012年 前川 裕一. All rights reserved.
//

#import "EditFaceViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "NopperaEffect.h"
#import "MisawaEffect.h"
#import "DragonBallEffect.h"
#import "KonanEffect.h"
#import "EditCharacterViewController.h"

@interface EditFaceViewController ()
{
    bool cameraOnFlag;
    bool cancelFlag;
    UIAlertView *alert;
    
    NopperaEffect *nopperaEffect;
    UIImage *nopperaEffectedImage;
    UIImage *misawaEffectedImage;
    UIImage *dragonBallEffectedImage;
    UIImage *konanEffectedImage;
    NSUserDefaults *userDefault;
}
@end

@implementation EditFaceViewController

@synthesize delegate, cameraImage;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithImage:(UIImage*)image {
    self = [super init];
    if (self) {
        
        UIView *naviView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 50)];
        [naviView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"bar_face_detect"]]];
        [self.view addSubview:naviView];
        
        imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 50, 320, 320)];
        imageView.image = image;
        [self.view addSubview:imageView];
        
        UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [cancelBtn addTarget:self action:@selector(editCancel)
                                  forControlEvents:UIControlEventTouchUpInside];
        [cancelBtn setImage:[UIImage imageNamed:@"cancel@2x.png"] forState:UIControlStateNormal];
        
        cancelBtn.frame = CGRectMake(10, 5, 35, 35);
        [naviView addSubview:cancelBtn];
        
        UIButton *doneBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [doneBtn setImage:[UIImage imageNamed:@"done@2x.png"] forState:UIControlStateNormal];
        [doneBtn addTarget:self action:@selector(editDone) forControlEvents:UIControlEventTouchUpInside];
        doneBtn.frame = CGRectMake(275, 5, 35, 35);
        [naviView addSubview:doneBtn];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    cameraOnFlag = NO;
    cancelFlag = NO;

    self.view.backgroundColor = [UIColor whiteColor];

    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 370, 320, 90)];
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = scrollView.bounds;
    gradient.colors = [NSArray arrayWithObjects:(id)[UIColor whiteColor].CGColor,
                                                (id)[UIColor grayColor].CGColor, nil];
    [scrollView.layer insertSublayer:gradient atIndex:0];
    [self.view addSubview:scrollView];
    
    UILabel *labels[3];
    UIButton *btn[3];
    for (int i = 0; i < 3; i++) {
        btn[i] = [UIButton buttonWithType:UIButtonTypeCustom];
        btn[i].frame = CGRectMake(85*i+40, 375, 70, 70);

        labels[i] = [[UILabel alloc]init];
        labels[i].frame = CGRectMake(85*i+40, 450, 70, 10);
        labels[i].backgroundColor = [UIColor clearColor];
        labels[i].textColor = [UIColor whiteColor];
        labels[i].font = [UIFont fontWithName:@"Arial Rounded MT Bold" size:10];
        labels[i].textAlignment = UITextAlignmentCenter;
        
        NSString *str = [NSString stringWithFormat:@"%@%d%@", @"faceicon", i + 1, @".png"];
        [btn[i] setImage:[UIImage imageNamed:str] forState:UIControlStateNormal];
        switch (i) {
            case 0:
                [btn[i] addTarget:self action:@selector(effectMsw)
                                       forControlEvents:UIControlEventTouchUpInside];
                labels[i].text = @"ミサワ";
                break;
            case 1:
                [btn[i] addTarget:self action:@selector(effectDB) forControlEvents:UIControlEventTouchUpInside];
                labels[i].text = @"サイヤ人";
                break;
            case 2:
                [btn[i] addTarget:self action:@selector(effectKonan) forControlEvents:UIControlEventTouchUpInside];
                labels[i].text = @"コナン";
                break;
            default:
                break;
        }
        
        [self.view addSubview:btn[i]];
        [self.view addSubview:labels[i]];
        NSLog(@"%d;:", i);
    }

    alert = [[UIAlertView alloc] initWithTitle:@"Processing"
                                 message:@"Please wait ..." delegate:self
                                 cancelButtonTitle:nil otherButtonTitles:nil, nil];
    [alert show];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (nopperaEffectedImage == NULL)
    {
        nopperaEffect = [[NopperaEffect alloc] init];
        nopperaEffectedImage = [nopperaEffect createNopperaBoEffect:imageView.image];
    }
    
    if ([alert isVisible]) [alert dismissWithClickedButtonIndex:0 animated:NO];
}

- (void) editCancel {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) editDone {
    EditCharacterViewController *editCharViewController = [[EditCharacterViewController alloc] initWithImage:imageView.image];
    [self.navigationController pushViewController:editCharViewController animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void) effectMsw {
    [self doMisawaEffect:nil];
}

- (void) effectDB {
    [self doDragonBallEffect:nil];
}

- (void) effectKonan {
    [self doKonanEffect:nil];
}

- (void)doMisawaEffect:(id)sender
{
    if (misawaEffectedImage == NULL)
    {
        MisawaEffect *misawaEffect = [[MisawaEffect alloc] init];
        CGPoint graPos = [[[nopperaEffect getProperties] objectAtIndex:4] CGPointValue];
        misawaEffectedImage = [misawaEffect createMisawaEffect:nopperaEffectedImage
                                            maskedImage:[nopperaEffect getMaskedImage]
                                            GravityPos:graPos];
        [imageView setImage:misawaEffectedImage];
    }
    else
    {
        [imageView setImage:misawaEffectedImage];
    }
}

- (void)doDragonBallEffect:(id)sender
{
    if (dragonBallEffectedImage == NULL)
    {
        DragonBallEffect *dragonBallEffect = [[DragonBallEffect alloc] init];
        dragonBallEffectedImage = [dragonBallEffect createDragonBallEffect:nopperaEffectedImage
                                                                properties:[nopperaEffect getProperties]];
        [imageView setImage:dragonBallEffectedImage];
    }
    else
    {
        [imageView setImage:dragonBallEffectedImage];
    }

}

- (void)doKonanEffect:(id)sender
{
    if (konanEffectedImage == NULL)
    {
        KonanEffect *konanEffect = [[KonanEffect alloc] init];
        konanEffectedImage = [konanEffect createKonanEffect:nopperaEffectedImage
                                                      properties:[nopperaEffect getProperties]];
        [imageView setImage:konanEffectedImage];
    }
    else
    {
        [imageView setImage:konanEffectedImage];
    }
    
}

-(void)initializeLocalInstance
{
    misawaEffectedImage = NULL;
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"effectedImage"];
}

@end