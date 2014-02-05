Guru-iOS
========

Images together in action from a user's social profile and a parse-hosted collection

Motivation
----------

This project uses the great Chute [PhotoPickerPlus](https://github.com/chute/photo-picker-plus-ios/) pod to accomplish majority of social network integration with photos.

In addition, it accomplishes the following:

1. It shows how to add custom features onto the Chute photo picker popover.
2. The interface looks like the following in their configuration plist:
```json
{
	"services":[
		"facebook", 
		"google", 
		"googledrive", 
		"instagram", 
		"flickr", 
		"picasa", 
		"dropbox", 
		"skydrive",
	],
	"local_features":[
		"take_photo",
		"last_taken_photo",
		"camera_photos",
		"test"
	],
	"custom_features": [
		{
			"name": "custom_gallery",
			"storyboard": "Main_iPhone",
			"controller": "ParseImagePickerView",
			"popoverDidFinishPickingNotification": "kParseImagePickerDidFinishPickingNotification",
			"popoverDidCancelPickingNotification": "kParseImagePickerDidCancelPickingNotification"
		}
	]
}
```

Test-driving this project
-------------------------

Follow these steps and hopefully, you can see what I implemented:

1. Don't run pod install as the PhotoPickerPlus that is checked into Pods is what supports custom features. I haven't had a chance to submit this upstream.
2. Set the chute API key and secret in `guru/Configuration/GCConfiguration.plist`
3. Set the parse API key and id in `guru/AppDelegate.m`
4. Code your ParseImagePickerController appropriately, or request me for a mirror of test data my App's databrowser is loaded with.
5. Test it out in simulator or on your iDevice.


License
-------

Copyright (c) 2014 Karan Batra [karanganesha04@gmail.com](mailto:karanganesha04@gmail.com)

Parts of DZNPhotoPickerController are under MIT License with authorship of Copyright (c) 2013 Ignacio Romero Zurbuchen iromero@dzen.cl.

I reserve the right to all the images or artwork in this project. However, all the code in this project is made available under the MIT license. The terms are as below:
> The MIT License (MIT)

> Copyright (c) <year> <copyright holders>

> Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

> The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

> THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
