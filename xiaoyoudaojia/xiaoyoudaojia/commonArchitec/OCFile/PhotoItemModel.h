//
//  PhotoItemModel.h
//  ImgPickerDemo
//
//  Created by 世纪阳天 on 16/11/14.
//  Copyright © 2016年 世纪阳天. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface PhotoItemModel : NSObject

@property (nonatomic , assign) BOOL isSelect;
@property (nonatomic , copy) UIImage *smallImg;
@property (nonatomic , copy) UIImage *bigImg;

@end
