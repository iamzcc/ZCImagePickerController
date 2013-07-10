
#import <UIKit/UIKit.h>

@interface ZCAssetCell : UITableViewCell

- (id)initWithAssets:(NSArray *)assets reuseIdentifier:(NSString *)identifier;
- (void)setAssets:(NSArray *)assets;

@end