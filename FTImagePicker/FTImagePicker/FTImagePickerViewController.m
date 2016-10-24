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
    if(!self.selectedItemsArray){
        self.selectedItemsArray = [[NSMutableArray alloc] init];
    }
    //Configure FTDetailView
    [self.FTDetailView setAutoresizesSubviews:YES];
    [self.FTDetailView setFrame:[UIScreen mainScreen].bounds];
    [self.FTDetailView.detailCollectionView setFrame:self.FTDetailView.frame];
    self.FTDetailView.multipleSelectOn = self.multipleSelectOn;
    self.FTDetailView.detailCollectionView.allowsMultipleSelection = self.FTDetailView.multipleSelectOn;
    self.FTDetailView.ImagePickerCollectionView = self.FTimagePickerCollectionView;
    self.FTDetailView.delegate = self;
    
    //set cell scaleFactor and scale criteria
    self.scaleCriteria = 1.0;
    self.cellScaleFactor = 3;
    
    //set multiple selection mode
    self.FTimagePickerCollectionView.allowsMultipleSelection = self.multipleSelectOn;
    self.selectBtn.hidden = !(self.multipleSelectOn);
    
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
    //Notification center observer
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshImagePicker) name:UIApplicationWillEnterForegroundNotification object:nil];
}
- (void) refreshImagePicker{
    NSLog(@"fore");
    [self.allAssets removeAllObjects];
    if([self.albumName isEqualToString:@"default"]){
        //fetch images
        [self fetchAllImageOrVideoFromDevice: PHAssetMediaTypeImage];
        //fetch videos
        [self fetchAllImageOrVideoFromDevice:PHAssetMediaTypeVideo];
    }
    else{
        [self fetchImagesOrVideosFromAlbum];
    }
    //pass assets to detail view
    self.FTDetailView.allAssets = self.allAssets;
    [self.FTimagePickerCollectionView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (BOOL)prefersStatusBarHidden{
    return YES;
}

#pragma mark - Image Fetching
- (void) fetchAllImageOrVideoFromDevice: (PHAssetMediaType) mediaType {
    PHFetchOptions *allPhotosOptions = [[PHFetchOptions alloc] init];
    allPhotosOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
    PHFetchResult *allPhotosResult = [PHAsset fetchAssetsWithMediaType:mediaType options:allPhotosOptions];
    [allPhotosResult enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self.allAssets addObject:obj];
    }];
}

- (void) fetchImagesOrVideosFromAlbum {
    //Fetching user albums
    PHFetchResult *userAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAny options:nil];
    [userAlbums enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        PHAssetCollection *collection = obj;
        PHFetchResult *fetchingResultForCount = [PHAsset fetchAssetsInAssetCollection:collection options:nil];
        //add albums which have at least one item in their album.
        if(fetchingResultForCount.count > 0 && collection.assetCollectionSubtype != PHAssetCollectionSubtypeSmartAlbumUserLibrary){
                if([self.albumName isEqualToString:collection.localizedTitle]){
                PHFetchOptions *albumsFetchingOptions = [[PHFetchOptions alloc] init];
                albumsFetchingOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
                PHFetchResult *assetResultForAlbum = [PHAsset fetchAssetsInAssetCollection:collection options:albumsFetchingOptions];
                [assetResultForAlbum enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    [self.allAssets addObject:obj];
                }];
            }
        }
    }];
    //Fetching smart albums
    PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAny options:nil];
    [smartAlbums enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        PHAssetCollection *collection = obj;
        PHFetchResult *fetchingResultForCount = [PHAsset fetchAssetsInAssetCollection:collection options:nil];
        //add albums which have at least one item in their album.
        if(fetchingResultForCount.count > 0 && collection.assetCollectionSubtype != PHAssetCollectionSubtypeSmartAlbumUserLibrary){
            if([self.albumName isEqualToString:collection.localizedTitle]){
                PHFetchOptions *albumsFetchingOptions = [[PHFetchOptions alloc] init];
                albumsFetchingOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
                PHFetchResult *assetResultForAlbum = [PHAsset fetchAssetsInAssetCollection:collection options:albumsFetchingOptions];
                [assetResultForAlbum enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    [self.allAssets addObject:obj];
                }];
            }
        }
    }];

}

