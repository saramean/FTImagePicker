//
//  FTDetailView.m
//  FTImagePicker
//
//  Created by Park on 2016. 10. 20..
//  Copyright © 2016년 Parkfantagram /inc. All rights reserved.
//

#import "FTDetailView.h"

@implementation FTDetailView

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
    return cell;
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

- (CGSize) collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return self.bounds.size;
}

- (NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.allAssets.count;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

//gesture recognizer delegate
//if movement toward y direction is larger than direction toward x, gesture recognizer begins
//else, collection view's normal pan handle its scroll
- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)gestureRecognizer{
    CGPoint translation = [gestureRecognizer translationInView:self.detailCollectionView];
    NSLog(@"%f, %f", translation.x, translation.y);
    if(translation.x*translation.x < translation.y*translation.y){
        NSLog(@"recognizer begin");
        return YES;
    }
    else{
        NSLog((@"recognizer doesn't begin"));
        return NO;
    }
}


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
@end
