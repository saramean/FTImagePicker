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
    //Default setting of select button is hidden
    //In single selection mode, button doesn't appear
    //In Multiple selection mode, appears when a user selects more than minimum select number.
    self.selectBtn.hidden = YES;
    self.deleteBtn.hidden = YES;
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
    self.FTDetailView.multipleSelectMin = self.multipleSelectMin;
    self.FTDetailView.multipleSelectMax = self.multipleSelectMax;
    self.FTDetailView.detailCollectionView.allowsMultipleSelection = self.FTDetailView.multipleSelectOn;
    self.FTDetailView.ImagePickerCollectionView = self.FTimagePickerCollectionView;
    self.FTDetailView.delegate = self;
    
    //set cell scaleFactor and scale criteria
    self.scaleCriteria = 1.0;
    self.cellScaleFactor = 3;
    
    //set multiple selection mode
    self.FTimagePickerCollectionView.allowsMultipleSelection = self.multipleSelectOn;
    
    //fetch images when app start, doesn't fetch images when loaded from selected album
    if(self.allAssets.count == 0){
        //fetch all images from device
        if([PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusAuthorized){
            [self fetchAllImageOrVideoFromDevice];
        }
    }
    //pass assets to detail view
    self.FTDetailView.allAssets = self.allAssets;
    //get camera rolls local title
    PHFetchResult *cameraRoll = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:nil];
    [cameraRoll enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        PHAssetCollection *collection = obj;
        self.cameraRollLocalTitle = collection.localizedTitle;
    }];
    
    //set Theme of album list
    [self changeTheme:self.theme];
    
    //Notification center observer
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshImagePicker) name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - Status Bar Hidden
- (BOOL)prefersStatusBarHidden{
    return YES;
}

#pragma mark - Theme
- (void) changeTheme: (NSInteger) theme{
    //white version
    if(theme == 0){
        self.FTimagePickerCollectionView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:1.0];
        self.FTDetailView.detailCollectionView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:1.0];
        self.buttonBarView.backgroundColor = [UIColor colorWithWhite:0.92 alpha:0.7];
        self.FTDetailView.buttonBarView.backgroundColor = [UIColor colorWithWhite:0.92 alpha:0.7];
        [self.view setTintColor:[UIColor colorWithWhite:0.25 alpha:1.0]];
        [self.FTDetailView setTintColor:[UIColor colorWithWhite:0.25 alpha:1.0]];
    }
    //black version
    else if(theme == 1){
        self.FTimagePickerCollectionView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:1.0];
        self.FTDetailView.detailCollectionView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:1.0];
        self.buttonBarView.backgroundColor = [UIColor colorWithWhite:0.08 alpha:0.7];
        self.FTDetailView.buttonBarView.backgroundColor = [UIColor colorWithWhite:0.08 alpha:0.7];
        [self.view setTintColor:[UIColor colorWithWhite:0.65 alpha:1.0]];
        [self.FTDetailView setTintColor:[UIColor colorWithWhite:0.65 alpha:1.0]];
    }
}

#pragma mark - Refresh image picker
- (void) refreshImagePicker{
    [self.allAssets removeAllObjects];
    if([self.albumName isEqualToString:self.cameraRollLocalTitle]){
        //fetch images
        [self fetchAllImageOrVideoFromDevice];
    }
    else{
        [self fetchImagesOrVideosFromAlbum];
    }
    //pass assets to detail view
    self.FTDetailView.allAssets = self.allAssets;
    [self.FTimagePickerCollectionView reloadData];
    [self.FTDetailView.detailCollectionView reloadData];
}


