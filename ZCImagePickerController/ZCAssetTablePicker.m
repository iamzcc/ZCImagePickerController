
#import <AssetsLibrary/AssetsLibrary.h>

#import "ZCAssetTablePicker.h"
#import "ZCAssetCell.h"
#import "ZCAsset.h"
#import "ZCImagePickerController.h"
#import "ZCHelper.h"

@interface ZCAssetTablePicker ()

@property (nonatomic, strong) ALAssetsGroup *assetsGroup;
@property (nonatomic, strong) NSMutableArray *selectedAssets;
@property (nonatomic, strong) NSMutableSet *selectedAssetsURLs;

@end

static const CGFloat kTopInset = 2.0;
static const CGFloat kRowHeight = 79.0;
static const CGFloat kFooterHeight = 60.0;
//static const CGFloat kScreenHeight = 480.0;

@implementation ZCAssetTablePicker {
    
@private
    UILabel *_navigationBarTitleLabel;
    UILabel *_tableFooterLabel;
    NSUInteger _maximumAllowsSelectionCount;
    NSString *_groupPersistentID;
}

@synthesize assetsGroup, selectedAssets, selectedAssetsURLs;

#pragma mark - Public Methods

- (id)initWithGroupPersistentID:(NSString *)groupPersistentID {
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        _groupPersistentID = groupPersistentID;
    }
    return self;
}

#pragma mark - View LifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.wantsFullScreenLayout = YES;
    self.contentSizeForViewInPopover = CGSizeMake(320, 460);
    
    UIEdgeInsets tableViewInsets = self.tableView.contentInset;
    
    self.tableView.contentInset = UIEdgeInsetsMake(tableViewInsets.top + kTopInset, tableViewInsets.left, tableViewInsets.bottom, tableViewInsets.right);
    
    self.tableView.allowsSelection = NO;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    _tableFooterLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.tableView.frame), kFooterHeight)];
    _tableFooterLabel.font = [UIFont systemFontOfSize:20.0];
    _tableFooterLabel.textColor = [UIColor grayColor];
    _tableFooterLabel.textAlignment = NSTextAlignmentCenter;
    
    _navigationBarTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 44)];
    _navigationBarTitleLabel.backgroundColor = [UIColor clearColor];
    
    if ([ZCHelper isPhone]) {
        _navigationBarTitleLabel.font = [UIFont boldSystemFontOfSize:20.0];
    }
    else {
        _navigationBarTitleLabel.font = [UIFont boldSystemFontOfSize:18.0];
    }
    
    _navigationBarTitleLabel.adjustsFontSizeToFitWidth = YES;
    
    _navigationBarTitleLabel.textAlignment = NSTextAlignmentCenter;
    _navigationBarTitleLabel.text = NSLocalizedStringFromTable(@"Loading...", LOCALIZED_STRING_TABLE, nil);
    
    [self setTitleLabelEnabled];
    
    _maximumAllowsSelectionCount = ((ZCImagePickerController *)self.navigationController).maximumAllowsSelectionCount;
    self.selectedAssets = [NSMutableArray arrayWithCapacity:_maximumAllowsSelectionCount];
    self.selectedAssetsURLs = [NSMutableSet setWithCapacity:_maximumAllowsSelectionCount];
    
    self.tableView.tableFooterView = _tableFooterLabel;
    
    self.navigationItem.titleView = _navigationBarTitleLabel;
	
	UIBarButtonItem *doneButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneAction:)];
	[self.navigationItem setRightBarButtonItem:doneButtonItem];
    
    [self reloadData];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSUInteger maxCountInEachRow = floor(self.view.bounds.size.width / 79.0f);
    NSInteger numberOfAssets = [self.assetsGroup numberOfAssets];
    NSInteger numberOfRows = ceil((float)numberOfAssets / maxCountInEachRow);
    
    return numberOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    ZCAssetCell *cell = (ZCAssetCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[ZCAssetCell alloc] initWithAssets:[self assetsForIndexPath:indexPath] reuseIdentifier:CellIdentifier];
    }
	else {
        [cell setAssets:[self assetsForIndexPath:indexPath]];
	}
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return kRowHeight;
}

#pragma mark - ZCAssetProtocal

