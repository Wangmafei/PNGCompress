//
//  DestinationButton.h
//  ToolLab
//
//  Created by Wangmafei on 2020/9/1.
//  Copyright © 2020 BLACK DRAGON LAB. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN
@class DestinationButton;
@protocol DestinationButtonDelegate <NSObject>

@optional
- (void)destinationButton:(DestinationButton *)destinationButton dataArray:(NSArray *)dataArray;
@end

@interface DestinationButton : NSButton
@property (nonatomic, weak) id <DestinationButtonDelegate> delegate;
@property (nonatomic) BOOL isReceivingDrag;
@end

NS_ASSUME_NONNULL_END
