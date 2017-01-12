//
//  ViewController.m
//  FTImagePicker
//
//  Created by Park on 2016. 10. 20..
//  Copyright © 2016년 Parkfantagram /inc. All rights reserved.
//

#import "ViewController.h"


@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    if(!self.selectedAssets){
        self.selectedAssets = [[NSMutableArray alloc] init];
    }
    self.themeSwitch.on = NO;
    self.themeNumber = self.themeSwitch.on;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)OpenImagePicker:(UIControl *)sender {
    FTImagePickerOptions *imagePickerOptions = [[FTImagePickerOptions alloc] init];
    imagePickerOptions.firstShowingController = FTImagePicker;
    imagePickerOptions.multipleSelectOn = self.multiSelectSwitch.on;
    if(self.multiSelectSwitch.on){
        imagePickerOptions.multipleSelectMax = 9;
        imagePickerOptions.multipleSelectMin = 3;
    }
    else{
        imagePickerOptions.multipleSelectMin = 1;
    }
    if(self.mediaTypeSegment.selectedSegmentIndex == 0){
        imagePickerOptions.mediaTypeToUse = ImagesOnly;
    }
    else if(self.mediaTypeSegment.selectedSegmentIndex == 1){
        imagePickerOptions.mediaTypeToUse = VideosOnly;
    }
    else{
        imagePickerOptions.mediaTypeToUse = ImagesAndVideos;
    }
    imagePickerOptions.regularAlbums = @[@2,@3,@4, @5,@6];
    imagePickerOptions.theme = self.themeNumber;
    imagePickerOptions.cellPinchZoomOn = NO;
    imagePickerOptions.numberOfCellsInLine = 4;
    //imagePickerOptions.mediaSubTypeToUse = @[@(PHAssetMediaSubtypePhotoLive), @(PHAssetMediaSubtypePhotoPanorama)];
    [FTImagePickerManager presentFTImagePicker:self withOptions:imagePickerOptions];
}

- (IBAction)themeChange:(UISwitch *)sender {
    self.themeNumber = self.themeSwitch.on;
}

- (void)getSelectedImageAssetsFromImagePicker:(NSMutableArray *)selectedAssetsArray{
    NSLog(@"asdfa");
    self.selectedAssets = selectedAssetsArray;
    NSMutableArray *arrayForImageViews = [[NSMutableArray alloc] init];
    [arrayForImageViews addObject:self.imageView1];
    [arrayForImageViews addObject:self.imageView2];
    [arrayForImageViews addObject:self.imageView3];
    [arrayForImageViews addObject:self.imageView4];
    [arrayForImageViews addObject:self.imageView5];
    [arrayForImageViews addObject:self.imageView6];
    [arrayForImageViews addObject:self.imageView7];
    [arrayForImageViews addObject:self.imageView8];
    [arrayForImageViews addObject:self.imageView9];
    
    for(int i = 0 ; i < self.selectedAssets.count ; i++){
        PHAsset *asset = self.selectedAssets[i];
        UIImageView *tempImageView = arrayForImageViews[i];
        [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:tempImageView.bounds.size contentMode:PHImageContentModeAspectFill options:nil resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            tempImageView.image = result;
        }];
    }
}

- (void)imagePickerCanceledWithOutSelection{
    NSLog(@"picker canceled");
}
@end
