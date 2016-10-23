//
//  ViewController.h
//  FTImagePicker
//
//  Created by Park on 2016. 10. 20..
//  Copyright © 2016년 Parkfantagram /inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FTImagePicker.h"

@interface ViewController : UIViewController <FTImagePickerViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) NSMutableArray *selectedAssets;

- (IBAction)OpenImagePicker:(UIControl *)sender;


@end

