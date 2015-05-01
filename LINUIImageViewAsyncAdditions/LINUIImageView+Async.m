//
//  LINUIImageView+Async.m
//  LINUIImageViewAsyncAdditions
//
//  Copyright (c) 2015年 com.covelline. All rights reserved.
//

#import "LINUIImageView+Async.h"

#import <objc/runtime.h>
#import <SDWebImage/UIImageView+WebCache.h>

#import "LINAsyncImageURLProvider.h"
#import "LINAsyncProcessedImageURLProvider.h"
#import "LINAsyncImageRequestHeadersFilterRegistrar.h"
#import "LINAsyncImageResolvedURLCache.h"
#import "LINAsyncImageProcessedImageCache.h"

static char asyncProviderKey;

@implementation UIImageView (LINUIImageViewAsyncAdditions)

- (id<LINAsyncImageURLProvider>)lin_provider {
    return objc_getAssociatedObject(self, &asyncProviderKey);
}

- (void)lin_setImageProvider:(id<LINAsyncImageURLProvider>)provider
                   completed:(SDWebImageCompletionBlock)completedBlock {

    [self lin_setImageProvider:provider
              placeholderImage:nil
                       options:SDWebImageRetryFailed
                     completed:completedBlock];
}

- (void)lin_setImageProvider:(id<LINAsyncImageURLProvider>)provider
            placeholderImage:(UIImage *)placeholder
                     options:(SDWebImageOptions)options
                   completed:(SDWebImageCompletionBlock)completedBlock {

    [self lin_setImageProvider:provider
              placeholderImage:placeholder
                       options:options
                      progress:nil
                     completed:completedBlock];
}

- (void)lin_setImageProvider:(id<LINAsyncImageURLProvider>)provider
            placeholderImage:(UIImage *)placeholder
                     options:(SDWebImageOptions)options
                    progress:(SDWebImageDownloaderProgressBlock)progressBlock
                   completed:(SDWebImageCompletionBlock)completedBlock {
    
    objc_setAssociatedObject(self, &asyncProviderKey, provider, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    // sd_setImageWithURL の内部でキャンセルの処理を行っているが resolveImageURL で
    // 時間がかかることを考慮してここでキャンセルを行っておく
    [self sd_cancelCurrentImageLoad];
    
    __weak UIImageView *wself = self;
    void (^downloadImageWithURL)(NSURL *resolvedURL) = ^void(NSURL *resolvedURL) {
        typeof(wself) sSelf = wself;
        
        if ([provider conformsToProtocol:@protocol(LINAsyncProcessedImageURLProvider)]) {
            
            // 加工済み画像がキャッシュされていたらそれを使って終了.
            
            NSString *processedImageCacheKey = ((id <LINAsyncProcessedImageURLProvider>)provider).processedImageCacheKey;
            UIImage *processedImage =  [[LINAsyncImageProcessedImageCache sharedCache] imageForKey:processedImageCacheKey];
            
            if (processedImage) {
                
                dispatch_main_sync_safe(^{
                    
                    sSelf.image = processedImage;
                    
                    if (completedBlock) {
                        completedBlock(processedImage, nil, SDImageCacheTypeMemory, resolvedURL);
                    }
                });
                return;
            }
        }
        
        if ([provider respondsToSelector:@selector(headersFilterBlock)]) {
            
            LINAsyncImageDownloadHeadersFilterBlock block = provider.headersFilterBlock;
            if (block) {
                [LINAsyncImageRequestHeadersFilterRegistrar.sharedRegistrar registerFilterBlock:block forURL:resolvedURL];
            }
        }
        
        [sSelf sd_setImageWithURL:resolvedURL
                 placeholderImage:placeholder
                          options:options
                         progress:progressBlock
                        completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                            
                            [LINAsyncImageRequestHeadersFilterRegistrar.sharedRegistrar unregisterFilterBlockForURL:imageURL];
                            
                            if ([provider isEqual:sSelf.lin_provider] == NO) {
                                // provider が変更された場合は終了
                                return;
                            }
                            
                            if ([provider conformsToProtocol:@protocol(LINAsyncProcessedImageURLProvider)]) {
                                
                                id <LINAsyncProcessedImageURLProvider> processProvider = (id <LINAsyncProcessedImageURLProvider>)provider;
                                
                                [processProvider processImageWithOriginalImage:image
                                                           forResolvedImageURL:imageURL
                                                             didProcessedBlock:^(UIImage *processedImage) {
                                                                 
                                                                 if (processProvider.shouldCacheProcessedImage) {
                                                                     
                                                                     [LINAsyncImageProcessedImageCache.sharedCache storeImage:processedImage
                                                                                                                       forKey:processProvider.processedImageCacheKey];
                                                                 }
                                                                 
                                                                 if ([sSelf.lin_provider isEqual:provider] == NO) {
                                                                     // provider が変更された場合は終了
                                                                     return;
                                                                 }
                                                                 
                                                                 dispatch_main_sync_safe(^{
                                                                     sSelf.image = processedImage;
                                                                     if (completedBlock) {
                                                                         completedBlock(processedImage, error, cacheType, imageURL);
                                                                     }
                                                                 });
                                                             }];
                            } else {
                                
                                if (completedBlock) {
                                    completedBlock(image, error, cacheType, imageURL);
                                }
                            }
                        }];
    };
    
    /*
     
     最初にキャッシュされている URL が使用可能かどうかをチェックして
     URL がキャッシュされていなかったら解決しにいく
     
     */
    if (provider.shouldCacheResolvedURL
        && [LINAsyncImageResolvedURLCache.sharedURLCache URLForKey:provider.resolvedURLCacheKey]) {
        
        NSURL *cachedURL = [LINAsyncImageResolvedURLCache.sharedURLCache URLForKey:provider.resolvedURLCacheKey];
        
        downloadImageWithURL(cachedURL);
        
    } else {
        
        [provider resolveImageURL:^(NSURL *resolvedURL, NSError *error) {
            typeof (self) sSelf = wself;
            
            if (sSelf == nil) {
                return;
            }

            if ([sSelf.lin_provider isEqual:provider] == NO) {
                // provider が変更された場合は終了
                return;
            }
            
            if (error) {
                
                if (completedBlock) {
                    dispatch_main_sync_safe(^{
                        completedBlock(nil, error, SDImageCacheTypeNone, resolvedURL);
                    });
                }
                return;
            }
            
            if (provider.shouldCacheResolvedURL) {
                [LINAsyncImageResolvedURLCache.sharedURLCache storeURL:resolvedURL forKey:provider.resolvedURLCacheKey];
            }
            
            downloadImageWithURL(resolvedURL);
        }];
    }
}

- (void)lin_cancelCurrentImageLoad {
    [self sd_cancelCurrentImageLoad];
}

@end
