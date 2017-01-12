//
//  FTImagePicker.h
//  FTImagePicker
//
//  Created by Park on 2016. 10. 20..
//  Copyright © 2016년 Parkfantagram /inc. All rights reserved.
//

#ifndef FTImagePicker_h
#define FTImagePicker_h


#endif /* FTImagePicker_h */
#import "FTAlbumListViewController.h"
#import "FTImagePickerViewController.h"
#import "FTDetailViewController.h"

typedef NS_ENUM(NSInteger, FTFirstShowingController) {
    FTAlbumList = 1,
    FTImagePicker = 2,
};

typedef NS_ENUM(NSInteger, MediaTypeToUse) {
    ImagesOnly = 1,
    VideosOnly = 2,
    ImagesAndVideos = 3,
};

typedef NS_ENUM(NSInteger, ImagePickerTheme) {
    WhiteVersion = 0,
    BlackVersion = 1
};

@interface FTImagePickerOptions : NSObject
/* Determines first showing controller. if the value is FTAlbumList(1), FTimagePicker present AlbumList first, if the value is FTImagePicker(2), it will present Image picker first.
 Default value is FTImagePicker. */
@property (assign, nonatomic) FTFirstShowingController firstShowingController;
/* Determines multiple selection mode. Default value is NO */
@property (assign, nonatomic) BOOL multipleSelectOn;
/* Determines maximum count selection. Default value is 1 */
@property (assign, nonatomic) NSInteger multipleSelectMax;
/* Determines minimum count selection preventing error. Default value is 1 */
@property (assign, nonatomic) NSInteger multipleSelectMin;

//Setting which albums will be used in the app
//        // PHAssetCollectionTypeAlbum regular subtypes
//        PHAssetCollectionSubtypeAlbumRegular         = 2,
//        PHAssetCollectionSubtypeAlbumSyncedEvent     = 3,
//        PHAssetCollectionSubtypeAlbumSyncedFaces     = 4,
//        PHAssetCollectionSubtypeAlbumSyncedAlbum     = 5,
//        PHAssetCollectionSubtypeAlbumImported        = 6,
//
//        // PHAssetCollectionTypeAlbum shared subtypes
//        PHAssetCollectionSubtypeAlbumMyPhotoStream   = 100,
//        PHAssetCollectionSubtypeAlbumCloudShared     = 101,  ICloud Shared
//
//        // PHAssetCollectionTypeSmartAlbum subtypes
//        PHAssetCollectionSubtypeSmartAlbumGeneric    = 200,
//        PHAssetCollectionSubtypeSmartAlbumPanoramas  = 201,     Panoramas
//        PHAssetCollectionSubtypeSmartAlbumVideos     = 202,     Videos
//        PHAssetCollectionSubtypeSmartAlbumFavorites  = 203,     Favorites
//        PHAssetCollectionSubtypeSmartAlbumTimelapses = 204,     Time-lapse
//        PHAssetCollectionSubtypeSmartAlbumAllHidden  = 205,
//        PHAssetCollectionSubtypeSmartAlbumRecentlyAdded = 206,  RecentlyAdded
//        PHAssetCollectionSubtypeSmartAlbumBursts     = 207,     연사
//        PHAssetCollectionSubtypeSmartAlbumSlomoVideos = 208,    Slo-mo
//        PHAssetCollectionSubtypeSmartAlbumUserLibrary = 209,    Camer Roll
//        PHAssetCollectionSubtypeSmartAlbumSelfPortraits PHOTOS_AVAILABLE_IOS_TVOS(9_0, 10_0) = 210,  Selfie
//        PHAssetCollectionSubtypeSmartAlbumScreenshots PHOTOS_AVAILABLE_IOS_TVOS(9_0, 10_0) = 211,    Screenshots

/* Determines usage of Camera roll in the Albumlist. Default value is YES */
// need to be implemented.
@property (assign, nonatomic) BOOL useCameraRoll;
/* Determines regular albums to use in Image picker. Default value is all of the albums
 For example, @[@2, @3, @4, @5, @6, @100, @101]; */
@property (strong, nonatomic) NSArray *regularAlbums;
/* Determines smart albums to use in Image picker. Default value is all of the albums
 For example, @[@200, @201, @202, @203, @204, @205, @206, @207, @208, @210, @211]; */
@property (strong, nonatomic) NSArray *smartAlbums;
/* Determines media types to use in the image picker. Default value is ImagesOnly */
//            ImagesOnly = 1,
//            VideosOnly = 2,
//            ImagesAndVideos = 3,
@property (assign, nonatomic) NSInteger mediaTypeToUse;
/* Setting media Subtype to use
        PHAssetMediaSubtypeNone               = 0,
 
        // Photo subtypes
        PHAssetMediaSubtypePhotoPanorama      = (1UL << 0),
        PHAssetMediaSubtypePhotoHDR           = (1UL << 1),
        PHAssetMediaSubtypePhotoScreenshot PHOTOS_AVAILABLE_IOS_TVOS(9_0, 10_0) = (1UL << 2),
        PHAssetMediaSubtypePhotoLive PHOTOS_AVAILABLE_IOS_TVOS(9_1, 10_0) = (1UL << 3),
        PHAssetMediaSubtypePhotoDepthEffect PHOTOS_AVAILABLE_IOS_TVOS(10_2, 10_1) = (1UL << 4),
 
        // Video subtypes
        PHAssetMediaSubtypeVideoStreamed      = (1UL << 16),
        PHAssetMediaSubtypeVideoHighFrameRate = (1UL << 17),
        PHAssetMediaSubtypeVideoTimelapse     = (1UL << 18), */
/* Determines media subTypeToUse. Default is All of the subtypes */
@property (strong, nonatomic) NSArray *mediaSubTypeToUse;
/* Determines theme of image picker. Default value is White Version (0) */
//          WhiteVersion = 0;
//          BlackVersion = 1;
@property (assign, nonatomic) ImagePickerTheme theme;
/* Determines usage of cell pinch zoom. Default value is NO */
@property (assign, nonatomic) BOOL cellPinchZoomOn;
/* Determines number of cells in Line of ImagePicker. Default value is 3 */
/* Minimum is 2 and Maximum is 6. if value is lower than 2, it becomes 2 and if value is over than 6, it becomes 6. */
@property (assign, nonatomic) NSInteger numberOfCellsInLine;
/* Determines HeaderSize of ImagePicker. Default value is 0 */
@property (assign, nonatomic) CGFloat imagePickerHeaderHeight;
@end


@interface FTImagePickerManager : NSObject

+ (void) presentFTImagePicker: (UIViewController *) viewController withOptions: (FTImagePickerOptions *) FTImagePickerOptions;
+ (void) managePhotoLibrarySetting: (UIViewController *) viewController withOptions: (FTImagePickerOptions *) FTImagePickerOptions;


@end



