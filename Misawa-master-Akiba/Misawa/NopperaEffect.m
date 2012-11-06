//
//  NopperaEffect.m
//  Misawa
//
//  Created by cyberagent on 2012/11/06.
//  Copyright (c) 2012年 Shinya Akiba. All rights reserved.
//


#import "NopperaEffect.h"

@implementation NopperaEffect

- (UIImage *)createNopperaBoEffect:(UIImage *)originalImage
{
    //定数宣言
    //const int imageViewLongSize = 320;
    //const int imageViewShortSize = 240;
    CGFloat width = originalImage.size.width;
    CGFloat height = originalImage.size.height;
    const CGFloat EYE_WIDTH_RATE = 0.40f;
    const CGFloat EYE_HEIGHT_RATE = 0.25f;
    const CGFloat MOUTH_HEIGHT_RATE = 0.25f;
    float startRate = 0.9, endRate = 0, delta = 0.01;
    
    // 検出器生成 /////////////////////////////////////////////////////////////////////////////////////////
    NSDictionary *options = [NSDictionary dictionaryWithObject:CIDetectorAccuracyLow
                                                        forKey:CIDetectorAccuracy];
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeFace
                                              context:nil options:options];
    
    // 顔検出////////////////////////////////////////////////////////////////////////////////////////////
    CIImage *ciImage = [[CIImage alloc] initWithCGImage:originalImage.CGImage];
    NSArray* features = [detector featuresInImage:ciImage];
    
    // 検出された顔ごとに処理＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊
    for(CIFaceFeature* faceFeature in features)
    {
        // 座標系修正用Transform（アフィン変換）
        CGAffineTransform transform = CGAffineTransformMakeScale(1, -1);
        transform = CGAffineTransformTranslate(transform, 0, -originalImage.size.height);
        
        // 顔の領域の決定と変数宣言--------------------------------------------------------
        CGFloat faceWidth = faceFeature.bounds.size.width;
        CGFloat faceHeight = faceFeature.bounds.size.height;
        
        CGPoint leftEyePos;
        CGPoint rightEyePos;
        CGPoint mouthPos;
        CGPoint gravityPos;
        
        CGFloat eyeA = 0;
        CGFloat eyeB = 0;
        CGFloat faceA = 0;
        CGFloat faceB = 0;
        
        // 全パーツを検出できていれば処理を開始する
        if (faceFeature.hasLeftEyePosition && faceFeature.hasMouthPosition && faceFeature.hasRightEyePosition)
        {
            // パーツの座標を取得し、UIKitの座標に変換
            leftEyePos = CGPointApplyAffineTransform(faceFeature.leftEyePosition, transform);
            rightEyePos = CGPointApplyAffineTransform(faceFeature.rightEyePosition, transform);
            mouthPos = CGPointApplyAffineTransform(faceFeature.mouthPosition, transform);
            // 重心を算出
            gravityPos = CGPointMake((leftEyePos.x + rightEyePos.x)/2,
                                     (leftEyePos.y + rightEyePos.y)/2);
            // 顔の大きさに応じて目の楕円の長径と短径を決定（すべて2乗しておく）
            eyeA = pow((gravityPos.x - (leftEyePos.x - faceWidth*EYE_WIDTH_RATE*0.5)), 2);
            eyeB = pow(faceHeight*EYE_HEIGHT_RATE, 2);
            // 顔の大きさに応じて顔の楕円の長径と短径を決定（すべて2乗しておく）
            faceA = pow((mouthPos.y + faceHeight*MOUTH_HEIGHT_RATE - gravityPos.y), 2);
            if (eyeA > faceA)
            {
                faceB = faceA;
                faceA = eyeA;
            }
            else faceB = eyeA;
        }
        
        // プロパティに保存 //////////////////////////////////////////////////////////////////
        properties = [[NSMutableArray alloc] init];
        [properties addObject:[NSValue valueWithCGRect:faceFeature.bounds]];    // 1. 顔領域
        [properties addObject:[NSValue valueWithCGPoint:leftEyePos]];           // 2. 左目位置
        [properties addObject:[NSValue valueWithCGPoint:rightEyePos]];          // 3. 右目位置
        [properties addObject:[NSValue valueWithCGPoint:mouthPos]];             // 4. 口位置
        [properties addObject:[NSValue valueWithCGPoint:gravityPos]];           // 5. 重心位置
        // マスク画像を作成する //////////////////////////////////////////////////////////////////
        maskedFaceImage = [self createMaskedImage:originalImage GravityPos:gravityPos
                                         property:CGRectMake(eyeA, eyeB, faceA, faceB) ];
        
        
        // パーツ画像を小さくしながら重ねて描画していく////////////////////////////////////////////////////////////////
        // エフェクト画像UIImage
        UIImage *effectedImage = originalImage;
        // マスク画像の重心位置
        CGPoint tempGravityPos = CGPointMake(0, 0);
        
        for (float rate = startRate; rate > endRate; rate -= delta)
        {
            // 切り抜き画像のリサイズ -----------------------------------------------------------
            CGSize sz = CGSizeMake(maskedFaceImage.size.width * rate, maskedFaceImage.size.height * rate);
            UIGraphicsBeginImageContext(sz);
            [maskedFaceImage drawInRect:CGRectMake(0, 0, sz.width, sz.height)];
            UIImage *tempMaskedImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            
            tempGravityPos = CGPointMake(gravityPos.x * rate, gravityPos.y * rate);// リサイズにあわせて重心位置も調整
            
            // パーツのUIImageを元UIImageに合成--------------------------------------------------
            // CGContextを作成
            unsigned char *bitmap = malloc(width * height * sizeof(unsigned char) * 4);
            CGContextRef bitmapContext = CGBitmapContextCreate(bitmap, width, height, 8, width*4,
                                                               CGColorSpaceCreateDeviceRGB(),
                                                               kCGImageAlphaPremultipliedFirst);
            // imgAをbitmapContextに描画
            CGContextDrawImage(bitmapContext, CGRectMake(0, 0, width, height), effectedImage.CGImage);
            // imgBをimgAの隣に描画
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
        }
        
        
        // ぼかしまくる /////////////////////////////////////////////////////////////////
        effectedImage = [self shadeFace:effectedImage Gravity:gravityPos
                        ellipseProperty:CGRectMake(eyeA, eyeB, faceA, faceB)];
        effectedImage = [self shadeFace:effectedImage Gravity:gravityPos
                        ellipseProperty:CGRectMake(eyeA, eyeB, faceA, faceB)];
        effectedImage = [self shadeFace:effectedImage Gravity:gravityPos
                        ellipseProperty:CGRectMake(eyeA, eyeB, faceA, faceB)];
        effectedImage = [self shadeFace:effectedImage Gravity:gravityPos
                        ellipseProperty:CGRectMake(eyeA, eyeB, faceA, faceB)];
        effectedImage = [self shadeFace:effectedImage Gravity:gravityPos
                        ellipseProperty:CGRectMake(eyeA, eyeB, faceA, faceB)];
        effectedImage = [self shadeFace:effectedImage Gravity:gravityPos
                        ellipseProperty:CGRectMake(eyeA, eyeB, faceA, faceB)];
        // 結果を返す /////////////////////////////////////////////////////////////////
        return effectedImage;
    }
    
    return originalImage;
}

