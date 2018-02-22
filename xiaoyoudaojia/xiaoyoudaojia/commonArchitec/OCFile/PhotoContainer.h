//
//  PhotoContainer.h
//  ImgPickerDemo
//
//  Created by 世纪阳天 on 16/11/15.
//  Copyright © 2016年 世纪阳天. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotoContainer : UIImageView
{
    UIImageView *_content;
    UIScrollView *_scroll;
    CGFloat  _lastScale;
}

- (void)recoverScale;

@end
