//
//  EditFaceViewController.m
//  Misawa
//
//  Created by cyberagent on 2012/11/02.
//  Copyright (c) 2012年 前川 裕一. All rights reserved.
//

#import "EditCharacterViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "MojiEffect.h"
#import "Constants.h"
#import "ASIFormDataRequest.h"

#define S3_URL @"https://misawa-photoes.s3.amazonaws.com/"

@interface EditCharacterViewController ()
{
    NSString *uniqueString;
    UIAlertView *alert;
    UIImage *effectedImage;
    UIImage *mojiMisawa1Image;
    UIImage *mojiMisawa2Image;
    UIImage *mojiMisawa3Image;
    UIImage *mojiMisawa4Image;
    UIImage *mojiMisawa5Image;
    bool cameraOnFlag;
    bool cancelFlag;
}
@end

@implementation EditCharacterViewController

@synthesize delegate, imageView;
@synthesize s3 = _s3;

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
        UIView *naviView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 45)];
        CAGradientLayer *gradient = [CAGradientLayer layer];
        gradient.frame = naviView.bounds;
        gradient.colors = [NSArray arrayWithObjects:(id)[UIColor blackColor].CGColor,
                           (id)[UIColor whiteColor].CGColor, nil];
        [naviView.layer insertSublayer:gradient atIndex:0];
        [self.view addSubview:naviView];
        
        imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 50, 320, 320)];
        imageView.image = image;
        [self.view addSubview:imageView];
        effectedImage = imageView.image;
        
        UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [cancelBtn addTarget:self action:@selector(editCancel) forControlEvents:UIControlEventTouchUpInside];
        [cancelBtn setImage:[UIImage imageNamed:@"cancel.png"] forState:UIControlStateNormal];
        cancelBtn.frame = CGRectMake(10, 10, 70, 25);
        [naviView addSubview:cancelBtn];
        
        UIButton *upLoadBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [upLoadBtn setImage:[UIImage imageNamed:@"upload.png"] forState:UIControlStateNormal];
        [upLoadBtn addTarget:self action:@selector(upLoad) forControlEvents:UIControlEventTouchUpInside];
        upLoadBtn.frame = CGRectMake(245, 10, 70, 25);
        [naviView addSubview:upLoadBtn];
        
        [self initializeLocalInstance];
    }
    return self;
}

- (void) editCancel {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) editDone {
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    cameraOnFlag = NO;
    cancelFlag = NO;
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    if(![ACCESS_KEY_ID isEqualToString:@"CHANGE ME"]
       && self.s3 == nil)
    {
        self.s3 = [[AmazonS3Client alloc] initWithAccessKey:ACCESS_KEY_ID withSecretKey:SECRET_KEY];
        // Create the picture bucket.
        S3CreateBucketRequest *createBucketRequest = [[S3CreateBucketRequest alloc] initWithName:[Constants pictureBucket]];
        S3CreateBucketResponse *createBucketResponse = [self.s3 createBucket:createBucketRequest];
        if(createBucketResponse.error != nil)
        {
            NSLog(@"Error: %@", createBucketResponse.error);
        }
    }

    //editCharacterScrollView.center = CGPointMake(160, 342);
    //editCharacterToolBar.center = CGPointMake(160, 389);

    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 370, 380, 90)];
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = scrollView.bounds;
    gradient.colors = [NSArray arrayWithObjects:(id)[UIColor whiteColor].CGColor,
                                                (id)[UIColor grayColor].CGColor, nil];
    [scrollView.layer insertSublayer:gradient atIndex:0];
    [scrollView setScrollEnabled:YES];
    [scrollView setShowsHorizontalScrollIndicator:YES];
    [scrollView setContentSize:CGSizeMake(440, scrollView.frame.size.height - 10)];
    
    UIButton *btn[5];
    for (int i = 0; i < 5; i++) {
        btn[i] = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        NSString *str = [NSString stringWithFormat:@"%@%d%@", @"example", i + 1, @".png"];
        [btn[i] setImage:[UIImage imageNamed:str] forState:UIControlStateNormal];
        btn[i].tag = i;
        [btn[i] addTarget:self action:@selector(setMojiMisawa:) forControlEvents:UIControlEventTouchUpInside];
        btn[i].frame = CGRectMake(70*i+10, 5, 70, 70);
        [scrollView addSubview:btn[i]];
    }
    
    [self.view addSubview:scrollView];
    

    // アラート作成
    alert = [[UIAlertView alloc] init];
    alert.delegate = self;
    alert.title = @"Confirmation";
    alert.message = @"Do you discard this image?";
    [alert addButtonWithTitle:@"Yes"];
    [alert addButtonWithTitle:@"No"];

    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setLocale:[NSLocale systemLocale]];       // コレと
    [formatter setTimeZone:[NSTimeZone systemTimeZone]]; // コレ
    [formatter setDateFormat:@"yyyy-MM-dd-hh-mm-ss"];
    
    NSString* dateString = [formatter stringFromDate:[NSDate date]];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    uniqueString = [NSString stringWithFormat:@"%@%@", [defaults objectForKey:@"uuID"], dateString];
}

