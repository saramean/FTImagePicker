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
        //Another setting for AlbumList and ImagePicker here!!
        //setting For mutiple selection of image picker
        FTImagePickerViewController.multipleSelectOn = NO;
        albumListViewController.multipleSelectOn = FTImagePickerViewController.multipleSelectOn;
        
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
        [FTImagePickerManager managePhotoLibrarySetting:viewController firstShowingController:firstShowingController];
    }
}

+ (void)managePhotoLibrarySetting:(UIViewController *)viewController firstShowingController:(FTFirstShowingController)firstShowingController{
    
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    
    //self function cannot be used in the block??
    //so make a viewController for using in the block
    
    if(status == PHAuthorizationStatusNotDetermined){
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            if(status == PHAuthorizationStatusAuthorized){
                [FTImagePickerManager presentFTImagePicker:viewController firstShowingController:firstShowingController];
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
