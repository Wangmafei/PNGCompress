//
//  ImageCompressionModel.m
//  ToolLab
//
//  Created by Wangmafei on 2020/9/1.
//  Copyright © 2020 BLACK DRAGON LAB. All rights reserved.
//

#import "ImageCompressionOperation.h"
#import "PNGCompress-Swift.h"
#import "NSTaskWithProgress.h"
static ImageCompressionOperation *selfClass = nil;
@interface ImageCompressionOperation ()

@end
@implementation ImageCompressionOperation
@synthesize executing = _executing;
@synthesize finished = _finished;

- (instancetype)initWithIndex:(NSInteger)index filePath:(NSString *)filePath{
    self = [super init];
    if (self) {
        self.index = index;
        self.filePath = filePath;
        NSArray *array = [filePath componentsSeparatedByString:@"/"];
        self.fileName = array.lastObject;
    }
    return self;
}
 
- (void)start {
    @autoreleasepool{
        self.executing = YES;
        if (self.cancelled) {
            [self done];
            return;
        }
        
        //在这里定义自己的并发任务
        selfClass = self;
        self.size = [self sizeAtPath:self.filePath];
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            self.state = 1;
            [self postNotification];
        }];
        
        NSString *quality = [NSString stringWithFormat:@"--quality=%ld",(long)self.quality];
        NSString *ext = [NSString stringWithFormat:@"--ext=%@.png",self.keepOriginalImage?@"-new":@""];
        NSArray *arguments = @[@"--force",quality,@"--verbose",@"--strip",ext,self.filePath];
        
        NSString *launchPath = [[NSBundle mainBundle] pathForResource:@"pngquant" ofType:nil];
        [NSTaskWithProgress launchedTaskWithLaunchPath:launchPath arguments:arguments progress:^(NSTask *task, NSString *output) {
          
        } completion:^(NSTask *task, NSString *output) {
            self.state = 2;
            self.compressSize = [self sizeAtPath:self.filePath];
            [self postNotification];
            [self done];
        }];
    }
}

- (void)postNotification{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"IMAGE_COMPROSSION_NOTIFICATION" object:nil userInfo:@{@"fileName":self.fileName}];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(imageCompressionOperation:)]) {
      [self.delegate imageCompressionOperation:self];
    }
}

- (long long)sizeAtPath:(NSString *)path {
    NSFileManager *fm = [NSFileManager defaultManager];
    BOOL isDir = YES;
    if (![fm fileExistsAtPath:path isDirectory:&isDir]) {
        return 0;
    };
    unsigned long long fileSize = 0;
    if (isDir) {
        NSDirectoryEnumerator *enumerator = [fm enumeratorAtPath:path];
        while (enumerator.nextObject) {
            fileSize += enumerator.fileAttributes.fileSize;
        }
    } else {
        fileSize = [fm attributesOfItemAtPath:path error:nil].fileSize;
    }
    return fileSize;
}

// 任务执行完成，手动设置状态
- (void)done {
    self.finished = YES;
    self.executing = NO;
    selfClass = nil;
}

#pragma mark - setter -- getter
- (void)setExecuting:(BOOL)executing {
    //调用KVO通知
    [self willChangeValueForKey:@"isExecuting"];
    _executing = executing;
    //调用KVO通知
    [self didChangeValueForKey:@"isExecuting"];
}

- (BOOL)isExecuting {
    return _executing;
}

- (void)setFinished:(BOOL)finished {
    if (_finished != finished) {
        [self willChangeValueForKey:@"isFinished"];
        _finished = finished;
        [self didChangeValueForKey:@"isFinished"];
    }
}

- (BOOL)isFinished {
    return _finished;
}

// 返回YES 标识为并发Operation
- (BOOL)isAsynchronous {
    return YES;
}

//- (void)compressProgress:(float)progress{
//    self.state = 1;
//    if (progress > self.progress) {
//        self.progress = progress;
//    }
//    if (self.delegate && [self.delegate respondsToSelector:@selector(imageCompressionOperation:)]) {
//        [self.delegate imageCompressionOperation:self];
//    }
//}

