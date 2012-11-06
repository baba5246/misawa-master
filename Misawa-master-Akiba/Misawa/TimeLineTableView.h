//
//  TimeLineTableView.h
//  Misawa
//
//  Created by Shinya Akiba on 12/11/02.
//  Copyright (c) 2012年 Shinya Akiba. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface TimeLineTableView : UITableView

@property (nonatomic, retain) id timeLineDelegate;

- (void) mainTableLoad;

@end
