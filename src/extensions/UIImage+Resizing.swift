// UIImage+Resizing.swift
// Copyright (c) 2016 Nyx0uf
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.


import UIKit


public enum NYXCropMode
{
	case topLeft
	case topCenter
	case topRight
	case bottomLeft
	case bottomCenter
	case bottomRight
	case leftCenter
	case rightCenter
	case center
}

public enum NYXScaleMode
{
	case scaleToFill
	case aspectFit
	case aspectFill
}


public extension UIImage
{
	// MARK: - Cropping
	public func cropped(toSize: CGSize) -> UIImage?
	{
		return self.cropped(toSize: toSize, mode: .topLeft)
	}

	public func cropped(toSize: CGSize, mode: NYXCropMode) -> UIImage?
	{
		guard let cgImage = self.cgImage else
		{
			return nil
		}

		let size = self.size
		var x: CGFloat = 0.0, y: CGFloat = 0.0
		switch (mode)
		{
			case .topLeft:
				x = 0.0
				y = 0.0
			case .topCenter:
				x = (size.width - toSize.width) * 0.5
				y = 0.0
			case .topRight:
				x = size.width - toSize.width
				y = 0.0
			case .bottomLeft:
				x = 0.0
				y = size.height - toSize.height
			case .bottomCenter:
				x = (size.width - toSize.width) * 0.5
				y = size.height - toSize.height
			case .bottomRight:
				x = size.width - toSize.width
				y = size.height - toSize.height
			case .leftCenter:
				x = 0.0
				y = (size.height - toSize.height) * 0.5
			case .rightCenter:
				x = size.width - toSize.width
				y = (size.height - toSize.height) * 0.5
			case .center:
				x = (size.width - toSize.width) * 0.5
				y = (size.height - toSize.height) * 0.5
		}

		var newSize = toSize
		if self.imageOrientation == .left ||
			self.imageOrientation == .leftMirrored ||
			self.imageOrientation == .right ||
			self.imageOrientation == .rightMirrored
		{
			var temp = x
			x = y
			y = temp

			temp = newSize.width
			newSize.width = newSize.height
			newSize.height = temp
		}

		// Create the cropped image
		let cropRect = CGRect(x * self.scale, y * self.scale, newSize.width * self.scale, newSize.height * self.scale)
		guard let croppedImageRef = cgImage.cropping(to: cropRect) else
		{
			return nil
		}

		return UIImage(cgImage: croppedImageRef, scale: self.scale, orientation: self.imageOrientation)
	}

	func smartCropped(toSize: CGSize) -> UIImage?
	{
		guard let cgImage = self.cgImage else
		{
			return nil
		}

		let sourceWidth = size.width * scale
		let sourceHeight = size.height * scale
		let targetWidth = toSize.width
		let targetHeight = toSize.height

		// Calculate aspect ratios
		let sourceRatio = sourceWidth / sourceHeight
		let targetRatio = targetWidth / targetHeight

		// Determine what side of the source image to use for proportional scaling
		let scaleWidth = (sourceRatio <= targetRatio)

		// Proportionally scale source image
		var scalingFactor: CGFloat, scaledWidth: CGFloat, scaledHeight: CGFloat
		if (scaleWidth)
		{
			scalingFactor = 1.0 / sourceRatio
			scaledWidth = targetWidth
			scaledHeight = CGFloat(round(targetWidth * scalingFactor))
		}
		else
		{
			scalingFactor = sourceRatio
			scaledWidth = CGFloat(round(targetHeight * scalingFactor))
			scaledHeight = targetHeight
		}
		let scaleFactor = scaledHeight / sourceHeight

		let destRect = CGRect(CGPoint.zero, toSize).integral
		// Crop center
		let destX = CGFloat(round((scaledWidth - targetWidth) * 0.5))
		let destY = CGFloat(round((scaledHeight - targetHeight) * 0.5))
		let sourceRect = CGRect(ceil(destX / scaleFactor), destY / scaleFactor, targetWidth / scaleFactor, targetHeight / scaleFactor).integral

		// Create scale-cropped image
		if #available(iOS 10, *)
		{
			let renderer = UIGraphicsImageRenderer(size: destRect.size)
			return renderer.image() { rendererContext in
				guard let sourceImg = cgImage.cropping(to: sourceRect) else // cropping happens here
				{
					return
				}
				let image = UIImage(cgImage: sourceImg, scale: 0.0, orientation: imageOrientation)
				image.draw(in: destRect) // the actual scaling happens here, and orientation is taken care of automatically
			}
		}
		else
		{
			UIGraphicsBeginImageContextWithOptions(destRect.size, false, 0.0) // 0.0 = scale for device's main screen
			guard let sourceImg = cgImage.cropping(to: sourceRect) else // cropping happens here
			{
				return nil
			}
			let image = UIImage(cgImage: sourceImg, scale: 0.0, orientation: imageOrientation)
			image.draw(in: destRect) // the actual scaling happens here, and orientation is taken care of automatically
			let final = UIGraphicsGetImageFromCurrentImageContext()
			UIGraphicsEndImageContext()
			return final
		}
	}

