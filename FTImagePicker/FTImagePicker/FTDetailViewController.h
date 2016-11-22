//
//  FTDetailViewController.h
//  FTImagePicker
//
//  Created by Park on 2016. 11. 18..
//  Copyright © 2016년 Parkfantagram /inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FTImagePickerCells.h"
@import AVKit;
@class DismissDetailViewControllerAnimation;
@class DismissDetailViewControllerAnimationWithInteraction;

@protocol FTDetailViewControllerDelegate <NSObject>

- (void) singleSelectionModeSelectionConfirmed: (NSMutableArray *) selectedAssetArray;
- (void) enforceCellToSelectUpdateLayout: (NSIndexPath *) indexPathForUpdatingCell;
- (void) enforceCellToDeselectAndUpdateLayout: (NSIndexPath *) indexPathForUpdatingCell;

@end

@interface FTDetailViewController : UIViewController <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate, UIGestureRecognizerDelegate, cellSelectionLayoutChange, UIViewControllerTransitioningDelegate>
@property (strong, nonatomic) NSMutableArray *allAssets;
@property (nonatomic) BOOL multipleSelectOn;
@property (nonatomic) NSInteger multipleSelectMin;
@property (nonatomic) NSInteger multipleSelectMax;
@property (strong, nonatomic) NSMutableArray *selectedItemsArray;
@property (nonatomic) NSInteger selectedItemCount;
@property (strong, nonatomic) UICollectionView *ImagePickerCollectionView;
@property (strong, nonatomic) UICollectionView *detailCollectionView;
@property (weak, nonatomic) IBOutlet UIButton *selectBtn;
@property (weak, nonatomic) IBOutlet UIButton *deleteBtn;
@property (strong, nonatomic) UIImageView *imageViewForTransition;
@property (strong, nonatomic) AVPlayerViewController *videoPlayerViewController;
@property (weak, nonatomic) id<FTDetailViewControllerDelegate> delegate;
@property (strong, nonatomic) NSIndexPath *currentShowingCellsIndexPath;
@property (weak, nonatomic) IBOutlet UIView *buttonBarView;
@property (assign, nonatomic) NSInteger theme;
@property (strong, nonatomic) DismissDetailViewControllerAnimation *dismissAnimation;
@property (strong, nonatomic) UIPanGestureRecognizer *panGesture;

- (IBAction)dismissViewControllerDownPan:(UIPanGestureRecognizer *)sender;
- (IBAction)dismissViewControllerBtnClicked:(UIButton *)sender;
- (IBAction)selectBtnClicked:(UIButton *)sender;
- (IBAction)deleteBtnClicked:(id)sender;
@end

@interface DismissDetailViewControllerAnimation : NSObject <UIViewControllerAnimatedTransitioning>
@property (strong, nonatomic) UIImageView *imageViewForTransition;
@property (strong, nonatomic) UIView *hidingCellView;
@property (assign, nonatomic) CGRect finalFrame;
@property (strong, nonatomic) FTDetailViewCollectionViewCell *cellDismissing;
@end
