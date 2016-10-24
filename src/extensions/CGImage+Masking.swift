// CGImage+Masking.swift
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


import CoreGraphics


public extension CGImage
{
	public func masked(withImage maskImage: CGImage) -> CGImage?
	{
		// Create an ARGB bitmap context
		let originalWidth = self.width
		let originalHeight = self.height
		guard let bmContext = CGContext.ARGBBitmapContext(width: originalWidth, height: originalHeight, withAlpha: true) else
		{
			return nil
		}

		// Image quality
		bmContext.setShouldAntialias(true)
		bmContext.setAllowsAntialiasing(true)
		bmContext.interpolationQuality = .high

		// Image mask
		guard let mask = CGImage(maskWidth: maskImage.width, height: maskImage.height, bitsPerComponent: maskImage.bitsPerComponent, bitsPerPixel: maskImage.bitsPerPixel, bytesPerRow: maskImage.bytesPerRow, provider: maskImage.dataProvider!, decode: nil, shouldInterpolate: false) else
		{
			return nil
		}

		// Draw the original image in the bitmap context
		let r = CGRect(0, 0, originalWidth, originalHeight)
		bmContext.clip(to: r, mask: maskImage)
		bmContext.draw(self, in: r)

		// Get the CGImage object
		guard let imageRefWithAlpha = bmContext.makeImage() else
		{
			return nil
		}

		// Apply the mask
		return imageRefWithAlpha.masking(mask)
	}
}
