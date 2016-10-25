//
//  FTImagePicker.m
//  FTImagePicker
//
//  Created by Park on 2016. 10. 20..
//  Copyright © 2016년 Parkfantagram /inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FTImagePicker.h"

@interface FTImagePickerManager ()

@end

@implementation FTImagePickerManager

+ (void)presentFTImagePicker:(UIViewController *)viewController firstShowingController:(FTFirstShowingController)firstShowingController{
    if([PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusAuthorized) {
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"FTImagePickerStoryBoard" bundle:nil];
        FTAlbumLIstViewController *albumListViewController = [storyBoard instantiateViewControllerWithIdentifier:@"FTAlbumLIstViewController"];
        FTImagePickerViewController *FTImagePickerViewController = [storyBoard instantiateViewControllerWithIdentifier:@"FTImagePickerViewController"];
        UINavigationController *navigationController = [storyBoard instantiateViewControllerWithIdentifier:@"FTImagePickerNavigationController"];
        [FTImagePickerViewController setDelegate:(id)viewController];
        albumListViewController.callerController = viewController;
        PHFetchResult *fetchingAlbumTitle = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:nil];
        [fetchingAlbumTitle enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            PHAssetCollection *collection = obj;
            FTImagePickerViewController.albumName =collection.localizedTitle;
        }];
        
        //Another setting for AlbumList and ImagePicker here!!
        //setting For mutiple selection of image picker
#pragma mark - Multiple Selection Option
        FTImagePickerViewController.multipleSelectOn = YES;
        FTImagePickerViewController.multipleSelectMin = 9;
        FTImagePickerViewController.multipleSelectMax = 9;
        FTImagePickerViewController.selectedItemCount = 0;
        albumListViewController.multipleSelectOn = FTImagePickerViewController.multipleSelectOn;
        albumListViewController.multipleSelectMax = FTImagePickerViewController.multipleSelectMax;
        
#pragma mark - Album Selection Option
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
//        PHAssetCollectionSubtypeSmartAlbumBursts     = 207,
//        PHAssetCollectionSubtypeSmartAlbumSlomoVideos = 208,    Slo-mo
//        PHAssetCollectionSubtypeSmartAlbumUserLibrary = 209,    Camer Roll
//        PHAssetCollectionSubtypeSmartAlbumSelfPortraits PHOTOS_AVAILABLE_IOS_TVOS(9_0, 10_0) = 210,  Selfie
//        PHAssetCollectionSubtypeSmartAlbumScreenshots PHOTOS_AVAILABLE_IOS_TVOS(9_0, 10_0) = 211,    Screenshots
        
        //Camera Roll is added as a default album
        //Add or Delete albums you want
        albumListViewController.regularAlbums = @[@2, @3, @4, @5, @6, @100];
        albumListViewController.smartAlbums = @[@200, @201, @202, @203, @204, @205, @206, @207, @208, @210, @211];
#pragma mark - Media Type Option
//            ImagesOnly = 1,
//            VideosOnly = 2,
//            ImagesAndVideos = 3,
        albumListViewController.mediaTypeToUse = 3;
        FTImagePickerViewController.mediaTypeToUse = albumListViewController.mediaTypeToUse;
        
        
        //make a stack for showing appropriate ViewController for purpose of the app.
        //show album list first
        if(firstShowingController == FTAlbumList){
            [navigationController setViewControllers:@[albumListViewController] animated:NO];
        }
        //show image picker first
        else{
        [navigationController setViewControllers:@[albumListViewController, FTImagePickerViewController] animated:NO];
        }
        [viewController presentViewController:navigationController animated:YES completion:nil];
    }
    else{
        [self managePhotoLibrarySetting:viewController firstShowingController:firstShowingController];
    }
}

+ (void)managePhotoLibrarySetting:(UIViewController *)viewController firstShowingController:(FTFirstShowingController)firstShowingController{
    
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    
    //self function cannot be used in the block??
    //so make a viewController for using in the block
    
    if(status == PHAuthorizationStatusNotDetermined){
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            if(status == PHAuthorizationStatusAuthorized){
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self presentFTImagePicker:viewController firstShowingController:firstShowingController];
                });
            }
            else{
                NSString *title = @"Cannot access PhotoLibrary";
                NSString *message = @"If you want to use this feature. plz authorize photo library permission";
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *allowAction = [UIAlertAction actionWithTitle:@"Allow" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [alertController dismissViewControllerAnimated:YES completion:nil];
                    NSURL *settingUrl = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                    [[UIApplication sharedApplication] openURL:settingUrl];
                }];
                UIAlertAction *dontAllowAction = [UIAlertAction actionWithTitle:@"Don't Allow" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [alertController dismissViewControllerAnimated:YES completion:nil];
                }];
                [alertController addAction:dontAllowAction];
                [alertController addAction:allowAction];
                [viewController presentViewController:alertController animated:YES completion:nil];

            }
        }];
    }
    else if (status == PHAuthorizationStatusDenied){
        NSString *title = @"Cannot access PhotoLibrary";
        NSString *message = @"If you want to use this feature. plz authorize photo library permission";
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *allowAction = [UIAlertAction actionWithTitle:@"Allow" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [alertController dismissViewControllerAnimated:YES completion:nil];
            NSURL *settingUrl = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
            [[UIApplication sharedApplication] openURL:settingUrl];
        }];
        UIAlertAction *dontAllowAction = [UIAlertAction actionWithTitle:@"Don't Allow" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [alertController dismissViewControllerAnimated:YES completion:nil];
        }];
        [alertController addAction:dontAllowAction];
        [alertController addAction:allowAction];
        [viewController presentViewController:alertController animated:YES completion:nil];
    }

}

@end
