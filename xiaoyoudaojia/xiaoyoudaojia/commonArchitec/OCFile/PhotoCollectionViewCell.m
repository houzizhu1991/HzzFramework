//
//  PhotoCollectionViewCell.m
//  ImgPickerDemo
//
//  Created by 世纪阳天 on 16/11/14.
//  Copyright © 2016年 世纪阳天. All rights reserved.
//

#import "PhotoCollectionViewCell.h"

@implementation PhotoCollectionViewCell

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];

    UIImage *renderImg = [self imageWithTintColor:[UIColor colorWithRed:52/255.0 green:166/255.0 blue:171/255.0 alpha:1] blendMode:kCGBlendModeOverlay image:[UIImage imageNamed:@"check_box"]];
    
    [self.selectBtn setBackgroundImage:[UIImage imageNamed:@"check_box_outline_blank"] forState:UIControlStateNormal];
    [self.selectBtn setBackgroundImage:renderImg forState:UIControlStateSelected];
}

- (IBAction)click:(id)sender {
    if ([self.delegate conformsToProtocol:@protocol(PhotoOperationDelegate) ]) {
        if ([self.delegate respondsToSelector:@selector(convertActionWithCellIndex:)]) {
            [self.delegate convertActionWithCellIndex:self.itemIndex];
        }
    }
}


- (void)configWithModel:(PhotoItemModel *)model {
    self.contentPhoto.image = model.smallImg;
    self.coverView.hidden   = !model.isSelect;
    self.selectBtn.selected = model.isSelect;
    
}

- (UIImage *) imageWithTintColor:(UIColor *)tintColor blendMode:(CGBlendMode)blendMode image:(UIImage *)img{
    
    //We want to keep alpha, set opaque to NO; Use 0.0f for scale to use the scale factor of the device’s main screen.
    UIGraphicsBeginImageContextWithOptions(img.size, NO, 0.0f);
    [tintColor setFill];
    CGRect bounds = CGRectMake(0, 0, img.size.width, img.size.height);
    UIRectFill(bounds);
    
    //Draw the tinted image in context
    [img drawInRect:bounds blendMode:blendMode alpha:1.0f];
    
    if (blendMode != kCGBlendModeDestinationIn) {
        [img drawInRect:bounds blendMode:kCGBlendModeDestinationIn alpha:1.0f];
    }
    
    UIImage *tintedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return tintedImage;
    
}



@end
