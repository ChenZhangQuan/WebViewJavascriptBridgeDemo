//
//  ZQCollectionCell.h
//  ZQJiemian
//
//  Created by czq on 15/12/14.
//  Copyright (c) 2015年 陈樟权. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ZQCollectionCell : UICollectionViewCell


@property(nonatomic,strong)UIImage *image;

@property(nonatomic,assign)NSInteger page;

@property(nonatomic,copy)void(^tapCell)(UIImageView *imageView);

@property(nonatomic,copy)void(^savePic)(UIImage *image);

@end
