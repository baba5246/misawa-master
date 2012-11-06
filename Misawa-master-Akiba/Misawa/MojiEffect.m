//
//  MojiEffect.m
//  Misawa
//
//  Created by cyberagent on 2012/11/04.
//  Copyright (c) 2012年 前川 裕一. All rights reserved.
//

#import "MojiEffect.h"

@implementation MojiEffect

// 文字セリフ画像を合成する /////////////////////////////////////////////////////////////////////////////////
- (UIImage *)createMojiEffect:(UIImage *) originalImage :(int) selector
{
    CGFloat width = originalImage.size.width;
    CGFloat height = originalImage.size.height;

    UIImage *mojiImage = [[UIImage alloc] init];

    switch (selector) {
        case 1:
            mojiImage = [UIImage imageNamed:@"example1.png"];
            break;
        case 2:
            mojiImage = [UIImage imageNamed:@"example2.png"];
            break;
        case 3:
            mojiImage = [UIImage imageNamed:@"example3.png"];
            break;
        case 4:
            mojiImage = [UIImage imageNamed:@"example4.png"];
            break;
        case 5:
            mojiImage = [UIImage imageNamed:@"example5.png"];
            break;
        default:
            mojiImage = NULL;
            break;
    }

    // 文字画像を合成する
    unsigned char *bitmap = malloc(width * height * sizeof(unsigned char) * 4);
    CGContextRef bitmapContext = CGBitmapContextCreate(bitmap, width, height, 8, width*4,
                                                       CGColorSpaceCreateDeviceRGB(),
                                                       kCGImageAlphaPremultipliedFirst);
    // imgAをbitmapContextに描画
    CGContextDrawImage(bitmapContext, CGRectMake(0, 0, width, height), originalImage.CGImage);
    // imgBをimgAの隣に描画
    CGContextDrawImage(bitmapContext, CGRectMake(0, 0, mojiImage.size.width, mojiImage.size.height),
                       mojiImage.CGImage);
    // CGContextからCGImageを作成
    CGImageRef imageWithMoji1Ref = CGBitmapContextCreateImage (bitmapContext);
    // CGImageからUIImageを作成
    originalImage = [UIImage imageWithCGImage:imageWithMoji1Ref];
    // bitmapを解放
    free(bitmap);
    
    // 結果を返す
    NSLog(@"image::%@", originalImage);

    return originalImage;
}

@end
