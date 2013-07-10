
#import <UIKit/UIKit.h>

@class ZCAsset;

@protocol ZCAssetProtocal <NSObject>

- (void)assetDidSelect:(ZCAsset *)asset;

@end

@class ALAsset;

@interface ZCAsset : UIControl

@property (nonatomic, strong) ALAsset *asset;
@property (nonatomic, getter = isSelected) BOOL selected;
@property (nonatomic, weak) id<ZCAssetProtocal> delegate;

- (id)initWithAsset:(ALAsset *)asset selected:(BOOL)selected;

@end