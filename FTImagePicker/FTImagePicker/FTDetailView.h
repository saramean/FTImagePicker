//
//  FTDetailView.h
//  FTImagePicker
//
//  Created by Park on 2016. 10. 20..
//  Copyright © 2016년 Parkfantagram /inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FTImagePickerCells.h"
//@import AVFoundation;
@import AVKit;

@protocol FTDetailViewDelegate <NSObject>

- (void) singleSelectionModeSelectionConfirmed: (NSMutableArray *) selectedAssetArray;
- (void) presentAlertController: (UIAlertController *) alertController;
- (void) presentAVPlayerViewController: (AVPlayerViewController *) AVPlayerViewController AVPlayer:(AVPlayer *) AVPlayer;
- (void) enforceCellToSelectUpdateLayout: (NSIndexPath *) indexPathForUpdatingCell;
- (void) enforceCellToDeselectAndUpdateLayout: (NSIndexPath *) indexPathForUpdatingCell;

@end


@interface FTDetailView : UIView <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate, UIGestureRecognizerDelegate, cellSelectionLayoutChange>
@property (strong, nonatomic) NSMutableArray *allAssets;
@property (nonatomic) BOOL multipleSelectOn;
@property (nonatomic) NSInteger multipleSelectMin;
@property (nonatomic) NSInteger multipleSelectMax;
@property (strong, nonatomic) NSMutableArray *selectedItemsArray;
@property (nonatomic) NSInteger selectedItemCount;
@property (strong, nonatomic) UICollectionView *ImagePickerCollectionView;
@property (weak, nonatomic) IBOutlet UICollectionView *detailCollectionView;
@property (weak, nonatomic) IBOutlet UIButton *selectBtn;
@property (strong, nonatomic) UIImageView *imageViewForTransition;
@property (strong, nonatomic) AVPlayerViewController *videoPlayerViewController;
@property (weak, nonatomic) id<FTDetailViewDelegate> delegate;
@property (strong, nonatomic) NSIndexPath *currentShowingCellsIndexPath;
@property (weak, nonatomic) IBOutlet UIView *buttonBarView;

- (IBAction)dismissViewDownPan:(UIPanGestureRecognizer *)sender;
- (IBAction)dismissViewBtnClicked:(UIButton *)sender;
- (IBAction)selectBtnClicked:(UIButton *)sender;

@end