#pragma mark - Image Fetching
- (void) fetchAllImageOrVideoFromDevice {
    NSDate *methodStart = [NSDate date];
    PHFetchResult *cameraRollAlbum = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:nil];
    [cameraRollAlbum enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        PHAssetCollection *collection = obj;
        PHFetchOptions *albumsFetchingOptions = [[PHFetchOptions alloc] init];
        albumsFetchingOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
        if(self.mediaTypeToUse != 3){
            albumsFetchingOptions.predicate = [NSPredicate predicateWithFormat:@"mediaType = %d", self.mediaTypeToUse];
        }
        else{
            albumsFetchingOptions.predicate = [NSPredicate predicateWithFormat:@"mediaType != %d", self.mediaTypeToUse];
        }
        PHFetchResult *assetResultForAlbum = [PHAsset fetchAssetsInAssetCollection:collection options:albumsFetchingOptions];
        [assetResultForAlbum enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [self.allAssets addObject:obj];
        }];
    }];
    NSDate *methodFinish = [NSDate date];
    NSTimeInterval executionTime = [methodFinish timeIntervalSinceDate:methodStart];
    NSLog(@"refresh camera roll excutionTime = %f", executionTime);
}

- (void) fetchImagesOrVideosFromAlbum {
    NSDate *methodStart = [NSDate date];
    //Fetching user albums
    PHFetchResult *userAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAny options:nil];
    [userAlbums enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        PHAssetCollection *collection = obj;
        PHFetchResult *fetchingResultForCount = [PHAsset fetchAssetsInAssetCollection:collection options:nil];
        //add albums which have at least one item in their album.
        if(fetchingResultForCount.count > 0){
            if([self.albumName isEqualToString:collection.localizedTitle]){
                PHFetchOptions *albumsFetchingOptions = [[PHFetchOptions alloc] init];
                albumsFetchingOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
                if(self.mediaTypeToUse != 3){
                    albumsFetchingOptions.predicate = [NSPredicate predicateWithFormat:@"mediaType = %d", self.mediaTypeToUse];
                }
                else{
                    albumsFetchingOptions.predicate = [NSPredicate predicateWithFormat:@"mediaType != %d", self.mediaTypeToUse];
                }
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
                if(self.mediaTypeToUse != 3){
                    albumsFetchingOptions.predicate = [NSPredicate predicateWithFormat:@"mediaType = %d", self.mediaTypeToUse];
                }
                else{
                    albumsFetchingOptions.predicate = [NSPredicate predicateWithFormat:@"mediaType != %d", self.mediaTypeToUse];
                }
                PHFetchResult *assetResultForAlbum = [PHAsset fetchAssetsInAssetCollection:collection options:albumsFetchingOptions];
                [assetResultForAlbum enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    [self.allAssets addObject:obj];
                }];
            }
        }
    }];
    NSDate *methodFinish = [NSDate date];
    NSTimeInterval executionTime = [methodFinish timeIntervalSinceDate:methodStart];
    NSLog(@"refresh album excutionTime = %f", executionTime);
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
        //selection is only available when selected items count is below or equeal to multiple select max count
        //This limitation is defined in collectionView shouldSelectItemAtIndexPath method.
        FTImagePickerCollectionViewCell *imagePickerCell = (FTImagePickerCollectionViewCell *) [collectionView cellForItemAtIndexPath:indexPath];
        [self selectedCellLayoutChange:imagePickerCell];
        [self.FTDetailView.detailCollectionView selectItemAtIndexPath:indexPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
        [self.selectedItemsArray addObject:indexPath];
        self.selectedItemCount += 1;
        NSLog(@"selected count %d", (int)self.selectedItemCount);
        //force collectionview in detailview to update selected cell layout
        [self.FTDetailView collectionView:self.FTDetailView.detailCollectionView didSelectItemAtIndexPath:indexPath];
        //select button shows only when a user selects items more than the minimum number
        if(self.selectedItemCount >= self.multipleSelectMin){
            self.selectBtn.hidden = NO;
        }
        //delete button shows when at least one asset chosen.
        if(self.selectedItemCount > 0 && !self.syncedAlbum){
            self.deleteBtn.hidden = NO;
            self.albumBtn.hidden = YES;
        }
    }
}

