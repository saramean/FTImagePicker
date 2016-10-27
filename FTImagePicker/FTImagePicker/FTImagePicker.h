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
#import "FTDetailView.h"

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
/* Determines theme of image picker. Default value is White Version (0) */
//          WhiteVersion = 0;
//          BlackVersion = 1;
@property (assign, nonatomic) ImagePickerTheme theme;

@end


@interface FTImagePickerManager : NSObject

+ (void) presentFTImagePicker: (UIViewController *) viewController withOptions: (FTImagePickerOptions *) FTImagePickerOptions;
+ (void) managePhotoLibrarySetting: (UIViewController *) viewController withOptions: (FTImagePickerOptions *) FTImagePickerOptions;


@end



