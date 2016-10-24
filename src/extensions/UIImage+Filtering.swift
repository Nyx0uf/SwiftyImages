// UIImage+Filtering.swift
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
	public func alphaed(value: CGFloat) -> UIImage?
	{
		guard let transparentImageRef = self.cgImage?.alphaed(value: value) else
		{
			return nil
		}

		return UIImage(cgImage: transparentImageRef, scale: self.scale, orientation: self.imageOrientation)
	}

	// Value should be in the range (-255, 255)
	public func brightened(value: Float) -> UIImage?
	{
		guard let brightenedImageRef = self.cgImage?.brightened(value: value) else
		{
			return nil
		}

		return UIImage(cgImage: brightenedImageRef, scale: self.scale, orientation: self.imageOrientation)
	}

	/// (-255, 255)
	public func contrasted(value: Float) -> UIImage?
	{
		guard let contrastedImageRef = self.cgImage?.contrasted(value: value) else
		{
			return nil
		}

		return UIImage(cgImage: contrastedImageRef, scale: self.scale, orientation: self.imageOrientation)
	}

	public func edgeDetected(_ bias: Int32 = 0) -> UIImage?
	{
		guard let edgedImageRef = self.cgImage?.edgeDetected(bias) else
		{
			return nil
		}

		return UIImage(cgImage: edgedImageRef, scale: self.scale, orientation: self.imageOrientation)
	}

	public func embossed(_ bias: Int32 = 0) -> UIImage?
	{
		guard let embossedImageRef = self.cgImage?.embossed(bias) else
		{
			return nil
		}

		return UIImage(cgImage: embossedImageRef, scale: self.scale, orientation: self.imageOrientation)
	}

	/// (0.01, 8)
	public func gammaCorrected(value: Float) -> UIImage?
	{
		guard let gammaImageRef = self.cgImage?.gammaCorrected(value: value) else
		{
			return nil
		}

		return UIImage(cgImage: gammaImageRef, scale: self.scale, orientation: self.imageOrientation)
	}

	public func grayscaled() -> UIImage?
	{
		guard let grayscaledImageRef = self.cgImage?.grayscaled() else
		{
			return nil
		}

		return UIImage(cgImage: grayscaledImageRef, scale: self.scale, orientation: self.imageOrientation)
	}

	public func inverted() -> UIImage?
	{
		guard let invertedImageRef = self.cgImage?.inverted() else
		{
			return nil
		}

		return UIImage(cgImage: invertedImageRef, scale: self.scale, orientation: self.imageOrientation)
	}

	public func sepiaed() -> UIImage?
	{
		guard let sepiaImageRef = self.cgImage?.sepiaed() else
		{
			return nil
		}

		return UIImage(cgImage: sepiaImageRef, scale: self.scale, orientation: self.imageOrientation)
	}

	public func sharpened(_ bias: Int32 = 0) -> UIImage?
	{
		guard let sharpenedImageRef = self.cgImage?.sharpened(bias) else
		{
			return nil
		}

		return UIImage(cgImage: sharpenedImageRef, scale: self.scale, orientation: self.imageOrientation)
	}

	public func unsharpened(_ bias: Int32 = 0) -> UIImage?
	{
		guard let unsharpenedImageRef = self.cgImage?.unsharpened(bias) else
		{
			return nil
		}

		return UIImage(cgImage: unsharpenedImageRef, scale: self.scale, orientation: self.imageOrientation)
	}
}
