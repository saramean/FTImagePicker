//
//  FTImagePickerViewController.h
//  FTImagePicker
//
//  Created by Park on 2016. 10. 20..
//  Copyright © 2016년 Parkfantagram /inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FTDetailView.h"
#import "FTImagePickerCells.h"

@protocol FTImagePickerViewControllerDelegate <NSObject>

- (void) getSelectedImageAssetsFromImagePicker: (NSMutableArray *) selectedAssetsArray;

@end


@interface FTImagePickerViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, FTDetailViewDelegate, cellSelectionLayoutChange>
@property (strong, nonatomic) NSMutableArray *allAssets;
@property (weak, nonatomic) IBOutlet UICollectionView *FTimagePickerCollectionView;
@property (strong, nonatomic) IBOutlet FTDetailView *FTDetailView;
@property (nonatomic) CGFloat scaleCriteria;
@property (nonatomic) NSInteger cellScaleFactor;
@property (nonatomic) BOOL multipleSelectOn;
@property (nonatomic) NSInteger multipleSelectMin;
@property (nonatomic) NSInteger multipleSelectMax;
@property (nonatomic) NSInteger selectedItemCount;
@property (nonatomic) NSInteger mediaTypeToUse;
@property (nonatomic) NSString *cameraRollLocalTitle;
@property (strong, nonatomic) NSMutableArray *selectedItemsArray;
@property (strong, nonatomic) NSMutableDictionary *selectedItemsDictionary;
@property (weak, nonatomic) IBOutlet UIButton *selectBtn;
@property (weak, nonatomic) id<FTImagePickerViewControllerDelegate> delegate;
@property (strong, nonatomic) NSString *albumName;
@property (assign, nonatomic) NSInteger theme;
@property (weak, nonatomic) IBOutlet UIView *buttonBarView;


- (IBAction)backToAlbumLeftEdgePan:(UIScreenEdgePanGestureRecognizer *)sender;
- (IBAction)backToAlbumBtnClicked:(UIButton *)sender;
- (IBAction)showDetailCellLongPressed:(UILongPressGestureRecognizer *)sender;
- (IBAction)cellZoomInOutPinch:(UIPinchGestureRecognizer *)sender;
- (IBAction)cancelImagePickerBtnClicked:(UIButton *)sender;
- (IBAction)multiSelectConfirmedSelectBtnClicked:(id)sender;


@end
