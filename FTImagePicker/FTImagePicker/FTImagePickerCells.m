//
//  FTImagePickerCells.m
//  FTImagePicker
//
//  Created by Park on 2016. 10. 20..
//  Copyright © 2016년 Parkfantagram /inc. All rights reserved.
//

#import "FTImagePickerCells.h"

@implementation FTAlbumListCollectionViewCell
@end

@implementation FTImagePickerCollectionViewCell
@end

@implementation FTDetailViewCollectionViewCell
- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self){
        self.scrollViewForZoom = [[UIScrollView alloc] initWithFrame:self.bounds];
        self.detailImageView = [[UIImageView alloc] initWithFrame:self.scrollViewForZoom.bounds];
        self.detailImageView.contentMode = UIViewContentModeScaleAspectFit;
        self.detailImageView.userInteractionEnabled = YES;
        
        [self.contentView addSubview:self.scrollViewForZoom];
        [self.scrollViewForZoom addSubview:self.detailImageView];
    }
    return self;
}
@end