- (void)assetDidSelect:(ZCAsset *)asset {
    if (asset.isSelected) {
        [self.selectedAssets addObject:asset];
        
        NSURL *assetURL = [[asset.asset defaultRepresentation] url];
        [self.selectedAssetsURLs addObject:assetURL];
    }
    else {
        [self.selectedAssets removeObject:asset];
        
        NSURL *assetURL = [[asset.asset defaultRepresentation] url];
        [self.selectedAssetsURLs removeObject:assetURL];
    }
    [self updateNavigationBarStatus];
}

#pragma mark - Private Methods

- (void)setTitleLabelEnabled {
    if ([ZCHelper isiOS7orLater]) {
        _navigationBarTitleLabel.textColor = [UIColor blackColor];
    }
    else {
        _navigationBarTitleLabel.textColor = [UIColor colorWithWhite:1.0 alpha:1.0];
        _navigationBarTitleLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:1.0];
        _navigationBarTitleLabel.shadowOffset = CGSizeMake(0, -1);
    }
}

- (void)setTitleLabelDisabled {
    if ([ZCHelper isiOS7orLater]) {
        _navigationBarTitleLabel.textColor = [UIColor lightGrayColor];
    }
    else {
        _navigationBarTitleLabel.textColor = [UIColor colorWithWhite:1.0 alpha:0.7];
        _navigationBarTitleLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.3];
    }
}

- (void)reloadData {
    
    __block BOOL albumAlreadyExist = NO;
    
    [((ZCImagePickerController *)self.navigationController).assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        
        if (group) {
            if ([_groupPersistentID isEqualToString:[group valueForProperty:ALAssetsGroupPropertyPersistentID]]) {
                albumAlreadyExist = YES;
                *stop = YES;
                
                ZCImagePickerController *currentNavigationController = (ZCImagePickerController *)self.navigationController;
                
                [group setAssetsFilter:[ALAssetsFilter allPhotos]];
                NSUInteger photoCount = [group numberOfAssets];
                NSString *photoPart = photoCount > 1 || photoCount == 0 ? [NSString stringWithFormat:NSLocalizedStringFromTable(@"%i Photos", LOCALIZED_STRING_TABLE, nil), photoCount] : NSLocalizedStringFromTable(@"1 Photo", LOCALIZED_STRING_TABLE, nil);
                
                [group setAssetsFilter:[ALAssetsFilter allVideos]];
                NSUInteger videoCount = [group numberOfAssets];
                NSString *videoPart = videoCount > 1 || videoCount == 0 ? [NSString stringWithFormat:NSLocalizedStringFromTable(@"%i Videos", LOCALIZED_STRING_TABLE, nil), videoCount] : NSLocalizedStringFromTable(@"1 Video", LOCALIZED_STRING_TABLE, nil);
                
                if (currentNavigationController.mediaType == ZCMediaAllPhotos) {
                    _tableFooterLabel.text = photoPart;
                }
                else if (currentNavigationController.mediaType == ZCMediaAllVideos) {
                    _tableFooterLabel.text = videoPart;
                }
                else {
                    _tableFooterLabel.text = [NSString stringWithFormat:@"%@, %@", photoPart, videoPart];
                }
                
                [group setAssetsFilter:[currentNavigationController assetsGroupFilter]];
                self.assetsGroup = group;
                
                // Reset tableview offset when data is ready
                NSUInteger numberOfRows = [self.tableView.dataSource tableView:self.tableView numberOfRowsInSection:0];
                CGFloat viewHeight = self.view.bounds.size.height;
                
                CGFloat topOffset = numberOfRows * kRowHeight + kTopInset + kFooterHeight - viewHeight;
                if (topOffset > 0) {
                    self.tableView.contentOffset = CGPointMake(0, topOffset);
                }
                else {
                    if (numberOfRows == 0) {
                        self.tableView.contentOffset = CGPointMake(0, -64);
                    }
                    else {
                        self.tableView.contentOffset = CGPointMake(0, 0);
                    }
                }
                
                [self.tableView reloadData];
                [self updateNavigationBarStatus];
            }
        }
        else {
            if (!albumAlreadyExist) {
                [self.navigationController popViewControllerAnimated:YES];
            }
        }
        
    } failureBlock:^(NSError *error) {
        UIAlertView *errorView = [[UIAlertView alloc] initWithTitle:[error localizedDescription] message:[error localizedRecoverySuggestion] delegate:nil cancelButtonTitle:NSLocalizedStringFromTable(@"OK", LOCALIZED_STRING_TABLE, nil) otherButtonTitles:nil];
        [errorView show];
        
        [self updateNavigationBarStatus];
    }];
}

