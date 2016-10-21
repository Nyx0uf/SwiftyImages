# SwiftyImages

***SwiftyImages*** is the continuation of [NYXImagesKit](https://github.com/Nyx0uf/NYXImagesKit), it's more modern, uses *Swift 3* and requires at least *iOS 9.3*.

It's a framework which regroups a collection of useful extensions and classes to interact with images and colors.


## UIImage extensions

### Filtering

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
12. Blur


### Masking

This extension is composed of a single method which allows to mask an image with another one, you just have to create the mask image you desire.

	let maskedImage = myImage.masked(withImage: maskImage)


### Resizing

This extension can be used to crop to scale images.


#### Cropping

	let croppedImage = myImage.cropped(toSize: CGSize(width, height))

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

	let scaledImage1 = myImage.scaled(factor: 0.5)
	let scaledImage2 = myImage.scaled(toSize: CGSize(width, height)


### Rotating

With this extension you can rotate, flip or reflect an image.

	let reflectedImage = myImage.reflected()
	let flippedImage = myImage.horizontallyFlipped()
	let rotatedImage = myImage.rotated(degrees: 45.0)


### Saving

This extension allows you to save an image at a specified path or file URL among these format : **BMP**, **GIF**, **JPG**, **PNG**, **TIFF**.

	let success = myImage.save(to: yourURL)
	let success = myImage.save(toPath: yourPath, type: .jpg)


### Creating a gradient image

	let gradient = UIImage.makeGrayGradient(width: width, height: height, fromAlpha: 1.0, toAlpha: 1.0)


### Creating an image from a string

	let stringImage = UIImage.makeFromString("SwiftyImages", font: textFont, fontColor: fontColor, backgroundColor: bgColor, maxSize: maxSize)


## UIColor extensions

Some utilities to create color from a hexadecimal value, invert a color and more.


## CGContext extensions

3 functions to easily get a bitmap context :

	let bmContext = CGContext.ARGBBitmapContext(width: width, height: height, withAlpha: false)
	let bmContext = CGContext.RGBABitmapContext(width: width, height: height, withAlpha: true)
	let bmContext = CGContext.GrayBitmapContext(width: width, height: height)


## Classes

### NYXProgressiveImageView

This is a subclass of *UIImageView* to load asynchronously an image from an URL and display it as it is being downloaded. Image caching is supported.
For more informations see <https://cocoaintheshell.whine.fr/2012/01/nyximageskit-class-nyxprogressiveimageview/> and <https://cocoaintheshell.whine.fr/2011/05/progressive-images-download-imageio/>.


### KawaiiColors

Class to match colors like iTunes 11.

	let analyzer = KawaiiColors(image: myImage)
	analyzer.analyze()
	//analyzer.edgeColor
	//analyzer.dominantColor
	//analyzer.primaryColor
	//analyzer.secondaryColor
	//analyzer.thirdColor


### LICENSE

**SwiftyImages** is released under the MIT License, see LICENSE file.