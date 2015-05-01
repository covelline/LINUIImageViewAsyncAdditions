//
//  LINUIImageView+Async.h
//  LINUIImageViewAsyncAdditions
//
//  Copyright (c) 2015年 com.covelline. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <SDWebImage/SDWebImageManager.h>

@protocol LINAsyncImageURLProvider;

/**

 Async ( ˘ω˘)

 */
@interface UIImageView (LINUIImageViewAsyncAdditions)

- (id<LINAsyncImageURLProvider>)lin_provider;


/**
 
 便利な方.

 */
- (void)lin_setImageProvider:(id <LINAsyncImageURLProvider>)provider
                   completed:(SDWebImageCompletionBlock)completedBlock;

/**

 options とかは `UIImage+WebCache` を参照.

 */
- (void)lin_setImageProvider:(id <LINAsyncImageURLProvider>)provider
            placeholderImage:(UIImage *)placeholder
                     options:(SDWebImageOptions)options
                   completed:(SDWebImageCompletionBlock)completedBlock;

- (void)lin_cancelCurrentImageLoad;

@end
