//
//  ZQCollectionCell.m
//  ZQJiemian
//
//  Created by czq on 15/12/14.
//  Copyright (c) 2015年 陈樟权. All rights reserved.
//

#import "ZQCollectionCell.h"
#import "UIView+Extension.h"
#import "UIImageView+WebCache.h"
#define detailViewH 50
#define kDeviceHeight [UIScreen mainScreen].bounds.size.height
#define kDeviceWidth [UIScreen mainScreen].bounds.size.width
@interface ZQCollectionCell()

@property(nonatomic,weak)UIImageView *imageView;
@property(nonatomic,weak)UIView *detailView;
@property(nonatomic,weak)UILabel *titleView;

@end

@implementation ZQCollectionCell

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        UIImageView *imageView =[[UIImageView alloc] init];
        [self.contentView addSubview:imageView];
        self.imageView = imageView;
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.layer.cornerRadius = 8;
        imageView.layer.masksToBounds = YES;
        imageView.userInteractionEnabled = YES;
        [imageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageViewClick)]];
        [imageView addGestureRecognizer:[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(imageViewLongPress)]];
        
        
    }
    return self;
}



-(void)setImage:(UIImage *)image{
    _image = image;
    
    self.imageView.image = image;

    
    [self setNeedsLayout];
}

-(void)layoutSubviews{
    [super layoutSubviews];

    self.imageView.frame = CGRectMake(0, 0, kDeviceWidth, kDeviceHeight);


}

-(void)imageViewClick{
    if(self.tapCell){
        self.tapCell(self.imageView);
    }
}

-(void)imageViewLongPress{
    if (self.savePic) {
        self.savePic(self.imageView.image);
    }
}

@end
