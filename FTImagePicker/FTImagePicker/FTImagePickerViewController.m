//
//  FTImagePickerViewController.m
//  FTImagePicker
//
//  Created by Park on 2016. 10. 20..
//  Copyright © 2016년 Parkfantagram /inc. All rights reserved.
//

#import "FTImagePickerViewController.h"

@implementation PHAsset (TKFetchAssetsInCollection)

+ (PHFetchResult *) fetchAssetInAssetCollection:(PHAssetCollection *) collection withSortDescriptorKey:(NSString *)sortDescriptorKey withMediaType:(PHAssetMediaType) mediaType withMediaSubtypes:(NSArray<NSNumber *> *) mediaSubtypes{
    PHFetchOptions *albumsFetchingOptions = [[PHFetchOptions alloc] init];
    if(sortDescriptorKey){
        albumsFetchingOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:sortDescriptorKey ascending:NO]];
    }
    NSPredicate *mediaTypePredicate;
    if(mediaType != 3){
        mediaTypePredicate = [NSPredicate predicateWithFormat:@"mediaType = %d", mediaType];
    }
    else{
        mediaTypePredicate = [NSPredicate predicateWithFormat:@"mediaType != %d", mediaType];
    }
    NSMutableArray *mediaSubtypePredicates = [[NSMutableArray alloc] init];
    for(NSNumber *mediaSubtype in mediaSubtypes){
        NSPredicate *mediaSubtypePredicate;
        if([mediaSubtype integerValue] == 0){
            mediaSubtypePredicate = [NSPredicate predicateWithFormat:@"!(((mediaSubtype & %d) | (mediaSubtype & %d) |  (mediaSubtype & %d) | (mediaSubtype & %d) | (mediaSubtype & %d) | (mediaSubtype & %d) | (mediaSubtype & %d) | (mediaSubtype & %d)) != 0)", PHAssetMediaSubtypePhotoHDR, PHAssetMediaSubtypePhotoLive, PHAssetMediaSubtypePhotoPanorama, PHAssetMediaSubtypePhotoScreenshot, PHAssetMediaSubtypeVideoStreamed, PHAssetMediaSubtypeVideoTimelapse, PHAssetMediaSubtypePhotoDepthEffect, PHAssetMediaSubtypeVideoHighFrameRate];
        }
        else{
            mediaSubtypePredicate = [NSPredicate predicateWithFormat:@"(mediaSubtype & %d) != 0", [mediaSubtype integerValue]];
        }
        [mediaSubtypePredicates addObject:mediaSubtypePredicate];
    }
    NSPredicate *compoundMediaSubtypePredicate = [NSCompoundPredicate orPredicateWithSubpredicates:mediaSubtypePredicates];
    NSPredicate *predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[mediaTypePredicate, compoundMediaSubtypePredicate]];
    //NSLog(@"predicate %@", predicate);
    albumsFetchingOptions.predicate = predicate;
    
    PHFetchResult *fetchResult = [PHAsset fetchAssetsInAssetCollection:collection options:albumsFetchingOptions];
    
    return fetchResult;
}