// マスク画像作成メソッド //////////////////////////////////////////////////////////////////
- (UIImage *) createMaskedImage :(UIImage *)originalImage GravityPos:(CGPoint)gravityPosition property:(CGRect)property
{
    // データプロバイダを取得する
    CGDataProviderRef dataProvider;
    dataProvider = CGImageGetDataProvider([originalImage CGImage]);
    
    // ビットマップデータを取得する
    CFDataRef data = CGDataProviderCopyData(dataProvider);
    CFMutableDataRef inputData = CFDataCreateMutableCopy(0, 0, data);
    UInt8* buffer = (UInt8*)CFDataGetMutableBytePtr(inputData);
    
    // 各ピクセルに黒もしくは白を書き込んでいく
    size_t bytesPerRow = CGImageGetBytesPerRow(originalImage.CGImage);
    for (int y = 0; y < originalImage.size.height; y++) {
        for (int x = 0; x < originalImage.size.width; x++) {
            
            //重心の上下でピクセルの判定を変える
            if (y < gravityPosition.y) // 重心より上の場合
            {
                //座標系変換
                int tempX = x - gravityPosition.x;
                int tempY = y - gravityPosition.y;
                //楕円内にあるかどうかの判定
                UInt8* tmp = 0;
                if ((pow(tempX, 2) / property.origin.x) + (pow(tempY, 2) / property.origin.y) > 1) // ない場合
                {
                    tmp = buffer + y * bytesPerRow + x * 4;
                    *(tmp + 3) = 255;
                    *(tmp + 2) = 255;
                    *(tmp + 1) = 255;
                    *(tmp + 0) = 255;
                }
                else // ある場合
                {
                    tmp = buffer + y * bytesPerRow + x * 4;
                    *(tmp + 3) = 0;
                    *(tmp + 2) = 0;
                    *(tmp + 1) = 0;
                    *(tmp + 0) = 0;
                }                    //NSLog(@"gravity:(%f, %f)", gravityPos.x, gravityPos.y);
            }
            else // 重心より下の場合
            {
                //座標系変換
                int tempX = x - gravityPosition.x;
                int tempY = y - gravityPosition.y;
                //楕円内にあるかどうかの判定
                UInt8* tmp = 0;
                if (((CGFloat)pow(tempX, 2) / property.size.height)
                    + ((CGFloat)pow(tempY, 2) / property.size.width) > 1) // ない場合
                {
                    tmp = buffer + y * bytesPerRow + x * 4;
                    *(tmp + 3) = 255;
                    *(tmp + 2) = 255;
                    *(tmp + 1) = 255;
                    *(tmp + 0) = 255;
                }
                else // ある場合
                {
                    tmp = buffer + y * bytesPerRow + x * 4;
                    *(tmp + 3) = 0;
                    *(tmp + 2) = 0;
                    *(tmp + 1) = 0;
                    *(tmp + 0) = 0;
                }
            }
        }
    }
    
    // pixel値からUIImageの再合成
    CFDataRef resultData = CFDataCreate(NULL, buffer, CFDataGetLength(data));
    CGDataProviderRef resultDataProvider = CGDataProviderCreateWithCFData(resultData);
    CGImageRef resultCgImage = CGImageCreate(CGImageGetWidth(originalImage.CGImage),
                                             CGImageGetHeight(originalImage.CGImage),
                                             CGImageGetBitsPerComponent(originalImage.CGImage),
                                             CGImageGetBitsPerPixel(originalImage.CGImage),
                                             bytesPerRow,
                                             CGImageGetColorSpace(originalImage.CGImage),
                                             CGImageGetBitmapInfo(originalImage.CGImage),
                                             resultDataProvider,
                                             NULL, CGImageGetShouldInterpolate(originalImage.CGImage),
                                             CGImageGetRenderingIntent(originalImage.CGImage));
    
    // マスク画像の作成
    UIImage *maskImage = [[UIImage alloc] initWithCGImage:resultCgImage];
    
    
    // マスク画像から切り抜き画像を作成//////////////////////////////////////////////////////////////////////
    // マスク画像をCGImageに変換する
    CGImageRef maskRef = maskImage.CGImage;
    // マスクを作成する
    CGImageRef mask = CGImageMaskCreate(CGImageGetWidth(maskRef),
                                        CGImageGetHeight(maskRef),
                                        CGImageGetBitsPerComponent(maskRef),
                                        CGImageGetBitsPerPixel(maskRef),
                                        CGImageGetBytesPerRow(maskRef),
                                        CGImageGetDataProvider(maskRef), NULL, false);
    // マスクの形に切り抜く
    CGImageRef masked = CGImageCreateWithMask(originalImage.CGImage, mask);
    // CGImageをUIImageに変換する
    UIImage *maskedImage = [UIImage imageWithCGImage:masked];
    
    // 後処理
    CGImageRelease(resultCgImage);
    CFRelease(resultDataProvider);
    CFRelease(resultData);
    CFRelease(data);
    CGImageRelease(mask);
    CGImageRelease(masked);
    
    return maskedImage;
}

