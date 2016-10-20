//
//  FTAlbumLIstViewController.m
//  FTImagePicker
//
//  Created by Park on 2016. 10. 20..
//  Copyright © 2016년 Parkfantagram /inc. All rights reserved.
//

#import "FTAlbumLIstViewController.h"

@interface FTAlbumLIstViewController ()

@end

@implementation FTAlbumLIstViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if(!self.albumsArray){
        self.albumsArray = [[NSMutableArray alloc] init];
    }
    PHFetchResult *cameraRoll = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:nil];
    [cameraRoll enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self.albumsArray addObject:obj];
    }];
    
    //Fetching user albums
    PHFetchOptions *albumsFetchingOptions = [[PHFetchOptions alloc] init];
    albumsFetchingOptions.predicate = [NSPredicate predicateWithFormat:@"estimatedAssetCount > 0"];
    PHFetchResult *userAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAny options:albumsFetchingOptions];
    [userAlbums enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        PHAssetCollection *collection = obj;
        NSLog(@"album title %@", collection.localizedTitle);
        [self.albumsArray addObject:obj];
    }];
    //Fetching smart albums
    PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAny options:nil];
    [smartAlbums enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        PHAssetCollection *collection = obj;
        NSLog(@"album title %@", collection.localizedTitle);
        PHFetchResult *fetchingResultForCount = [PHAsset fetchAssetsInAssetCollection:collection options:nil];
        //add albums which have at least one item in their album.
        if(fetchingResultForCount.count > 0 && collection.assetCollectionSubtype != PHAssetCollectionSubtypeSmartAlbumUserLibrary){
            [self.albumsArray addObject:obj];
        }
    }];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.albumsArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    FTAlbumListCollectionViewCell *cell = [self.albumlistCollectionView dequeueReusableCellWithReuseIdentifier:@"albumListCells" forIndexPath:indexPath];
    PHAssetCollection *collection = self.albumsArray[indexPath.row];
    cell.albumTitle.text = collection.localizedTitle;
    cell.albumCollection = collection;
    PHFetchResult *assetResultForAlbumCover = [PHAsset fetchAssetsInAssetCollection:collection options:nil];
    int albumCoverNumber = (int)assetResultForAlbumCover.count;
    if(albumCoverNumber > 3){
        albumCoverNumber = 3;
    }
    NSMutableArray *assetForAlbumCover = [[NSMutableArray alloc] init];
    NSArray *arrayForCellImages = @[cell.imageView1, cell.imageView2, cell.imageView3];
    for (int i = 0 ; i < albumCoverNumber ; i ++){
        [assetResultForAlbumCover enumerateObjectsAtIndexes:[NSIndexSet indexSetWithIndex:i] options:NSEnumerationConcurrent usingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [assetForAlbumCover addObject:obj];
        }];
    }
    for (int i = 0; i < albumCoverNumber ; i ++){
        [[PHImageManager defaultManager] requestImageForAsset:assetForAlbumCover[i] targetSize:cell.imageView1.bounds.size contentMode:PHImageContentModeAspectFill options:nil resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            UIImageView * imageView = arrayForCellImages[i];
            imageView.image = result;
            imageView.layer.cornerRadius = 5;
            imageView.layer.borderWidth = 1;
            imageView.layer.borderColor = [UIColor colorWithWhite:0 alpha:0.1].CGColor;
        }];
    }
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    CGSize mainScreenSize = [UIScreen mainScreen].bounds.size;
    float cellWidth = (mainScreenSize.width-1)/2;
    NSLog(@"%f", cellWidth);
    return CGSizeMake(cellWidth, cellWidth*17/15);
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString:@"albumListToImagePicker"]){
        FTImagePickerViewController *imagePickerViewController = segue.destinationViewController;
        FTAlbumListCollectionViewCell *cell = sender;
        PHFetchResult *assetResultForAlbum = [PHAsset fetchAssetsInAssetCollection:cell.albumCollection options:nil];
        NSMutableArray *assetForAlbum = [[NSMutableArray alloc] init];
        [assetResultForAlbum enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [assetForAlbum addObject:obj];
        }];
        imagePickerViewController.allAssets = assetForAlbum;
    }
}


@end