@end

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
    
    //Memory allocation for transition animation
    self.showDetailViewAnimation = [[ShowDetailViewControllerAnimation alloc] init];
    
    //Configure PanGesture for multiSelection
    self.panGestureForMultiSelection.enabled = self.multipleSelectOn;
    
    //Configure FTDetailViewController
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"FTImagePickerStoryBoard" bundle:nil];
    self.FTDetailViewController = [storyBoard instantiateViewControllerWithIdentifier:@"FTDetailViewController"];
    self.FTDetailViewController.multipleSelectOn = self.multipleSelectOn;
    self.FTDetailViewController.multipleSelectMax = self.multipleSelectMax;
    self.FTDetailViewController.multipleSelectMin = self.multipleSelectMin;
    self.FTDetailViewController.ImagePickerCollectionView = self.FTimagePickerCollectionView;
    self.FTDetailViewController.delegate = (id)self;
    self.FTDetailViewController.theme = self.theme;
    
    //set scale criteria for cell pinch zoom recognizer
    self.scaleCriteria = 1.0;
    
    //set multiple selection mode
    self.FTimagePickerCollectionView.allowsMultipleSelection = self.multipleSelectOn;
    
    //fetch images when app start, doesn't fetch images when loaded from selected album
    if(self.allAssets.count == 0){
        //fetch all images from device
        if([PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusAuthorized){
            [self fetchAllImageOrVideoFromDevice];
        }
    }
    //pass assets to detailViewController
    self.FTDetailViewController.allAssets = self.allAssets;
    //Configure FTDetailViewController's CollectionView
    UICollectionViewFlowLayout *collectionViewLayout = [[UICollectionViewFlowLayout alloc] init];
    collectionViewLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    collectionViewLayout.minimumLineSpacing = 0;
    collectionViewLayout.minimumInteritemSpacing = 0;
    self.FTDetailViewController.detailCollectionView = [[UICollectionView alloc] initWithFrame:self.FTDetailViewController.view.bounds collectionViewLayout:collectionViewLayout];
    self.FTDetailViewController.detailCollectionView.allowsMultipleSelection = self.FTDetailViewController.multipleSelectOn;
    self.FTDetailViewController.detailCollectionView.delegate = self.FTDetailViewController;
    self.FTDetailViewController.detailCollectionView.dataSource = self.FTDetailViewController;
    self.FTDetailViewController.detailCollectionView.pagingEnabled = YES;
    [self.FTDetailViewController.detailCollectionView setUserInteractionEnabled:YES];
    [self.FTDetailViewController.detailCollectionView registerClass:[FTDetailViewCollectionViewCell class] forCellWithReuseIdentifier:@"detailViewCells"];
    [self.FTDetailViewController.view insertSubview:self.FTDetailViewController.detailCollectionView belowSubview:self.FTDetailViewController.buttonBarView];
    
    //3d touch Configuration
    if(self.traitCollection.forceTouchCapability == UIForceTouchCapabilityAvailable){
        self.longPressGesture.enabled = NO;
        [self registerForPreviewingWithDelegate:(id)self sourceView:self.FTimagePickerCollectionView];
    }
    
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
        self.buttonBarView.backgroundColor = [UIColor colorWithWhite:0.92 alpha:0.7];
        [self.view setTintColor:[UIColor colorWithWhite:0.25 alpha:1.0]];
        self.FTDetailViewController.detailCollectionView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:1.0];
    }
    //black version
    else if(theme == 1){
        self.FTimagePickerCollectionView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:1.0];
        self.buttonBarView.backgroundColor = [UIColor colorWithWhite:0.08 alpha:0.7];
        [self.view setTintColor:[UIColor colorWithWhite:0.65 alpha:1.0]];
        self.FTDetailViewController.detailCollectionView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:1.0];
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
    self.FTDetailViewController.allAssets = self.allAssets;
    [self.FTimagePickerCollectionView reloadData];
    [self.FTDetailViewController.detailCollectionView reloadData];
}


