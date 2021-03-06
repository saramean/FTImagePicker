//
//  FTImagePickerViewController.h
//  FTImagePicker
//
//  Created by Park on 2016. 10. 20..
//  Copyright © 2016년 Parkfantagram /inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FTDetailViewController.h"
#import "FTImagePickerCells.h"
@class ShowDetailViewControllerAnimation;

typedef NS_ENUM(NSUInteger, MultiSelectionDistanceTransition) {
    MultiSelectionDistanceTransitionNone,
    MultiSelectionDistanceTransitionIncreasing,
    MultiSelectionDistanceTransitionDecreasing,
};

@interface PHAsset (TKFetchAssetsInCollection)
+(PHFetchResult *) fetchAssetInAssetCollection:(PHAssetCollection *) collection withSortDescriptorKey:(NSString *)sortDescriptorKey withMediaType:(PHAssetMediaType) mediaType withMediaSubtypes:(NSArray<NSNumber *> *) mediaSubtypes;
@end

@protocol FTImagePickerViewControllerDelegate <NSObject>

- (void) getSelectedImageAssetsFromImagePicker: (NSMutableArray *) selectedAssetsArray;
- (void) imagePickerCanceledWithOutSelection;

@end


@interface FTImagePickerViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, FTDetailViewControllerDelegate, cellSelectionLayoutChange, UIViewControllerTransitioningDelegate,UIViewControllerPreviewingDelegate, UIGestureRecognizerDelegate>
@property (strong, nonatomic) NSMutableArray *allAssets;
@property (weak, nonatomic) IBOutlet UICollectionView *FTimagePickerCollectionView;
@property (strong, nonatomic) FTDetailViewController *FTDetailViewController;
@property (nonatomic) CGFloat scaleCriteria;
@property (nonatomic) NSInteger cellScaleFactor;
@property (nonatomic) BOOL multipleSelectOn;
@property (nonatomic) NSInteger multipleSelectMin;
@property (nonatomic) NSInteger multipleSelectMax;
@property (nonatomic) NSInteger selectedItemCount;
@property (nonatomic) NSInteger mediaTypeToUse;
@property (strong, nonatomic) NSArray *mediaSubTypeToUse;
@property (nonatomic) NSString *cameraRollLocalTitle;
@property (strong, nonatomic) NSMutableArray *selectedItemsArray;
@property (weak, nonatomic) IBOutlet UIButton *selectBtn;
@property (weak, nonatomic) id<FTImagePickerViewControllerDelegate> delegate;
@property (strong, nonatomic) NSString *albumName;
@property (assign, nonatomic) NSInteger theme;
@property (weak, nonatomic) IBOutlet UIView *buttonBarView;
@property (weak, nonatomic) IBOutlet UIButton *deleteBtn;
@property (weak, nonatomic) IBOutlet UIButton *albumBtn;
@property (assign, nonatomic) BOOL syncedAlbum;
@property (strong, nonatomic) ShowDetailViewControllerAnimation *showDetailViewAnimation;
@property (strong, nonatomic) IBOutlet UILongPressGestureRecognizer *longPressGesture;
@property (strong, nonatomic) NSIndexPath *indexPathForSelectedCell;
@property (assign, nonatomic) BOOL cellPinchZoomOn;
@property (assign, nonatomic) NSInteger numberOfCellsInLine;
@property (assign, nonatomic) CGFloat imagePickerHeaderHeight;
//Multi Selection by pan gesture
@property (strong, nonatomic) IBOutlet UIPanGestureRecognizer *panGestureForMultiSelection;
@property (assign, nonatomic) CGPoint startPoint;
@property (assign, nonatomic) CGPoint endPoint;
@property (assign, nonatomic) BOOL selectionMode;

- (IBAction)backToAlbumLeftEdgePan:(UIScreenEdgePanGestureRecognizer *)sender;
- (IBAction)backToAlbumBtnClicked:(UIButton *)sender;
- (IBAction)showDetailCellLongPressed:(UILongPressGestureRecognizer *)sender;
- (IBAction)cellZoomInOutPinch:(UIPinchGestureRecognizer *)sender;
- (IBAction)cancelImagePickerBtnClicked:(UIButton *)sender;
- (IBAction)multiSelectConfirmedSelectBtnClicked:(id)sender;
- (IBAction)deleteAssetsBtnClicked:(id)sender;
- (IBAction)multiSelectionByPanGesture:(UIPanGestureRecognizer *)sender;
@end

@interface ShowDetailViewControllerAnimation : NSObject<UIViewControllerAnimatedTransitioning>
@property (strong, nonatomic) UIImageView *imageViewForTransition;
@property (strong, nonatomic) UIView *hidingCellView;
@end
