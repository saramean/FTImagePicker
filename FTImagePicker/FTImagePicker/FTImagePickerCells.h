//
//  FTImagePickerCells.h
//  FTImagePicker
//
//  Created by Park on 2016. 10. 20..
//  Copyright © 2016년 Parkfantagram /inc. All rights reserved.
//

#ifndef FTImagePickerCells_h
#define FTImagePickerCells_h


#endif /* FTImagePickerCells_h */
#import <UIKit/UIKit.h>
@import Photos;

@protocol cellSelectionLayoutChange <NSObject>
@optional
- (void) selectedCellLayoutChange: (__kindof UICollectionViewCell *) selectedCell;
- (void) deselectedCellLayoutChange: (__kindof UICollectionViewCell *) deselectedCell;
@end


@interface FTAlbumListCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UILabel *albumTitle;
@property (weak, nonatomic) IBOutlet UIImageView *imageView1;
@property (weak, nonatomic) IBOutlet UIImageView *imageView2;
@property (weak, nonatomic) IBOutlet UIImageView *imageView3;
@property (strong, nonatomic) PHAssetCollection *albumCollection;
@end

@interface FTImagePickerCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *thumbnailForCells;

@end

@interface FTDetailViewCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *detailImageView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollViewForZoom;

@end
