//
//  DestinationButton.m
//  ToolLab
//
//  Created by Wangmafei on 2020/9/1.
//  Copyright © 2020 BLACK DRAGON LAB. All rights reserved.
//

#import "DestinationButton.h"
#import <Masonry.h>

@interface DestinationButton ()

@end
@implementation DestinationButton

- (instancetype)initWithCoder:(NSCoder *)coder{
    self = [super initWithCoder:coder];
    if (self) {
        [self registerForDraggedTypes:@[NSPasteboardTypeFileURL, NSPasteboardTypePNG]];
    }
    return self;
}

#pragma mark - NSDraggingDestination
-(void)draggingEnded:(id<NSDraggingInfo>)sender{
    NSLog(@"-- draggingEnded");
    
    self.isReceivingDrag = NO;
}


// 拖进来但没放下时调用
-(void)draggingExited:(id<NSDraggingInfo>)sender{
    NSLog(@"-- draggingExited");
    
}

/* 拖动数据进入来时调用 可以在这里判断数据是什么类型 */
-(NSDragOperation)draggingEntered:(id<NSDraggingInfo>)sender{
    
    self.isReceivingDrag = YES;
    NSPasteboard *pb = [sender draggingPasteboard];
    if ([[pb types] containsObject:NSPasteboardTypeFileURL]) {
        return NSDragOperationCopy;
    }
    return NSDragOperationNone;
}

-(BOOL)prepareForDragOperation:(id<NSDraggingInfo>)sender{
    NSPasteboard *pb = [sender draggingPasteboard];
    NSArray *list = [pb propertyListForType:NSFilenamesPboardType];
    NSMutableArray *dataArray = [NSMutableArray array];
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        [list enumerateObjectsUsingBlock:^(NSString *path, NSUInteger idx, BOOL * _Nonnull stop) {
            BOOL isDirectory;
            [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDirectory];
            if (isDirectory) {
                NSError *errSubPath = nil;
                NSArray *subPathOfDirectoryArray = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:path error:&errSubPath];
                if (nil == errSubPath) {
                    [subPathOfDirectoryArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        if ([obj hasSuffix:@".png"]) {
                            NSString *filePath = [NSString stringWithFormat:@"%@/%@",path,obj];
                            [dataArray addObject:filePath];
                        }
                    }];
                }
            }else{
                if ([path hasSuffix:@".png"]) {
                    [dataArray addObject:path];
                }
            }
        }];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.delegate && [self.delegate respondsToSelector:@selector(destinationButton:dataArray:)]) {
                [self.delegate destinationButton:self dataArray:dataArray];
            }
        });
    });
    return YES;
}

@end
