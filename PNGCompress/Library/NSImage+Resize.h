//
//  NSImage+Resize.h
//  ToolLab
//
//  Created by Wangmafei on 2020/9/1.
//  Copyright © 2020 BLACK DRAGON LAB. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSImage (Resize)
+ (NSImage *)resizeWithSourceImage:(NSImage*)sourceImage size:(CGSize)size;
@end

NS_ASSUME_NONNULL_END
