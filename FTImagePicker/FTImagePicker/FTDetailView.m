//
//  FTDetailView.m
//  FTImagePicker
//
//  Created by Park on 2016. 10. 20..
//  Copyright © 2016년 Parkfantagram /inc. All rights reserved.
//

#import "FTDetailView.h"

@implementation FTDetailView

#pragma mark - Item Selection
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"cell selected");
    //single selection mode
    if(!self.multipleSelectOn){
        
    }
    //multiple selection mode
    else{
        FTDetailViewCollectionViewCell *cell = (FTDetailViewCollectionViewCell *) [collectionView cellForItemAtIndexPath:indexPath];
        [self selectedCellLayoutChange:cell];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath{
    FTDetailViewCollectionViewCell *cell = (FTDetailViewCollectionViewCell *) [collectionView cellForItemAtIndexPath:indexPath];
    [self deselectedCellLayoutChange:cell];
}

#pragma mark - Configuring Cells
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    FTDetailViewCollectionViewCell *cell = [self.detailCollectionView dequeueReusableCellWithReuseIdentifier:@"detailViewCells" forIndexPath:indexPath];
    //remove uilabel for reused cells
    for(UIView *view in cell.subviews){
        if([view isKindOfClass:[UIButton class]]){
            [view removeFromSuperview];
        }
    }
    PHAsset *assetForIndexPath = self.allAssets[indexPath.row];
    [[PHImageManager defaultManager] requestImageForAsset:assetForIndexPath targetSize:CGSizeMake(cell.bounds.size.width*3, cell.bounds.size.height*2)  contentMode:PHImageContentModeAspectFit options:nil resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        //set image
        [cell.detailImageView setFrame:self.frame];
        cell.detailImageView.image = result;
        //configure scroll view
        cell.scrollViewForZoom.maximumZoomScale = 3.0;
        cell.scrollViewForZoom.minimumZoomScale = 1.0;
        cell.scrollViewForZoom.delegate = self;
        cell.scrollViewForZoom.zoomScale = 1.0;
        //if asset is Video type
        if(assetForIndexPath.mediaType == PHAssetMediaTypeVideo){
            //add Button to show its video asset
            UIButton *playButton = [[UIButton alloc] initWithFrame:CGRectMake(self.bounds.size.width/2-20, self.bounds.size.height/2 - 15, 40, 30)];
            [playButton setTitle:@"Play" forState:UIControlStateNormal];
            playButton.tintColor = [UIColor whiteColor];
            [playButton addTarget:self action:@selector(playVideosButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
            [cell addSubview:playButton];
        }
        //Hide delete button when the asset if synced from itunes
        //Because asset synced from itunes cannot be deleted in IPhone
        if(assetForIndexPath.sourceType == PHAssetSourceTypeiTunesSynced){
            self.deleteBtn.hidden = YES;
        }
        else{
            self.deleteBtn.hidden = NO;
        }
    }];
    if(cell.selected){
        [self selectedCellLayoutChange:cell];
    }
    else{
        [self deselectedCellLayoutChange:cell];
    }
    return cell;
}
#pragma mark - Scroll View Delegate
//make sure add correct item by select button
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    self.selectBtn.enabled = NO;
    self.deleteBtn.enabled = NO;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    self.selectBtn.enabled = YES;
    self.deleteBtn.enabled = YES;
}

//scroll view delegate
- (UIView *) viewForZoomingInScrollView:(UIScrollView *)scrollView{
    for (UIView *view in scrollView.subviews){
        if([view isKindOfClass:[UIImageView class]]){
            return view;
        }
    }
    return nil;
}

//did delegate is used to get current showing cell's information by scroll
- (void) scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset{
    NSLog(@"scroll view content offset x: %f, y: %f", scrollView.contentOffset.x, scrollView.contentOffset.y);
    NSLog(@"scoll view targetConetnOffset x: %f, y: %f", targetContentOffset->x, targetContentOffset->y);
    [self selectBtnConfigure:scrollView withVelocity:velocity targetContentOffset:targetContentOffset];
    [self moveImagePickersScrollToCurrentShowingItem:scrollView withVelocity:velocity targetContentOffset:targetContentOffset];
    [self scrollViewZoomReset:scrollView withVelocity:velocity targetContentOffset:targetContentOffset];
    
}

