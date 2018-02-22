//
//  SelectImgsViewController.h
//  ImgPickerDemo
//
//  Created by 世纪阳天 on 16/11/14.
//  Copyright © 2016年 世纪阳天. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhotoCollectionViewCell.h"

@interface SelectImgsViewController : UIViewController<PhotoOperationDelegate>

@property (assign, nonatomic) NSInteger maxNum;
- (void)addCallBack:(void(^)(NSArray *))block;

- (void)sendResult;


@end
