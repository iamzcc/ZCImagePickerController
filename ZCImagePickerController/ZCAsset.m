
#import <AssetsLibrary/AssetsLibrary.h>
#import <QuartzCore/QuartzCore.h>

#import "ZCAsset.h"

static const CGFloat kThumbWidth = 75.0;
static const CGFloat kThumbHeight = 75.0;

@implementation ZCAsset {
    
@private
    CALayer *_selectionOverlayLayer;
    CALayer *_videoOverlayLayer;
}

@synthesize delegate;

- (id)initWithAsset:(ALAsset *)asset selected:(BOOL)selected {
    
    self = [super initWithFrame:CGRectMake(0, 0, kThumbWidth, kThumbHeight)];
	if (self) {
		self.asset = asset;
        
		CGRect thumbFrame = CGRectMake(0, 0, kThumbWidth, kThumbHeight);
        
        CALayer *thumbLayer = [CALayer layer];
        thumbLayer.frame = thumbFrame;
        thumbLayer.contents = (id)[self.asset thumbnail];
        [self.layer addSublayer:thumbLayer];
        
        if ([[asset valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypeVideo]) {
            _videoOverlayLayer = [CALayer layer];
            _videoOverlayLayer.frame = thumbFrame;
            _videoOverlayLayer.contents = (id)[UIImage imageNamed:@"VideoOverlay.png"].CGImage;
            
            [self.layer addSublayer:_videoOverlayLayer];
            
            double duration = ((NSNumber *)[asset valueForProperty:ALAssetPropertyDuration]).doubleValue;
            NSUInteger seconds = (int)duration % 60;
            NSUInteger minutes = (int)duration / 60;
            NSString *durationString = [NSString stringWithFormat:@"%i:%.2i", minutes, seconds];
            
            CATextLayer *durationLayer = [CATextLayer layer];
            durationLayer.contentsScale = [UIScreen mainScreen].scale;
            durationLayer.frame = CGRectMake(0, 58, 71, 16);
            durationLayer.fontSize = 13.0;
            durationLayer.string = durationString;
            durationLayer.alignmentMode = kCAAlignmentRight;
            
            [_videoOverlayLayer addSublayer:durationLayer];
        }
        
        _selectionOverlayLayer = [CALayer layer];
        _selectionOverlayLayer.frame = thumbFrame;
        _selectionOverlayLayer.contents = (id)[UIImage imageNamed:@"SelectionOverlay.png"].CGImage;
        _selectionOverlayLayer.hidden = !selected;
        
        [self.layer addSublayer:_selectionOverlayLayer];
        
        [self addTarget:self action:@selector(toggleSelection) forControlEvents:UIControlEventTouchUpInside];
    }
    
	return self;
}

- (void)dealloc {
    [self removeTarget:self action:NULL forControlEvents:UIControlEventTouchUpInside];
}

- (void)toggleSelection {
    _selectionOverlayLayer.hidden  = !_selectionOverlayLayer.hidden;
    
    if ([self.delegate respondsToSelector:@selector(assetDidSelect:)]) {
        [self.delegate assetDidSelect:self];
    }
}

- (BOOL)isSelected {
    return !_selectionOverlayLayer.hidden;
}

- (void)setSelected:(BOOL)selected {
    _selectionOverlayLayer.hidden = !selected;
}

@end