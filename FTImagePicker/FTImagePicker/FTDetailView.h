//
//  FTDetailView.h
//  FTImagePicker
//
//  Created by Park on 2016. 10. 20..
//  Copyright © 2016년 Parkfantagram /inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FTImagePickerCells.h"

@protocol FTDetailViewDelegate <NSObject>

- (void) singleSelectionModeSelectionConfirmed: (NSMutableArray *) selectedAssetArray;

@end


@interface FTDetailView : UIView <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate, UIGestureRecognizerDelegate>
@property (strong, nonatomic) NSMutableArray *allAssets;
@property (nonatomic) BOOL multipleSelectOn;
@property (strong, nonatomic) UICollectionView *ImagePickerCollectionView;
@property (weak, nonatomic) IBOutlet UICollectionView *detailCollectionView;
@property (weak, nonatomic) IBOutlet UIButton *selectBtn;
@property (strong, nonatomic) UIImageView *imageViewForTransition;
@property (weak, nonatomic) id<FTDetailViewDelegate> delegate;

- (IBAction)dismissViewDownPan:(UIPanGestureRecognizer *)sender;
- (IBAction)dismissViewBtnClicked:(UIButton *)sender;
- (IBAction)selectBtnClicked:(UIButton *)sender;

@end
