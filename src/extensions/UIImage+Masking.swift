// UIImage+Masking.swift
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


public extension UIImage
{
	public func masked(withImage maskImage: UIImage) -> UIImage?
	{
		guard let cgImage = self.cgImage, let cgMaskImage = maskImage.cgImage else
		{
			return nil
		}

		// Create an ARGB bitmap context
		let originalWidth = Int(self.size.width)
		let originalHeight = Int(self.size.height)
		guard let bmContext = CGContext.ARGBBitmapContext(width: originalWidth, height: originalHeight, withAlpha: true) else
		{
			return nil
		}

		// Image quality
		bmContext.setShouldAntialias(true)
		bmContext.setAllowsAntialiasing(true)
		bmContext.interpolationQuality = .high

		// Image mask
		guard let mask = CGImage(maskWidth: Int(maskImage.size.width), height: Int(maskImage.size.height), bitsPerComponent: cgMaskImage.bitsPerComponent, bitsPerPixel: cgMaskImage.bitsPerPixel, bytesPerRow: cgMaskImage.bytesPerRow, provider: cgMaskImage.dataProvider!, decode: nil, shouldInterpolate: false) else
		{
			return nil
		}

		// Draw the original image in the bitmap context
		let r = CGRect(x: 0, y: 0, width: originalWidth, height: originalHeight)
		bmContext.clip(to: r, mask: cgMaskImage)
		bmContext.draw(cgImage, in: r)

		// Get the CGImage object
		guard let imageRefWithAlpha = bmContext.makeImage() else
		{
			return nil
		}

		// Apply the mask
		guard let maskedImageRef = imageRefWithAlpha.masking(mask) else
		{
			return nil
		}

		return UIImage(cgImage: maskedImageRef, scale: self.scale, orientation: self.imageOrientation)
	}
}