#pragma mark Scroll View Zoom Reset
- (void) scrollViewZoomReset:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset{
    if(self.currentShowingCellsIndexPath != [self getCurrentShowingCellsIndexPath:scrollView withVelocity:velocity targetContentOffset:targetContentOffset]){
        FTDetailViewCollectionViewCell *previousCell = (__kindof UICollectionViewCell *) [self.detailCollectionView cellForItemAtIndexPath:self.currentShowingCellsIndexPath];
        [UIView animateWithDuration:0 delay:0.3 options:UIViewAnimationOptionTransitionNone animations:^{
            previousCell.scrollViewForZoom.zoomScale = 1.0;
        } completion:nil];
        self.currentShowingCellsIndexPath = [self getCurrentShowingCellsIndexPath:scrollView withVelocity:velocity targetContentOffset:targetContentOffset];
    }
}

- (NSIndexPath *) getCurrentShowingCellsIndexPath:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset{
    NSArray *visibleItem = [NSArray arrayWithArray:[self.detailCollectionView indexPathsForVisibleItems]];
    NSIndexPath *indexPathForCell;
    NSIndexPath *firstObjectIndexPath = [visibleItem firstObject];
    NSIndexPath *lastObjectIndexPath = [visibleItem lastObject];
    if(targetContentOffset->x > scrollView.contentOffset.x){
        if(firstObjectIndexPath.row > lastObjectIndexPath.row){
            indexPathForCell = firstObjectIndexPath;
        }
        else{
            indexPathForCell = lastObjectIndexPath;
        }
    }
    //scroll view is heading -x direction
    else{
        if(firstObjectIndexPath.row < lastObjectIndexPath.row){
            indexPathForCell = firstObjectIndexPath;
        }
        else{
            indexPathForCell = lastObjectIndexPath;
        }
    }
    return indexPathForCell;
}

- (__kindof UICollectionViewCell *) getCurrentShowingCell:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset{
    NSArray *visibleItem = [NSArray arrayWithArray:[self.detailCollectionView indexPathsForVisibleItems]];
    FTDetailViewCollectionViewCell *detailViewCell;
    NSIndexPath *firstObjectIndexPath = [visibleItem firstObject];
    NSIndexPath *lastObjectIndexPath = [visibleItem lastObject];
    NSIndexPath *indexPathForCell;
    //scroll view is heading +x direction
    if(targetContentOffset->x > scrollView.contentOffset.x){
        if(firstObjectIndexPath.row > lastObjectIndexPath.row){
            indexPathForCell = firstObjectIndexPath;
        }
        else{
            indexPathForCell = lastObjectIndexPath;
        }
        detailViewCell =(FTDetailViewCollectionViewCell *) [self.detailCollectionView cellForItemAtIndexPath:indexPathForCell];
    }
    //scroll view is heading -x direction
    else{
        if(firstObjectIndexPath.row < lastObjectIndexPath.row){
            indexPathForCell = firstObjectIndexPath;
        }
        else{
            indexPathForCell = lastObjectIndexPath;
        }
        detailViewCell =(FTDetailViewCollectionViewCell *) [self.detailCollectionView cellForItemAtIndexPath:indexPathForCell];
    }
    return detailViewCell;
}

#pragma mark - Scroll Caller CollectionView
- (void) moveImagePickersScrollToCurrentShowingItem: (UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset{
    NSIndexPath *indexPathForCurrentCell = [self getCurrentShowingCellsIndexPath:scrollView withVelocity:velocity targetContentOffset:targetContentOffset];
    [self.ImagePickerCollectionView scrollToItemAtIndexPath:indexPathForCurrentCell atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:NO];
}

#pragma mark - Collection View Configuring
- (CGSize) collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return self.bounds.size;
}

