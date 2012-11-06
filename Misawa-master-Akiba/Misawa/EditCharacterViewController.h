//
//  EditFaceViewController.h
//  Misawa
//
//  Created by cyberagent on 2012/11/02.
//  Copyright (c) 2012年 前川 裕一. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EditFaceViewController.h"
#import <AWSiOSSDK/S3/AmazonS3Client.h>

typedef enum {
    GrandCentralDispatch,
    Delegate,
    BackgroundThread
} UploadType;


@protocol editCharacterViewControllerDelegate;

@interface EditCharacterViewController : UIViewController<AmazonServiceRequestDelegate>
{
    IBOutlet UIScrollView *editCharacterScrollView;
    IBOutlet UIToolbar *editCharacterToolBar;
    IBOutlet UIBarButtonItem *cameraBtn;
    IBOutlet UIBarButtonItem *shareBtn;
    IBOutlet UIButton *moji1Btn;
    IBOutlet UIButton *moji2Btn;
    IBOutlet UIButton *moji3Btn;
    IBOutlet UIButton *moji4Btn;
    IBOutlet UIButton *moji5Btn;
    
    UploadType _uploadType;
    
    id <editCharacterViewControllerDelegate> delegate;
}

@property(retain, nonatomic)id <editCharacterViewControllerDelegate> delegate;
@property (retain, nonatomic) UIImageView *imageView;
@property (nonatomic, retain) AmazonS3Client *s3;

-(id)initWithImage:(UIImage*)image;
- (IBAction)cameraOn:(id)sender;
- (IBAction)shareImage:(id)sender;
- (IBAction)cancelEdit:(id)sender;
- (IBAction)setMojiMisawa1:(id)sender;
- (IBAction)setMojiMisawa2:(id)sender;
- (IBAction)setMojiMisawa3:(id)sender;
- (IBAction)setMojiMisawa4:(id)sender;
- (IBAction)setMojiMisawa5:(id)sender;

@end

@protocol editCharacterViewControllerDelegate
@optional
-(void)uploadPhotoToS3:(UIImage *)picture;
-(void)cameraOnMethod;
-(void)setTabBarIndex0;
-(void)addEditFaceViewController;
@end