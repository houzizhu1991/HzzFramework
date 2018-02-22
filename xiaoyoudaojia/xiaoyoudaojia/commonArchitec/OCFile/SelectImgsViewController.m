//
//  SelectImgsViewController.m
//  ImgPickerDemo
//
//  Created by 世纪阳天 on 16/11/14.
//  Copyright © 2016年 世纪阳天. All rights reserved.
//

#import "SelectImgsViewController.h"
#import "PhotoEnlargeViewController.h"
//#import "PhotoCollectionViewCell.h"
#import <Photos/Photos.h>
#import "PhotoItemModel.h"

const NSInteger space = 5;

@interface SelectImgsViewController ()<UICollectionViewDataSource,
    UICollectionViewDelegate,
    UICollectionViewDelegateFlowLayout>

{
    CGFloat _itemWidth;
    void (^callBack)(NSArray *);
}

@property (strong, nonatomic)  UIButton *sendResultBtn;
@property (strong, nonatomic) NSMutableArray *selectedResult;
@property (strong, nonatomic) NSMutableArray *itemArr;
@property (strong, nonatomic) UIActivityIndicatorView *indicator;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

//@property (strong, nonatomic) NSLock *lock;

@end

@implementation SelectImgsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"相册";
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:self.sendResultBtn];
    
    UIButton *left = [UIButton buttonWithType:UIButtonTypeCustom];
    left.frame = CGRectMake(0, 0, 70, 40);
    [left setImage:[UIImage imageNamed:@"icon_back"]
          forState:UIControlStateNormal];
    left.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [left addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:left];

    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    
    flowLayout.minimumLineSpacing = space;
    flowLayout.minimumInteritemSpacing = space;
    flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    [self.collectionView setCollectionViewLayout:flowLayout];
    
    _itemWidth = ([UIScreen mainScreen].bounds.size.width - 2 * space) / 3;
    
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    [self.collectionView registerNib:
     [UINib nibWithNibName:NSStringFromClass([PhotoCollectionViewCell class]) bundle:nil] forCellWithReuseIdentifier:
     NSStringFromClass([PhotoCollectionViewCell class])];
    
    // 监听
    [self addObserver:self forKeyPath:@"selectedResult" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
    
    //self.lock = [[NSLock alloc]init];
    
    PHAuthorizationStatus tAuthStatus = [PHPhotoLibrary authorizationStatus];
    // 无权限
    if(tAuthStatus == PHAuthorizationStatusRestricted || tAuthStatus == PHAuthorizationStatusDenied) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"此应用无法使用你的相册，请在iPhone的设置中开启访问相册!" preferredStyle: UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel  handler:nil];
        [alert addAction:cancelAction];
        
        UIAlertAction *queryAction = [UIAlertAction actionWithTitle:@"去设置" style:UIAlertActionStyleDefault  handler:^(UIAlertAction *action) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
        } ];
        [alert addAction:queryAction];
        [self presentViewController:alert animated:YES completion:nil];
        
        
    }
    // 未知权限
    else if (tAuthStatus == PHAuthorizationStatusNotDetermined) {
        
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            
            if (status == PHAuthorizationStatusAuthorized) {
                
                [self getImgs];
            }
        }];
        
    }
    else {
        [self getImgs];
    }

    // Do any additional setup after loading the view from its nib.
}

- (void)getImgs {
    
     dispatch_group_t group = dispatch_group_create();
    
     dispatch_async(dispatch_get_main_queue(), ^{
        [self.indicator startAnimating];
     });
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
        
        //获取相册内的照片
        PHCachingImageManager* imageManager = [[PHCachingImageManager   alloc]init];
        
        for (int i=0; i<smartAlbums.count; i++) {
            PHCollection *collection = smartAlbums[i];
            
            PHAssetCollection* assetCollection=(PHAssetCollection*)collection;
            PHFetchResult* fetchResult=[PHAsset fetchAssetsInAssetCollection:assetCollection options:nil];
            
            // 缓存获取结果
            [imageManager startCachingImagesForAssets: (NSArray *)fetchResult targetSize:CGSizeMake(_itemWidth, _itemWidth) contentMode:PHImageContentModeAspectFill options:nil];
            
            for (int j = 0; j < [fetchResult countOfAssetsWithMediaType:PHAssetMediaTypeImage]; j++) {
                
                PHAsset* asset = fetchResult[j];
                // cell model
                __block PhotoItemModel *model = [[PhotoItemModel alloc] init];
                model.isSelect = NO;
                [self.itemArr addObject:model];
                
                 dispatch_group_enter(group);
                
                PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
                options.synchronous = NO;
                options.deliveryMode = PHImageRequestOptionsDeliveryModeOpportunistic;
                options.networkAccessAllowed = YES; //允许从网络获取
                options.progressHandler=^(double progress, NSError *error, BOOL *stop, NSDictionary *info){
                    //下载进度 progress
                };
                
                // asyn
                [imageManager requestImageForAsset:asset targetSize:CGSizeMake(700,700) contentMode:PHImageContentModeAspectFit options:options resultHandler:^(UIImage *result, NSDictionary *info) {
                    
                    // 可能出现并发访问
                    //[self.lock lock];
                    
                     NSLog(@"size ===== %f %f",result.size.width, result.size.height);
                    
                    if (model.smallImg == nil && (result.size.width < 200 && result.size.height < 200)) {
                        model.smallImg = result;
                    }else {
                        model.bigImg = result;
                        dispatch_group_leave(group);
               
                    }
                    
                    //[self.lock unlock];
                    
                    
                }];
              }
            }
        
        //  异步通知
        dispatch_group_notify(group, dispatch_get_main_queue(), ^{
             [self.indicator stopAnimating];
            [self.collectionView reloadData];
        });
    });
}


