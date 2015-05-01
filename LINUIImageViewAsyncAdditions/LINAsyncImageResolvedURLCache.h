//
//  LINAsyncImageResolvedURLCache.h
//  LINUIImageViewAsyncAdditions
//
//  Copyright (c) 2015年 com.covelline. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 
 不要な通信を防ぐために解決済みの URL を保存しておくキャッシュ.
 
 NSCache を使っているので勝手に開放される.

 */
@interface LINAsyncImageResolvedURLCache : NSObject

+ (instancetype)sharedURLCache;

/**

 URL をキャッシュする.

 */
- (void)storeURL:(NSURL *)resolvedURL forKey:(NSString *)key;

/**

 解決済みの URL を取得する.
 キャッシュに存在しない場合は nil.

 */
- (NSURL *)URLForKey:(NSString *)key;

@end
