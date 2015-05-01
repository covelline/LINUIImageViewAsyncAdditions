# LINUIImageViewAsyncAdditions

( ˘ω˘) Async ( ˘ω˘) Rely on SDWebImage ( ˘ω˘)

This is draft... ( ˘ω˘)

But we have used in [feather for Twitter](http://appstore.com/featherfortwitter "feather for Twitter"). ( ˘ω˘)

SDWebImage can asynchronous "image" download.

LINUIImageViewAsyncAdditions can asynchronous "image" download and asynchronous "URL" resolve.

e.g.

In order to getting Flickr image URL from Flickr short URL, We request to Flickr API.

## Example


### Implementation LINAsyncImageURLProvider

```objc

@interface FlickrImageIdentifier : NSObject <LINAsyncImageURLProvider>

- (instancetype)initWithFlickrShortURLString:(NSString*)urlString;

@end

```

```objc

@implementation FlickrImageIdentifier

- (instancetype)initWithFlickrShortURLString:(NSString *)urlString {
  // initialize code
  //e.g. _urlString = urlString;
}

#pragma mark - LINAsyncImageURLProvider

- (void)resolveImageURL:(LINAsyncImageResolvedURLDidGetBlock)didGetImageURLBlock {

  NSURL *URL = [NSURL URLWithString:self.urlString];

  // Asynchronous resolve Flickr image URL. using FlickrKit.

  FKFlickrPhotosGetSizes *getSizes = [FKFlickrPhotosGetSizes.alloc init];
  getSizes.photo_id = self.urlString.tb_flickrPhotoID;

  FlickrKit *fk = FlickrKit.sharedFlickrKit;
  [fk call:getSizes completion:^(NSDictionary *response, NSError *error) {

    if (error) {
      return didGetImageURLBlock(nil, URL);
    }

    NSArray *sizes = [[response valueForKeyPath:@"sizes.size"] asArray];
    if (sizes.count == 0) {
      return didGetImageURLBlock(nil, URL);
    }

    NSURL *imageURL = [self bestSizeURLWith:sizes];
    didGetImageURLBlock(imageURL, URL);
  }];
}

// Caching Resolved URL

- (BOOL)shouldCacheResolvedURL {
    return YES;
}

- (NSString *)resolvedURLCacheKey {
    return self.urlString;
}

@end

```

### Load Image

```objc
@implementation FlickrImageView

- (void)setFlickrShortURL:(NSString *)urlString {

  FlickrImageIdentifier *identifier = [FlickrImageIdentifier.alloc initWithFlickrShortURLString:urlString];

  // async resolve url and async download image
  [_imageView lin_setImageProvider:identifier completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
    // hogehoge
  }];
}

@end

```

### Processed Image Feature

Use `LINAsyncProcessedImageURLProvider`.

```objc

@interface CircleImageIdentifier : NSObject <LINAsyncProcessedImageURLProvider>

- (instancetype)initWithURLString:(NSString *)urlString;

@end

```

```objc

@implementation CircleImageIdentifier

- (instancetype)initWithURLString:(NSString *)urlString {
  // initialize code
}

#pragma mark - LINAsyncImageURLProvider

// - resolve url code

#pragma mark - AsyncProcessedImageURLProvider

- (void)processImageWithOriginalImage:(UIImage *)originalImage
                  forResolvedImageURL:(NSURL *)resolvedImageURL
                    didProcessedBlock:(void (^)(UIImage *))didProcessedBlock {

    // do not UI Thread.
    dispatch_async(self.class.processQueue, ^{

        // Processing to round the image...

        didProcessedBlock(processedImage);
    });
}

// Caching Processed Image

- (BOOL)shouldCacheProcessedImage {
    return YES;
}

- (NSString *)processedImageCacheKey {
  // uniq key
  return _processedImageKey;
}


```

## TODO

- Add test
- Add cocoapods
