//
//  TimeLineTableView.m
//  Misawa
//
//  Created by Shinya Akiba on 12/11/02.
//  Copyright (c) 2012年 Shinya Akiba. All rights reserved.
//

#import "TimeLineTableView.h"
#import "TimeLineMutableArray.h"
#import "TimeLineCell.h"
#import "ImageLoader.h"

@interface TimeLineTableView ()
{
    TimeLineMutableArray *timeLineArray;
}

@end

@implementation TimeLineTableView

@synthesize timeLineDelegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame style:(UITableViewStyle)style {
    self = [super initWithFrame:frame style:style];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        [self setDelegate:(id)self];
        [self setDataSource:(id)self];
    }
    return self;
}

//テーブルが更新されたら呼ばれる。
-(void)tableView:(UITableView*)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (void) mainTableLoad {
    timeLineArray = [[TimeLineMutableArray alloc] init];

  NSString *encURL = [@"http://heavens-misawa.herokuapp.com/api/feed/12" stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:encURL]];
    NSData *json_data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    NSError *error=nil;

    NSString *jsonObject;
    NSLog(@"%@", json_data);
    if (json_data) {
        jsonObject = [NSJSONSerialization JSONObjectWithData:json_data options:NSJSONReadingAllowFragments error:&error];
    } else {
        jsonObject = @"[{\"photos\":{\"kkk\", rol}}]";
    }
    
    NSData* data = [jsonObject dataUsingEncoding:NSASCIIStringEncoding];

    if (data) {
        NSDictionary* json = [NSJSONSerialization
                              JSONObjectWithData:data
                              options:kNilOptions
                              error:&error];
        NSArray *jsonArray = [json objectForKey:@"photos"];
        for (NSDictionary* photo in jsonArray) {
            [timeLineArray.userName addObject:[photo objectForKey:@"photo_url"]];
        }
    }
    [self reloadData];
}

//セクションの数
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

// 要素の数。
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [timeLineArray.userName count];
}

//セルの設定
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    TimeLineCell *cell = (TimeLineCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];

    if (cell==nil)
    {
        cell = [[TimeLineCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }

    NSString *url = [timeLineArray.userName objectAtIndex:indexPath.row];

    cell.tlLabel.text = url;
    
    ImageLoader *imageLoader = [ImageLoader sharedInstance];
    UIImage *image = [imageLoader cacedImageForUrl:url];
    cell.tlImageView.image = image;
    cell.tlImageView.alpha = 0.0f;
    [UIView animateWithDuration:1.0f//アニメーションの時間
                     animations:^{
                         cell.tlImageView.alpha = 1.0f;
                     }
                     completion:^(BOOL finished){
                         //アニメーション後に呼ばれる部分。
                     }];

    if (!image) {
        // 画像をロード
        __weak TimeLineTableView *_self = self; // 循環参照よけ
        // completionの中身が終了したら、{}の中を実行する。
        [imageLoader loadImage:url completion:^(UIImage *image) {
            if (image) {
                NSDictionary *dictionary = [NSDictionary dictionaryWithObject:image forKey:[NSString stringWithFormat:@"%d" , indexPath.row]];
                [_self performSelectorOnMainThread:@selector(LoadImage:) withObject:dictionary waitUntilDone:YES];
            }
        }];
    } else {
        [cell.tlActivityIndicator stopAnimating];
        [cell.tlActivityIndicator removeFromSuperview];
    }
    return cell;
}

- (void) LoadImage:(id)dictionary {
    NSDictionary *dict = (NSDictionary*)dictionary;

    if ([dict count]) {
        NSString *string = [[dict allKeys] objectAtIndex:0];

        TimeLineCell *cell = (TimeLineCell *)[self cellForRowAtIndexPath:[NSIndexPath indexPathForRow:[string intValue] inSection:0]];
        cell.tlImageView.image = [dict objectForKey:string];
        [cell.tlActivityIndicator stopAnimating];
        [cell.tlActivityIndicator removeFromSuperview];
        [cell setNeedsLayout];
        [cell setNeedsDisplay];
        cell.tlImageView.alpha = 0.0f;
        [UIView animateWithDuration:1.0f//アニメーションの時間
                         animations:^{
                             cell.tlImageView.alpha = 1.0f;
                         }
                         completion:^(BOOL finished){ 
                         }];
    }
}

//セルを選択したとき
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    TimeLineCell *cell = (TimeLineCell *)[self cellForRowAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:0]];
    [timeLineDelegate performSelector:@selector(pushToDetailView:) withObject:cell.tlImageView.image];
    [self deselectRowAtIndexPath:indexPath animated:YES];
}

//セルの高さ
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 190;
}

@end