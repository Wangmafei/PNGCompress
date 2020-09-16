//
//  NSImage+Resize.m
//  ToolLab
//
//  Created by Wangmafei on 2020/9/1.
//  Copyright © 2020 BLACK DRAGON LAB. All rights reserved.
//

#import "NSImage+Resize.h"

@implementation NSImage (Resize)
+ (NSImage *)resizeWithSourceImage:(NSImage*)sourceImage size:(CGSize)size {
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = size.width;
    CGFloat targetHeight = size.height;
    CGFloat scaleFactor = 0.0;
    CGFloat widthFactor = targetWidth / width;
    CGFloat heightFactor = targetHeight / height;
    scaleFactor = (widthFactor>heightFactor)?widthFactor:heightFactor;

    CGFloat readHeight = targetHeight/scaleFactor;
    CGFloat readWidth = targetWidth/scaleFactor;
    CGPoint readPoint = CGPointMake(
                                    widthFactor>heightFactor?0:(width-readWidth)*0.5,
                                    widthFactor<heightFactor?0:(height-readHeight)*0.5);

    NSImage *newImage = [[NSImage alloc] initWithSize:size];
    CGRect thumbnailRect = {{0.0, 0.0}, size};
    NSRect imageRect = {readPoint, {readWidth, readHeight}};
    [newImage lockFocus];
    [sourceImage drawInRect:thumbnailRect fromRect:imageRect operation:NSCompositingOperationCopy fraction:1.0];
    [newImage unlockFocus];
    return newImage;
}
@end
