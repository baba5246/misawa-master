//
//  TimeLineMutableArray.m
//  Misawa
//
//  Created by Shinya Akiba on 12/11/02.
//  Copyright (c) 2012年 Shinya Akiba. All rights reserved.
//

#import "TimeLineMutableArray.h"

@implementation TimeLineMutableArray

@synthesize userName;

- (id)init{
    
    userName = [NSMutableArray array];
    return self;
}

@end