- (void)doneAction:(id)sender {
    
    NSMutableArray *selectedAssetsArray = [NSMutableArray arrayWithCapacity:_maximumAllowsSelectionCount];
    
    for (ZCAsset *asset in self.selectedAssets) {
        [selectedAssetsArray addObject:asset.asset];
    }
    
    [(ZCImagePickerController *)self.navigationController selectedAssets:selectedAssetsArray];
}

- (void)updateNavigationBarStatus {
    NSUInteger photoSelectCount = [self.selectedAssetsURLs count];
    
    ZCImagePickerController *currentNavigationController = (ZCImagePickerController *)self.navigationController;
    
    if (photoSelectCount > 0) {
        
        // set the navigation bar title
        NSString *titleOdd = @"1 Item";
        NSString *titlePlural = @"%i Items";
        
        if (currentNavigationController.mediaType == ZCMediaAllPhotos) {
            titleOdd = @"1 Photo";
            titlePlural = @"%i Photos";
        }
        else if (currentNavigationController.mediaType == ZCMediaAllVideos) {
            titleOdd = @"1 Video";
            titlePlural = @"%i Videos";
        }
        
        if (photoSelectCount == 1) {
            _navigationBarTitleLabel.text = NSLocalizedStringFromTable(titleOdd, LOCALIZED_STRING_TABLE, nil);
        }
        else {
            _navigationBarTitleLabel.text = [NSString stringWithFormat:NSLocalizedStringFromTable(titlePlural, LOCALIZED_STRING_TABLE, nil), photoSelectCount];
        }
        
        // set the done button status
        if (photoSelectCount <= _maximumAllowsSelectionCount) {
            self.navigationItem.rightBarButtonItem.enabled = YES;
            self.navigationItem.prompt = nil;
            
            [self setTitleLabelEnabled];
        }
        else {
            self.navigationItem.rightBarButtonItem.enabled = NO;
            NSString *moreThanMaxString = [NSString stringWithFormat:NSLocalizedStringFromTable(@"You can only select a maximum of %i", LOCALIZED_STRING_TABLE, nil), _maximumAllowsSelectionCount];
            
            // On iPad, prompt message in UIPopoverController is not showed correctly, so we use title label to show the prompt message.
            if ([ZCHelper isPhone]) {
                self.navigationItem.prompt = moreThanMaxString;
                [self setTitleLabelDisabled];
            }
            else {
                _navigationBarTitleLabel.text = moreThanMaxString;
            }
        }
    }
    else {
        NSString *titleSelect = @"Select Items";
        if (currentNavigationController.mediaType == ZCMediaAllPhotos) {
            titleSelect = @"Select Photos";
        }
        else if (currentNavigationController.mediaType == ZCMediaAllVideos) {
            titleSelect = @"Select Videos";
        }
        
        _navigationBarTitleLabel.text = NSLocalizedStringFromTable(titleSelect, LOCALIZED_STRING_TABLE, nil);
        self.navigationItem.rightBarButtonItem.enabled = YES;
        self.navigationItem.prompt = nil;
        
        [self setTitleLabelEnabled];
    }
}

- (NSArray *)assetsForIndexPath:(NSIndexPath *)indexPath {
    NSUInteger maxCountInEachRow = floor(self.view.bounds.size.width / 79.0f);
    NSUInteger startIndex = indexPath.row * maxCountInEachRow;
    NSUInteger length = MIN([self.assetsGroup numberOfAssets] - startIndex , maxCountInEachRow);
    NSRange range = NSMakeRange(startIndex, length);
    
    NSMutableArray *rowAssets = [NSMutableArray arrayWithCapacity:maxCountInEachRow];
    [self.assetsGroup enumerateAssetsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:range] options:NSEnumerationConcurrent usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
        
        if (result) {
            ZCAsset *asset = [[ZCAsset alloc] initWithAsset:result selected:[self.selectedAssetsURLs containsObject:[[result defaultRepresentation] url]]];
            asset.delegate = self;
            [rowAssets addObject:asset];
        }
    }];
    return rowAssets;
}

@end