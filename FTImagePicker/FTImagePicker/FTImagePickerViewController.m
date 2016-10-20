//
//  FTImagePickerViewController.m
//  FTImagePicker
//
//  Created by Park on 2016. 10. 20..
//  Copyright © 2016년 Parkfantagram /inc. All rights reserved.
//

#import "FTImagePickerViewController.h"

@interface FTImagePickerViewController ()

@end

@implementation FTImagePickerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if(!self.allAssets){
        self.allAssets = [[NSMutableArray alloc] init];
    }
    //set detail view size to screen size
    [self.FTDetailView setAutoresizesSubviews:YES];
    [self.FTDetailView setFrame:[UIScreen mainScreen].bounds];
    [self.FTDetailView.detailCollectionView setFrame:self.FTDetailView.frame];
    
    //set cell scaleFactor and scale criteria
    self.scaleCriteria = 1;
    self.cellScaleFactor = 4;
    
    
    //fetch images when app start, doesn't fetch images when loaded from selected album
    if(self.allAssets.count == 0){
        //fetch all images from device
        if([PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusAuthorized){
            //fetch images
            [self fetchAllImageOrVideoFromDevice: PHAssetMediaTypeImage];
            //fetch videos
            [self fetchAllImageOrVideoFromDevice:PHAssetMediaTypeVideo];
        }
    }
    //pass assets to detail view
    self.FTDetailView.allAssets = self.allAssets;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) fetchAllImageOrVideoFromDevice: (PHAssetMediaType) mediaType {
    PHFetchOptions *allPhotosOptions = [[PHFetchOptions alloc] init];
    allPhotosOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
    PHFetchResult *allPhotosResult = [PHAsset fetchAssetsWithMediaType:mediaType options:allPhotosOptions];
    [allPhotosResult enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self.allAssets addObject:obj];
    }];
    
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.allAssets.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    FTImagePickerCollectionViewCell * cell = [self.FTimagePickerCollectionView dequeueReusableCellWithReuseIdentifier:@"imagePickerCells" forIndexPath:indexPath];
    [[PHImageManager defaultManager] requestImageForAsset:self.allAssets[indexPath.row] targetSize:cell.bounds.size contentMode:PHImageContentModeAspectFill options:nil resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        cell.thumbnailForCells.image = result;
    }];
    
    return cell;
}

//set cell size delegate
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    float screenWidth = [UIScreen mainScreen].bounds.size.width;
    float cellWidth = (screenWidth-(self.cellScaleFactor-1))/self.cellScaleFactor;
    return CGSizeMake(cellWidth, cellWidth);
}




- (IBAction)backToAlbumLeftEdgePan:(UIScreenEdgePanGestureRecognizer *)sender {
    CGPoint translation = [sender translationInView:self.FTimagePickerCollectionView];
    NSLog(@"%f, %f", translation.x, translation.y);
    if(sender.state == UIGestureRecognizerStateEnded){
        if(translation.x > 20){
            [self.navigationController popViewControllerAnimated:YES];
        }
    }

}

- (IBAction)backToAlbumBtnClicked:(UIButton *)sender {
     [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)showDetailCellLongPressed:(UILongPressGestureRecognizer *)sender {
    NSLog(@"long");
    //get index path from long pressed point
    CGPoint location = [sender locationInView:self.FTimagePickerCollectionView];
    NSIndexPath *indexPath = [self.FTimagePickerCollectionView indexPathForItemAtPoint:location];
    //scroll to show selected image
    [self.FTDetailView.detailCollectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
    //show sub view
    [self.view addSubview:self.FTDetailView];
}

- (IBAction)cellZoomInOutPinch:(UIPinchGestureRecognizer *)sender {
    CGFloat scale = sender.scale;
    NSLog(@"scale %f", scale);
    NSLog(@"criteria %f", self.scaleCriteria);
    if(sender.state == UIGestureRecognizerStateBegan){
        self.FTimagePickerCollectionView.scrollEnabled = NO;
    }
    else if(sender.state == UIGestureRecognizerStateChanged){
        if((scale - self.scaleCriteria)* (scale - self.scaleCriteria) > 0.4){
            if((scale - self.scaleCriteria) > 0 && self.cellScaleFactor > 2){
                self.cellScaleFactor -= 1;
                NSLog(@"scaleFactor %ld", (long)self.cellScaleFactor);
            }
            else if((scale - self.cellScaleFactor) < 0 && self.cellScaleFactor < 6){
                self.cellScaleFactor += 1;
                NSLog(@"scaleFactor %ld", (long)self.cellScaleFactor);
            }
            self.scaleCriteria = scale;
            [self.FTimagePickerCollectionView reloadData];
        }
    }
    else {
        self.FTimagePickerCollectionView.scrollEnabled = YES;
        self.scaleCriteria = 1.0;
    }
    
}
@end
