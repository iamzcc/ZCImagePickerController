
#define LOCALIZED_STRING_TABLE @"ZCLocalized"

typedef enum _ZCMediaType {
    ZCMediaAllAssets,
    ZCMediaAllPhotos,
    ZCMediaAllVideos
} ZCMediaType;

@class ZCImagePickerController;

@protocol ZCImagePickerControllerDelegate <NSObject>

@optional
- (void)zcImagePickerController:(ZCImagePickerController *)imagePickerController didFinishPickingMediaWithInfo:(NSArray *)info;
- (void)zcImagePickerControllerDidCancel:(ZCImagePickerController *)imagePickerController;

@end

@class ALAssetsLibrary;
@class ALAssetsFilter;

#import <UIKit/UIKit.h>

@interface ZCImagePickerController : UINavigationController

@property (nonatomic, weak) id<ZCImagePickerControllerDelegate> imagePickerDelegate;
@property (nonatomic) NSUInteger maximumAllowsSelectionCount;
@property (nonatomic, strong) ALAssetsLibrary *assetsLibrary;
@property (nonatomic) ZCMediaType mediaType;

- (void)selectedAssets:(NSArray *)assets;
- (void)cancelImagePicker;
- (ALAssetsFilter *)assetsGroupFilter;

@end