#pragma mark - Collection View selection handling
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    //single selection mode
    if(!self.multipleSelectOn){
        PHAsset *selectedAsset = [self.allAssets objectAtIndex:indexPath.row];
        [self.selectedItemsArray addObject:selectedAsset];
        [self didFinishSelectPhotosFromImagePicker];
    }
    //multiple selection mode
    else{
        FTImagePickerCollectionViewCell *imagePickerCell = (FTImagePickerCollectionViewCell *) [collectionView cellForItemAtIndexPath:indexPath];
        imagePickerCell.layer.borderWidth = 2.0;
        imagePickerCell.layer.borderColor = [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:0.8].CGColor;
        imagePickerCell.alpha = 0.5;
        [self.FTDetailView.detailCollectionView selectItemAtIndexPath:indexPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath{
    //single selection mode
    if(!self.multipleSelectOn){
        
    }
    //multiple selection mode
    else{
        FTImagePickerCollectionViewCell *imagePickerCell = (FTImagePickerCollectionViewCell *) [collectionView cellForItemAtIndexPath:indexPath];
        imagePickerCell.layer.borderWidth = 0;
        imagePickerCell.layer.borderColor = nil;
        imagePickerCell.alpha = 1.0;
        [self.FTDetailView.detailCollectionView deselectItemAtIndexPath:indexPath animated:NO];
    }
}

//single selection mode select item in detail view delegate
- (void) singleSelectionModeSelectionConfirmed:(NSMutableArray *)selectedAssetArray{
    PHAsset *selectedAsset = [selectedAssetArray firstObject];
    [self.selectedItemsArray addObject:selectedAsset];
    [self didFinishSelectPhotosFromImagePicker];
}

#pragma mark - Configuring Collection View
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.allAssets.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    FTImagePickerCollectionViewCell * cell = [self.FTimagePickerCollectionView dequeueReusableCellWithReuseIdentifier:@"imagePickerCells" forIndexPath:indexPath];
    [[PHImageManager defaultManager] requestImageForAsset:self.allAssets[indexPath.row] targetSize:CGSizeMake(cell.bounds.size.width*1.5, cell.bounds.size.height*1.5) contentMode:PHImageContentModeAspectFill options:nil resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        cell.thumbnailForCells.image = result;
    }];
    //Because cell is reused when user scroll down or up collection view. it is needed to set cell's status by their selection property
    if(cell.selected){
        cell.layer.borderWidth = 2.0;
        cell.layer.borderColor = [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:0.8].CGColor;
        cell.alpha = 0.5;
    }
    else{
        cell.layer.borderWidth = 0;
        cell.layer.borderColor = nil;
        cell.alpha = 1;
    }
    
    return cell;
}

