//
//  NopperaEffect.h
//  Misawa
//
//  Created by cyberagent on 2012/11/06.
//  Copyright (c) 2012年 Shinya Akiba. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NopperaEffect : NSObject
{
    UIImage *maskedFaceImage;
    NSMutableArray *properties;
    
}

- (UIImage *)getMaskedImage;
- (NSMutableArray *)getProperties;
- (UIImage *)createNopperaBoEffect:(UIImage *)originalImage;

@end