//
//  DragonBallEffect.m
//  Misawa
//
//  Created by cyberagent on 2012/11/06.
//  Copyright (c) 2012年 Shinya Akiba. All rights reserved.
//

#import "DragonBallEffect.h"

@implementation DragonBallEffect

- (UIImage *)createDragonBallEffect :(UIImage *)originalImage properties:(NSMutableArray *) properties
{
    //定数宣言
    const CGFloat width = originalImage.size.width;
    const CGFloat height = originalImage.size.height;
    const float EYE_WIDTH_RATE = 0.70, EYE_HEIGHT_RATE = 0.25;
    const float MOUTH_WIDTH_RATE = 0.40, MOUTH_HEIGHT_RATE = 0.40;
    float LEFT_EYE_RATE = 0, RIGHT_EYE_RATE = 0;
    
    CGRect faceBounds = [[properties objectAtIndex:0] CGRectValue];
    CGFloat faceWidth = faceBounds.size.width;
    CGFloat faceHeight = faceBounds.size.height;
    CGPoint leftEyePos = [[properties objectAtIndex:1] CGPointValue];
    CGPoint rightEyePos = [[properties objectAtIndex:2] CGPointValue];
    CGPoint mouthPos = [[properties objectAtIndex:3] CGPointValue];
    CGPoint gravityPos = [[properties objectAtIndex:4] CGPointValue];
    
    // 座標系修正用Transform（アフィン変換）
    CGAffineTransform transform = CGAffineTransformMakeScale(1, -1);
    transform = CGAffineTransformTranslate(transform, 0, -originalImage.size.height);
    // UIKitの座標に変換
    leftEyePos = CGPointApplyAffineTransform(leftEyePos, transform);
    rightEyePos = CGPointApplyAffineTransform(rightEyePos, transform);
    mouthPos = CGPointApplyAffineTransform(mouthPos, transform);
    
    
    // 各パーツ領域を決定
    LEFT_EYE_RATE = EYE_WIDTH_RATE * (gravityPos.x - faceBounds.origin.x) / faceWidth;
    CGRect leftEyeRect = CGRectMake(leftEyePos.x - faceWidth*LEFT_EYE_RATE*0.5,
                                    leftEyePos.y - faceHeight*EYE_HEIGHT_RATE*0.30,
                                    faceWidth*LEFT_EYE_RATE,
                                    faceHeight*EYE_HEIGHT_RATE);
    RIGHT_EYE_RATE = EYE_WIDTH_RATE - LEFT_EYE_RATE;
    CGRect rightEyeRect = CGRectMake(rightEyePos.x - faceWidth*RIGHT_EYE_RATE*0.45,
                                     rightEyePos.y - faceHeight*EYE_HEIGHT_RATE*0.30,
                                     faceWidth*RIGHT_EYE_RATE,
                                     faceHeight*EYE_HEIGHT_RATE);
    CGRect mouthRect = CGRectMake(mouthPos.x - faceWidth*MOUTH_WIDTH_RATE*0.5,
                                  mouthPos.y - faceHeight*MOUTH_HEIGHT_RATE*0.5 + faceHeight*0.15,
                                  faceWidth*MOUTH_WIDTH_RATE,
                                  faceHeight*MOUTH_HEIGHT_RATE);
    // 各パーツ画像読み込み
    UIImage *leftEyeImage = [UIImage imageNamed:@"gokuLeft.png"];
    UIImage *rightEyeImage = [UIImage imageNamed:@"gokuRight.png"];
    UIImage *mouthImage = [UIImage imageNamed:@"gokuMouth.png"];
    
    // 画像を描画
    // CGContextを作成
    unsigned char *bitmap = malloc(width * height * sizeof(unsigned char) * 4);
    CGContextRef bitmapContext = CGBitmapContextCreate(bitmap, width, height, 8, width*4,
                                                       CGColorSpaceCreateDeviceRGB(),
                                                       kCGImageAlphaPremultipliedFirst);
    // 元画像をbitmapContextに描画
    CGContextDrawImage(bitmapContext, CGRectMake(0, 0, width, height), originalImage.CGImage);
    // 顔の中心にマスク画像を描画
    CGContextDrawImage(bitmapContext, leftEyeRect, leftEyeImage.CGImage);
    // 顔の中心にマスク画像を描画
    CGContextDrawImage(bitmapContext, rightEyeRect, rightEyeImage.CGImage);
    // 顔の中心にマスク画像を描画
    CGContextDrawImage(bitmapContext, mouthRect, mouthImage.CGImage);
    // CGContextからCGImageを作成
    CGImageRef imageRef = CGBitmapContextCreateImage (bitmapContext);
    // CGImageからUIImageを作成
    UIImage *effectedImage = [UIImage imageWithCGImage:imageRef];
    
    return effectedImage;
}

@end
