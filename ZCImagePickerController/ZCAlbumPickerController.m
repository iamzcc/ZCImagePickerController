
#import <AssetsLibrary/AssetsLibrary.h>

#import "ZCAlbumPickerController.h"
#import "ZCImagePickerController.h"
#import "ZCAssetTablePicker.h"
#import "ZCHelper.h"

@interface ZCAlbumPickerController ()

@property (nonatomic, strong) NSMutableArray *assetsGroups;

@end

static const CGFloat kRowHeight = 57.0;

@implementation ZCAlbumPickerController

@synthesize assetsGroups;

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
	
    self.wantsFullScreenLayout = YES;
    
    self.contentSizeForViewInPopover = CGSizeMake(320, 460);
    
    self.navigationItem.title = NSLocalizedStringFromTable(@"Loading...", LOCALIZED_STRING_TABLE, nil);
    
    if ([ZCHelper isPhone]) {
        UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self.navigationController action:@selector(cancelImagePicker)];
        [self.navigationItem setRightBarButtonItem:cancelButton];
    }

	self.assetsGroups = [NSMutableArray array];
    
    [self reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.assetsGroups count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.textLabel.font = [UIFont boldSystemFontOfSize:17.0];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    ALAssetsGroup *assetsGroup = (ALAssetsGroup *)[self.assetsGroups objectAtIndex:indexPath.row];
    NSInteger assetsCount = [assetsGroup numberOfAssets];
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@ (%d)", [assetsGroup valueForProperty:ALAssetsGroupPropertyName], assetsCount];
    cell.imageView.image = [UIImage imageWithCGImage:[assetsGroup posterImage]];
	
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *assetsGroupPersistentID = [((ALAssetsGroup *)[self.assetsGroups objectAtIndex:indexPath.row]) valueForProperty:ALAssetsGroupPropertyPersistentID];
    ZCAssetTablePicker *assetTablePicker = [[ZCAssetTablePicker alloc] initWithGroupPersistentID:assetsGroupPersistentID];
    
	[self.navigationController pushViewController:assetTablePicker animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return kRowHeight;
}

#pragma mark - Private Methods

- (void)reloadData {
    
    [self.assetsGroups removeAllObjects];
    
    // Load Albums into assetsGroups
    dispatch_async(dispatch_get_main_queue(), ^ {
        
        @autoreleasepool {
            
            // Group Enumerator Block
            void (^assetGroupEnumerator)(ALAssetsGroup *, BOOL *) = ^(ALAssetsGroup *group, BOOL *stop) {
                
                if (group) {
                    [group setAssetsFilter:[(ZCImagePickerController *)self.navigationController assetsGroupFilter]];
                    [self.assetsGroups addObject:group];
                }
                else {
                    [self.tableView reloadData];
                    self.navigationItem.title = NSLocalizedStringFromTable(@"Albums", LOCALIZED_STRING_TABLE, nil);
                }
            };
            
            // Group Enumerator Failure Block
            void (^assetGroupEnumberatorFailure)(NSError *) = ^(NSError *error) {
                
                UIAlertView *errorView = [[UIAlertView alloc] initWithTitle:[error localizedDescription] message:[error localizedRecoverySuggestion] delegate:nil cancelButtonTitle:NSLocalizedStringFromTable(@"OK", LOCALIZED_STRING_TABLE, nil) otherButtonTitles:nil];
                [errorView show];
                
                self.navigationItem.title = NSLocalizedStringFromTable(@"Albums", LOCALIZED_STRING_TABLE, nil);
            };
            
            // Enumerate Albums
            [((ZCImagePickerController *)self.navigationController).assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll
                                                                                                usingBlock:assetGroupEnumerator
                                                                                              failureBlock:assetGroupEnumberatorFailure];
        }
    });
}

@end