- (void) upLoad {
    [self uploadPhotoToS3:imageView.image];
}

-(void)uploadPhotoToS3:(UIImage*)image {
    // Convert the image to JPEG data.
    NSData *imageData = UIImageJPEGRepresentation(image, 1.0);
    
    if(_uploadType == GrandCentralDispatch)
    {
        NSLog(@"grandcentraldispatch");
        [self processGrandCentralDispatchUpload:imageData:image];
    }
    else if(_uploadType == Delegate)
    {
        NSLog(@"Delegate");
        [self processDelegateUpload:imageData];
    }
    else if(_uploadType == BackgroundThread)
    {
        NSLog(@"BackgroundThread");
        [self processBackgroundThreadUpload:imageData];
    }
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}

- (void)processBackgroundThreadUpload:(NSData *)imageData
{
    [self performSelectorInBackground:@selector(processBackgroundThreadUploadInBackground:)
                           withObject:imageData];
}

- (void)processBackgroundThreadUploadInBackground:(NSData *)imageData
{
    // Upload image data.  Remember to set the content type.
    //    S3PutObjectRequest *por = [[S3PutObjectRequest alloc] initWithKey:PICTURE_NAME
    //                                                              inBucket:[Constants pictureBucket]];
    S3PutObjectRequest *por = [[S3PutObjectRequest alloc] initWithKey:uniqueString
                                                             inBucket:[Constants pictureBucket]];
    
    por.contentType = @"image/jpeg";
    por.data        = imageData;
    
    // Put the image data into the specified s3 bucket and object.
    S3PutObjectResponse *putObjectResponse = [self.s3 putObject:por];
    [self performSelectorOnMainThread:@selector(showCheckErrorMessage:)
                           withObject:putObjectResponse.error
                        waitUntilDone:NO];
}

- (void)processGrandCentralDispatchUpload:(NSData *)imageData:(UIImage*)image
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        // Upload image data.  Remember to set the content type.
        S3PutObjectRequest *por = [[S3PutObjectRequest alloc] initWithKey:uniqueString
                                                                 inBucket:[Constants pictureBucket]];
        
        por.contentType = @"image/jpeg";
        por.data        = imageData;
        
        // Put the image data into the specified s3 bucket and object.
        S3PutObjectResponse *putObjectResponse = [self.s3 putObject:por];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if(putObjectResponse.error != nil)
            {
                NSLog(@"Error: %@", putObjectResponse.error);
                [self showAlertMessage:[putObjectResponse.error.userInfo objectForKey:@"message"] withTitle:@"Upload Error"];
            }
            else
            {
                [self showAlertMessage:@"The image was successfully uploaded." withTitle:@"Upload Completed"];
                [self postToEC2];
                [self.navigationController popToRootViewControllerAnimated:YES];
            }
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        });
    });
}

- (void)processDelegateUpload:(NSData *)imageData
{
    // Upload image data.  Remember to set the content type.
    S3PutObjectRequest *por = [[S3PutObjectRequest alloc] initWithKey:uniqueString
                                                             inBucket:[Constants pictureBucket]];
    por.contentType = @"image/jpeg";
    por.data = imageData;
    por.delegate = self;
    
    // Put the image data into the specified s3 bucket and object.
    [self.s3 putObject:por];
}

- (void)showAlertMessage:(NSString *)message withTitle:(NSString *)title
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                        message:message
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    [alertView show];
}

