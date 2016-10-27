//
//  FTAlbumLIstViewController.h
//  FTImagePicker
//
//  Created by Park on 2016. 10. 20..
//  Copyright © 2016년 Parkfantagram /inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FTImagePickerCells.h"
#import "FTImagePickerViewController.h"

@interface FTAlbumLIstViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>
//multiple selection on boolean value for enabling multiple touch in the image picker
@property (assign, nonatomic) BOOL useCameraRoll;
@property (nonatomic) BOOL multipleSelectOn;
@property (nonatomic) NSInteger multipleSelectMin;
@property (nonatomic) NSInteger multipleSelectMax;
@property (nonatomic) NSInteger selectedItemCount;
@property (strong, nonatomic) NSMutableDictionary *selectedItemsDictionary;
@property (nonatomic) NSInteger mediaTypeToUse;
@property (strong, nonatomic) NSArray *regularAlbums;
@property (strong, nonatomic) NSArray *smartAlbums;
@property (strong, nonatomic) NSMutableArray *albumsArray;
@property (strong, nonatomic) __kindof UIViewController *callerController;
@property (weak, nonatomic) IBOutlet UICollectionView *albumlistCollectionView;
@property (assign, nonatomic) NSInteger theme;
@property (strong, nonatomic) UIColor *albumTitleColor;
@property (assign, nonatomic) CGColorRef albumCellBorderColor;

@end
