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
        cell.layer.borderWidth = 2.0;
        cell.layer.borderColor = [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:0.8].CGColor;
        cell.alpha = 0.5;
    }
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath{
    //single selection mode
    if(!self.multipleSelectOn){
        
    }
    //multiple selection mode
    else{
        FTDetailViewCollectionViewCell *cell = (FTDetailViewCollectionViewCell *) [collectionView cellForItemAtIndexPath:indexPath];
        cell.layer.borderWidth = 0;
        cell.layer.borderColor = nil;
        cell.alpha = 1.0;
    }
}

#pragma mark - Configuring Cells
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    FTDetailViewCollectionViewCell *cell = [self.detailCollectionView dequeueReusableCellWithReuseIdentifier:@"detailViewCells" forIndexPath:indexPath];
    
    [[PHImageManager defaultManager] requestImageForAsset:self.allAssets[indexPath.row] targetSize:cell.bounds.size contentMode:PHImageContentModeAspectFit options:nil resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        //set image
        [cell.detailImageView setFrame:self.frame];
        cell.detailImageView.image = result;
        //configure scroll view
        cell.scrollViewForZoom.maximumZoomScale = 3.0;
        cell.scrollViewForZoom.minimumZoomScale = 1.0;
        cell.scrollViewForZoom.delegate = self;
        cell.scrollViewForZoom.zoomScale = 1.0;
    }];
    if(cell.selected){
        cell.layer.borderWidth = 2.0;
        cell.layer.borderColor = [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:0.8].CGColor;
        cell.alpha = 0.5;
    }
    else{
        cell.layer.borderWidth = 0;
        cell.layer.borderColor = nil;
        cell.alpha = 1.0;
    }
    return cell;
}
#pragma mark - Scroll View Delegate
//scroll view delegate
- (UIView *) viewForZoomingInScrollView:(UIScrollView *)scrollView{
    for (UIView *view in scrollView.subviews){
        if([view isKindOfClass:[UIImageView class]]){
            return view;
        }
    }
    return nil;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    NSArray *visibleItem = [NSArray arrayWithArray:[self.detailCollectionView indexPathsForVisibleItems]];
    FTDetailViewCollectionViewCell *detailViewCell =(FTDetailViewCollectionViewCell *) [self.detailCollectionView cellForItemAtIndexPath:[visibleItem lastObject]];
    NSLog(@"%d", detailViewCell.selected);
    if(detailViewCell.selected){
        [self.selectBtn setTitle:@"Deselect" forState:UIControlStateNormal];
    }
    else{
        [self.selectBtn setTitle:@"Select" forState:UIControlStateNormal];
    }
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
- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)gestureRecognizer{
    CGPoint translation = [gestureRecognizer translationInView:self.detailCollectionView];
    if(translation.x*translation.x < translation.y*translation.y){
        return YES;
    }
    else{
        return NO;
    }
}

#pragma mark - Dismiss View
- (IBAction)dismissViewDownPan:(UIPanGestureRecognizer *)sender {
    CGPoint translation = [sender translationInView:self.detailCollectionView];
    if(sender.state == UIGestureRecognizerStateBegan){
        
    }
    else if(sender.state == UIGestureRecognizerStateChanged){
        
    }
    else if(sender.state == UIGestureRecognizerStateEnded){
        if(translation.y > 50 && translation.x < 50){
            [self removeFromSuperview];
        }
    }
    else{
        
    }
}

- (IBAction)dismissViewBtnClicked:(UIButton *)sender {
    [self removeFromSuperview];
}

- (IBAction)selectBtnClicked:(UIButton *)sender {
    if(self.multipleSelectOn){
        NSArray *itemToBeSelectedOrDeselected = [NSArray arrayWithArray:[self.detailCollectionView indexPathsForVisibleItems]];
        FTDetailViewCollectionViewCell *detailViewCell =(FTDetailViewCollectionViewCell *) [self.detailCollectionView cellForItemAtIndexPath:itemToBeSelectedOrDeselected[0]];
        if([sender.currentTitle isEqualToString:@"Select"]){
            [self.detailCollectionView selectItemAtIndexPath:itemToBeSelectedOrDeselected[0] animated:YES scrollPosition:UICollectionViewScrollPositionNone];
            [self.ImagePickerCollectionView selectItemAtIndexPath:itemToBeSelectedOrDeselected[0] animated:NO scrollPosition:UICollectionViewScrollPositionNone];
            [sender setTitle:@"Deselect" forState:UIControlStateNormal];
            detailViewCell.layer.borderWidth = 2.0;
            detailViewCell.layer.borderColor = [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:0.8].CGColor;
            detailViewCell.alpha = 0.5;
        }
        else{
            [self.detailCollectionView deselectItemAtIndexPath:itemToBeSelectedOrDeselected[0] animated:YES];
            [self.ImagePickerCollectionView deselectItemAtIndexPath: itemToBeSelectedOrDeselected[0] animated:NO];
            [sender setTitle:@"Select" forState:UIControlStateNormal];
            detailViewCell.layer.borderWidth = 0;
            detailViewCell.layer.borderColor = nil;
            detailViewCell.alpha = 1.0;
        }
    }
}
@end
