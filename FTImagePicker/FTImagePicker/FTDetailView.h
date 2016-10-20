//
//  FTDetailView.h
//  FTImagePicker
//
//  Created by Park on 2016. 10. 20..
//  Copyright © 2016년 Parkfantagram /inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FTImagePickerCells.h"

@interface FTDetailView : UIView <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate, UIGestureRecognizerDelegate>
@property (strong, nonatomic) NSMutableArray *allAssets;
@property (weak, nonatomic) IBOutlet UICollectionView *detailCollectionView;
- (IBAction)dismissViewDownPan:(UIPanGestureRecognizer *)sender;
- (IBAction)dismissViewBtnClicked:(UIButton *)sender;

@end
