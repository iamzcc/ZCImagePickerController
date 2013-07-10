
#import <UIKit/UIKit.h>

#import "ZCAsset.h"

@interface ZCAssetTablePicker : UITableViewController <ZCAssetProtocal>

- (id)initWithGroupPersistentID:(NSString *)groupPersistentID;

@end