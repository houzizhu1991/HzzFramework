//
//  PhotoCollectionViewCell.h
//  ImgPickerDemo
//
//  Created by 世纪阳天 on 16/11/14.
//  Copyright © 2016年 世纪阳天. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhotoItemModel.h"

@protocol PhotoOperationDelegate <NSObject>

- (void)convertActionWithCellIndex:(NSInteger)index;

@end

@interface PhotoCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIButton *selectBtn;
@property (weak, nonatomic) IBOutlet UIImageView *contentPhoto;
@property (weak, nonatomic) IBOutlet UIImageView *coverView;

@property (nonatomic , assign) NSInteger itemIndex;
@property (nonatomic , weak) id <PhotoOperationDelegate> delegate;

- (void)configWithModel:(PhotoItemModel *)model;

@end
