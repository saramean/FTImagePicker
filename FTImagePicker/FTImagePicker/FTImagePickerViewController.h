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

@interface FTImagePickerViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
@property (strong, nonatomic) NSMutableArray *allAssets;
@property (weak, nonatomic) IBOutlet UICollectionView *FTimagePickerCollectionView;
@property (strong, nonatomic) IBOutlet FTDetailView *FTDetailView;


- (IBAction)backToAlbumLeftEdgePan:(UIScreenEdgePanGestureRecognizer *)sender;
- (IBAction)backToAlbumBtnClicked:(UIButton *)sender;
- (IBAction)showDetailCellLongPressed:(UILongPressGestureRecognizer *)sender;

@end