//set cell size delegate
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    float screenWidth = [UIScreen mainScreen].bounds.size.width;
    float cellWidth = (screenWidth-(self.cellScaleFactor-1))/self.cellScaleFactor;
    return CGSizeMake(cellWidth, cellWidth);
}
#pragma mark - Back To application from picker
- (void) didFinishSelectPhotosFromImagePicker{
    [self.delegate getSelectedImageAssetsFromImagePicker:self.selectedItemsArray];
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - Navigation Controll
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

#pragma mark - See Detail Photo
- (IBAction)showDetailCellLongPressed:(UILongPressGestureRecognizer *)sender {
    if(sender.state == UIGestureRecognizerStateBegan){
        //get index path from long pressed point
        CGPoint location = [sender locationInView:self.FTimagePickerCollectionView];
        NSIndexPath *indexPath = [self.FTimagePickerCollectionView indexPathForItemAtPoint:location];
        //scroll to show selected image
        [self.FTDetailView.detailCollectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
        //show sub view
//        //selected cell in image picker
//        FTImagePickerCollectionViewCell *selectedCell = (FTImagePickerCollectionViewCell *)[self.FTimagePickerCollectionView cellForItemAtIndexPath:indexPath];
//        //get frame from selected cell and convert it according to collection's superview to get correct cgrect value according to main screen
//        CGRect convertedRect = [self.FTimagePickerCollectionView convertRect:selectedCell.frame toView:[self.FTimagePickerCollectionView superview]];
//        //make a image view for transition effect
//        UIImageView *imageViewForTransition = [[UIImageView alloc] initWithFrame:convertedRect];
//        imageViewForTransition.contentMode = UIViewContentModeScaleAspectFill;
//        imageViewForTransition.clipsToBounds = YES;
//        [[PHImageManager defaultManager] requestImageForAsset:self.allAssets[indexPath.row] targetSize:self.FTDetailView.frame.size contentMode:PHImageContentModeAspectFill options:nil resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
//            imageViewForTransition.image = result;
//        }];
//        //make a another image view for hiding cell image
//        UIView *hidingImageView = [[UIView alloc] initWithFrame:self.FTDetailView.detailCollectionView.bounds];
//        hidingImageView.backgroundColor = self.FTDetailView.detailCollectionView.backgroundColor;
        //add subviews
        [self.view addSubview:self.FTDetailView];
//        [self.FTDetailView.detailCollectionView addSubview:hidingImageView];
//        [self.view addSubview:imageViewForTransition];
//        //animation effect configuration
//        [self.FTDetailView setAlpha:0.0];
//        [UIView animateWithDuration:0.2 animations:^{
//            [self.FTDetailView setAlpha:1];
//            [imageViewForTransition setFrame:CGRectInset(self.FTDetailView.frame, -0.015*CGRectGetWidth(self.FTDetailView.frame), -0.015*CGRectGetHeight(self.FTDetailView.frame)) ];
//            imageViewForTransition.contentMode = UIViewContentModeScaleAspectFit;
//        } completion:^(BOOL finished) {
//            [imageViewForTransition removeFromSuperview];
//            [hidingImageView removeFromSuperview];
//        }];
    }
}


#pragma mark - Cell Zoom In and Out
- (IBAction)cellZoomInOutPinch:(UIPinchGestureRecognizer *)sender {
    CGFloat scale = sender.scale;
    NSLog(@"scale %f", scale);
    NSLog(@"criteria %f", self.scaleCriteria);
    CGFloat difference = (scale - self.scaleCriteria)* (scale - self.scaleCriteria);
    if(sender.state == UIGestureRecognizerStateBegan){
        self.FTimagePickerCollectionView.scrollEnabled = NO;
    }
    else if(sender.state == UIGestureRecognizerStateChanged){
        //Pinch gesture's scale increses or decreses fast when scale is over 1, but very slowly changes in the region below 1.
        //So it needs to have different action by region(over 1 and below 1)
        //when scale is below 1, needs to be much more sensitive
        if(scale <= 1){
            if(difference > 0.03){
                NSLog(@"scale %f criteria %f difference %f",scale, self.scaleCriteria, scale - self.scaleCriteria);
                if((scale - self.scaleCriteria) > 0 && self.cellScaleFactor > 2){
                    self.cellScaleFactor -= 1;
                    NSLog(@"scaleFactor %ld", (long)self.cellScaleFactor);
                    [self.FTimagePickerCollectionView reloadData];
                }
                else if((scale - self.scaleCriteria) < 0 && self.cellScaleFactor < 6){
                    self.cellScaleFactor += 1;
                    NSLog(@"scaleFactor %ld", (long)self.cellScaleFactor);
                    [self.FTimagePickerCollectionView reloadData];
                }
                self.scaleCriteria = scale;
            }

        }
        //when scale is over 1, doesn't need to be sensitive like in the region below 1
        else if(difference > 0.12){
            NSLog(@"scale %f criteria %f difference %f",scale, self.scaleCriteria, scale - self.scaleCriteria);
            if((scale - self.scaleCriteria) > 0 && self.cellScaleFactor > 2){
                self.cellScaleFactor -= 1;
                NSLog(@"scaleFactor %ld", (long)self.cellScaleFactor);
                [self.FTimagePickerCollectionView.collectionViewLayout invalidateLayout];
                //[self.FTimagePickerCollectionView reloadData];
            }
            else if((scale - self.scaleCriteria) < 0 && self.cellScaleFactor < 6){
                self.cellScaleFactor += 1;
                NSLog(@"scaleFactor %ld", (long)self.cellScaleFactor);
                [self.FTimagePickerCollectionView.collectionViewLayout invalidateLayout];
                //[self.FTimagePickerCollectionView reloadData];
            }
            self.scaleCriteria = scale;
        }
    }
    else {
        self.FTimagePickerCollectionView.scrollEnabled = YES;
        self.scaleCriteria = 1.0;
    }
    
}


- (IBAction)cancelImagePickerBtnClicked:(UIButton *)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}
@end