#pragma mark dataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _itemArr.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    PhotoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([PhotoCollectionViewCell class]) forIndexPath:indexPath];
    cell.delegate = self;
    return cell;

}

#pragma mark layout
- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    PhotoCollectionViewCell *newCell = (PhotoCollectionViewCell *)cell;
    newCell.itemIndex = indexPath.row;
    [newCell configWithModel:_itemArr[indexPath.row]];
    
}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(_itemWidth, _itemWidth);
}


- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(space, 0, 0, 0);
}

#pragma mark delegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"_____%ld",indexPath.row);
    
    [self convertActionWithCellIndex:indexPath.row];
   
//    UIStoryboard *photoSB = [UIStoryboard storyboardWithName: @"SelectPhotoStoryboard" bundle:nil];
//
//    PhotoEnlargeViewController *enlargeVC = [photoSB instantiateViewControllerWithIdentifier:@"PhotoEnlarge"];
//    enlargeVC.curIndex = indexPath.row;
//    enlargeVC.sourceArr =  self.itemArr ;
//    enlargeVC.observedVC = self;
//    enlargeVC.maxNum  = self.maxNum;
//    [self.navigationController presentViewController:enlargeVC animated:YES completion:nil];
    
}


- (void)convertActionWithCellIndex:(NSInteger)index {
    PhotoItemModel *model = self.itemArr[index];
    
    // 判断是否超过最大发送数
    if (self.selectedResult.count == self.maxNum && model.isSelect == NO) {
        return;
    }
    
    model.isSelect = !model.isSelect;
    if (model.isSelect) {
        [[self mutableArrayValueForKey: @"selectedResult"] addObject: model];
    }
    else {
        if ([[self mutableArrayValueForKey: @"selectedResult"] containsObject:model]) {
            [[self mutableArrayValueForKey: @"selectedResult"] removeObject:model];
        }
    
    }
    [self.collectionView reloadData];
    
}

#pragma mark observe
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if ([keyPath isEqualToString: @"selectedResult"]) {
        if (self.selectedResult.count == 0) {
            self.sendResultBtn.enabled = NO;
        }
        else {
            
            NSString *title = [NSString stringWithFormat:@"发送(%ld%@%ld)",self.selectedResult.count, @"/", self.maxNum];
            [self.sendResultBtn setTitle: title forState: UIControlStateNormal];
            self.sendResultBtn.enabled = YES;
        }
        
    }
    
}

#pragma mark block
- (void)addCallBack:(void (^)(NSArray *))block {
    callBack = block;
}

- (void)sendResult {
    
    [self.selectedResult removeAllObjects];
    [self.itemArr enumerateObjectsUsingBlock:^(PhotoItemModel *model, NSUInteger idx, BOOL * _Nonnull stop) {
        if (model.isSelect) {
            [self.selectedResult addObject:model];
        }
    }];
    
    if (callBack && self.selectedResult.count) {
        if ([[self.selectedResult valueForKeyPath :@"bigImg"] containsObject:[NSNull null]]) {
             [self.navigationController popViewControllerAnimated:YES];
            return;
        }
        
        callBack([self.selectedResult valueForKeyPath :@"bigImg"]);
        if (self.presentedViewController) {
            [self.presentedViewController dismissViewControllerAnimated:YES completion:^{
                // 页面不可点
                self.navigationController.view.userInteractionEnabled = NO;
                [self.navigationController popViewControllerAnimated:YES];
            }];
        }
        else {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}


#pragma mark lazy load
- (UIButton *)sendResultBtn {
    if (!_sendResultBtn) {
        _sendResultBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _sendResultBtn.frame = CGRectMake(0, 0, 120, 30);
        _sendResultBtn.titleLabel.font = [UIFont systemFontOfSize:16];
        _sendResultBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        [_sendResultBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_sendResultBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateDisabled];
        [_sendResultBtn setTitle: @"" forState: UIControlStateDisabled];
        [_sendResultBtn addTarget:self action: @selector(sendResult) forControlEvents:UIControlEventTouchUpInside];
         _sendResultBtn.enabled = NO;
    }
    return _sendResultBtn;
}


- (NSMutableArray *)selectedResult {
    if (!_selectedResult) {
        _selectedResult = [NSMutableArray arrayWithCapacity:self.maxNum];
    }
    return _selectedResult;
}

- (NSMutableArray *)itemArr {
    if (!_itemArr) {
        _itemArr = [NSMutableArray array];
    }
    return _itemArr;
}

- (UIActivityIndicatorView *)indicator {
    if (!_indicator) {
        _indicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        _indicator.center = self.view.center;
        [self.view addSubview:_indicator];
        
    }
    return _indicator;

}

- (void)backAction {
    [self.navigationController popViewControllerAnimated:true];
}


- (void)dealloc {
    [self removeObserver:self forKeyPath: @"selectedResult"];
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
