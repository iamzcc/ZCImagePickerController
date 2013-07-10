
#import "ZCAssetCell.h"
#import "ZCAsset.h"

@implementation ZCAssetCell {
    
@private
	NSArray *_rowAssets;
}

- (id)initWithAssets:(NSArray *)assets reuseIdentifier:(NSString *)identifier {
    
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    
	if (self) {
		_rowAssets = assets;
        
        for (ZCAsset *asset in _rowAssets) {
            [asset setFrame:CGRectZero];
            
            [self addSubview:asset];
        }
	}
	
	return self;
}

- (void)setAssets:(NSArray *)assets {
	
	for (ZCAsset *asset in _rowAssets) {
        [asset removeFromSuperview];
	}
    
    _rowAssets = assets;
    
    for (ZCAsset *asset in _rowAssets) {
        [asset setFrame:CGRectZero];
        
        [self addSubview:asset];
    }
}

- (void)layoutSubviews {
    CGRect frame = CGRectMake(4, 2, 75, 75);
    
    for (ZCAsset *asset in _rowAssets) {
        [asset setFrame:frame];
        frame.origin.x = frame.origin.x + frame.size.width + 4;
    }
}

@end