//
//int progress_callback_function(float progress, void* user_info) {
//    if (selfClass) {
//        [selfClass compressProgress:progress];
//    }
//    return 1;
//}

//- (NSInteger)compress:(char*)path{
//    if (path == NULL) {
//        fprintf(stderr, "Please specify a path to a PNG file\n");
//        return EXIT_FAILURE;
//    }
//    const char *input_png_file_path = path;
//    
//    // Load PNG file and decode it as raw RGBA pixels
//    // This uses lodepng library for PNG reading (not part of libimagequant)
//    
//    unsigned int width, height;
//    unsigned char *raw_rgba_pixels;
//    unsigned int status = lodepng_decode32_file(&raw_rgba_pixels, &width, &height, input_png_file_path);
//    if (status) {
//        fprintf(stderr, "Can't load %s: %s\n", input_png_file_path, lodepng_error_text(status));
//        return EXIT_FAILURE;
//    }
//    
//    // Use libimagequant to make a palette for the RGBA pixels
//    
//    liq_attr *handle = liq_attr_create();
//    
//    liq_image *input_image = liq_image_create_rgba(handle, raw_rgba_pixels, width, height, 0);
////    liq_attr_set_progress_callback(handle, progress_callback_function, NULL);
//    // You could set more options here, like liq_set_quality
//    liq_result *quantization_result;
//    if (liq_image_quantize(input_image, handle, &quantization_result) != LIQ_OK) {
//        fprintf(stderr, "Quantization failed\n");
//        return EXIT_FAILURE;
//    }
//    
//    // Use libimagequant to make new image pixels from the palette
//    
//    size_t pixels_size = width * height;
//    unsigned char *raw_8bit_pixels = malloc(pixels_size);
//    liq_set_dithering_level(quantization_result, 1.0);
//    
//    liq_write_remapped_image(quantization_result, input_image, raw_8bit_pixels, pixels_size);
//    const liq_palette *palette = liq_get_palette(quantization_result);
//    
//    // Save converted pixels as a PNG file
//    // This uses lodepng library for PNG writing (not part of libimagequant)
//    
//    LodePNGState state;
//    lodepng_state_init(&state);
//    state.info_raw.colortype = LCT_PALETTE;
//    state.info_raw.bitdepth = 8;
//    state.info_png.color.colortype = LCT_PALETTE;
//    state.info_png.color.bitdepth = 8;
//    
//    for(int i=0; i < palette->count; i++) {
//        lodepng_palette_add(&state.info_png.color, palette->entries[i].r, palette->entries[i].g, palette->entries[i].b, palette->entries[i].a);
//        lodepng_palette_add(&state.info_raw, palette->entries[i].r, palette->entries[i].g, palette->entries[i].b, palette->entries[i].a);
//    }
//    
//    unsigned char *output_file_data;
//    size_t output_file_size;
//    unsigned int out_status = lodepng_encode(&output_file_data, &output_file_size, raw_8bit_pixels, width, height, &state);
//    if (out_status) {
//        fprintf(stderr, "Can't encode image: %s\n", lodepng_error_text(out_status));
//        return EXIT_FAILURE;
//    }
//    
//    const char *output_png_file_path = path;
//    FILE *fp = fopen(output_png_file_path, "wb");
//    if (!fp) {
//        fprintf(stderr, "Unable to write to %s\n", output_png_file_path);
//        return EXIT_FAILURE;
//    }
//    fwrite(output_file_data, 1, output_file_size, fp);
//    fclose(fp);
//    
////    printf("Written %s\n", output_png_file_path);
//    
//    // Done. Free memory.
//    
//    liq_result_destroy(quantization_result); // Must be freed only after you're done using the palette
//    liq_image_destroy(input_image);
//    liq_attr_destroy(handle);
//    free(raw_8bit_pixels);
//    lodepng_state_cleanup(&state);
//    return EXIT_SUCCESS;
//}
@end
