//
//  CameraViewController.m
//  misawa
//
//  Created by Shinya Akiba on 12/11/02.
//  Copyright (c) 2012年 Shinya Akiba. All rights reserved.
//

#import "CameraViewController.h"
#import "PickerController.h"
#import "HttpClient.h"
#import "EditFaceViewController.h"

@interface CameraViewController ()
{
    UIImageView *imageView;
    NSString *uniqueString;
}
@end

@implementation CameraViewController

@synthesize cameraViewDelegate;

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
	// Do any additional setup after loading the view.
    imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 300, 350)];
    imageView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:imageView];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setLocale:[NSLocale systemLocale]];       // コレと
    [formatter setTimeZone:[NSTimeZone systemTimeZone]]; // コレ
    [formatter setDateFormat:@"yyyy-MM-dd-hh-mm-ss"];

    NSString* dateString = [formatter stringFromDate:[NSDate date]];
    NSLog(@"date:%@", dateString);
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    uniqueString = [NSString stringWithFormat:@"%@%@", [defaults objectForKey:@"uuID"], dateString];
}

- (void) showCameraView {
    //    UIImagePickerController *pickerController;
    //    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
    
    //使用可能かどうか調べる。
    if (![UIImagePickerController isSourceTypeAvailable:sourceType]) {
        return;
    }
    
    PickerController *imagePicker = [[PickerController alloc] init];
    imagePicker.sourceType = sourceType;
    imagePicker.allowsEditing = YES;
    [imagePicker setDelegate:(id)self];
    // イメージピッカーを表示する
    //カメラ連続表示
    //twitterのoAuth
    //画像の非同期表示
    //タイムテーブルの非同期表示
    [self presentModalViewController:imagePicker animated:YES];
}

- (void)imagePickerController:(UIImagePickerController*)picker
        didFinishPickingImage:(UIImage*)image
                  editingInfo:(NSDictionary*)editingInfo
{
    NSURL* referenceURL = [editingInfo objectForKey:UIImagePickerControllerReferenceURL];
    NSLog(@"referenceURL:%@", referenceURL);
    NSLog(@"picker:%@", picker);
    NSLog(@"image:%@", image);
    NSLog(@"editingInfo:%@", editingInfo);

    CGSize  size = { 320, 320 };
    UIGraphicsBeginImageContext(size);

    // 画像を縮小して描画する
    CGRect  rect;
    rect.origin = CGPointZero;
    rect.size = size;
    [image drawInRect:rect];

    // 描画した画像を取得する
    UIImage* shrinkedImage;
    shrinkedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    imageView.image = shrinkedImage;
    //  ここで、モーダルビューを閉じて、RatingViewControllerを呼び出す。
    [self dismissModalViewControllerAnimated:YES];
    [self viewDidAppear:YES];
}

- (void) viewDidAppear:(BOOL)animated {
    NSLog(@"cameraViewController:%s:", __func__);
    if (imageView.image) {
        [self moveToEditFaceViewController];
    }
    else [self.tabBarController setSelectedIndex:0];
}

- (void) moveToEditFaceViewController {
    EditFaceViewController *editFaceViewController = [[EditFaceViewController alloc] initWithImage:imageView.image];
    imageView.image = nil;
    [cameraViewDelegate performSelector:@selector(push:) withObject:editFaceViewController];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end