- (BOOL) collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if(!self.multipleSelectOn){
        return YES;
    }
    else if(self.selectedItemCount < self.multipleSelectMax){
        return YES;
    }
    //if mutiple select max count reached show alert
    else{
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Maximum Selection" message:[NSString stringWithFormat:@"You can choose up to %d images.", (int)self.multipleSelectMax] preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *OKAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:OKAction];
        [self presentViewController:alertController animated:YES completion:nil];
        return NO;
    }
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath{
    //multiple selection mode
    FTImagePickerCollectionViewCell *imagePickerCell = (FTImagePickerCollectionViewCell *) [collectionView cellForItemAtIndexPath:indexPath];
    [self deselectedCellLayoutChange:imagePickerCell];
    [self.FTDetailView.detailCollectionView deselectItemAtIndexPath:indexPath animated:NO];
    for(int i = 0; i < self.selectedItemsArray.count; i++){
        if(self.selectedItemsArray[i] == indexPath){
            [self.selectedItemsArray removeObjectAtIndex:i];
        }
    }
    self.selectedItemCount -= 1;
    NSLog(@"selected count %d", (int)self.selectedItemCount);
    //force collectionview in detailview to update deselected cell layout
    [self.FTDetailView collectionView:self.FTDetailView.detailCollectionView didDeselectItemAtIndexPath:indexPath];
    //select button shows only when a user selects items more than the minimum number
    if(self.selectedItemCount < self.multipleSelectMin){
        self.selectBtn.hidden = YES;
    }
    if(self.selectedItemCount < 1 && !self.syncedAlbum){
        self.deleteBtn.hidden = YES;
        self.albumBtn.hidden = NO;
    }
}

#pragma mark - Selected and Deselected cells layout
- (void) selectedCellLayoutChange:(__kindof UICollectionViewCell *)selectedCell{
    selectedCell.layer.borderWidth = 2.0;
    selectedCell.layer.borderColor = [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:0.8].CGColor;
    selectedCell.alpha = 0.5;
}

- (void) deselectedCellLayoutChange:(__kindof UICollectionViewCell *)deselectedCell{
    deselectedCell.layer.borderWidth = 0;
    deselectedCell.layer.borderColor = nil;
    deselectedCell.alpha = 1.0;
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
    for(UIView *view in cell.subviews){
        if([view isKindOfClass:[UILabel class]]){
            [view removeFromSuperview];
        }
    }
    PHAsset *assetForIndexPath = self.allAssets[indexPath.row];
    [[PHImageManager defaultManager] requestImageForAsset:assetForIndexPath targetSize:CGSizeMake(cell.bounds.size.width*1.5, cell.bounds.size.height*1.5) contentMode:PHImageContentModeAspectFill options:nil resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        cell.thumbnailForCells.image = result;
        //if asset is Video type
        if(assetForIndexPath.mediaType == PHAssetMediaTypeVideo){
            UILabel *videoDuration = [[UILabel alloc] initWithFrame:CGRectMake(cell.bounds.size.width - 55, cell.bounds.size.height - 25, 60, 20)];
            videoDuration.text = [NSString stringWithFormat:@"%02d:%02d", (int)assetForIndexPath.duration/60, (int)assetForIndexPath.duration % 60];
            videoDuration.textColor = [UIColor whiteColor];
            [cell addSubview:videoDuration];
        }
    }];
    //Because cell is reused when user scroll down or up collection view. it is needed to set cell's status by their selection property
    if(cell.selected){
        [self selectedCellLayoutChange:cell];
    }
    else{
        [self deselectedCellLayoutChange:cell];
    }
    
    return cell;
}