- (NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.allAssets.count;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

#pragma mark - Gesture Recognizer Delegate
//gesture recognizer delegate
//if movement toward y direction is larger than direction toward x, gesture recognizer begins
//else, collection view's normal pan handle its scroll
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    CGPoint location = [gestureRecognizer locationInView:self];
    if([gestureRecognizer isKindOfClass:[UIScreenEdgePanGestureRecognizer class]]){
        //For preventing dismiss video player when video player control bar slider controled
        if(location.y > self.frame.size.height - 100){
            return NO;
        }
        else{
            return YES;
        }
    }
    else if([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]){
        UIPanGestureRecognizer *panGestureRecognizer = (UIPanGestureRecognizer *) gestureRecognizer;
        CGPoint translation = [panGestureRecognizer translationInView:self.detailCollectionView];
        if(translation.x*translation.x < translation.y*translation.y){
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

#pragma mark - Dismiss View
- (IBAction)dismissViewDownPan:(UIPanGestureRecognizer *)sender {
    CGPoint translation = [sender translationInView:self.detailCollectionView];
    CGPoint location = [sender locationInView:self];
    if(sender.state == UIGestureRecognizerStateBegan){
        //make a imageView For transition and configure
        self.imageViewForTransition = [[UIImageView alloc] initWithFrame:self.bounds];
        self.imageViewForTransition.contentMode = UIViewContentModeScaleAspectFit;
        self.imageViewForTransition.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.0];
        //selected cell for get image from it
        FTDetailViewCollectionViewCell *selectedCell = (FTDetailViewCollectionViewCell *) [self.detailCollectionView cellForItemAtIndexPath:[[self.detailCollectionView indexPathsForVisibleItems] firstObject]];
        //assign image to imageview
        self.imageViewForTransition.image = selectedCell.detailImageView.image;
        //Image picker cell for destination point of transition
        FTImagePickerCollectionViewCell *selectedCellInImagePicker = (FTImagePickerCollectionViewCell *) [self.ImagePickerCollectionView cellForItemAtIndexPath:[[self.detailCollectionView indexPathsForVisibleItems] firstObject]];
        //hide image in image picker for effect
        [selectedCellInImagePicker.contentView setAlpha:0.0];
        //hide image view in detail collection view
        [selectedCell.detailImageView setAlpha:0.0];
        //add imageView as subview of Image Picker collection view
        [self addSubview:self.imageViewForTransition];
    }
    else if(sender.state == UIGestureRecognizerStateChanged){
        self.backgroundColor = [UIColor colorWithWhite:1.0 alpha:1.0 - translation.y*0.003];
        [self.detailCollectionView setAlpha:1.0 -translation.y*0.003];
        self.imageViewForTransition.center = location;
    }
    else{
        //selected cell in detail view
        FTDetailViewCollectionViewCell *selectedCell = (FTDetailViewCollectionViewCell *) [self.detailCollectionView cellForItemAtIndexPath:[[self.detailCollectionView indexPathsForVisibleItems] firstObject]];
        //Image picker cell for destination point of transition
        FTImagePickerCollectionViewCell *selectedCellInImagePicker = (FTImagePickerCollectionViewCell *) [self.ImagePickerCollectionView cellForItemAtIndexPath:[[self.detailCollectionView indexPathsForVisibleItems] firstObject]];
        //dismiss detail view
        if(translation.y > 20){
            //Animation effect
            [UIView animateWithDuration:0.2 animations:^{
                CGRect convertedRect = [self.ImagePickerCollectionView convertRect:selectedCellInImagePicker.frame toView:[self.ImagePickerCollectionView superview]];
                NSLog(@"converted frame x:%f, y:%f", convertedRect.origin.x, convertedRect.origin.y);
                [self.imageViewForTransition setFrame:convertedRect];
                NSLog(@"cell frame x:%f, y:%f", selectedCellInImagePicker.frame.origin.x, selectedCellInImagePicker.frame.origin.y);
            } completion:^(BOOL finished) {
                self.imageViewForTransition.contentMode = UIViewContentModeScaleAspectFill;
                [self.imageViewForTransition removeFromSuperview];
                [self removeFromSuperview];
                //show cell in image picker after transition
                [selectedCellInImagePicker.contentView setAlpha:1.0];
                //restore background coler of detail view and collection view
                self.backgroundColor = [UIColor colorWithWhite:1.0 alpha:1.0];
                [self.detailCollectionView setAlpha:1.0];
                //restore image view in detail collection view
                [selectedCell.detailImageView setAlpha:1.0];
            }];
        }
        //cancel dismiss
        else{
            //Animation effect
            [UIView animateWithDuration:0.2 animations:^{
                [self.imageViewForTransition setFrame:self.bounds];
            } completion:^(BOOL finished) {
                [self.imageViewForTransition removeFromSuperview];
                //show cell in image picker after transition
                [selectedCellInImagePicker.contentView setAlpha:1.0];
                //restore background coler of detail view and collection view
                self.backgroundColor = [UIColor colorWithWhite:1.0 alpha:1.0];
                [self.detailCollectionView setAlpha:1.0];
                //restore image view in detail collection view
                [selectedCell.detailImageView setAlpha:1.0];
            }];
        }
    }
}

- (IBAction)dismissViewBtnClicked:(UIButton *)sender {
    //make a imageView For transition and configure
    UIImageView *imageViewForTransition = [[UIImageView alloc] initWithFrame:self.ImagePickerCollectionView.bounds];
    imageViewForTransition.contentMode = UIViewContentModeScaleAspectFit;
    //selected cell for get image from it
    FTDetailViewCollectionViewCell *selectedCell = (FTDetailViewCollectionViewCell *) [self.detailCollectionView cellForItemAtIndexPath:[[self.detailCollectionView indexPathsForVisibleItems] firstObject]];
    //assign image to imageview
    imageViewForTransition.image = selectedCell.detailImageView.image;
    //add imageView as subview of Image Picker collection view
    [self.ImagePickerCollectionView addSubview:imageViewForTransition];
    //Image picker cell for destination point of transition
    FTImagePickerCollectionViewCell *selectedCellInImagePicker = (FTImagePickerCollectionViewCell *) [self.ImagePickerCollectionView cellForItemAtIndexPath:[[self.detailCollectionView indexPathsForVisibleItems] firstObject]];
    //hide image in image picker for effect
    [selectedCellInImagePicker.contentView setAlpha:0.0];
    //Animation effect
    [UIView animateWithDuration:0.2 animations:^{
        [imageViewForTransition setFrame:selectedCellInImagePicker.frame];
        [self setAlpha:0.0];
    } completion:^(BOOL finished) {
        imageViewForTransition.contentMode = UIViewContentModeScaleAspectFill;
        [imageViewForTransition removeFromSuperview];
        [self removeFromSuperview];
        //show cell in image picker after transition
        [selectedCellInImagePicker.contentView setAlpha:1.0];
    }];
}

#pragma mark - Configure Select Button
//Check focused item is selected item or not
- (void) selectBtnConfigure:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *) targetContentOffset{
    FTDetailViewCollectionViewCell *detailViewCell = [self getCurrentShowingCell:scrollView withVelocity:velocity targetContentOffset:targetContentOffset];
    if(detailViewCell.selected){
        [self.selectBtn setTitle:@"Deselect" forState:UIControlStateNormal];
    }
    else{
        [self.selectBtn setTitle:@"Select" forState:UIControlStateNormal];
    }
}


#pragma mark - Select button clicked
- (IBAction)selectBtnClicked:(UIButton *)sender {
    //single selection mode
    if(!self.multipleSelectOn){
        NSMutableArray *selectedItem;
        if(!selectedItem){
            selectedItem = [[NSMutableArray alloc] init];
        }
        [selectedItem addObject:[self.allAssets objectAtIndex:[[self.detailCollectionView indexPathsForVisibleItems] firstObject].row]];
        [self.delegate singleSelectionModeSelectionConfirmed:selectedItem];
    }
    //multiple select action
    else{
        NSArray *itemToBeSelectedOrDeselected = [NSArray arrayWithArray:[self.detailCollectionView indexPathsForVisibleItems]];
        NSLog(@"itemToBeSelectedOrDeselected count %d", (int) itemToBeSelectedOrDeselected.count);
        FTDetailViewCollectionViewCell *detailViewCell =(FTDetailViewCollectionViewCell *) [self.detailCollectionView cellForItemAtIndexPath:itemToBeSelectedOrDeselected[0]];
        if([sender.currentTitle isEqualToString:@"Select"]){
            if(self.selectedItemCount < self.multipleSelectMax){
                [self.detailCollectionView selectItemAtIndexPath:itemToBeSelectedOrDeselected[0] animated:YES scrollPosition:UICollectionViewScrollPositionNone];
                [self.ImagePickerCollectionView selectItemAtIndexPath:itemToBeSelectedOrDeselected[0] animated:NO scrollPosition:UICollectionViewScrollPositionNone];
                [self.delegate enforceCellToSelectUpdateLayout:itemToBeSelectedOrDeselected[0]];
                [sender setTitle:@"Deselect" forState:UIControlStateNormal];
                [self selectedCellLayoutChange:detailViewCell];
                //addObject Action occurs in delegate(enforceCellToSelectUpdateLayout)
                //[self.selectedItemsArray addObject:itemToBeSelectedOrDeselected[0]];
                self.selectedItemCount += 1;
                NSLog(@"selected items array count %d", (int)self.selectedItemsArray.count);
                NSLog(@"selected count %d", (int)self.selectedItemCount);
            }
            else{
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Maximum Selection" message:[NSString stringWithFormat:@"You can choose up to %d images.", (int)self.multipleSelectMax] preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *OKAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
                [alertController addAction:OKAction];
                [self.delegate presentAlertController:alertController];
            }
        }
        else{
            [self.detailCollectionView deselectItemAtIndexPath:itemToBeSelectedOrDeselected[0] animated:YES];
            [self.ImagePickerCollectionView deselectItemAtIndexPath: itemToBeSelectedOrDeselected[0] animated:NO];
            [self.delegate enforceCellToDeselectAndUpdateLayout:itemToBeSelectedOrDeselected[0]];
            [sender setTitle:@"Select" forState:UIControlStateNormal];
            [self deselectedCellLayoutChange:detailViewCell];
            //removeObject Action occurs in delegate(enforceCellToDeselectAndUpdateLayout)
//            for(int i = 0; i < self.selectedItemsArray.count; i++){
//                if(self.selectedItemsArray[i] == itemToBeSelectedOrDeselected[0]){
//                    [self.selectedItemsArray removeObjectAtIndex:i];
//                }
//            }
            self.selectedItemCount -= 1;
            NSLog(@"selected count %d", (int)self.selectedItemCount);
        }
    }
}

#pragma mark - Delete Button Clicked
- (IBAction)deleteBtnClicked:(UIButton *)sender {
    NSArray<NSIndexPath *> *itemToBeDeleted = [NSArray arrayWithArray:[self.detailCollectionView indexPathsForVisibleItems]];
    PHAsset *assetWillbeDeleted = self.allAssets[itemToBeDeleted[0].row];
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        [PHAssetChangeRequest deleteAssets:@[assetWillbeDeleted]];
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        if(success){
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.allAssets removeObjectAtIndex:(int) itemToBeDeleted[0].row];
                [self.ImagePickerCollectionView reloadData];
                [self.detailCollectionView reloadData];
            });
        }
        else{
            NSLog(@"Error %@", error.localizedDescription);
        }
    }];
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

