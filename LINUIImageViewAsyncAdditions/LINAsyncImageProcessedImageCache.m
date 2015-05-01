//
//  LINAsyncImageProcessedImageCache.m
//  LINUIImageViewAsyncAdditions
//
//  Copyright (c) 2015年 com.covelline. All rights reserved.
//

#import "LINAsyncImageProcessedImageCache.h"

@interface LINAsyncImageProcessedImageCache ()

@property (nonatomic) NSCache *memCache;

@end

@implementation LINAsyncImageProcessedImageCache

+ (instancetype)sharedCache {

    static LINAsyncImageProcessedImageCache *instance;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [self new];
    });

    return instance;
}

#pragma mark -

- (instancetype)init {
    self = [super init];
    if (self) {
        _memCache = [NSCache.alloc init];
        _memCache.name = NSStringFromClass(self.class);
        _memCache.countLimit = 200;
    }
    return self;
}

- (void)storeImage:(UIImage *)image forKey:(NSString *)key {

    if (image == nil || key == nil) {
        return;
    }

    [_memCache setObject:image forKey:key];
}

- (UIImage *)imageForKey:(NSString *)key {

    if (key == nil) {
        return nil;
    }
    return [_memCache objectForKey:key];
}

@end
