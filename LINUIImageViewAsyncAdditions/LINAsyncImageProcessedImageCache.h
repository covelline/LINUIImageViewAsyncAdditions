//
//  LINAsyncImageProcessedImageCache.h
//  LINUIImageViewAsyncAdditions
//
//  Copyright (c) 2015年 com.covelline. All rights reserved.
//

#import <Foundation/Foundation.h>

@class UIImage;

/*
 
 加工済み画像のキャッシュ

 */
@interface LINAsyncImageProcessedImageCache : NSObject

#pragma mark -

+ (instancetype)sharedCache;

- (void)storeImage:(UIImage *)image forKey:(NSString *)key;

- (UIImage *)imageForKey:(NSString *)key;

@end
