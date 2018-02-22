//
//  PhotoContainer.m
//  ImgPickerDemo
//
//  Created by 世纪阳天 on 16/11/15.
//  Copyright © 2016年 世纪阳天. All rights reserved.
//

#import "PhotoContainer.h"


const float maxScale = 4;
const float minScale = 0.6;

@implementation PhotoContainer

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc]initWithTarget:self action:@selector(imgScaleChanged:)];
        [self addGestureRecognizer:pinch];
        
        _scroll = [[UIScrollView alloc]initWithFrame:self.bounds];
        _scroll.showsHorizontalScrollIndicator = NO;
        _scroll.showsVerticalScrollIndicator = NO;
        [self addSubview:_scroll];
        
        _lastScale = 1.0f;
        
        _content = [[UIImageView alloc]initWithFrame:_scroll.bounds];
        [_scroll addSubview:_content];
        
    }
    return self;

}

// override
- (void)setImage:(UIImage *)image {
    _content.image = image;

}

- (void)setContentMode:(UIViewContentMode)contentMode {
    _content.contentMode = contentMode;
}

#pragma mark 捏合手势
- (void)imgScaleChanged:(UIPinchGestureRecognizer *)pin {
    
    CGFloat scale = pin.scale;
    if (pin.state == UIGestureRecognizerStateBegan) {
    
    }
    if (pin.state == UIGestureRecognizerStateChanged) {
            NSLog(@"((((((((%f",pin.scale);
        
//            lastScale = self.scale
//
//            CGAffineTransform currentTransform = _content.transform;
//            CGAffineTransform newTransform = CGAffineTransformScale(currentTransform, scale, scale);
//            _content.transform = newTransform;
        
        //放大情况
//        if(scale > 1.0){
//            if(_lastScale > maxScale) return;
//        }
//        
//        //缩小情况
//        if (scale < 1.0) {
//            if (_lastScale < minScale) return;
//        }
        
        _content.transform = CGAffineTransformScale(_content.transform, scale, scale);
        _lastScale *=scale;
        pin.scale = 1.0;
        
           // frame 已经改变
            NSLog(@"_______%@",NSStringFromCGRect(_content.frame));
           // update contentsize
           _scroll.contentSize = _content.frame.size;
           NSLog(@"*******%@",NSStringFromCGSize(_scroll.contentSize));
           // 固定中心点
           _content.center = CGPointMake(_scroll.contentSize.width / 2 , _scroll.contentSize.height / 2);
           CGFloat Xmargin = (_scroll.contentSize.width - self.bounds.size.width) / 2;
           CGFloat Ymargin = (_scroll.contentSize.height - self.bounds.size.height) / 2;
           _scroll.contentOffset = CGPointMake(Xmargin, Ymargin);
       
    }
    
        // 当手指离开屏幕时, 判断缩放越界
        if([pin state] == UIGestureRecognizerStateEnded) {
            // a表示x方向的scale变换幅度，d表示y方向的
            if (_content.transform.a < minScale || _content.transform.a > maxScale) {
                [UIView animateWithDuration:0.3f animations:^{
                    [self recoverScale];
                }];
            }
       }
}

#pragma mark cancel
- (void)recoverScale {
    _scroll.contentSize = self.bounds.size;
    _scroll.contentOffset = CGPointZero;

    // !!!先还原transform，再还原frame
    _content.transform = CGAffineTransformIdentity;
    _content.frame = self.bounds;
    

}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/









@end
