//
//  LINAsyncImageResolvedURLCache.m
//  LINUIImageViewAsyncAdditions
//
//  Copyright (c) 2015年 com.covelline. All rights reserved.
//

#import "LINAsyncImageResolvedURLCache.h"

@interface LINAsyncImageResolvedURLCache()

@property (nonatomic) NSCache *memCache;

@end

@implementation LINAsyncImageResolvedURLCache

+ (instancetype)sharedURLCache {

    static LINAsyncImageResolvedURLCache *instance;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{

        instance = [self new];
    });

    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {

        _memCache = [NSCache.alloc init];
        _memCache.name = NSStringFromClass(self.class);
        _memCache.countLimit = 1000; // 大した容量じゃないから多めにキャッシュする
    }
    return self;
}

- (void)storeURL:(NSURL *)resolvedURL forKey:(NSString *)key {
    if (resolvedURL == nil || key == nil) {
        return;
    }

    [_memCache setObject:resolvedURL.absoluteString forKey:key];
}

- (NSURL *)URLForKey:(NSString *)key {

    if (key == nil) {
        return nil;
    }

    NSString *urlString = [_memCache objectForKey:key];

    if (urlString == nil) {
        return nil;
    }

    return [NSURL URLWithString:urlString];
}

@end
