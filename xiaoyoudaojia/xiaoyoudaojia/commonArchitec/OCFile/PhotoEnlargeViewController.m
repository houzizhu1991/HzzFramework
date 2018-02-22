//
//  PhotoEnlargeViewController.m
//  ImgPickerDemo
//
//  Created by 世纪阳天 on 16/11/14.
//  Copyright © 2016年 世纪阳天. All rights reserved.
//

#import "PhotoEnlargeViewController.h"
#import "PhotoContainer.h"
#import "SelectImgsViewController.h"

@interface PhotoEnlargeViewController ()<UIScrollViewDelegate>

{
    UIScrollView *_scroll;
}

@property (weak, nonatomic) IBOutlet UILabel *descLb;
@property (nonatomic ,strong) NSMutableArray *scaleArr;
@property (weak, nonatomic) IBOutlet UIButton *sendBtn;
@property (weak, nonatomic) IBOutlet UIButton *selectCurPhotoBtn;


@end

@implementation PhotoEnlargeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self initContentView];
    
    // 监听弱引用数组
    [self.observedVC addObserver:self forKeyPath:@"selectedResult" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
    // 监听当前图片索引
     [self addObserver:self forKeyPath:@"curIndex" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
    
    // 删除样式
    if (self.canDelete == YES) {
        self.sendBtn.hidden = NO;
        [self.sendBtn setTitle: @"删除" forState: UIControlStateNormal];
        self.selectCurPhotoBtn.hidden = YES;
    }
    
    // Do any additional setup after loading the view from its nib.
}


- (void)initContentView {
    
    _scroll = [[UIScrollView alloc]initWithFrame:[UIScreen mainScreen].bounds];
    _scroll.pagingEnabled = YES;
    _scroll.delegate = self;
    _scroll.showsHorizontalScrollIndicator = NO;
    [self.view addSubview:_scroll];
    
    NSInteger subViewNum = MIN(3, self.sourceArr.count);
    for (int i = 0; i < subViewNum; i++) {
        
        PhotoContainer *img = [[PhotoContainer alloc]initWithFrame: CGRectMake(
                                            i * CGRectGetWidth(_scroll.bounds),
                                                                         0,
                                            CGRectGetWidth(_scroll.bounds),
                                            CGRectGetHeight(_scroll.bounds))];
        img.tag = 1000 + i;
        img.contentMode = UIViewContentModeScaleAspectFit;
        img.userInteractionEnabled = YES;
        // initial value
        PhotoItemModel *model = self.sourceArr[i];
        img.image = model.bigImg;
        [_scroll addSubview:img];
        
    }
    
    _scroll.contentSize = CGSizeMake(subViewNum * CGRectGetWidth(_scroll.bounds), 0);
    [self.view sendSubviewToBack:_scroll];
    
    [self.selectCurPhotoBtn setImage:[UIImage imageNamed:@"check_box_outline_blank"] forState:UIControlStateNormal];
    [self.selectCurPhotoBtn setImage:[UIImage imageNamed:@"check_box"] forState:UIControlStateSelected];
    
     self.descLb.text = [NSString stringWithFormat:@"%ld/%ld",self.curIndex + 1, self.sourceArr.count];

    if (self.sourceArr.count >= 3) {
        [self reloadPhotos];
    }else {
          _scroll.contentOffset = CGPointMake(CGRectGetWidth(_scroll.bounds) * self.curIndex, 0);
    }
    
    // initial
    [self refreshSelection];
    
}


- (void)reloadPhotos {
    PhotoContainer *leftView   =  (PhotoContainer *)[_scroll viewWithTag:1000 + 0];
    PhotoContainer *centerView =  (PhotoContainer *)[_scroll viewWithTag:1000 + 1];
    PhotoContainer *rightView  =  (PhotoContainer *)[_scroll viewWithTag:1000 + 2];
    
    [leftView recoverScale];
    [centerView recoverScale];
    [rightView recoverScale];
    
    PhotoItemModel *centerModel = self.sourceArr[self.curIndex];
    centerView.image  =  centerModel.bigImg;

    NSInteger previous = (self.curIndex - 1 + self.sourceArr.count) % self.sourceArr.count;
    PhotoItemModel *leftModel = self.sourceArr[previous];
    leftView.image = leftModel.bigImg;
    
    NSInteger next = (self.curIndex + 1) % self.sourceArr.count;
    PhotoItemModel *rightModel = self.sourceArr[next];
    rightView.image = rightModel.bigImg;

    _scroll.contentOffset = CGPointMake(CGRectGetWidth(centerView.bounds), 0);
    // refresh
    self.descLb.text = [NSString stringWithFormat:@"%ld/%ld",self.curIndex + 1, self.sourceArr.count];

}


#pragma mark delegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (self.sourceArr.count < 3) {
        self.curIndex = _scroll.contentOffset.x/_scroll.frame.size.width;
        self.descLb.text = [NSString stringWithFormat:@"%ld/%ld",self.curIndex + 1, self.sourceArr.count];
        return;
    }
    
    // 往右滑动
    if (scrollView.contentOffset.x > 1.5 * CGRectGetWidth(_scroll.bounds)) {
        self.curIndex = (self.curIndex + 1) % self.sourceArr.count;
    }
    // 往左滑动
    else if(scrollView.contentOffset.x < 0.5 * CGRectGetWidth(_scroll.bounds)) {
        self.curIndex = (self.curIndex - 1 + self.sourceArr.count) % self.sourceArr.count;
    }
    else {
    
    }
    
    [self reloadPhotos];
}


