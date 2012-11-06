//
//  MisawaEffect.h
//  Misawa
//
//  Created by cyberagent on 2012/11/04.
//  Copyright (c) 2012年 前川 裕一. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreImage/CoreImage.h>
#import <QuartzCore/QuartzCore.h>
#import <Foundation/Foundation.h>

@interface MisawaEffect : NSObject

- (UIImage *) createMisawaEffect:(UIImage *)originalImage
                     maskedImage:(UIImage *)maskedImage
                      GravityPos:(CGPoint)gravityPos;

@end