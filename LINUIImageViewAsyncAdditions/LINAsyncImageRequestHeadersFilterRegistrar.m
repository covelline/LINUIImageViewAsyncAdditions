//
//  LINAsyncImageRequestHeadersFilterRegistrar.m
//  LINUIImageViewAsyncAdditions
//
//  Copyright (c) 2015年 com.covelline. All rights reserved.
//

#import "LINAsyncImageRequestHeadersFilterRegistrar.h"

#import <SDWebImage/SDWebImageDownloader.h>

@interface LINAsyncImageRequestHeadersFilterRegistrar ()

@property (nonatomic) NSMutableDictionary *blocks;

@end

@implementation LINAsyncImageRequestHeadersFilterRegistrar

+ (instancetype)sharedRegistrar {

    static LINAsyncImageRequestHeadersFilterRegistrar *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [LINAsyncImageRequestHeadersFilterRegistrar new];
    });
    return instance;
}

#pragma mark -

- (instancetype)init {
    self = [super init];
    if (self) {

        _blocks = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)registerFilterBlock:(LINAsyncImageDownloadHeadersFilterBlock)block forURL:(NSURL *)url {

    if (block == nil || url == nil) {
        return;
    }

    @synchronized(self) {

        _blocks[url.absoluteString] = block;

        if (SDWebImageDownloader.sharedDownloader.headersFilter == nil) {

            __weak typeof(self) wself = self;
            SDWebImageDownloader.sharedDownloader.headersFilter = ^NSDictionary *(NSURL *url, NSDictionary *headers) {

                @synchronized(wself) {
                    LINAsyncImageDownloadHeadersFilterBlock block = wself.blocks[url.absoluteString];
                    if (block) {
                        return block(url, headers);
                    }
                }
                return headers;
            };
        }
    }
}


- (void)unregisterFilterBlockForURL:(NSURL *)url {

    if (url == nil) {
        return;
    }

    @synchronized(self) {

        [_blocks removeObjectForKey:url.absoluteString];

        if (_blocks.count == 0 && SDWebImageDownloader.sharedDownloader.headersFilter != nil) {
            SDWebImageDownloader.sharedDownloader.headersFilter = nil;
            
        }
    }
}

@end