//set cell size delegate
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    float screenWidth = [UIScreen mainScreen].bounds.size.width;
    float cellWidth = floor((screenWidth-(self.cellScaleFactor-1))/self.cellScaleFactor);
    return CGSizeMake(cellWidth, cellWidth);
}
//
//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
//    float screenWidth = [UIScreen mainScreen].bounds.size.width;
//    float cellWidth = floor((screenWidth-(self.cellScaleFactor-1))/self.cellScaleFactor);
//    float headerSize = (screenWidth - (cellWidth*self.cellScaleFactor) - (self.cellScaleFactor -1))/2;
//    NSLog(@"header Size %f", headerSize);
//    NSLog(@"header Size %f, cell width %f, plus %f, screen width %f", headerSize, cellWidth, headerSize*2+cellWidth*self.cellScaleFactor+self.cellScaleFactor-1, screenWidth);
//    return CGSizeMake(headerSize, 0);
//}
//
//- (CGSize) collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section{
//    float screenWidth = [UIScreen mainScreen].bounds.size.width;
//    float cellWidth = floor((screenWidth-(self.cellScaleFactor-1))/self.cellScaleFactor);
//    float footerSize = (screenWidth - (cellWidth*self.cellScaleFactor) - (self.cellScaleFactor -1))/2;
//    return CGSizeMake(footerSize, self.buttonBarView.frame.size.height);
//}

#pragma mark - Cell layout update
- (void) enforceCellToSelectUpdateLayout:(NSIndexPath *)indexPathForUpdatingCell{
    [self collectionView:self.FTimagePickerCollectionView didSelectItemAtIndexPath:indexPathForUpdatingCell];
}

- (void) enforceCellToDeselectAndUpdateLayout:(NSIndexPath *)indexPathForUpdatingCell{
    [self collectionView:self.FTimagePickerCollectionView didDeselectItemAtIndexPath:indexPathForUpdatingCell];
}


#pragma mark - Communication With Detail View
//single selection mode select item in detail view delegate
- (void) singleSelectionModeSelectionConfirmed:(NSMutableArray *)selectedAssetArray{
    PHAsset *selectedAsset = [selectedAssetArray firstObject];
    [self.selectedItemsArray addObject:selectedAsset];
    [self didFinishSelectPhotosFromImagePicker];
}

//delegate for showing alertController from detailview
- (void) presentAlertController:(UIAlertController *)alertController{
    [self presentViewController:alertController animated:YES completion:nil];
}

//delegate for playing videos
- (void) presentAVPlayerViewController:(AVPlayerViewController *)AVPlayerViewController AVPlayer:(AVPlayer *)AVPlayer{
    [self presentViewController:AVPlayerViewController animated:NO completion:nil];
    [AVPlayer play];
}

#pragma mark - Back To application from picker
- (void) didFinishSelectPhotosFromImagePicker{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    [self.delegate getSelectedImageAssetsFromImagePicker:self.selectedItemsArray];
}

- (IBAction)multiSelectConfirmedSelectBtnClicked:(id)sender {
    if(self.selectedItemCount < self.multipleSelectMin){
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Select More Images" message:[NSString stringWithFormat:@"You need to select at least %d images", (int)self.multipleSelectMin] preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *OKAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:OKAction];
        [self presentViewController:alertController animated:YES completion:nil];
    }
    else{
        NSArray *tempArrayForSelectedIndexPath = [NSArray arrayWithArray:self.selectedItemsArray];
        [self.selectedItemsArray removeAllObjects];
        for(NSIndexPath *indexPath in tempArrayForSelectedIndexPath){
            [self.selectedItemsArray addObject:self.allAssets[indexPath.row]];
        }
        NSLog(@"sent items %d", (int)self.selectedItemsArray.count);
        [self.delegate getSelectedImageAssetsFromImagePicker:self.selectedItemsArray];
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }
}

