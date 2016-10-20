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

@interface FTImagePickerManager : NSObject

+ (void) presentFTImagePicker: (UIViewController *) viewController firstShowingController:(FTFirstShowingController) firstShowingController;
+ (void) managePhotoLibrarySetting: (UIViewController *) viewController firstShowingController:(FTFirstShowingController) firstShowingController;

@end


