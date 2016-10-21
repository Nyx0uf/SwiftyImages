// UIImage+Rotating.swift
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
import Accelerate


public extension UIImage
{
	public func horizontallyFlipped() -> UIImage?
	{
		return self.rotated(radians: 0.0, flipOverHorizontalAxis: true, flipOverVerticalAxis: false)
	}

	public func verticallyFlipped() -> UIImage?
	{
		return self.rotated(radians: 0.0, flipOverHorizontalAxis: false, flipOverVerticalAxis: true)
	}

	public func rotated(radians: CGFloat) -> UIImage?
	{
		return self.rotated(radians: radians, flipOverHorizontalAxis: false, flipOverVerticalAxis: false)
	}

	public func rotated(degrees: CGFloat) -> UIImage?
	{
		return self.rotated(radians: degreesToRadians(degrees), flipOverHorizontalAxis: false, flipOverVerticalAxis: false)
	}

	public func rotated(degrees: CGFloat, flipOverHorizontalAxis: Bool, flipOverVerticalAxis: Bool) -> UIImage?
	{
		return self.rotated(radians: degreesToRadians(degrees), flipOverHorizontalAxis: flipOverHorizontalAxis, flipOverVerticalAxis: flipOverVerticalAxis)
	}

	public func rotated(radians: CGFloat, flipOverHorizontalAxis: Bool, flipOverVerticalAxis: Bool) -> UIImage?
	{
		guard let cgImage = self.cgImage else
		{
			return nil
		}

		// Create an ARGB bitmap context
		let width = cgImage.width
		let height = cgImage.height

		let rotatedRect = CGRect(0, 0, width, height).applying(CGAffineTransform(rotationAngle: radians))

		guard let bmContext = CGContext.ARGBBitmapContext(width: Int(rotatedRect.size.width), height: Int(rotatedRect.size.height), withAlpha: true) else
		{
			return nil
		}

		// Image quality
		bmContext.setShouldAntialias(true)
		bmContext.setAllowsAntialiasing(true)
		bmContext.interpolationQuality = .high

		// Rotation happen here (around the center)
		bmContext.scaleBy(x: +(rotatedRect.size.width / 2.0), y: +(rotatedRect.size.height / 2.0))
		bmContext.rotate(by: radians)

		// Do flips
		bmContext.scaleBy(x: (flipOverHorizontalAxis ? -1.0 : 1.0), y: (flipOverVerticalAxis ? -1.0 : 1.0))

		// Draw the image in the bitmap context
		bmContext.draw(cgImage, in: CGRect(-(CGFloat(width) / 2.0), -(CGFloat(height) / 2.0), CGFloat(width), CGFloat(height)))

		// Create an image object from the context
		guard let resultImageRef = bmContext.makeImage() else
		{
			return nil
		}

		return UIImage(cgImage: resultImageRef, scale: self.scale, orientation: self.imageOrientation)
	}

	public func pixelsRotated(degrees: Float) -> UIImage?
	{
		return self.pixelsRotated(radians: degreesToRadians(degrees))
	}

	public func pixelsRotated(radians: Float) -> UIImage?
	{
		guard let cgImage = self.cgImage else
		{
			return nil
		}

		// Create an ARGB bitmap context
		let width = Int(self.size.width * self.scale)
		let height = Int(self.size.height * self.scale)
		let bytesPerRow = width * numberOfComponentsPerARBGPixel
		guard let bmContext = CGContext.ARGBBitmapContext(width: width, height: height, withAlpha: true) else
		{
			return nil
		}

		// Draw the image in the bitmap context
		bmContext.draw(cgImage, in: CGRect(0, 0, width, height))

		// Grab the image raw data
		guard let data = bmContext.data else
		{
			return nil
		}

		var src = vImage_Buffer(data: data, height: vImagePixelCount(height), width: vImagePixelCount(width), rowBytes: bytesPerRow)
		var dst = vImage_Buffer(data: data, height: vImagePixelCount(height), width: vImagePixelCount(width), rowBytes: bytesPerRow)
		let bgColor: [UInt8] = [0, 0, 0, 0]
		vImageRotate_ARGB8888(&src, &dst, nil, radians, bgColor, vImage_Flags(kvImageBackgroundColorFill))

		guard let rotatedImageRef = bmContext.makeImage() else
		{
			return nil
		}

		return UIImage(cgImage: rotatedImageRef, scale: self.scale, orientation: self.imageOrientation)
	}

	public func reflected(height: Int = 0, fromAlpha: CGFloat = 1.0, toAlpha: CGFloat = 0.0) -> UIImage?
	{
		guard let cgImage = self.cgImage else
		{
			return nil
		}

		var h = height
		let width = Int(self.size.width)
		if h <= 0
		{
			h = Int(self.size.height)
			return nil
		}

		UIGraphicsBeginImageContextWithOptions(CGSize(width, height), false, 0.0)
		guard let mainViewContentContext = UIGraphicsGetCurrentContext() else
		{
			return nil
		}

		guard let gradientMaskImage = CGImage.makeGrayGradient(width: 1, height: h, fromAlpha: fromAlpha, toAlpha: toAlpha) else
		{
			return nil
		}

		mainViewContentContext.clip(to: CGRect(0, 0, width, h), mask: gradientMaskImage)
		mainViewContentContext.draw(cgImage, in: CGRect(0, 0, width, Int(self.size.height)))

		let theImage = UIGraphicsGetImageFromCurrentImageContext()

		UIGraphicsEndImageContext()

		return theImage
	}
}
