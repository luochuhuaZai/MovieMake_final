//
//  HZViewController.m
//  MovieMake_01
//
//  Created by huazai on 15/3/12.
//  Copyright (c) 2015年 LitterDeveloper. All rights reserved.
//

#import "HZViewController.h"
#import <CoreImage/CoreImage.h>


@interface HZViewController ()

@end

@implementation HZViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    //把几个图片准备好
    self.images = [NSMutableArray array];
    self.subtitles = [NSMutableArray array];
    
    self.imagesAplha = 0.0;
    self.imagesX = 0;
    self.imagesY = 0;
    
    [self insertImagesToArray:self.images];
    
    [self testCompressionSession];
}

- (void)insertImagesToArray:(NSMutableArray *)images{
    
    UIImage *image1 = [UIImage imageNamed:@"1.jpg"];
    UIImage *image2 = [UIImage imageNamed:@"2.jpg"];
    UIImage *image3 = [UIImage imageNamed:@"3.jpg"];
    UIImage *image4 = [UIImage imageNamed:@"1.jpg"];
    UIImage *image5 = [UIImage imageNamed:@"2.jpg"];
    UIImage *image6 = [UIImage imageNamed:@"3.jpg"];
    
    
    [self.images addObject:image1];
    [self.images addObject:image2];
    [self.images addObject:image3];
    [self.images addObject:image4];
    [self.images addObject:image5];
    [self.images addObject:image6];
    
    [self.subtitles addObject:@"Hello,One"];
    [self.subtitles addObject:@"Hello,Two"];
    [self.subtitles addObject:@"Hello,Three"];
    [self.subtitles addObject:@"Hello,One"];
    [self.subtitles addObject:@"Hello,Two"];
    [self.subtitles addObject:@"Hello,Three"];
}

//- (void)didReceiveMemoryWarning
//{
//    [super didReceiveMemoryWarning];
//    // Dispose of any resources that can be recreated.
//}

- (void)testCompressionSession
{
    //NSString *moviePath = [[NSBundle mainBundle] pathForResource:@”Movie” ofType:@”mov”];
    
    CGSize size = CGSizeMake(800,640);//定义视频的大小
    
    NSError *error = nil;
    
    unlink([VEDIOPATH UTF8String]);
    
    //—-initialize compression engine
    AVAssetWriter __block *videoWriter = [[AVAssetWriter alloc] initWithURL:[NSURL fileURLWithPath:VEDIOPATH]
                                                           fileType:AVFileTypeMPEG4
                                                              error:&error];
    NSParameterAssert(videoWriter);
    if(error)
        NSLog(@"error = %@", [error localizedDescription]);
    
    NSDictionary *videoSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                   AVVideoCodecH264, AVVideoCodecKey,
                                   [NSNumber numberWithInt:size.width], AVVideoWidthKey,
                                   [NSNumber numberWithInt:size.height], AVVideoHeightKey, nil];
    
    AVAssetWriterInput *writerInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:videoSettings];
    
    NSDictionary *sourcePixelBufferAttributesDictionary = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:kCVPixelFormatType_32ARGB], kCVPixelBufferPixelFormatTypeKey, nil];
    
    AVAssetWriterInputPixelBufferAdaptor *adaptor = [AVAssetWriterInputPixelBufferAdaptor assetWriterInputPixelBufferAdaptorWithAssetWriterInput:writerInput sourcePixelBufferAttributes:sourcePixelBufferAttributesDictionary];
    
    NSParameterAssert(writerInput);
    NSParameterAssert([videoWriter canAddInput:writerInput]);
    
    if ([videoWriter canAddInput:writerInput])
        NSLog(@" ");
    else
        NSLog(@" ");
    
    [videoWriter addInput:writerInput];
    
    [videoWriter startWriting];
    [videoWriter startSessionAtSourceTime:kCMTimeZero];
    
    //合成多张图片为一个视频文件
    dispatch_queue_t dispatchQueue = dispatch_queue_create("mediaInputQueue", NULL);
    int __block frame = 0;
    
    [writerInput requestMediaDataWhenReadyOnQueue:dispatchQueue usingBlock:^{
        while ([writerInput isReadyForMoreMediaData])
        {
            if(++frame >= 600)
            {
                [writerInput markAsFinished];
                [videoWriter finishWriting];
                videoWriter = nil;
                NSLog(@"Finished");
                break;
            }
            
            CVPixelBufferRef buffer = NULL;
            
            int idx = frame/100;
            //NSLog(@"%i",idx);
            
            buffer = (CVPixelBufferRef)[self pixelBufferFromCGImage:[[self.images objectAtIndex:idx] CGImage] andSize:size andFrame:frame andImageNum:idx];
            
            if (buffer)
            {
                if(![adaptor appendPixelBuffer:buffer withPresentationTime:CMTimeMake(frame, 120)])
                    NSLog(@"FAIL......");
                else
                    CFRelease(buffer);
            }
            
        }
    }];
}

