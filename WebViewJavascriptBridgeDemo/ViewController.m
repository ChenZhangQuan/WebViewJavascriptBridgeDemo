//
//  ViewController.m
//  WebViewJavascriptBridgeDemo
//
//  Created by 陈樟权 on 16/3/11.
//  Copyright © 2016年 陈樟权. All rights reserved.
//

#import "ViewController.h"
#import "WebViewJavascriptBridge.h"
#import "SDWebImageManager.h"
#import "UIImageView+WebCache.h"
#import "ZQCollectionCell.h"
#define kDeviceHeight [UIScreen mainScreen].bounds.size.height
#define kDeviceWidth [UIScreen mainScreen].bounds.size.width
#define kWS(xxx)   __weak typeof (self) xxx = self

@interface ViewController ()<UICollectionViewDataSource,UICollectionViewDelegate>
@property WebViewJavascriptBridge* bridge;
@property(nonatomic,strong) UIWebView *webView;
@property(nonatomic,strong) NSMutableArray *allImagesOfThisArticle;
@property(nonatomic,weak) UICollectionView *collectionView;
@property(nonatomic,weak) UIPageControl *pageControl;
@property(nonatomic,assign) NSInteger index;
@property(nonatomic,assign) CGRect rect;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // 2.创建一个webView，显示网页
    UIWebView *webView = [[UIWebView alloc] init];
    webView.frame = self.view.bounds;
    [self.view addSubview:webView];
    self.webView = webView;
    
    [WebViewJavascriptBridge enableLogging];
    //
    _bridge = [WebViewJavascriptBridge bridgeForWebView:webView];

    
    

    
    [_bridge registerHandler:@"ObjC Echo" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@"js调用了ObjC Echo %@", data);
    }];
    
    [_bridge registerHandler:@"downloadImages" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@"js调用了downloadImages %@", data);
        NSDictionary *dict = (NSDictionary *)data;
        [self downloadAllImagesInNative:dict[@"images"]];
    }];
    
    
    [_bridge registerHandler:@"imageDidClicked" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@"js调用了imageDidClicked %@", data);
        self.index = [[data objectForKey:@"index"] integerValue];
//        self.index--;
        CGFloat originX = [[data objectForKey:@"x"] floatValue];
        
        CGFloat originY = [[data objectForKey:@"y"] floatValue];
        
        CGFloat width   = [[data objectForKey:@"width"] floatValue];
        
        CGFloat height  = [[data objectForKey:@"height"] floatValue];
        
        self.rect = CGRectMake(originX, originY, width, height);
        
        [self imageClick:self.rect];
    }];
    
    
    
//    [self renderButtons:webView];
    [self loadExamplePage:webView];


    
}



- (void)renderButtons:(UIWebView*)webView {
    UIFont* font = [UIFont fontWithName:@"HelveticaNeue" size:12.0];
    
    UIButton *callbackButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [callbackButton setTitle:@"Call handler" forState:UIControlStateNormal];
    [callbackButton addTarget:self action:@selector(callHandler:) forControlEvents:UIControlEventTouchUpInside];
    [self.view insertSubview:callbackButton aboveSubview:webView];
    callbackButton.frame = CGRectMake(10, 400, 100, 35);
    callbackButton.titleLabel.font = font;
    
    UIButton* reloadButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [reloadButton setTitle:@"Reload webview" forState:UIControlStateNormal];
    [reloadButton addTarget:webView action:@selector(reload) forControlEvents:UIControlEventTouchUpInside];
    [self.view insertSubview:reloadButton aboveSubview:webView];
    reloadButton.frame = CGRectMake(110, 400, 100, 35);
    reloadButton.titleLabel.font = font;
}

- (void)callHandler:(id)sender {
    id data = @{ @"ocbackdata": @"1234567" };
    [_bridge callHandler:@"JS Echo" data:data responseCallback:^(id response) {
//        NSLog(@"testJavascriptHandler responded: %@", response);
    }];
}

- (void)loadExamplePage:(UIWebView*)webView {
    NSString* htmlPath = [[NSBundle mainBundle] pathForResource:@"ExampleApp" ofType:@"html"];
    NSString* appHtml = [NSString stringWithContentsOfFile:htmlPath encoding:NSUTF8StringEncoding error:nil];
    NSURL *baseURL = [NSURL fileURLWithPath:htmlPath];
    [webView loadHTMLString:appHtml baseURL:baseURL];
}

-(void)downloadAllImagesInNative:(NSArray *)imageUrls{
    
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    
    //初始化一个置空元素数组
    
    _allImagesOfThisArticle = [NSMutableArray arrayWithCapacity:imageUrls.count];//本地的一个用于保存所有图片的数组
    
    for (NSUInteger i = 0; i < imageUrls.count; i++) {
    
        [_allImagesOfThisArticle addObject:[NSNull null]];
        
    }
    
    for (NSUInteger i = 0; i < imageUrls.count; i++) {
        
        NSString *_url = imageUrls[i];
     
        [manager downloadImageWithURL:[NSURL URLWithString:_url] options:SDWebImageHighPriority progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {

            
            if (image) {
                [_allImagesOfThisArticle replaceObjectAtIndex:i withObject:image];
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    
                    //把图片在磁盘中的地址传回给JS
                    
                    NSString *key = [manager cacheKeyForURL:imageURL];
                    NSString *source = [manager.imageCache defaultCachePathForKey:key];
                    
                    [_bridge callHandler:@"imagesDownloadComplete" data:@[key,source]];
                    
                });
                
            }
            
        }];
        
    }
    
}




