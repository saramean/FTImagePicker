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


@interface FTImagePickerViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
@property (strong, nonatomic) NSMutableArray *allAssets;
@property (weak, nonatomic) IBOutlet UICollectionView *FTimagePickerCollectionView;
@property (strong, nonatomic) IBOutlet FTDetailView *FTDetailView;
@property (nonatomic) CGFloat scaleCriteria;
@property (nonatomic) NSInteger cellScaleFactor;
@property (nonatomic) BOOL multipleSelectOn;
@property (strong, nonatomic) NSMutableArray *selectedItemsArray;
@property (weak, nonatomic) IBOutlet UIButton *selectBtn;
@property (weak, nonatomic) id<FTImagePickerViewControllerDelegate> delegate;


- (IBAction)backToAlbumLeftEdgePan:(UIScreenEdgePanGestureRecognizer *)sender;
- (IBAction)backToAlbumBtnClicked:(UIButton *)sender;
- (IBAction)showDetailCellLongPressed:(UILongPressGestureRecognizer *)sender;
- (IBAction)cellZoomInOutPinch:(UIPinchGestureRecognizer *)sender;
- (IBAction)cancelImagePickerBtnClicked:(UIButton *)sender;


@end
