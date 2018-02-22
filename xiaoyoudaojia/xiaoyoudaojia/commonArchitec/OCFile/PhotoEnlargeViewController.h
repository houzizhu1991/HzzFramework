//
//  PhotoEnlargeViewController.h
//  ImgPickerDemo
//
//  Created by 世纪阳天 on 16/11/14.
//  Copyright © 2016年 世纪阳天. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhotoItemModel.h"
@class SelectImgsViewController;

@interface PhotoEnlargeViewController : UIViewController

@property (assign ,nonatomic) NSInteger maxNum;

@property (strong ,nonatomic) NSMutableArray *sourceArr;

// weak reference
@property (weak ,nonatomic) SelectImgsViewController *observedVC;


@property (nonatomic ,assign) NSInteger curIndex;

@property (nonatomic, assign) BOOL canDelete;

@property (nonatomic, copy) void (^deleteBlock)(NSInteger index);

@end
