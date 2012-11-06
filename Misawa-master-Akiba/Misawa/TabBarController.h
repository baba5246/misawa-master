//
//  TabBarController.h
//  Misawa
//
//  Created by Shinya Akiba on 12/11/02.
//  Copyright (c) 2012年 Shinya Akiba. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TabBarController : UITabBarController<UITabBarControllerDelegate, UIAlertViewDelegate>
{
    UITabBar *tab;
}

- (void)push;

@end