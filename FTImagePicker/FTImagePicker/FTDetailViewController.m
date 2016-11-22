//
//  FTDetailViewController.m
//  FTImagePicker
//
//  Created by Park on 2016. 11. 18..
//  Copyright © 2016년 Parkfantagram /inc. All rights reserved.
//

#import "FTDetailViewController.h"

@interface FTDetailViewController ()

@end

@implementation FTDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor clearColor];
    self.dismissAnimation = [[DismissDetailViewControllerAnimation alloc] init];
        
    //set Theme of album list
    [self changeTheme:self.theme];
}

- (void)viewWillAppear:(BOOL)animated{
    //add pangesture for dismissing ViewController
    self.panGesture = [[UIPanGestureRecognizer alloc] init];
    self.panGesture.delegate = self;
    [self.panGesture addTarget:self action:@selector(dismissViewControllerDownPan:)];
    [self.detailCollectionView addGestureRecognizer:self.panGesture];
    [self.detailCollectionView scrollToItemAtIndexPath:self.currentShowingCellsIndexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)prefersStatusBarHidden{
    return YES;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    NSLog(@"touched");
}

#pragma mark - Theme
- (void) changeTheme: (NSInteger) theme{
    //white version
    if(theme == 0){
        self.buttonBarView.backgroundColor = [UIColor colorWithWhite:0.92 alpha:0.7];
        [self.view setTintColor:[UIColor colorWithWhite:0.25 alpha:1.0]];
    }
    //black version
    else if(theme == 1){
        self.buttonBarView.backgroundColor = [UIColor colorWithWhite:0.08 alpha:0.7];
        [self.view setTintColor:[UIColor colorWithWhite:0.65 alpha:1.0]];
    }
}

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
        cell.detailImageView.image = result;
        //configure scroll view
        cell.scrollViewForZoom.maximumZoomScale = 3.0;
        cell.scrollViewForZoom.minimumZoomScale = 1.0;
        cell.scrollViewForZoom.delegate = self;
        cell.scrollViewForZoom.zoomScale = 1.0;
        cell.scrollViewForZoom.contentSize = cell.bounds.size;
        //if asset is Video type
        if(assetForIndexPath.mediaType == PHAssetMediaTypeVideo){
            //add Button to show its video asset
            UIButton *playButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.bounds.size.width/2-20, self.view.bounds.size.height/2 - 15, 40, 30)];
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
    //NSLog(@"scroll view content offset x: %f, y: %f", scrollView.contentOffset.x, scrollView.contentOffset.y);
    //NSLog(@"scoll view targetConetnOffset x: %f, y: %f", targetContentOffset->x, targetContentOffset->y);
    [self selectBtnConfigure:scrollView withVelocity:velocity targetContentOffset:targetContentOffset];
    [self moveImagePickersScrollToCurrentShowingItem:scrollView withVelocity:velocity targetContentOffset:targetContentOffset];
    [self scrollViewZoomReset:scrollView withVelocity:velocity targetContentOffset:targetContentOffset];
    
}

#pragma mark - Scroll View Zoom Reset
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
    CGFloat width = self.detailCollectionView.bounds.size.width - self.detailCollectionView.contentInset.left - self.detailCollectionView.contentInset.right;
    CGFloat height = self.detailCollectionView.bounds.size.height - self.detailCollectionView.contentInset.top - self.detailCollectionView.contentInset.bottom;
    return CGSizeMake(width, height);
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
    NSLog(@"bam");
    CGPoint location = [gestureRecognizer locationInView:self.view];
    if([gestureRecognizer isKindOfClass:[UIScreenEdgePanGestureRecognizer class]]){
        //For preventing dismiss video player when video player control bar slider controlled
        if(location.y > self.view.frame.size.height - 100){
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
- (IBAction)dismissViewControllerDownPan:(UIPanGestureRecognizer *)sender {
    CGPoint translation = [sender translationInView:self.detailCollectionView];
    CGPoint location = [sender locationInView:self.view];
    if(sender.state == UIGestureRecognizerStateBegan){
        //make a imageView For transition and configure
        self.imageViewForTransition = [[UIImageView alloc] initWithFrame:self.view.bounds];
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
        [self.view addSubview:self.imageViewForTransition];
    }
    else if(sender.state == UIGestureRecognizerStateChanged){
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
                [self.detailCollectionView setAlpha:0.0];
            } completion:^(BOOL finished) {
                [self dismissViewControllerAnimated:NO completion:nil];
                [self.imageViewForTransition removeFromSuperview];
                //show cell in image picker after transition
                [selectedCellInImagePicker.contentView setAlpha:1.0];
                //restore image view in detail collection view
                [selectedCell.detailImageView setAlpha:1.0];
            }];
        }
        //cancel dismiss
        else{
            //Animation effect
            [UIView animateWithDuration:0.2 animations:^{
                [self.imageViewForTransition setFrame:self.view.bounds];
            } completion:^(BOOL finished) {
                [self.imageViewForTransition removeFromSuperview];
                //show cell in image picker after transition
                [selectedCellInImagePicker.contentView setAlpha:1.0];
                [self.detailCollectionView setAlpha:1.0];
                //restore image view in detail collection view
                [selectedCell.detailImageView setAlpha:1.0];
            }];
        }
    }
}

