//
//  EditFaceViewController.h
//  Misawa
//
//  Created by cyberagent on 2012/11/02.
//  Copyright (c) 2012年 前川 裕一. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol editFaceViewControllerDelegate;

@interface EditFaceViewController : UIViewController
{
    NSData *imageData;
    UIImageView *imageView;
    IBOutlet UIBarButtonItem *cameraBtn;
    IBOutlet UIScrollView *editFaceScrollView;
    IBOutlet UIToolbar *editFaceToolBar;
    IBOutlet UIButton *misawaBtn;
    
    IBOutlet UIButton *dragonBollBtn;
    id <editFaceViewControllerDelegate> delegate;
}

@property(retain, nonatomic)id <editFaceViewControllerDelegate> delegate;
@property (nonatomic, retain) UIImage *cameraImage;

-(id)initWithImage:(UIImage*)image;
-(void)setImageOfImageView:(UIImage *)image;
-(IBAction)cameraOn:(id)sender;
-(IBAction)saveEditFace:(id)sender;
-(IBAction)cancelEdit:(id)sender;
- (IBAction)doMisawaEffect:(id)sender;
- (IBAction)doDragonBallEffect:(id)sender;
- (IBAction)doKonanEffect:(id)sender;
@end

@protocol editFaceViewControllerDelegate
-(void)uploadPhotoToS3:(UIImage *)picture;
-(void)cameraOnMethod;
-(void)setTabBarIndex0;
-(void)addEditCharacterView;
@end
