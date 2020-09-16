//
//  ImageCompressionViewItem.m
//  ToolLab
//
//  Created by Wangmafei on 2020/9/1.
//  Copyright © 2020 BLACK DRAGON LAB. All rights reserved.
//

#import "ImageCompressionViewItem.h"
#import "PNGCompress-Swift.h"
@interface ImageCompressionViewItem ()
@property (weak) IBOutlet RotatingArc *rotatingArc;
@property (weak) IBOutlet NSImageView *stateImageView;
@property (weak) IBOutlet NSTextField *desLabel;
@end

@implementation ImageCompressionViewItem

- (void)setOperation:(ImageCompressionOperation *)operation{
    _operation = operation;
    if (_operation.state == 1) {
        self.rotatingArc .hidden = NO;
        [self.rotatingArc startAnimation];
    }else{
        [self.rotatingArc stopAnimation];
        self.rotatingArc .hidden = YES;
    }
    if (_operation.state == 2) {
        self.stateImageView.hidden = NO;
        long size = (_operation.size-_operation.compressSize);
        if (size <= 0) {
            self.desLabel.stringValue = @"";
            self.desLabel.hidden = YES;
        }else{
            self.desLabel.hidden = NO;
            self.desLabel.stringValue = [NSString stringWithFormat:@"压缩 %@",[self fileSizeString:size]];
        }
    }else{
        self.desLabel.hidden = YES;
        self.stateImageView.hidden = YES;
    }
    
}

- (NSString *)fileSizeString:(long long)fileSize{
    if (fileSize > 1024.0*1024.0 && fileSize < 1024.0*1024.0*1024.0) {
        return [NSString stringWithFormat:@"%.2f MB",fileSize/1024.0/1024.0];
    }else if (fileSize > 1024.0*1024.0*1024) {
        return [NSString stringWithFormat:@"%.2f GB",fileSize/1024.0/1024.0/1024];
    }else if (fileSize > 1024.0 && fileSize < 1024.0*1024.0) {
        return [NSString stringWithFormat:@"%.2f KB",fileSize/1024.0];
    }else{
        return [NSString stringWithFormat:@"%.2f B",fileSize/1.0];
    }
}

@end
