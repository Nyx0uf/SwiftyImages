# SwiftyImages

***SwiftyImages*** is the continuation of [NYXImagesKit](https://github.com/Nyx0uf/NYXImagesKit), it's more modern, uses *Swift 3* and requires *iOS 9.3*.

It's a framework which regroups a collection of useful *UIImage* extensions to handle common operations such as filtering, blurring, enhancing, masking, reflecting, resizing, rotating, saving. There is also a subclass of *UIImageView* to load an image asynchronously from a URL and display it as it is downloaded.


### UIImage+Filtering

This category allows you to apply filters on a *UIImage* object, currently there are 11 filters :

1. Brighten
2. Contrast adjustment
3. Edge detection
4. Emboss
5. Gamma correction
6. Grayscale
7. Invert
8. Opacity
9. Sepia
10. Sharpen
11. Unsharpen


### UIImage+Blurring

This category is composed of a single method to blur an *UIImage*. Blurring is done using **vImage**.

	myImage.gaussianBlurred()


### UIImage+Masking

This category is composed of a single method which allows to mask an image with another one, you just have to create the mask image you desire.

	let masked = myImage.masked(withImage: mask)


### UIImage+Resizing

This category can be used to crop or to scale images.


#### Cropping

	let cropped = myImage.cropped(toSize: CGSize(width, height))

You can crop your image by 9 different ways :

1. Top left
2. Top center
3. Top right
4. Bottom left
5. Bottom center
6. Bottom right
7. Left center
8. Right center
9. Center


#### Scaling

You have the choice between two methods to scale images, the two methods will keep the aspect ratio of the original image.

	let scaled1 = myImage.scaled(factor: 0.5)
	let scaled2 = myImage.scaled(toSize: CGSize(width, height)


### UIImage+Rotating

With this category you can rotate or flip an *UIImage*, flipping is useful if you want to create a reflect effect.


### UIImage+Reflecting

This category allow the creation of a reflected image.

	let reflected = myImage.reflected()


### UIImage+Saving

This category allows you to save an *UIImage* at a specified path or file URL, there are five types supported :

1. BMP
2. GIF
3. JPG
4. PNG
5. TIFF


### NYXProgressiveImageView

This is a subclass of *UIImageView* to load asynchronously an image from an URL and display it as it is being downloaded. Image caching is supported.
For more informations see <https://cocoaintheshell.whine.fr/2012/01/nyximageskit-class-nyxprogressiveimageview/> and <https://cocoaintheshell.whine.fr/2011/05/progressive-images-download-imageio/>.


### LICENSE

**SwiftyImages** is released under the MIT License, see LICENSE file.

Twitter : @Nyx0uf
