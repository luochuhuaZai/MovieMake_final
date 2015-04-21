//
//  HZViewController.h
//  MovieMake_01
//
//  Created by huazai on 15/3/12.
//  Copyright (c) 2015年 LitterDeveloper. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface HZViewController : UIViewController

@property (nonatomic, strong) NSMutableArray *images;

@property float imagesAplha;
@property int imagesX;
@property int imagesY;

@property (nonatomic, strong) NSMutableArray *subtitles;

@end