- (IBAction)dismissViewControllerBtnClicked:(UIButton *)sender {
    //current cell's indexpath in detail view controller
    NSIndexPath *indexPath = [[self.detailCollectionView indexPathsForVisibleItems] firstObject];
    //make a imageView For transition and configure
    UIImageView *imageViewForTransition = [[UIImageView alloc] init];
    imageViewForTransition.contentMode = UIViewContentModeScaleAspectFit;
    //selected cell for get image from it
    FTDetailViewCollectionViewCell *selectedCell = (FTDetailViewCollectionViewCell *) [self.detailCollectionView cellForItemAtIndexPath:indexPath];
    //assign image to imageview
    imageViewForTransition.image = selectedCell.detailImageView.image;
    //assign imageview to transition
    self.dismissAnimation.imageViewForTransition = imageViewForTransition;
    //Image picker cell for destination point of transition
    FTImagePickerCollectionViewCell *selectedCellInImagePicker = (FTImagePickerCollectionViewCell *) [self.ImagePickerCollectionView cellForItemAtIndexPath:indexPath];
    //convert frame according to super view of imagepicker
    if(!selectedCellInImagePicker){
        selectedCellInImagePicker = [self.ImagePickerCollectionView dequeueReusableCellWithReuseIdentifier:@"imagePickerCells" forIndexPath:indexPath];
    }
    CGRect converted = [self.ImagePickerCollectionView convertRect:selectedCellInImagePicker.frame toView:self.ImagePickerCollectionView.superview];
    //hide image in image destination cell
    UIView *hidingCellView = [[UIView alloc] initWithFrame:converted];
    hidingCellView.backgroundColor = self.detailCollectionView.backgroundColor;
    self.dismissAnimation.hidingCellView = hidingCellView;
    self.dismissAnimation.finalFrame = converted;
    self.dismissAnimation.cellDismissing = selectedCell;
    self.transitioningDelegate = self;
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Transitioning Delegate
- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed{
    return self.dismissAnimation;
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
                [self presentViewController:alertController animated:YES completion:nil];
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
            [self.videoPlayerViewController.view setFrame:self.view.bounds];
            self.videoPlayerViewController.showsPlaybackControls = YES;
            [self presentViewController:self.videoPlayerViewController animated:NO completion:nil];
            [videoPlayer play];
        });
    }];
}

#pragma mark - Preview Action
- (NSArray<id<UIPreviewActionItem>> *)previewActionItems{
    UIPreviewAction *deleteAction = [UIPreviewAction actionWithTitle:@"Delete" style:UIPreviewActionStyleDestructive handler:^(UIPreviewAction * _Nonnull action, UIViewController * _Nonnull previewViewController) {
        NSLog(@"Delete");
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
    }];
    UIPreviewAction *cancelAction = [UIPreviewAction actionWithTitle:@"Cancel" style:UIPreviewActionStyleDefault handler:^(UIPreviewAction * _Nonnull action, UIViewController * _Nonnull previewViewController) {
        NSLog(@"Canceled");
    }];
    
    return @[deleteAction, cancelAction];
}

@end

#pragma mark - Transition Animation
@implementation DismissDetailViewControllerAnimation

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext{
    return 0.2;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext{
    UIView *fromView = [transitionContext viewForKey:UITransitionContextFromViewKey];
    UIView *containerView = [transitionContext containerView];
    UIView *toView = [transitionContext viewForKey:UITransitionContextToViewKey];
    
    self.imageViewForTransition.frame = containerView.frame;
    
    self.cellDismissing.detailImageView.hidden = YES;
    toView.hidden = NO;
    [containerView insertSubview:toView belowSubview:fromView];
    [containerView addSubview:self.hidingCellView];
    [containerView addSubview:self.imageViewForTransition];
    
    NSTimeInterval duration = [self transitionDuration:transitionContext];
    
    [UIView animateWithDuration:duration animations:^{
        [self.imageViewForTransition setFrame:self.finalFrame];
        [fromView setAlpha:0.0];
    } completion:^(BOOL finished) {
        [self.imageViewForTransition removeFromSuperview];
        [self.hidingCellView removeFromSuperview];
        [fromView setAlpha:1.0];
        self.cellDismissing.detailImageView.hidden = NO;
        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
    }];
}

@end