- (CVPixelBufferRef) pixelBufferFromCGImage: (CGImageRef) image andSize:(CGSize) size andFrame:(int)frame andImageNum:(int)idx
{
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGImageCompatibilityKey,
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGBitmapContextCompatibilityKey,
                             nil];
    CVPixelBufferRef pxbuffer = NULL;
    
    CVReturn status = CVPixelBufferCreate(kCFAllocatorDefault, size.width,
                                          size.height, kCVPixelFormatType_32ARGB, (__bridge CFDictionaryRef) options,
                                          &pxbuffer);
    
    NSParameterAssert(status == kCVReturnSuccess && pxbuffer != NULL);
    
    CVPixelBufferLockBaseAddress(pxbuffer, 0);
    void *pxdata = CVPixelBufferGetBaseAddress(pxbuffer);
    NSParameterAssert(pxdata != NULL);
    
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGContextRef context = CGBitmapContextCreate(pxdata, size.width,
                                                 size.height, 8, 4*size.width, rgbColorSpace,
                                                 kCGImageAlphaNoneSkipFirst);
    //CGContextSetFillColorWithColor(context, [UIColor blackColor].CGColor);
    NSParameterAssert(context);
    CGContextConcatCTM(context, CGAffineTransformMakeRotation(0));
    
    NSLog(@"==================%d", frame);
    self.imagesAplha = 0.8;
    
    CGContextSetAlpha(context, self.imagesAplha);
    CGContextDrawImage(context, CGRectMake(0, 0, 800, 640), image);
    
//    CGContextSaveGState(context);
//    
//    CGContextScaleCTM(context, 1, -1);
//    CGContextTranslateCTM(context, 0, -200);
//    
//    CATextLayer *subtitle1Text = [[CATextLayer alloc] init];
//    [subtitle1Text setFont:@"Helvetica-Bold"];
//    [subtitle1Text setFontSize:36];
//    [subtitle1Text setFrame:CGRectMake(0, 0, size.width, 400)];
//    [subtitle1Text setString:[self.subtitles objectAtIndex:idx]];
//    [subtitle1Text setAlignmentMode:kCAAlignmentCenter];
//    [subtitle1Text setForegroundColor:[[UIColor whiteColor] CGColor]];
//    
//    [subtitle1Text drawInContext:context];
    
    CGColorSpaceRelease(rgbColorSpace);
    CGContextRelease(context);
    
    CVPixelBufferUnlockBaseAddress(pxbuffer, 0);
    
    return pxbuffer;
}

//改图像透明度
- (UIImage *)imageByApplyingAlpha:(CGFloat)alpha  image:(UIImage*)image
{
    UIGraphicsBeginImageContextWithOptions(image.size, NO, 0.0f);
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGRect area = CGRectMake(0, 0, image.size.width, image.size.height);
    
    CGContextScaleCTM(ctx, 1, -1);
    CGContextTranslateCTM(ctx, 0, -area.size.height);
    
    CGContextSetBlendMode(ctx, kCGBlendModeMultiply);
    
    CGContextSetAlpha(ctx, alpha);
    
    CGContextDrawImage(ctx, area, image.CGImage);
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return newImage;
}
@end
