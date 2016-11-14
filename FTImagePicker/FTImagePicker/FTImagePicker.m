//
//  FTImagePicker.m
//  FTImagePicker
//
//  Created by Park on 2016. 10. 20..
//  Copyright © 2016년 Parkfantagram /inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FTImagePicker.h"

@interface FTImagePickerOptions ()
@end
@implementation FTImagePickerOptions

- (id) init{
    self = [super init];
    if(self != nil){
        self.firstShowingController = FTImagePicker;
        self.multipleSelectOn = NO;
        self.multipleSelectMax = 1;
        self.multipleSelectMin = 1;
        self.useCameraRoll = YES;
        self.regularAlbums = @[@2, @3, @4, @5, @6, @100, @101];
        self.smartAlbums = @[@200, @201, @202, @203, @204, @205, @206, @207, @208, @210, @211];
        self.mediaTypeToUse = ImagesOnly;
        self.theme = WhiteVersion;
    }
    return self;
}

@end

@interface FTImagePickerManager ()

@end

@implementation FTImagePickerManager

#pragma mark - present Image Picker
+ (void)presentFTImagePicker:(UIViewController *)viewController withOptions:(FTImagePickerOptions *)FTImagePickerOptions{
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
        
        //setting For mutiple selection of image picker
        FTImagePickerViewController.multipleSelectOn = FTImagePickerOptions.multipleSelectOn;
        FTImagePickerViewController.multipleSelectMin = FTImagePickerOptions.multipleSelectMin;
        FTImagePickerViewController.multipleSelectMax = FTImagePickerOptions.multipleSelectMax;
        FTImagePickerViewController.selectedItemCount = 0;
        albumListViewController.multipleSelectOn = FTImagePickerViewController.multipleSelectOn;
        albumListViewController.multipleSelectMax = FTImagePickerViewController.multipleSelectMax;
        albumListViewController.multipleSelectMin = FTImagePickerViewController.multipleSelectMin;
        //Albums to use in albumlist
        //Camera Roll is added as a default album
        albumListViewController.useCameraRoll = FTImagePickerOptions.useCameraRoll;
        //Add or Delete albums you want
        albumListViewController.regularAlbums = FTImagePickerOptions.regularAlbums;
        albumListViewController.smartAlbums = FTImagePickerOptions.smartAlbums;
        //Media type to use
        albumListViewController.mediaTypeToUse = FTImagePickerOptions.mediaTypeToUse;
        FTImagePickerViewController.mediaTypeToUse = albumListViewController.mediaTypeToUse;
        //Theme of image picker
        albumListViewController.theme = FTImagePickerOptions.theme;
        FTImagePickerViewController.theme = albumListViewController.theme;
        
        //make a stack for showing appropriate ViewController for purpose of the app.
        //show album list first
        if(FTImagePickerOptions.firstShowingController == FTAlbumList){
            [navigationController setViewControllers:@[albumListViewController] animated:NO];
        }
        //show image picker first
        else{
        [navigationController setViewControllers:@[albumListViewController, FTImagePickerViewController] animated:NO];
        }
        [viewController presentViewController:navigationController animated:YES completion:nil];
    }
    else{
        [self managePhotoLibrarySetting:viewController withOptions:FTImagePickerOptions];
    }
}


#pragma mark - Get PhotoLibrary Authorization from User
+ (void)managePhotoLibrarySetting:(UIViewController *)viewController withOptions:(FTImagePickerOptions *)FTImagePickerOptions{
    
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    
    //self function cannot be used in the block??
    //so make a viewController for using in the block
    
    if(status == PHAuthorizationStatusNotDetermined){
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            if(status == PHAuthorizationStatusAuthorized){
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self presentFTImagePicker:viewController withOptions:FTImagePickerOptions];
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


