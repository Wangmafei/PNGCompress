//
//  ImageCompressionViewItem.h
//  ToolLab
//
//  Created by Wangmafei on 2020/9/1.
//  Copyright © 2020 BLACK DRAGON LAB. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ImageCompressionOperation.h"
NS_ASSUME_NONNULL_BEGIN

@interface ImageCompressionViewItem : NSCollectionViewItem
@property (nonatomic, strong) ImageCompressionOperation *operation;
@property (weak) IBOutlet NSImageView *contentImageView;
@end

NS_ASSUME_NONNULL_END
