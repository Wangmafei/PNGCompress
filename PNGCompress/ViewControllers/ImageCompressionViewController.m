//
//  DocumentViewController.m
//  Toolbox
//
//  Created by Wangmafei on 2020/4/27.
//  Copyright © 2020 BLACK DRAGON LAB. All rights reserved.
//

#import "ImageCompressionViewController.h"
#import "NSTaskWithProgress.h"
#import "PNGCompress-Swift.h"
#import "DestinationButton.h"
#import "ImageCompressionViewItem.h"
#import "ImageCompressionOperation.h"
#import "NSImage+Resize.h"
@interface ImageCompressionViewController ()
<
NSCollectionViewDelegate,
NSCollectionViewDataSource,
DestinationButtonDelegate,
ImageCompressionOperationDelegate
>
@property (weak) IBOutlet DestinationButton *destinationButton;
@property (weak) IBOutlet NSCollectionView *collectionView;
@property (weak) IBOutlet CircularProgress *circularProgress;
@property (weak) IBOutlet NSTextField *desLabel;
@property (weak) IBOutlet NSTextField *qualityLabel;
@property (weak) IBOutlet NSButton *resetButton;
@property (weak) IBOutlet NSTextField *tipsLabel;
@property (weak) IBOutlet NSTextField *checkBoxLabel;
@property (weak) IBOutlet NSButton *checkBox;
@property (weak) IBOutlet NSTextField *qualityTipsLabel;
@property (weak) IBOutlet NSSlider *slider;
@property (nonatomic) NSInteger quality;
@property (nonatomic) BOOL keepOriginalImage;
@property (nonatomic, strong) NSOperationQueue *operationQueue;
@property (nonatomic, strong) NSMutableArray *dataArray;
@end

@implementation ImageCompressionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.keepOriginalImage = YES;
    self.quality = 100;
    self.dataArray = [NSMutableArray array];
    self.destinationButton.delegate = self;
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    [self.operationQueue addObserver:self forKeyPath:@"operations" options:0 context:NULL];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUI:) name:@"IMAGE_COMPROSSION_NOTIFICATION" object:nil];
}

- (void)updateUI:(NSNotification *)notification{
    NSDictionary *dictionary = notification.userInfo;
    NSString *fileName = [dictionary objectForKey:@"fileName"];
    self.desLabel.stringValue = fileName.length > 0 ?fileName:@"";
    self.circularProgress.progress = (self.dataArray.count-self.operationQueue.operations.count)*1.0/self.dataArray.count;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"IMAGE_COMPROSSION_NOTIFICATION" object:nil];
}


- (void)destinationButton:(DestinationButton *)destinationButton dataArray:(NSArray *)dataArray{
    if (dataArray.count) {
        __weak __typeof(self)weakSelf = self;
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_async(queue, ^{
            NSInteger count = self.dataArray.count;
            [dataArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                ImageCompressionOperation *operation = [[ImageCompressionOperation alloc] initWithIndex:(idx + count) filePath:obj];
                operation.quality = weakSelf.quality;
                operation.keepOriginalImage = weakSelf.keepOriginalImage;
                [weakSelf.dataArray addObject:operation];
                [weakSelf.operationQueue addOperation:operation];
            }];
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.circularProgress.hidden = NO;
                weakSelf.desLabel.hidden = NO;
                weakSelf.destinationButton.hidden = YES;
                weakSelf.checkBox.hidden = YES;
                weakSelf.qualityTipsLabel.hidden = YES;
                weakSelf.slider.hidden = YES;
                weakSelf.qualityLabel.hidden = YES;
                weakSelf.checkBoxLabel.hidden = YES;
                [weakSelf.collectionView reloadData];
            });
        });
    }
}

- (void)imageCompressionOperation:(ImageCompressionOperation *)imageCompressionOperation{
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:imageCompressionOperation.index inSection:0];
    [self.collectionView reloadItemsAtIndexPaths:[NSSet setWithObject:indexPath]];
}

- (NSInteger)numberOfSectionsInCollectionView:(NSCollectionView *)collectionView{
    return 1;
}

- (NSInteger)collectionView:(NSCollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.dataArray.count;
}

- (NSCollectionViewItem *)collectionView:(NSCollectionView *)collectionView itemForRepresentedObjectAtIndexPath:(NSIndexPath *)indexPath{
    ImageCompressionViewItem *viewItem = [collectionView  makeItemWithIdentifier:NSStringFromClass([ImageCompressionViewItem class]) forIndexPath:indexPath];
    ImageCompressionOperation *operation = self.dataArray[indexPath.item];
    operation.delegate = self;
    viewItem.operation = operation;
    if (!operation.thumbnailImage) {
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
            dispatch_async(queue, ^{
                NSImage *image = [[NSImage alloc] initWithContentsOfFile:operation.filePath];
                if (image.size.width > 100 || image.size.height > 100) {
                    image = [NSImage resizeWithSourceImage:image size:CGSizeMake(100, 100)];
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    operation.thumbnailImage = image;
                    viewItem.contentImageView.image = image;
                });
        });
    }
    return viewItem;
}