#pragma mark - Image Fetching
- (void) fetchAllImageOrVideoFromDevice {
    NSDate *methodStart = [NSDate date];
    PHFetchResult *cameraRollAlbum = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:nil];
    [cameraRollAlbum enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        PHAssetCollection *collection = obj;
        
        PHFetchResult *assetResultForAlbum = [PHAsset fetchAssetInAssetCollection:collection withSortDescriptorKey:nil withMediaType:self.mediaTypeToUse withMediaSubtypes:self.mediaSubTypeToUse];
        [assetResultForAlbum enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
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
                PHFetchResult *assetResultForAlbum = [PHAsset fetchAssetInAssetCollection:collection withSortDescriptorKey:nil withMediaType:self.mediaTypeToUse withMediaSubtypes:self.mediaSubTypeToUse];
                [assetResultForAlbum enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
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
                PHFetchResult *assetResultForAlbum = [PHAsset fetchAssetInAssetCollection:collection withSortDescriptorKey:nil withMediaType:self.mediaTypeToUse withMediaSubtypes:self.mediaSubTypeToUse];
                [assetResultForAlbum enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
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
        //selection is only available when selected items count is below or equal to multiple select max count
        //This limitation is defined in collectionView shouldSelectItemAtIndexPath method.
        [self followingCellSelectionProcedureWithCellsIndexPath:indexPath];
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
    [self followingCellDeselectionProcedureWithCellsIndexPath:indexPath];
}

- (IBAction)multiSelectionByPanGesture:(UIPanGestureRecognizer *)sender {
    //In the beginning state, get start point and Check if mode is select mode or not
    if(sender.state == UIGestureRecognizerStateBegan){
        self.startPoint = [sender locationInView:self.FTimagePickerCollectionView];
        NSIndexPath *startPointIndexPath = [self.FTimagePickerCollectionView indexPathForItemAtPoint:self.startPoint];
        FTImagePickerCollectionViewCell *cellAtStartPoint = (__kindof UICollectionViewCell *) [self.FTimagePickerCollectionView cellForItemAtIndexPath:startPointIndexPath];
        if(cellAtStartPoint.selected){
            self.selectionMode = NO;
        }
        else{
            self.selectionMode = YES;
        }
    }
    //In the changing state, Gets the end point and gets cell's indexpaths which is in the rect between start point and endpoint
    //In this stage, cell is not selected actually, cell just changes its layout
    else if(sender.state == UIGestureRecognizerStateChanged){
//        //If a finger reached screen boundary, scroll moves
//        CGPoint pointInView = [sender locationInView:self.view];
//        CGPoint velocity = [sender velocityInView:self.view];
//        NSLog(@"velocity y %f", velocity.y);
//        if(pointInView.y < 30){
//            self.FTimagePickerCollectionView.contentOffset = CGPointMake(self.FTimagePickerCollectionView.contentOffset.x, self.FTimagePickerCollectionView.contentOffset.y - velocity.y/10 - 1);
//        }
//        else if(pointInView.y > [UIScreen mainScreen].bounds.size.height - 50){
//            self.FTimagePickerCollectionView.contentOffset = CGPointMake(self.FTimagePickerCollectionView.contentOffset.x, self.FTimagePickerCollectionView.contentOffset.y + velocity.y/10 + 1);
//        }
        //Cell Layout Change
        self.endPoint = [sender locationInView:self.FTimagePickerCollectionView];
        NSIndexPath *indexPathForStartPoint = [self.FTimagePickerCollectionView indexPathForItemAtPoint:self.startPoint];
        NSIndexPath *indexPathForEndPoint = [self.FTimagePickerCollectionView indexPathForItemAtPoint:self.endPoint];
        if(!indexPathForEndPoint){
            indexPathForEndPoint = [NSIndexPath indexPathForRow:self.allAssets.count - 1 inSection:0];
        }
        //NSLog(@"startPoint %@ endPoint %@", indexPathForStartPoint, indexPathForEndPoint);
        NSArray<__kindof UICollectionViewCell *> *visibleCells = [self.FTimagePickerCollectionView visibleCells];
        if(indexPathForStartPoint.row < indexPathForEndPoint.row){
            if(self.selectionMode && indexPathForEndPoint.row - indexPathForStartPoint.row + 1 > self.multipleSelectMax - self.selectedItemCount){
                indexPathForEndPoint = [NSIndexPath indexPathForRow:indexPathForStartPoint.row + (self.multipleSelectMax - self.selectedItemCount) - 1 inSection:0];
            }
            for(__kindof UICollectionViewCell *cell in visibleCells){
                NSIndexPath *indexPath = [self.FTimagePickerCollectionView indexPathForCell:cell];
                if(!cell.selected && self.selectionMode){
                    if(indexPath.row >= indexPathForStartPoint.row && indexPath.row <= indexPathForEndPoint.row){
                        [self selectedCellLayoutChange:cell];
                    }
                    else{
                        [self deselectedCellLayoutChange:cell];
                    }
                    
                }
                else if(cell.selected && !self.selectionMode){
                    if(indexPath.row >= indexPathForStartPoint.row && indexPath.row <= indexPathForEndPoint.row){
                        [self deselectedCellLayoutChange:cell];
                    }
                    else{
                        [self selectedCellLayoutChange:cell];
                    }
                }
            }
        }
        else{
            if(self.selectionMode && indexPathForStartPoint.row - indexPathForEndPoint.row + 1 > self.multipleSelectMax - self.selectedItemCount){
                indexPathForEndPoint = [NSIndexPath indexPathForRow:indexPathForStartPoint.row - (self.multipleSelectMax - self.selectedItemCount) + 1 inSection:0];
            }
            for(__kindof UICollectionViewCell *cell in visibleCells){
                NSIndexPath *indexPath = [self.FTimagePickerCollectionView indexPathForCell:cell];
                if(!cell.selected && self.selectionMode){
                    if(indexPath.row >= indexPathForEndPoint.row && indexPath.row <= indexPathForStartPoint.row){
                        [self selectedCellLayoutChange:cell];
                    }
                    else{
                        [self deselectedCellLayoutChange:cell];
                    }
                }
                else if(cell.selected && !self.selectionMode){
                    if(indexPath.row >= indexPathForEndPoint.row && indexPath.row <= indexPathForStartPoint.row){
                        [self deselectedCellLayoutChange:cell];
                    }
                    else{
                        [self selectedCellLayoutChange:cell];
                    }
                }
            }
        }
    }
    //In the end state, finally select all the cell's which indexpaths is in the rect between start point and endpoint
    else{
        NSIndexPath *indexPathForStartPoint = [self.FTimagePickerCollectionView indexPathForItemAtPoint:self.startPoint];
        NSIndexPath *indexPathForEndPoint = [self.FTimagePickerCollectionView indexPathForItemAtPoint:self.endPoint];
        if(!indexPathForEndPoint){
            indexPathForEndPoint = [NSIndexPath indexPathForRow:self.allAssets.count - 1 inSection:0];
        }
        if(indexPathForStartPoint.row < indexPathForEndPoint.row){
            if(self.selectionMode && indexPathForEndPoint.row - indexPathForStartPoint.row + 1 > self.multipleSelectMax - self.selectedItemCount){
                indexPathForEndPoint = [NSIndexPath indexPathForRow:indexPathForStartPoint.row + (self.multipleSelectMax - self.selectedItemCount) - 1 inSection:0];
            }
            for(int i = (int)indexPathForStartPoint.row ; i < (int)indexPathForEndPoint.row + 1; i++){
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
                FTImagePickerCollectionViewCell *cell = (__kindof UICollectionViewCell*) [self.FTimagePickerCollectionView cellForItemAtIndexPath:indexPath];
                //selection mode
                if(self.selectionMode == YES && cell.selected == NO){
                    [self.FTimagePickerCollectionView selectItemAtIndexPath:indexPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
                    [self followingCellSelectionProcedureWithCellsIndexPath:indexPath];
                }
                //deselection mode
                else if(self.selectionMode == NO && cell.selected == YES){
                    [self.FTimagePickerCollectionView deselectItemAtIndexPath:indexPath animated:YES];
                    [self followingCellDeselectionProcedureWithCellsIndexPath:indexPath];
                }
            }
        }
        else{
            if(self.selectionMode && indexPathForStartPoint.row - indexPathForEndPoint.row + 1 > self.multipleSelectMax - self.selectedItemCount){
                indexPathForEndPoint = [NSIndexPath indexPathForRow:indexPathForStartPoint.row - (self.multipleSelectMax - self.selectedItemCount) + 1 inSection:0];
            }
            for(int i = (int)indexPathForEndPoint.row ; i < (int)indexPathForStartPoint.row + 1; i++){
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
                FTImagePickerCollectionViewCell *cell = (__kindof UICollectionViewCell*) [self.FTimagePickerCollectionView cellForItemAtIndexPath:indexPath];
                //selection mode
                if(self.selectionMode == YES && cell.selected == NO){
                    [self.FTimagePickerCollectionView selectItemAtIndexPath:indexPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
                    [self followingCellSelectionProcedureWithCellsIndexPath:indexPath];
                }
                //deselection mode
                else if(self.selectionMode == NO && cell.selected == YES){
                    [self.FTimagePickerCollectionView deselectItemAtIndexPath:indexPath animated:YES];
                    [self followingCellDeselectionProcedureWithCellsIndexPath:indexPath];
                }
            }
        }
    }
}

#pragma mark - Following Cell Selection Procedure
- (void) followingCellSelectionProcedureWithCellsIndexPath:(NSIndexPath *) indexPath{
    FTImagePickerCollectionViewCell *imagePickerCell = (FTImagePickerCollectionViewCell *) [self.FTimagePickerCollectionView cellForItemAtIndexPath:indexPath];
    [self selectedCellLayoutChange:imagePickerCell];
    [self.FTDetailViewController.detailCollectionView selectItemAtIndexPath:indexPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
    [self.selectedItemsArray addObject:indexPath];
    self.selectedItemCount += 1;
    NSLog(@"selected count %d", (int)self.selectedItemCount);
    //force collectionview in detailview to update selected cell layout
    [self.FTDetailViewController collectionView:self.FTDetailViewController.detailCollectionView didSelectItemAtIndexPath:indexPath];
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

- (void) followingCellDeselectionProcedureWithCellsIndexPath:(NSIndexPath *) indexPath{
    FTImagePickerCollectionViewCell *imagePickerCell = (FTImagePickerCollectionViewCell *) [self.FTimagePickerCollectionView cellForItemAtIndexPath:indexPath];
    [self deselectedCellLayoutChange:imagePickerCell];
    [self.FTDetailViewController.detailCollectionView deselectItemAtIndexPath:indexPath animated:NO];
    for(int i = 0; i < self.selectedItemsArray.count; i++){
        if(self.selectedItemsArray[i] == indexPath){
            [self.selectedItemsArray removeObjectAtIndex:i];
        }
    }
    self.selectedItemCount -= 1;
    NSLog(@"selected count %d", (int)self.selectedItemCount);
    //force collectionview in detailview to update deselected cell layout
    [self.FTDetailViewController collectionView:self.FTDetailViewController.detailCollectionView didDeselectItemAtIndexPath:indexPath];
    //select button shows only when a user selects items more than the minimum number
    if(self.selectedItemCount < self.multipleSelectMin){
        self.selectBtn.hidden = YES;
    }
    if(self.selectedItemCount < 1 && !self.syncedAlbum){
        self.deleteBtn.hidden = YES;
        self.albumBtn.hidden = NO;
    }
}

#pragma mark - Gesture Recognizer delegate
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    if([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]){
        UIPanGestureRecognizer *panGesture = (UIPanGestureRecognizer *) gestureRecognizer;
        CGPoint translation = [panGesture translationInView:self.FTimagePickerCollectionView];
        if(translation.x * translation.x > translation.y * translation.y){
            return YES;
        }
        else{
            return NO;
        }
    }
    else{
        return YES;
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
    float cellWidth = floor((screenWidth-(self.numberOfCellsInLine - 1))/self.numberOfCellsInLine);
    return CGSizeMake(cellWidth, cellWidth);
}

#pragma mark Collection View Header
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    if([kind isEqualToString:UICollectionElementKindSectionHeader]){
        if(self.imagePickerHeaderHeight != 0){
            FTImagePickerCollectionViewHeaderView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"ImagePickerCollectionViewHeader" forIndexPath:indexPath];
            
            headerView.albumNameForHeader.text = self.albumName;
            headerView.descForAlbum.text = @"";
            return headerView;
        }
        else{
            return nil;
        }
    }
    else{
        UICollectionReusableView *footerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"ImagePickerCollectionViewFooter" forIndexPath:indexPath];
        
        return footerView;
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
    float screenWidth = [UIScreen mainScreen].bounds.size.width;
    float headerHeight = self.imagePickerHeaderHeight;
    
    return CGSizeMake(screenWidth, headerHeight);
}

//- (CGSize) collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section{
//    float screenWidth = [UIScreen mainScreen].bounds.size.width;
//    float cellWidth = floor((screenWidth-(self.numberOfCellsInLine-1))/self.numberOfCellsInLine);
//    float footerSize = (screenWidth - (cellWidth*self.numberOfCellsInLine) - (self.numberOfCellsInLine -1))/2;
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
                [self.FTDetailViewController.detailCollectionView reloadData];
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
//Present DetailViewController by longPress(3d touch is not available)
- (IBAction)showDetailCellLongPressed:(UILongPressGestureRecognizer *)sender {
    if(sender.state == UIGestureRecognizerStateBegan){
        //synchronize multiselectFactor
        if(self.multipleSelectOn){
            self.FTDetailViewController.selectedItemsArray = self.selectedItemsArray;
            self.FTDetailViewController.selectedItemCount = self.selectedItemCount;
        }
        //get index path from long pressed point
        CGPoint location = [sender locationInView:self.FTimagePickerCollectionView];
        NSIndexPath *indexPath = [self.FTimagePickerCollectionView indexPathForItemAtPoint:location];
        //set current showing cell's index path value for detailview
        self.FTDetailViewController.currentShowingCellsIndexPath = indexPath;
        //show sub view
        //selected cell in image picker
        FTImagePickerCollectionViewCell *selectedCell = (FTImagePickerCollectionViewCell *)[self.FTimagePickerCollectionView cellForItemAtIndexPath:indexPath];
        //set select button status in detail view
        if(selectedCell.selected){
            [self.FTDetailViewController.selectBtn setTitle:@"Deselect" forState:UIControlStateNormal];
        }
        else{
            [self.FTDetailViewController.selectBtn setTitle:@"Select" forState:UIControlStateNormal];
        }
        //get frame from selected cell and convert it according to collection's superview to get correct cgrect value according to main screen
        CGRect convertedRect = [self.FTimagePickerCollectionView convertRect:selectedCell.frame toView:[self.FTimagePickerCollectionView superview]];
        //make a image view for transition effect
        UIImageView *imageViewForTransition = [[UIImageView alloc] initWithFrame:convertedRect];
        imageViewForTransition.contentMode = UIViewContentModeScaleAspectFill;
        imageViewForTransition.clipsToBounds = YES;
        [[PHImageManager defaultManager] requestImageForAsset:self.allAssets[indexPath.row] targetSize:self.FTDetailViewController.view.frame.size contentMode:PHImageContentModeAspectFill options:nil resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            imageViewForTransition.image = result;
        }];
        self.showDetailViewAnimation.imageViewForTransition = imageViewForTransition;
        //make another view for hiding cell image
        UIView *hidingCellView = [[UIView alloc] initWithFrame:convertedRect];
        hidingCellView.backgroundColor = self.FTDetailViewController.detailCollectionView.backgroundColor;
        self.showDetailViewAnimation.hidingCellView = hidingCellView;
        [self.view addSubview:hidingCellView];
        //Here, need to set destination view controller's delegate!!
        self.FTDetailViewController.transitioningDelegate = self;
        //Let presenting view controller be not hidden by presented view controller
        self.FTDetailViewController.modalPresentationStyle = UIModalPresentationCustom;
        [self.FTDetailViewController.detailCollectionView setAlpha:1.0];
        [self presentViewController:self.FTDetailViewController animated:YES completion:nil];
    }
}
//3d touch Peek
- (UIViewController *)previewingContext:(id<UIViewControllerPreviewing>)previewingContext viewControllerForLocation:(CGPoint)location{
    if([self.FTimagePickerCollectionView indexPathForItemAtPoint:location]){
        NSLog(@"preview");
        NSIndexPath *selectedCellsIndexPath = [self.FTimagePickerCollectionView indexPathForItemAtPoint:location];
        FTImagePickerCollectionViewCell *selectedCell = (__kindof UICollectionViewCell *) [self.FTimagePickerCollectionView cellForItemAtIndexPath:selectedCellsIndexPath];
        [previewingContext setSourceRect:selectedCell.frame];
        self.indexPathForSelectedCell = selectedCellsIndexPath;
        
        //synchronize multiselectFactor
        if(self.multipleSelectOn){
            self.FTDetailViewController.selectedItemsArray = self.selectedItemsArray;
            self.FTDetailViewController.selectedItemCount = self.selectedItemCount;
        }
        //set current showing cell's index path value for detailview
        self.FTDetailViewController.currentShowingCellsIndexPath = self.indexPathForSelectedCell;
        //Hide detail view menu when previewing
        self.FTDetailViewController.buttonBarView.hidden = YES;
        //set collection view of detailview controller to be seen
        [self.FTDetailViewController.detailCollectionView setAlpha:1.0];
        
        return self.FTDetailViewController;
    }
    else{
        return nil;
    }
}
//3d touch Pop
- (void)previewingContext:(id<UIViewControllerPreviewing>)previewingContext commitViewController:(UIViewController *)viewControllerToCommit{
    //show sub view
    //selected cell in image picker
    FTImagePickerCollectionViewCell *selectedCell = (FTImagePickerCollectionViewCell *)[self.FTimagePickerCollectionView cellForItemAtIndexPath:self.indexPathForSelectedCell];
    //set select button status in detail view
    if(selectedCell.selected){
        [self.FTDetailViewController.selectBtn setTitle:@"Deselect" forState:UIControlStateNormal];
    }
    else{
        [self.FTDetailViewController.selectBtn setTitle:@"Select" forState:UIControlStateNormal];
    }
    //Show detail view controller menu again
    self.FTDetailViewController.buttonBarView.hidden = NO;
    //Let presenting view controller not be hidden by presented view controller
    self.FTDetailViewController.modalPresentationStyle = UIModalPresentationCustom;
    [self presentViewController:self.FTDetailViewController animated:YES completion:nil];
}

#pragma mark - Transitioning Delegate
- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source{
    return self.showDetailViewAnimation;
}

#pragma mark - Cell Zoom In and Out
- (IBAction)cellZoomInOutPinch:(UIPinchGestureRecognizer *)sender {
    if(self.cellPinchZoomOn){
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
                    if((scale - self.scaleCriteria) > 0 && self.numberOfCellsInLine > 2){
                        self.numberOfCellsInLine -= 1;
                        NSLog(@"scaleFactor %ld", (long)self.numberOfCellsInLine);
                        [self.FTimagePickerCollectionView reloadData];
                    }
                    else if((scale - self.scaleCriteria) < 0 && self.numberOfCellsInLine < 6){
                        self.numberOfCellsInLine += 1;
                        NSLog(@"scaleFactor %ld", (long)self.numberOfCellsInLine);
                        [self.FTimagePickerCollectionView.collectionViewLayout invalidateLayout];
                        //[self.FTimagePickerCollectionView reloadData];
                    }
                    self.scaleCriteria = scale;
                }
                
            }
            //when scale is over 1, doesn't need to be sensitive like in the region below 1
            else if(difference > 0.12){
                NSLog(@"scale %f criteria %f difference %f",scale, self.scaleCriteria, scale - self.scaleCriteria);
                if((scale - self.scaleCriteria) > 0 && self.numberOfCellsInLine > 2){
                    self.numberOfCellsInLine -= 1;
                    NSLog(@"scaleFactor %ld", (long)self.numberOfCellsInLine);
                    [self.FTimagePickerCollectionView.collectionViewLayout invalidateLayout];
                    //[self.FTimagePickerCollectionView reloadData];
                }
                else if((scale - self.scaleCriteria) < 0 && self.numberOfCellsInLine < 6){
                    self.numberOfCellsInLine += 1;
                    NSLog(@"scaleFactor %ld", (long)self.numberOfCellsInLine);
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
}
#pragma mark - Check 3d touch Availibility
- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection{
    [super traitCollectionDidChange:previousTraitCollection];
    NSLog(@"changed");
    if(self.traitCollection.forceTouchCapability == UIForceTouchCapabilityAvailable){
        self.longPressGesture.enabled = NO;
    }
    else{
        self.longPressGesture.enabled = YES;
    }
}


@end

#pragma mark - Transition Animation
@implementation ShowDetailViewControllerAnimation

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext{
    return 0.2;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext{
    UIView *containerView = [transitionContext containerView];
    FTDetailViewController *ToViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    if(!ToViewController){
        return;
    }
    
    CGRect finalFrame = [transitionContext finalFrameForViewController:ToViewController];
    CGRect transitionFinalRect = CGRectInset(finalFrame, -0.015*CGRectGetWidth(finalFrame), -0.015*CGRectGetHeight(finalFrame));
    
    //View For Fromview Fadeout
    UIView *backgroundFadeOut = [[UIView alloc] initWithFrame:finalFrame];
    backgroundFadeOut.backgroundColor = ToViewController.detailCollectionView.backgroundColor;
    [backgroundFadeOut setAlpha:0.0];
    
    [containerView addSubview:ToViewController.view];
    [containerView addSubview:backgroundFadeOut];
    [containerView addSubview:self.imageViewForTransition];
    ToViewController.view.hidden = YES;
    
    NSTimeInterval duration = [self transitionDuration:transitionContext];
    
    [UIView animateWithDuration:duration animations:^{
        self.imageViewForTransition.contentMode = UIViewContentModeScaleAspectFit;
        [self.imageViewForTransition setFrame:transitionFinalRect];
        [backgroundFadeOut setAlpha:1.0];
    } completion:^(BOOL finished) {
        ToViewController.view.hidden = NO;
        [self.imageViewForTransition removeFromSuperview];
        [self.hidingCellView removeFromSuperview];
        [backgroundFadeOut removeFromSuperview];
        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
    }];
}
@end