- (IBAction)cancelImagePickerBtnClicked:(UIButton *)sender {
    [self.delegate imagePickerCanceledWithOutSelection];
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Delete Assets
- (IBAction)deleteAssetsBtnClicked:(id)sender {
    NSMutableArray *assetsWillBeDeleted = [[NSMutableArray alloc] init];
    NSMutableIndexSet *assetIndexSetWillBeDeleted = [[NSMutableIndexSet alloc] init];
    for(NSIndexPath *indexPath in self.selectedItemsArray){
        [assetsWillBeDeleted addObject:self.allAssets[indexPath.row]];
        [assetIndexSetWillBeDeleted addIndex:indexPath.row];
    }
    
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        [PHAssetChangeRequest deleteAssets:assetsWillBeDeleted];
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        if(success){
            NSLog(@"assets are deleted");
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.allAssets removeObjectsAtIndexes:assetIndexSetWillBeDeleted];
                [self.selectedItemsArray removeAllObjects];
                self.selectedItemCount = 0;
                [self.FTimagePickerCollectionView reloadData];
                [self.FTDetailView.detailCollectionView reloadData];
                self.albumBtn.hidden = NO;
                self.deleteBtn.hidden = YES;
            });
        }
        else{
            NSLog(@"error ""%@""", error);
        }
    }];
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
        //synchronize multiselectFactor
        if(self.multipleSelectOn){
            self.FTDetailView.selectedItemsArray = self.selectedItemsArray;
            self.FTDetailView.selectedItemCount = self.selectedItemCount;
        }
        //get index path from long pressed point
        CGPoint location = [sender locationInView:self.FTimagePickerCollectionView];
        NSIndexPath *indexPath = [self.FTimagePickerCollectionView indexPathForItemAtPoint:location];
        //set current showing cell's index path value for detailview
        self.FTDetailView.currentShowingCellsIndexPath = indexPath;
        //scroll to show selected image
        [self.FTDetailView.detailCollectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
        //show sub view
        //selected cell in image picker
        FTImagePickerCollectionViewCell *selectedCell = (FTImagePickerCollectionViewCell *)[self.FTimagePickerCollectionView cellForItemAtIndexPath:indexPath];
        //set select button status in detail view
        if(selectedCell.selected){
            [self.FTDetailView.selectBtn setTitle:@"Deselect" forState:UIControlStateNormal];
        }
        else{
            [self.FTDetailView.selectBtn setTitle:@"Select" forState:UIControlStateNormal];
        }
        //get frame from selected cell and convert it according to collection's superview to get correct cgrect value according to main screen
        CGRect convertedRect = [self.FTimagePickerCollectionView convertRect:selectedCell.frame toView:[self.FTimagePickerCollectionView superview]];
        //make a image view for transition effect
        UIImageView *imageViewForTransition = [[UIImageView alloc] initWithFrame:convertedRect];
        imageViewForTransition.contentMode = UIViewContentModeScaleAspectFill;
        imageViewForTransition.clipsToBounds = YES;
        [[PHImageManager defaultManager] requestImageForAsset:self.allAssets[indexPath.row] targetSize:self.FTDetailView.frame.size contentMode:PHImageContentModeAspectFill options:nil resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            imageViewForTransition.image = result;
        }];
        //make a another image view for hiding cell image
        UIView *hidingImageView = [[UIView alloc] initWithFrame:self.FTDetailView.detailCollectionView.bounds];
        hidingImageView.backgroundColor = self.FTDetailView.detailCollectionView.backgroundColor;
        //add subviews
        [self.view addSubview:self.FTDetailView];
        [self.FTDetailView.detailCollectionView addSubview:hidingImageView];
        [self.view addSubview:imageViewForTransition];
        //animation effect configuration
        [self.FTDetailView setAlpha:0.0];
        [UIView animateWithDuration:0.2 animations:^{
            [self.FTDetailView setAlpha:1];
            [imageViewForTransition setFrame:CGRectInset(self.FTDetailView.frame, -0.015*CGRectGetWidth(self.FTDetailView.frame), -0.015*CGRectGetHeight(self.FTDetailView.frame)) ];
            imageViewForTransition.contentMode = UIViewContentModeScaleAspectFit;
        } completion:^(BOOL finished) {
            [imageViewForTransition removeFromSuperview];
            [hidingImageView removeFromSuperview];
        }];
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
                    [self.FTimagePickerCollectionView.collectionViewLayout invalidateLayout];
                    //[self.FTimagePickerCollectionView reloadData];
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



@end