#pragma mark - Play Videos
- (void) playVideosButtonClicked:(id)sender{
    NSIndexPath *indexPath = [[self.detailCollectionView indexPathsForVisibleItems] firstObject];
    PHAsset *selectedAsset = self.allAssets[indexPath.row];
    [[PHImageManager defaultManager] requestAVAssetForVideo:selectedAsset options:nil resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
        dispatch_async(dispatch_get_main_queue(), ^{
            //AVPlayer
            self.videoPlayerViewController = [[AVPlayerViewController alloc] init];
            AVPlayerItem *playItem = [AVPlayerItem playerItemWithAsset: asset];
            AVPlayer *videoPlayer = [[AVPlayer alloc] initWithPlayerItem:playItem];
            self.videoPlayerViewController.player = videoPlayer;
            [self.videoPlayerViewController.view setFrame:self.bounds];
            self.videoPlayerViewController.showsPlaybackControls = YES;
//            //Button For Back To Detail View
//            UIButton *backToDetailViewBtn = [[UIButton alloc] initWithFrame:CGRectMake(18, 60, 44, 30)];
//            [backToDetailViewBtn setTitle:@"Back" forState:UIControlStateNormal];
//            [backToDetailViewBtn addTarget:self action:@selector(dismissVideoPlayer:) forControlEvents:UIControlEventTouchUpInside];
//            [self.videoPlayerViewController.view addSubview:backToDetailViewBtn];
//            //Edge Pan Gesture for same job with back button
//            UIScreenEdgePanGestureRecognizer *edgePanGesture = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(dismissVideoPlayer:)];
//            edgePanGesture.edges = UIRectEdgeLeft;
//            edgePanGesture.delegate = self;
//            [self.videoPlayerViewController.view addGestureRecognizer:edgePanGesture];
            [self.delegate presentAVPlayerViewController:self.videoPlayerViewController AVPlayer:videoPlayer];
//            [self addSubview:self.videoPlayerViewController.view];
//            [videoPlayer play];
        });
    }];
}
//
//- (void) dismissVideoPlayer:(id) sender {
//    [self.videoPlayerViewController.view removeFromSuperview];
//}

@end
