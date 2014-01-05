Important
==========

There has been a complete rework of the PhotoPicker component. 

If you are using the old legacy code you can find it in the pp-v1-legacy branch.
Read the documentation and migrate to the new version of the Photo Picker. It contains the Library and a Sample Project which you can use as a reference.

### Native Android Component


The Android component has been moved into its own separate GitHub Repository.

You can find it on the following link along with the sample project:
https://github.com/chute/photo-picker-plus-android



PhotoPickerPlus
==============

No external dependancies beyond Chute SDK which you can also find here:

https://github.com/chute/Chute-SDK-v2-iOS

Description
-----------

This class allows you to pick a photo from any supported online source such as Facebook, Instagram and Dropbox among others. It also replaces the standard picker in that it allows you to pick photos from the device, take photo with the camera or just to pick the latest photo in your library. It has integrated support for multiple image selection, just as the original Image Picker from Apple.

Screenshots
-----------
![screen1](/screenshots/screen1.png)
![screen2](/screenshots/screen2.png)
![screen3](/screenshots/screen3.png)
![screen4](/screenshots/screen4.png)
![screen5](/screenshots/screen5.png)
![screen6](/screenshots/screen6.png)
![screen7](/screenshots/screen7.png)
![screen8](/screenshots/screen8.png)
![screen9](/screenshots/screen9.png)
![screen10](/screenshots/screen10.png)
![screen11](/screenshots/screen11.png)
![screen12](/screenshots/screen12.png)
![screen13](/screenshots/screen13.png)

Initialization
--------------

 *   isMultipleSelectionEnabled - `BOOL` - If YES, picker does multi image selection, if NO, picker does single image selection.
 *   delegate `NSObject <PhotoPickerPlusDelegate>` - The delegate for this component. It should implement two of the following delegate methods, depending on single or multiple selection.
    *  `- (void)imagePickerController:(PhotoPickerViewController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info;`
    *  `- (void)imagePickerController:(PhotoPickerViewController *)picker didFinishPickingArrayOfMediaWithInfo:(NSArray *)info;`
    *  `- (void)imagePickerControllerDidCancel:(PhotoPickerViewController *)picker;`
    
Implementation
--------------
You will need to implement PhotoPickerPlus.h in your .h file. You will also need to put `<PhotoPickerViewControllerDelegate>`
```objective-c

	- (void)imagePickerControllerDidCancel:(PhotoPickerViewController *)picker{
    	if (self.popoverController) {
        	[self.popoverController dismissPopoverAnimated:YES];
    	}
    	else {
        	[self dismissViewControllerAnimated:YES completion:nil];
    	}
	}
	
    ////////////////////////
    //	  Single Photo	  //
    ////////////////////////
    
    - (void)showPhotoPickerPlus {
    	PhotoPickerViewController *picker = [PhotoPickerViewController new];
    	[picker setDelegate:self];
    	[picker setIsMultipleSelectionEnabled:NO];
    
    	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        	if (![[self popoverController] isPopoverVisible]) {
            	UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:picker];
            	[popover presentPopoverFromRect:[sender frame] inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
	            self.popoverController = popover;
    	    }
        	else {
            	[[self popoverController] dismissPopoverAnimated:YES];
	        }
    	}
	    else {
    	    [self presentViewController:picker animated:YES completion:nil];
	    }
	}
	
	- (void)imagePickerController:(PhotoPickerViewController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
		//place code for when the user picks photos here and do any
	    //additional work such as removing the picker from the screen
	}
	
	///////////////////////
    //	  Multi Photo    //
    ///////////////////////
    
    - (void)showPhotoPickerPlus {
    	PhotoPickerViewController *picker = [PhotoPickerViewController new];
    	[picker setDelegate:self];
    	[picker setIsMultipleSelectionEnabled:YES];
    	
    	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        	if (![[self popoverController] isPopoverVisible]) {
            	UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:picker];
            	[popover presentPopoverFromRect:[sender frame] inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
            	self.popoverController = popover;
        	}
        	else {
            	[[self popoverController] dismissPopoverAnimated:YES];
        	}
    	}
    	else {
        	[self presentViewController:picker animated:YES completion:nil];
    	}
	}
	
	- (void)imagePickerController:(PhotoPickerViewController *)picker didFinishPickingArrayOfMediaWithInfo:(NSArray *)info{
		//place code for when the user picks photos here and do any
	    //additional work such as removing the picker from the screen
	}
```

Tutorials
---------

[Adding PhotoPicker+ to an Existing Project](AddToExisting.md)

[Creating a PhotoPicker+ Sample Project](ChuteStarterProject.md)
