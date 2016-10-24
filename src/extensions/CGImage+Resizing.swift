// CGImage+Resizing.swift
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


public extension CGImage
{
	// MARK: - Cropping
	public func cropped(toSize: CGSize) -> CGImage?
	{
		return self.cropped(toSize: toSize, mode: .topLeft)
	}

	public func cropped(toSize: CGSize, mode: NYXCropMode) -> CGImage?
	{
		let size = CGSize(self.width, self.height)
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

		// Create the cropped image
		let cropRect = CGRect(x, y, toSize.width, toSize.height)
		return self.cropping(to: cropRect)
	}

	// MARK: - Scaling
	public func scaled(factor: CGFloat) -> CGImage?
	{
		let scaledSize = CGSize(CGFloat(self.width) * factor, CGFloat(self.height) * factor)
		return self.scaleToFillSize(scaledSize)
	}

	public func scaled(toSize: CGSize) -> CGImage?
	{
		return self.scaleToFillSize(toSize)
	}

	public func scaled(toSize: CGSize, mode: NYXScaleMode) -> CGImage?
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

	private func scaleToFillSize(_ scaleSize: CGSize) -> CGImage?
	{
		let destWidth = scaleSize.width
		let destHeight = scaleSize.height

		// Create an ARGB bitmap context
		guard let bmContext = CGContext.ARGBBitmapContext(width: Int(destWidth), height: Int(destHeight), withAlpha: self.hasAlpha()) else
		{
			return nil
		}

		// Image quality
		bmContext.setShouldAntialias(true)
		bmContext.setAllowsAntialiasing(true)
		bmContext.interpolationQuality = .high

		// Draw the image in the bitmap context
		UIGraphicsPushContext(bmContext)
		bmContext.draw(self, in: CGRect(0, 0, destWidth, destHeight))
		UIGraphicsPopContext()

		// Create an image object from the context
		return bmContext.makeImage()
	}

	private func scaleToFitSize(_ scaleSize: CGSize) -> CGImage?
	{
		// Keep aspect ratio
		var destWidth = 0, destHeight = 0
		let widthFloat = CGFloat(self.width)
		let heightFloat = CGFloat(self.height)
		if self.width > self.height
		{
			destWidth = Int(scaleSize.width)
			destHeight = Int(heightFloat * scaleSize.width / widthFloat)
		}
		else
		{
			destHeight = Int(scaleSize.height)
			destWidth = Int(widthFloat * scaleSize.height / heightFloat)
		}
		if destWidth > Int(scaleSize.width)
		{
			destWidth = Int(scaleSize.width)
			destHeight = Int(heightFloat * scaleSize.width / widthFloat)
		}
		if destHeight > Int(scaleSize.height)
		{
			destHeight = Int(scaleSize.height)
			destWidth = Int(widthFloat * scaleSize.height / heightFloat)
		}

		return self.scaleToFillSize(CGSize(destWidth, destHeight))
	}

	private func scaleToCoverSize(_ scaleSize: CGSize) -> CGImage?
	{
		var destWidth = 0, destHeight = 0
		let widthFloat = CGFloat(self.width)
		let heightFloat = CGFloat(self.height)
		let widthRatio = scaleSize.width / widthFloat
		let heightRatio = scaleSize.height / heightFloat

		// Keep aspect ratio
		if heightRatio > widthRatio
		{
			destHeight = Int(scaleSize.height)
			destWidth = Int(widthFloat * scaleSize.height / heightFloat)
		}
		else
		{
			destWidth = Int(scaleSize.width)
			destHeight = Int(heightFloat * scaleSize.width / widthFloat)
		}

		return self.scaleToFillSize(CGSize(destWidth, destHeight))
	}
}