	// MARK: - Scaling
	public func scaled(factor: CGFloat) -> UIImage?
	{
		let scaledSize = CGSize(self.size.width * factor, self.size.height * factor)
		return self.scaleToFillSize(scaledSize)
	}

	public func scaled(toSize: CGSize) -> UIImage?
	{
		return self.scaleToFillSize(toSize)
	}

	public func scaled(toSize: CGSize, mode: NYXScaleMode) -> UIImage?
	{
		switch (mode)
		{
			case .aspectFit:
				return self.scaleToFitSize(toSize)
			case .aspectFill:
				return self.scaleToCoverSize(toSize)
			default:
				return self.scaleToFillSize(toSize)
		}
	}

	private func scaleToFillSize(_ scaleSize: CGSize) -> UIImage?
	{
		guard let cgImage = self.cgImage else
		{
			return nil
		}

		var destWidth = Int(scaleSize.width * self.scale)
		var destHeight = Int(scaleSize.height * self.scale)
		if self.imageOrientation == .left
			|| self.imageOrientation == .leftMirrored
			|| self.imageOrientation == .right
			|| self.imageOrientation == .rightMirrored
		{
			let temp = destWidth
			destWidth = destHeight
			destHeight = temp
		}

		// Create an ARGB bitmap context
		guard let bmContext = CGContext.ARGBBitmapContext(width: destWidth, height: destHeight, withAlpha: cgImage.hasAlpha()) else
		{
			return nil
		}

		// Image quality
		bmContext.setShouldAntialias(true)
		bmContext.setAllowsAntialiasing(true)
		bmContext.interpolationQuality = .high

		// Draw the image in the bitmap context
		UIGraphicsPushContext(bmContext)
		bmContext.draw(cgImage, in: CGRect(0, 0, destWidth, destHeight))
		UIGraphicsPopContext()

		// Create an image object from the context
		guard let scaledImageRef = bmContext.makeImage() else
		{
			return nil
		}

		return UIImage(cgImage: scaledImageRef, scale: self.scale, orientation: self.imageOrientation)
	}

	private func scaleToFitSize(_ scaleSize: CGSize) -> UIImage?
	{
		// Keep aspect ratio
		var destWidth = 0, destHeight = 0
		if self.size.width > self.size.height
		{
			destWidth = Int(scaleSize.width)
			destHeight = Int(self.size.height * scaleSize.width / self.size.width)
		}
		else
		{
			destHeight = Int(scaleSize.height)
			destWidth = Int(self.size.width * scaleSize.height / self.size.height)
		}
		if destWidth > Int(scaleSize.width)
		{
			destWidth = Int(scaleSize.width)
			destHeight = Int(self.size.height * scaleSize.width / self.size.width)
		}
		if destHeight > Int(scaleSize.height)
		{
			destHeight = Int(scaleSize.height)
			destWidth = Int(self.size.width * scaleSize.height / self.size.height)
		}

		return self.scaleToFillSize(CGSize(destWidth, destHeight))
	}

	private func scaleToCoverSize(_ scaleSize: CGSize) -> UIImage?
	{
		var destWidth = 0, destHeight = 0
		let widthRatio = scaleSize.width / self.size.width
		let heightRatio = scaleSize.height / self.size.height

		// Keep aspect ratio
		if heightRatio > widthRatio
		{
			destHeight = Int(scaleSize.height)
			destWidth = Int(self.size.width * scaleSize.height / self.size.height)
		}
		else
		{
			destWidth = Int(scaleSize.width)
			destHeight = Int(self.size.height * scaleSize.width / self.size.width)
		}

		return self.scaleToFillSize(CGSize(destWidth, destHeight))
	}
}
