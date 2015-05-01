//
//  LINAsyncProcessedImageURLProvider.h
//  LINUIImageViewAsyncAdditions
//
//  Copyright (c) 2015年 com.covelline. All rights reserved.
//

#import "LINAsyncImageURLProvider.h"

/**

 何らかの加工をした画像をキャッシュから取得する方法と加工した画像を保存する方法を提供する

 */
@protocol LINAsyncProcessedImageURLProvider <LINAsyncImageURLProvider>

/**

 加工済みの 画像をキャッシュするかどうか. YES: キャッシュする.

 */
- (BOOL)shouldCacheProcessedImage;

/**

 加工済みの画像をキャッシュする一意な key を返す.

 */
- (NSString *)processedImageCacheKey;

/**

 画像を加工して保存する.

 @param originalImage 元の画像
 @param resolvedImageURL 画像の URL
 @param didProcessedBlock 加工が完了した時に呼び出される. processedImage には加工済みの画像が入ってくる.

 */
- (void)processImageWithOriginalImage:(UIImage *)originalImage
                  forResolvedImageURL:(NSURL *)resolvedImageURL
                    didProcessedBlock:(void (^)(UIImage *processedImage))didProcessedBlock;


@end