-(void)postToEC2
{
    NSLog(@"urlEC2:");
    S3ResponseHeaderOverrides *override = [[S3ResponseHeaderOverrides alloc] init];
    override.contentType = @"image/jpeg";
    
    // Request a pre-signed URL to picture that has been uplaoded.
    S3GetPreSignedURLRequest *gpsur = [[S3GetPreSignedURLRequest alloc] init];
    gpsur.key                     = ACCESS_KEY_ID;
    gpsur.bucket                  = [Constants pictureBucket];
    gpsur.expires                 = [NSDate dateWithTimeIntervalSinceNow:(NSTimeInterval) 3600]; // Added an hour's worth of seconds to the current time.
    gpsur.responseHeaderOverrides = override;
    
//    NSError *error;
//    NSURL *url = [self.s3 getPreSignedURL:gpsur error:&error];

    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:@"http://heavens-misawa.herokuapp.com/api/photo"]];

    NSString *urlForEC2 = [NSString stringWithFormat:@"%@%@", S3_URL, uniqueString];
    NSLog(@"urlEC2:%@", urlForEC2);
    
    [request setPostValue:@"1" forKey:@"user_id"];
    [request setPostValue:urlForEC2 forKey:@"photo_url"];
    
    [request setDelegate:self];
    [request setDidFinishSelector:@selector(requestDone:)];
    [request setDidFailSelector:@selector(requestWentWrong:)];
    [request startAsynchronous];
    // Get the URL
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
/*
- (void)viewDidUnload {
    editCharacterToolBar = nil;
    cameraBtn = nil;
    shareBtn = nil;
    cancelBtn = nil;
    imageView = nil;
    moji1Btn = nil;
    moji2Btn = nil;
    moji3Btn = nil;
    moji4Btn = nil;
    moji5Btn = nil;
    [super viewDidUnload];
}
*/

- (IBAction)cameraOn:(id)sender {
    cameraOnFlag = YES;
    [alert show];
}

- (void)setMojiMisawa:(id)sender {
    UIButton *btn = (UIButton*)sender;
    switch (btn.tag+1) {
        case 1:
            [self setMojiMisawa1:btn];
            break;
        case 2:
            [self setMojiMisawa2:btn];
            break;
        case 3:
            [self setMojiMisawa3:btn];
            break;
        case 4:
            [self setMojiMisawa4:btn];
            break;
        case 5:
            [self setMojiMisawa5:btn];
            break;

        default:
            break;
    }
}


- (void)setMojiMisawa1:(id)sender {
    if (mojiMisawa1Image == NULL)
    {
        MojiEffect *mojiEffect = [[MojiEffect alloc] init];
        mojiMisawa1Image = [mojiEffect createMojiEffect:effectedImage :1];
        [imageView setImage:mojiMisawa1Image];
    }
    else [imageView setImage:mojiMisawa1Image];
}

- (void)setMojiMisawa2:(id)sender {
    if (mojiMisawa2Image == NULL)
    {
        MojiEffect *mojiEffect = [[MojiEffect alloc] init];
        mojiMisawa2Image = [mojiEffect createMojiEffect:effectedImage :2];
        [imageView setImage:mojiMisawa2Image];
    }
    else [imageView setImage:mojiMisawa2Image];
}

- (void)setMojiMisawa3:(id)sender {
    if (mojiMisawa3Image == NULL)
    {
        MojiEffect *mojiEffect = [[MojiEffect alloc] init];
        mojiMisawa3Image = [mojiEffect createMojiEffect:effectedImage :3];
        [imageView setImage:mojiMisawa3Image];
    }
    else [imageView setImage:mojiMisawa3Image];
}

- (void)setMojiMisawa4:(id)sender {
    if (mojiMisawa4Image == NULL)
    {
        MojiEffect *mojiEffect = [[MojiEffect alloc] init];
        mojiMisawa4Image = [mojiEffect createMojiEffect:effectedImage :4];
        [imageView setImage:mojiMisawa4Image];
    }
    else [imageView setImage:mojiMisawa4Image];
}

- (void)setMojiMisawa5:(id)sender {
    if (mojiMisawa5Image == NULL)
    {
        MojiEffect *mojiEffect = [[MojiEffect alloc] init];
        mojiMisawa5Image = [mojiEffect createMojiEffect:effectedImage :5];
        [imageView setImage:mojiMisawa5Image];
    }
    else [imageView setImage:mojiMisawa5Image];
}

-(void)initializeLocalInstance
{
    mojiMisawa1Image = NULL;
    mojiMisawa2Image = NULL;
    mojiMisawa3Image = NULL;
    mojiMisawa4Image = NULL;
    mojiMisawa5Image = NULL;
    
    
    if (!cancelFlag)
    {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"effectedImage"];
        cancelFlag = NO;
    }
}

-(void)alertView:(UIAlertView*)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0://Yesの場合
            if (cameraOnFlag)
            {
                [delegate cameraOnMethod];
                cameraOnFlag = NO;
            }
            [self.view removeFromSuperview];
            [self initializeLocalInstance];
            break;
        case 1://Noの場合
            //何もしない
            break;
    }
}

@end