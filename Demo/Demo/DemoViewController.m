
#import "DemoViewController.h"
#import "ZCImagePickerController.h"

@implementation DemoViewController {
    UIButton *_launchButton;
    UIScrollView *_scrollView;
    UIPopoverController *_popoverController;
    NSMutableArray *_imageViewArray;
}

#pragma mark - View LifeCycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _imageViewArray = [NSMutableArray array];
    }
    return self;
}

- (void)dealloc {
    [_launchButton removeTarget:self action:NULL forControlEvents:UIControlEventTouchUpInside];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
    _launchButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    _launchButton.frame = CGRectMake(0, 0, 200, 40);
    _launchButton.center = CGPointMake(self.view.frame.size.width / 2, self.view.frame.size.height / 2);
    _launchButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin;
    [_launchButton setTitle:@"Launch" forState:UIControlStateNormal];
    [_launchButton addTarget:self action:@selector(launchImagePickerViewController) forControlEvents:UIControlEventTouchUpInside];
    
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    _scrollView.pagingEnabled = YES;
    _scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    [self.view addSubview:_scrollView];
    [self.view addSubview:_launchButton];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    CGRect workingFrame = _scrollView.frame;
	workingFrame.origin.x = 0;
	
	for (UIView *imageView in _imageViewArray) {
		imageView.frame = workingFrame;
		workingFrame.origin.x = workingFrame.origin.x + workingFrame.size.width;
	}
	
	[_scrollView setContentSize:CGSizeMake(workingFrame.origin.x, workingFrame.size.height)];
    _scrollView.contentOffset = CGPointMake(0, 0);
}

#pragma mark - ZCImagePickerControllerDelegate

- (void)zcImagePickerController:(ZCImagePickerController *)imagePickerController didFinishPickingMediaWithInfo:(NSArray *)info {
    [self dismissPickerView];
    
    for (UIView *subview in _imageViewArray) {
        [subview removeFromSuperview];
    }
    
    _imageViewArray = [NSMutableArray array];
    
	CGRect workingFrame = _scrollView.frame;
	workingFrame.origin.x = 0;
	
	for (NSDictionary *imageDic in info) {
        
		UIImageView *imageView = [[UIImageView alloc] initWithImage:[imageDic objectForKey:UIImagePickerControllerOriginalImage]];
		imageView.contentMode = UIViewContentModeScaleAspectFit;
		imageView.frame = workingFrame;
		
		[_scrollView addSubview:imageView];
        [_imageViewArray addObject:imageView];
		
		workingFrame.origin.x = workingFrame.origin.x + workingFrame.size.width;
	}
	
	[_scrollView setContentSize:CGSizeMake(workingFrame.origin.x, workingFrame.size.height)];
}

- (void)zcImagePickerControllerDidCancel:(ZCImagePickerController *)imagePickerController {
    [self dismissPickerView];
}

#pragma mark - Private Methods

- (void)launchImagePickerViewController {
    ZCImagePickerController *imagePickerController = [[ZCImagePickerController alloc] init];
    imagePickerController.imagePickerDelegate = self;
    imagePickerController.maximumAllowsSelectionCount = 5;
    imagePickerController.mediaType = ZCMediaAllAssets;
    
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        
        // You should present the image picker in a popover on iPad.
        
        _popoverController = [[UIPopoverController alloc] initWithContentViewController:imagePickerController];
        [_popoverController presentPopoverFromRect:_launchButton.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
    else {
        // Full screen on iPhone and iPod Touch.
        
        [self.view.window.rootViewController presentViewController:imagePickerController animated:YES completion:NULL];
    }
}

- (void)dismissPickerView {
    if (_popoverController) {
        [_popoverController dismissPopoverAnimated:YES];
    }
    else {
        [self dismissViewControllerAnimated:YES completion:NULL];
    }
}

@end
