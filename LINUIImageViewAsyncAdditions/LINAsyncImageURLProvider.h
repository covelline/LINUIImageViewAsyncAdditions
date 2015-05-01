//
//  LINAsyncImageURLProvider.h
//  LINUIImageViewAsyncAdditions
//
//  Copyright (c) 2015年 com.covelline. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NSDictionary *(^LINAsyncImageDownloadHeadersFilterBlock)(NSURL *url, NSDictionary *headers);
typedef void (^LINAsyncImageResolvedURLDidGetBlock)(NSURL *resolvedURL, NSError *error);

/**
 
 画像の取得に必要な情報を提供する.

 */
@protocol LINAsyncImageURLProvider <NSObject>

/**

 画像の URL を取得する.

 非同期になっているのは Flickr 等の API を経由しないと 画像 URL が取得できないサービスに対応するため.

 didGetImageURLBlock は同一スレッドで呼ばれる場合もあるし、非同期に呼ばれる場合もある.

 @param didGetImageURLBlock
 - resolvedURL: 画像の URL. 解決に失敗した場合は nil になる.
 - error: 解決に失敗した時にエラー情報
 */
- (void)resolveImageURL:(LINAsyncImageResolvedURLDidGetBlock)didGetImageURLBlock;

/**
 
 解決済みの URL をキャッシュするかどうか. YES: キャッシュする.

 */
- (BOOL)shouldCacheResolvedURL;

/**

 解決済みの URL をキャッシュする一意な key を返す.

 */
- (NSString *)resolvedURLCacheKey;

@optional

/**

 リクエストの header の内容を書き換える必要がある場合は
 このメソッドをオーバライドして header を書き換えるブロックを返す.

 ex)
 DirectMessage の画像の場合は画像を取得するリクエストの header に
 "Authorization" header を付ける必要がある
 */
- (LINAsyncImageDownloadHeadersFilterBlock)headersFilterBlock;

@end
