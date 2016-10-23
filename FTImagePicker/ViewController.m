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
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)OpenImagePicker:(UIControl *)sender {
    [FTImagePickerManager presentFTImagePicker:self firstShowingController:FTImagePicker];
}

- (void)getSelectedImageAssetsFromImagePicker:(NSMutableArray *)selectedAssetsArray{
    NSLog(@"asdfa");
    self.selectedAssets = selectedAssetsArray;
    PHAsset *asset = [self.selectedAssets firstObject];
    [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:self.imageView.bounds.size contentMode:PHImageContentModeAspectFit options:nil resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        self.imageView.image = result;
    }];
}
@end
