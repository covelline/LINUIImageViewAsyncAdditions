//
//  LINAsyncImageRequestHeadersFilterRegistrar.h
//  LINUIImageViewAsyncAdditions
//
//  Copyright (c) 2015年 com.covelline. All rights reserved.
//

#import "LINAsyncImageURLProvider.h"

/**
 
 SDWebImage で作られるリクエストの Header に割り込むためのブロックを管理する

 */
@interface LINAsyncImageRequestHeadersFilterRegistrar : NSObject

+ (instancetype)sharedRegistrar;

#pragma mark -

- (void)registerFilterBlock:(LINAsyncImageDownloadHeadersFilterBlock)block forURL:(NSURL *)url;

- (void)unregisterFilterBlockForURL:(NSURL *)url;

@end