// マスク画像取得メソッド //////////////////////////////////////////////////////////////////
- (UIImage *) getMaskedImage
{
    return maskedFaceImage;
}

// プロパティ取得メソッド ////////////////////////////////////////////////////////////////////////////////////
- (NSMutableArray *)getProperties
{
    return properties;
}

// 顔周囲の線をぼかすメソッド
- (UIImage *) shadeFace :(UIImage *)originalImage Gravity:(CGPoint)gravityPosition
         ellipseProperty:(CGRect)ellipseProperty
{
    // データプロバイダを取得する
    CGDataProviderRef dataProvider = CGImageGetDataProvider([originalImage CGImage]);
    
    // ビットマップデータを取得する
    CFDataRef data = CGDataProviderCopyData(dataProvider);
    CFMutableDataRef inputData = CFDataCreateMutableCopy(0, 0, data);
    UInt8* buffer = (UInt8*)CFDataGetMutableBytePtr(inputData);
    
    // 各ピクセルに黒もしくは白を書き込んでいく
    size_t bytesPerRow = CGImageGetBytesPerRow(originalImage.CGImage);
    for (int y = 0; y < originalImage.size.height; y++) {
        for (int x = 0; x < originalImage.size.width; x++) {
            
            //重心の上下でピクセルの判定を変える
            if (y < gravityPosition.y) // 重心より上の場合
            {
                //座標系変換
                int tempX = x - gravityPosition.x;
                int tempY = y - gravityPosition.y;
                //楕円内にあるかどうかの判定
                if ((pow(tempX, 2) / ellipseProperty.origin.x) + (pow(tempY, 2) / ellipseProperty.origin.y) < 1)
                {
                    UInt8* tmp = 0;
                    int r = 0, g = 0, b = 0, count = 24;
                    for (int deltaY = -2; deltaY < 3; deltaY++)
                    {
                        for (int deltaX = -2; deltaX < 3; deltaX++)
                        {
                            if (deltaX != 0 || deltaY != 0)
                            {
                                tmp = buffer + (y + deltaY) * bytesPerRow + (x+deltaX) * 4;
                                r += *(tmp + 3);
                                g += *(tmp + 2);
                                b += *(tmp + 1);
                            }
                        }
                    }
                    tmp = buffer + y * bytesPerRow + x * 4;
                    *(tmp + 3) = (int)(r / count);
                    *(tmp + 2) = (int)(g / count);
                    *(tmp + 1) = (int)(b / count);
                }
            }
            else // 重心より下の場合
            {
                //座標系変換
                int tempX = x - gravityPosition.x;
                int tempY = y - gravityPosition.y;
                //楕円内にあるかどうかの判定
                if (((CGFloat)pow(tempX, 2) / ellipseProperty.size.height)
                    + ((CGFloat)pow(tempY, 2) / ellipseProperty.size.width) < 1)
                {
                    UInt8* tmp = 0;
                    int r = 0, g = 0, b = 0, count = 48;
                    for (int deltaY = -3; deltaY < 4; deltaY++)
                    {
                        for (int deltaX = -3; deltaX < 4; deltaX++)
                        {
                            if (deltaX != 0 || deltaY != 0)
                            {
                                tmp = buffer + (y + deltaY) * bytesPerRow + (x+deltaX) * 4;
                                r += *(tmp + 3);
                                g += *(tmp + 2);
                                b += *(tmp + 1);
                            }
                        }
                    }
                    tmp = buffer + y * bytesPerRow + x * 4;
                    *(tmp + 3) = r / count;
                    *(tmp + 2) = g / count;
                    *(tmp + 1) = b / count;
                    
                }
            }
        }
    }
    
    // pixel値からUIImageの再合成
    CFDataRef resultData = CFDataCreate(NULL, buffer, CFDataGetLength(data));
    CGDataProviderRef resultDataProvider = CGDataProviderCreateWithCFData(resultData);
    CGImageRef resultCgImage = CGImageCreate(CGImageGetWidth(originalImage.CGImage),
                                             CGImageGetHeight(originalImage.CGImage),
                                             CGImageGetBitsPerComponent(originalImage.CGImage),
                                             CGImageGetBitsPerPixel(originalImage.CGImage),
                                             bytesPerRow,
                                             CGImageGetColorSpace(originalImage.CGImage),
                                             CGImageGetBitmapInfo(originalImage.CGImage),
                                             resultDataProvider,
                                             NULL, CGImageGetShouldInterpolate(originalImage.CGImage),
                                             CGImageGetRenderingIntent(originalImage.CGImage));
    
    // マスク画像の作成
    originalImage = [[UIImage alloc] initWithCGImage:resultCgImage];
    
    return originalImage;
}


@end