-(void)imageClick:(CGRect)rect{
;
    
    UIView *cover = [[UIView alloc] init];
    cover.frame = [UIScreen mainScreen].bounds;
    cover.backgroundColor = [UIColor blackColor];
    cover.alpha = 0;
    
    [self.navigationController.view addSubview:cover];
    [self.navigationController.view bringSubviewToFront:cover];
    NSAssert(self.index < 1000, @"Argument must be non-nil");
    
    
    UIImageView *tempImageView = [[UIImageView alloc] init];
    tempImageView.image = self.allImagesOfThisArticle[self.index];
    tempImageView.contentMode = UIViewContentModeScaleAspectFit;
    tempImageView.frame = rect;
    tempImageView.alpha = 0;
    tempImageView.userInteractionEnabled = YES;
    [self.navigationController.view addSubview:tempImageView];
    [self.navigationController.view bringSubviewToFront:tempImageView];
    
    [UIView animateWithDuration:0.25 animations:^{
        cover.alpha = 1;
        tempImageView.alpha = 1;
        tempImageView.frame = [UIScreen mainScreen].bounds;
        
    } completion:^(BOOL finished) {
        [cover removeFromSuperview];
        [tempImageView removeFromSuperview];
        [self setupCollectionView];
    }];
    
}

-(void)reduceImage:(UIImageView*)imageView{
    //先复制一张图片到最上面 而且带背景
    UIView *cover = [[UIView alloc] init];
    cover.frame = [UIScreen mainScreen].bounds;
    cover.backgroundColor = [UIColor blackColor];
    cover.alpha = 1;
    [self.navigationController.view addSubview:cover];
    
    CGRect rect = [imageView.superview convertRect:imageView.frame toView:self.navigationController.view];
    
    UIImageView *tempImageView = [[UIImageView alloc] init];
    //    tempImageView.backgroundColor = [UIColor whiteColor];
    tempImageView.image = imageView.image;
    tempImageView.contentMode = UIViewContentModeScaleAspectFit;
    tempImageView.frame = rect;
    tempImageView.userInteractionEnabled = YES;
    [self.navigationController.view addSubview:tempImageView];
    [self.navigationController.view bringSubviewToFront:tempImageView];
    
    //得到通过index当前图片所在的位置

    //    NSLog(@"%@",NSStringFromCGRect(selectedRect));
    
    [UIView animateWithDuration:0.25 animations:^{
        cover.alpha = 0;
        tempImageView.alpha = 0;
        tempImageView.frame = self.rect;
        
    } completion:^(BOOL finished) {
        [cover removeFromSuperview];
        [tempImageView removeFromSuperview];
        [self.collectionView removeFromSuperview];
        [self.pageControl removeFromSuperview];
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
        
    }];
}

-(void)setupCollectionView{
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.minimumInteritemSpacing = 0;
    flowLayout.minimumLineSpacing = 0;
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:[UIScreen mainScreen].bounds collectionViewLayout:flowLayout];
    collectionView.backgroundColor = [UIColor blackColor];
    collectionView.pagingEnabled = YES;
    collectionView.delegate = self;
    collectionView.dataSource = self;
    
    [self.navigationController.view addSubview:collectionView];
    [self.navigationController.view bringSubviewToFront:collectionView];
    self.collectionView = collectionView;
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    
    UIPageControl *pageControl = [[UIPageControl alloc] init];
    pageControl.frame = CGRectMake(0, kDeviceHeight - 150, kDeviceWidth, 150);
    pageControl.numberOfPages = self.allImagesOfThisArticle.count;
    pageControl.currentPage = self.index;
    [self.navigationController.view addSubview:pageControl];
    
    self.pageControl = pageControl;
    
    [collectionView registerClass:[ZQCollectionCell class] forCellWithReuseIdentifier:@"collectionCell"];
    
    [collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:self.index inSection:0] atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
    
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.allImagesOfThisArticle.count;
}

-(UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    
    ZQCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"collectionCell" forIndexPath:indexPath];
    

    cell.image = self.allImagesOfThisArticle[indexPath.row];
    kWS(weakSelf);
    cell.tapCell = ^(UIImageView *tapImageView){
        weakSelf.collectionView.hidden = YES;
        [weakSelf reduceImage:tapImageView];
    };
    
    cell.savePic = ^(UIImage*image){
        [weakSelf savePicToAlbum:image];
    };
    
    return cell;
    
    
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    CGSize size = self.collectionView.bounds.size;
    
    return size;
}

-(void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath{
    NSIndexPath *currentIndexPath = [self.collectionView indexPathsForVisibleItems].firstObject;
    self.index = currentIndexPath.item;
    self.pageControl.currentPage = self.index;
    
}

-(void)savePicToAlbum:(UIImage*)image{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"要保存到相册?" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *savePic = [UIAlertAction actionWithTitle:@"保存图片" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    }];
    [alertController addAction:savePic];
    UIAlertAction *cancelPic = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:cancelPic];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

-(void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
    if (error) {
        NSLog(@"保存失败");
    }else{
        NSLog(@"保存成功");
    }
    
}


@end
