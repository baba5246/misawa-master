//
//  MisawaEffect.m
//  Misawa
//
//  Created by cyberagent on 2012/11/04.
//  Copyright (c) 2012年 前川 裕一. All rights reserved.
//

#import "MisawaEffect.h"

@implementation MisawaEffect

- (UIImage*) createMisawaEffect:(UIImage *)originalImage
                    maskedImage:(UIImage *)maskedImage
                     GravityPos:(CGPoint)gravityPos
{
    //定数宣言
    const CGFloat width = originalImage.size.width;
    const CGFloat height = originalImage.size.height;
    // マスク画像の倍率
    float endRate = 0.5;
    
    // パーツ画像を小さくしながら重ねて描画していく////////////////////////////////////////////////////////////////
    // エフェクト画像UIImage
    UIImage *effectedImage = originalImage;
    // マスク画像の重心位置
    CGPoint tempGravityPos = CGPointMake(0, 0);
    
    // 切り抜き画像のリサイズ -----------------------------------------------------------
    CGSize sz = CGSizeMake(maskedImage.size.width * endRate, maskedImage.size.height * endRate);
    UIGraphicsBeginImageContext(sz);
    [maskedImage drawInRect:CGRectMake(0, 0, sz.width, sz.height)];
    UIImage *tempMaskedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    // リサイズにあわせて重心位置も調整
    tempGravityPos = CGPointMake(gravityPos.x * endRate, gravityPos.y * endRate);
    
    // パーツのUIImageを元UIImageに合成--------------------------------------------------
    // CGContextを作成
    unsigned char *bitmap = malloc(width * height * sizeof(unsigned char) * 4);
    CGContextRef bitmapContext = CGBitmapContextCreate(bitmap, width, height, 8, width*4,
                                                       CGColorSpaceCreateDeviceRGB(),
                                                       kCGImageAlphaPremultipliedFirst);
    // 元画像をbitmapContextに描画
    CGContextDrawImage(bitmapContext, CGRectMake(0, 0, width, height), effectedImage.CGImage);
    // 顔の中心にマスク画像を描画
    CGContextDrawImage(bitmapContext, CGRectMake(gravityPos.x - tempGravityPos.x,
                                                 effectedImage.size.height - gravityPos.y
                                                 - (tempMaskedImage.size.height - tempGravityPos.y),
                                                 tempMaskedImage.size.width, tempMaskedImage.size.height),
                       tempMaskedImage.CGImage);
    // CGContextからCGImageを作成
    CGImageRef imageRef = CGBitmapContextCreateImage (bitmapContext);
    // CGImageからUIImageを作成
    effectedImage = [UIImage imageWithCGImage:imageRef];
    //bitmapを解放
    free(bitmap);
    
    return effectedImage;
    
}

@end