### SCREEN SHOT
---
![Album Select in iOS7](http://xuexuefeng.com/images/blog2013/Nov/AlbumSelect~iOS7.PNG)
![Asset Picker in iOS 7](http://xuexuefeng.com/images/blog2013/Nov/AssetPicker~iOS7.PNG)
![Exceed Maximum Selection in iOS 7](http://xuexuefeng.com/images/blog2013/Nov/ExceedMaximumSelection~iOS7.PNG)

![Album Select](http://xuexuefeng.com/images/blog2013/Nov/AlbumSelect.PNG)
![Asset Picker](http://xuexuefeng.com/images/blog2013/Nov/AssetPicker.PNG)
![Exceed Maximum Selection](http://xuexuefeng.com/images/blog2013/Nov/ExceedMaximumSelection.PNG)


### FEATURES
---
1. Simulate the UI and user experience of UIImagePickerController.
2. `Videos and photos are supported`, just like the UIImagePickerController.
3. **Support setting the maximum number of photos and videos that the user can
select at one time**.
4. `Localization supported.` English, Simplified Chinese and Traditional Chinese are supported.
5. Auto reload albums when user modify photos and videos in the default photos app.
6. Support ARC.
7. Support iPhone and iPad.

>  Require OS : iOS5 or later
>  
>  Require Frameworks:
>  
> * AssetsLibrary.framework
> * QuartzCore.framework

### HOW TO USE
---

The image picker is created and displayed in a very similar way of the UIImagePickerController. The demo application shows how it is used.

```
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
```

The ZCImagePickerController will return the select images back to the ZCImagePickerControllerDelegate. The delegate contains to methods very similar to the ZCImagePickerControllerDelegate. Instead of returning one dictionary representing a single image the controller sends back an array of similarly structured dictionaries. The two delegate methods are:

```
- (void)zcImagePickerController:(ZCImagePickerController *)imagePickerController didFinishPickingMediaWithInfo:(NSArray *)info;
- (void)zcImagePickerControllerDidCancel:(ZCImagePickerController *)imagePickerController;
```

### LICENSE
---

The MIT License

Copyright © 2013 ZCCStudio
