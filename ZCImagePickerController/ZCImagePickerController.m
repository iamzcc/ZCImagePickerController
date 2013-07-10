
#import <AssetsLibrary/AssetsLibrary.h>

#import "ZCImagePickerController.h"
#import "ZCAlbumPickerController.h"
#import "ZCHelper.h"

@implementation ZCImagePickerController {
    
@private
    UIStatusBarStyle originalStatusBarStyle;
    UIBarStyle originalNavigationBarStyle;
    BOOL isOriginalNavigationBarTranslucent;
}

@synthesize imagePickerDelegate, maximumAllowsSelectionCount, assetsLibrary, mediaType;

#pragma mark - LifeCycle

- (id)init {
    self = [super init];
    if (self) {
        ZCAlbumPickerController *albumPickerController = [[ZCAlbumPickerController alloc] initWithStyle:UITableViewStylePlain];
        [self pushViewController:albumPickerController animated:NO];
        
        // maximum allow selection default value
        // setting the default value below
        self.maximumAllowsSelectionCount = 10;
        
        self.assetsLibrary = [[ALAssetsLibrary alloc] init];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadItemsFromAssetsLibrary:) name:ALAssetsLibraryChangedNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cancelImagePicker) name:UIApplicationWillResignActiveNotification object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ALAssetsLibraryChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if ([ZCHelper isPhone]) {
        // backup the original status bar and navigation bar style
        originalStatusBarStyle = [UIApplication sharedApplication].statusBarStyle;
        originalNavigationBarStyle = self.navigationBar.barStyle;
        isOriginalNavigationBarTranslucent = self.navigationBar.translucent;
        
        // change the status bar and navigation bar style
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent animated:YES];
        
        self.navigationBar.barStyle = UIBarStyleBlack;
        self.navigationBar.translucent = YES;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if ([ZCHelper isPhone]) {
        // restore the original status bar and navigation bar style
        [[UIApplication sharedApplication] setStatusBarStyle:originalStatusBarStyle animated:YES];
        
        self.navigationBar.barStyle = originalNavigationBarStyle;
        self.navigationBar.translucent = isOriginalNavigationBarTranslucent;
    }
}

#pragma mark - Private Methods

- (void)reloadItemsFromAssetsLibrary:(NSNotification *)notification {

    for (UIViewController *viewController in self.viewControllers) {
        if ([viewController respondsToSelector:@selector(reloadData)]) {
            [viewController performSelector:@selector(reloadData)];
        }
    }
}

- (void)cancelImagePicker {
	if ([self.imagePickerDelegate respondsToSelector:@selector(zcImagePickerControllerDidCancel:)]) {
		[self.imagePickerDelegate performSelector:@selector(zcImagePickerControllerDidCancel:) withObject:self];
	}
}

- (void)selectedAssets:(NSArray *)assets {

	NSMutableArray *returnArray = [[NSMutableArray alloc] init];
	
	for (ALAsset *asset in assets) {
        
		NSMutableDictionary *workingDictionary = [[NSMutableDictionary alloc] init];
		[workingDictionary setObject:[asset valueForProperty:ALAssetPropertyType] forKey:@"UIImagePickerControllerMediaType"];
        [workingDictionary setObject:[UIImage imageWithCGImage:[[asset defaultRepresentation] fullScreenImage]] forKey:@"UIImagePickerControllerOriginalImage"];
		[workingDictionary setObject:[[asset valueForProperty:ALAssetPropertyURLs] valueForKey:[[[asset valueForProperty:ALAssetPropertyURLs] allKeys] objectAtIndex:0]] forKey:@"UIImagePickerControllerReferenceURL"];
		
		[returnArray addObject:workingDictionary];
	}
    
	if ([self.imagePickerDelegate respondsToSelector:@selector(zcImagePickerController:didFinishPickingMediaWithInfo:)]) {
		[self.imagePickerDelegate performSelector:@selector(zcImagePickerController:didFinishPickingMediaWithInfo:) withObject:self withObject:returnArray];
	}
}

- (ALAssetsFilter *)assetsGroupFilter {
    if (self.mediaType == ZCMediaAllPhotos) {
        return [ALAssetsFilter allPhotos];
    }
    else if (self.mediaType == ZCMediaAllVideos) {
        return [ALAssetsFilter allVideos];
    }
    else {
        return [ALAssetsFilter allAssets];
    }
}

@end
