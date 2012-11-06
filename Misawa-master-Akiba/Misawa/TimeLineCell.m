//
//  TimeLineCell.m
//  Misawa
//
//  Created by Shinya Akiba on 12/11/02.
//  Copyright (c) 2012年 Shinya Akiba. All rights reserved.
//

#import "TimeLineCell.h"
#import <QuartzCore/QuartzCore.h>

@implementation TimeLineCell

@synthesize tlImageView, tlLabel, tlActivityIndicator, tlButton;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setLabel:tlLabel];
        [self setImageView:tlImageView];
        [self setActivityIndicator:tlActivityIndicator];
        self.selectionStyle = UITableViewCellSelectionStyleGray;
    }
    return self;
}

- (void) setLabel:(UILabel *)labelInCell {
    tlLabel = [[UILabel alloc] initWithFrame:CGRectMake(100, 20, 150, 50)];
    tlLabel.font = [UIFont systemFontOfSize:10];
//    [self addSubview:tlLabel];
}

- (void) setImageView:(UIImageView *)imageViewInCell {
    tlImageView = [[UIImageView alloc] initWithFrame:CGRectMake(17, 10, 160, 160)];
    tlImageView.backgroundColor = [UIColor clearColor];
    tlImageView.alpha = 0.0f;
    tlImageView.layer.cornerRadius = 10.0f;
    tlImageView.clipsToBounds = TRUE;
    [self addSubview:tlImageView];
}

- (void) setActivityIndicator:(UIActivityIndicatorView *)activityIndicatorInCell {

    tlActivityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    tlActivityIndicator.center = tlImageView.center;
    tlActivityIndicator.hidesWhenStopped = YES;
    [tlActivityIndicator startAnimating];
    [tlImageView addSubview:tlActivityIndicator];
}

- (void) setButtun:(UIButton*) buttonInCell {
    tlButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [tlButton setFrame:CGRectMake(140, 40, 50, 25)];
    [tlButton setImage:[UIImage imageNamed:@"like.png"] forState:UIControlStateNormal];
    [self addSubview:tlButton];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end