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
@property (strong, nonatomic) NSMutableArray *albumsArray;
@property (weak, nonatomic) IBOutlet UICollectionView *albumlistCollectionView;

@end