- (void)collectionView:(NSCollectionView *)collectionView didSelectItemsAtIndexPaths:(NSSet<NSIndexPath *> *)indexPaths{

}

//与用户交互的任务，这些任务通常跟UI级别的刷新相关，比如动画，这些任务需要在一瞬间完成.
//NSQualityOfServiceUserInteractive
// 由用户发起的并且需要立即得到结果的任务，比如滑动scroll view时去加载数据用于后续cell的显示，这些任务通常跟后续的用户交互相关，在几秒或者更短的时间内完成
//NSQualityOfServiceUserInitiated
// 一些可能需要花点时间的任务，这些任务不需要马上返回结果，比如下载的任务，这些任务可能花费几秒或者几分钟的时间
//NSQualityOfServiceUtility
// 一些可能需要花点时间的任务，这些任务不需要马上返回结果，比如下载的任务，这些任务可能花费几秒或者几分钟的时间
//NSQualityOfServiceBackground
// 一些可能需要花点时间的任务，这些任务不需要马上返回结果，比如下载的任务，这些任务可能花费几秒或者几分钟的时间
//NSQualityOfServiceDefault
- (NSOperationQueue *)operationQueue {
    if (!_operationQueue) {
        _operationQueue = [[NSOperationQueue alloc] init];
        _operationQueue.maxConcurrentOperationCount = 3;
        _operationQueue.qualityOfService = NSQualityOfServiceUserInteractive;
    }
    return _operationQueue;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    if (object == self.operationQueue && [keyPath isEqualToString:@"operations"]) {
        if ([self.operationQueue.operations count] == 0) {
            self.circularProgress.progress = 1;
            if (!self.operationQueue.operationCount) {
                NSMutableArray *sizeArray = [NSMutableArray array];
                NSMutableArray *compressSizeArray = [NSMutableArray array];
                dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
                dispatch_async(queue, ^{
                    [self.dataArray enumerateObjectsUsingBlock:^(ImageCompressionOperation *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        [sizeArray addObject: [NSNumber numberWithLong:obj.size]];
                        [compressSizeArray addObject: [NSNumber numberWithLong:obj.compressSize]];
                    }];
                    long size = [[sizeArray valueForKeyPath:@"@sum.longLongValue"] longLongValue];
                    long compressSize = [[compressSizeArray valueForKeyPath:@"@sum.longLongValue"] longLongValue];
                    long difference = size - compressSize;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.desLabel.stringValue = @"";
                        self.tipsLabel.stringValue = [NSString stringWithFormat:@"总计: %@    压缩: %@    压缩率: %.2f%%",[self fileSizeString:size],[self fileSizeString:difference],difference*1.0/size];
                        self.resetButton.hidden = NO;
                        self.tipsLabel.hidden = NO;
                        self.checkBox.hidden = YES;
                        self.qualityTipsLabel.hidden = YES;
                        self.slider.hidden = YES;
                        self.qualityLabel.hidden = YES;
                        self.checkBoxLabel.hidden = YES;
                    });
                });
            }
        }
    }else{
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
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

- (IBAction)resetAction:(NSButton *)sender {
    [self.dataArray removeAllObjects];
    [self.collectionView reloadData];
    self.desLabel.stringValue = @"";
    self.desLabel.hidden = YES;
    self.resetButton.hidden = YES;
    self.circularProgress.progress = 0;
    self.circularProgress.hidden = YES;
    self.destinationButton.hidden = NO;
    self.tipsLabel.hidden = YES;
    self.checkBox.hidden = NO;
    self.qualityTipsLabel.hidden = NO;
    self.slider.hidden = NO;
    self.qualityLabel.hidden = NO;
    self.checkBoxLabel.hidden = NO;
}

- (IBAction)selectImageAction:(NSButton *)sender {
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
      [openPanel setPrompt: @"Open"];
      [openPanel setCanChooseFiles:YES];
      [openPanel setCanChooseDirectories:YES];
      [openPanel setAllowsOtherFileTypes:YES];
      [openPanel setExtensionHidden:NO];
      [openPanel setAllowedFileTypes:@[@"png"]];
      openPanel.directoryURL = nil;
      
      __weak typeof(self)weakSelf = self;
      [openPanel beginSheetModalForWindow:self.view.window completionHandler:^(NSModalResponse returnCode) {
          if (returnCode == 1) {
              NSMutableArray *dataArray = [NSMutableArray array];
              NSURL *url = [openPanel URLs].firstObject;
              NSString *path = url.absoluteString;
              path = [path stringByReplacingOccurrencesOfString:@"file://" withString:@""];
              BOOL isDirectory;
              [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDirectory];
              dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
               dispatch_async(queue, ^{
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
                
                   dispatch_async(dispatch_get_main_queue(), ^{
                       [weakSelf destinationButton:self.destinationButton dataArray:dataArray];
                   });
               });
              
          }
      }];
}


- (IBAction)keepOriginalImageAction:(NSButton *)sender {
    self.keepOriginalImage = !self.keepOriginalImage;
}

- (IBAction)imageQualityAction:(NSSlider *)sender {
    self.quality = sender.integerValue;
    self.qualityLabel.stringValue = [NSString stringWithFormat:@"%ld%%",self.quality];

}

@end

