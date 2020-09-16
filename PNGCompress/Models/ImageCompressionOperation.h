//
//  ImageCompressionModel.h
//  ToolLab
//
//  Created by Wangmafei on 2020/9/1.
//  Copyright © 2020 BLACK DRAGON LAB. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class ImageCompressionOperation;
@protocol ImageCompressionOperationDelegate <NSObject>

@optional
- (void)imageCompressionOperation:(ImageCompressionOperation *)imageCompressionOperation;
@end
@interface ImageCompressionOperation : NSOperation
@property (nonatomic, weak) id <ImageCompressionOperationDelegate> delegate;
@property (nonatomic, strong) NSImage *thumbnailImage;
@property (nonatomic, copy) NSString *fileName;
@property (nonatomic, copy) NSString *filePath;
@property (nonatomic, readwrite, getter=isExecuting) BOOL executing;
@property (nonatomic, readwrite, getter=isFinished) BOOL finished;
@property (nonatomic) NSInteger index;
@property (nonatomic) NSInteger quality;
@property (nonatomic) CGFloat progress;
@property (nonatomic) long size;
@property (nonatomic) long compressSize;
@property (nonatomic) NSInteger state;//0 未运行 1 压缩中 2 完成
@property (nonatomic) BOOL keepOriginalImage;

- (instancetype)initWithIndex:(NSInteger)index filePath:(NSString *)filePath;
@end

NS_ASSUME_NONNULL_END