- (IBAction)back:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (IBAction)selectOrNot:(UIButton *)sender {
    if ([self.observedVC respondsToSelector:@selector(convertActionWithCellIndex:)]) {
        [self.observedVC convertActionWithCellIndex:self.curIndex];
    }
    
}

- (void)refreshSelection {
    
    if (self.canDelete) {
        return;
    }
    
    
    self.sendBtn.hidden = [[self.observedVC mutableArrayValueForKey:@"selectedResult"] count] == 0;
    NSString *title = [NSString stringWithFormat:@"发送(%ld%@%ld)",
                       [[self.observedVC mutableArrayValueForKey:@"selectedResult"] count],
                       @"/",
                       self.maxNum];
    [self.sendBtn setTitle: title forState: UIControlStateNormal];
    self.selectCurPhotoBtn.selected = [[self.observedVC mutableArrayValueForKey:@"selectedResult"] containsObject:self.sourceArr[self.curIndex]];

}

#pragma mark -- observe
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if ([keyPath isEqualToString: @"selectedResult"] || [keyPath isEqualToString: @"curIndex"]) {
        [self refreshSelection];
    }

}

#pragma mark -- action
- (IBAction)sendResult:(id)sender {
    
    if (self.canDelete) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"确认删除照片?" preferredStyle: UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel  handler:nil];
        [alert addAction:cancelAction];
        
        UIAlertAction *queryAction = [UIAlertAction actionWithTitle:@"删除" style:UIAlertActionStyleDefault  handler:^(UIAlertAction *action) {
            [self.sourceArr removeObjectAtIndex:self.curIndex];
            // 回调通知
            if (self.deleteBlock != nil) {
                self.deleteBlock(self.curIndex);
            }
            // 移除的最后一张
            if (self.curIndex == self.sourceArr.count) {
                self.curIndex = 0;
            }
            [self relayoutSubViews];
            
        
        } ];
        [alert addAction:queryAction];
        [self presentViewController:alert animated:YES completion:nil];
        
        return;
    }
    
    [self.observedVC sendResult];
}

- (void)relayoutSubViews {
    for (UIView * subView in _scroll.subviews) {
        [subView removeFromSuperview];
    }
    [_scroll removeFromSuperview];
    _scroll = nil;
    
    if (self.sourceArr.count == 0) {
        self.descLb.hidden = YES;
        self.sendBtn.hidden = YES;
        return;
    }
    [self initContentView];
    
}

- (void)dealloc {
    [self.observedVC removeObserver:self forKeyPath:@"selectedResult"];
    [self removeObserver:self forKeyPath:@"curIndex"];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
