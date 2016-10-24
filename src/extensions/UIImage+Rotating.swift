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


public extension UIImage
{
	public func horizontallyFlipped() -> UIImage?
	{
		guard let flipped = self.cgImage?.horizontallyFlipped() else
		{
			return nil
		}

		return UIImage(cgImage: flipped, scale: self.scale, orientation: self.imageOrientation)
	}

	public func verticallyFlipped() -> UIImage?
	{
		guard let flipped = self.cgImage?.verticallyFlipped() else
		{
			return nil
		}

		return UIImage(cgImage: flipped, scale: self.scale, orientation: self.imageOrientation)
	}

	public func rotated(radians: CGFloat) -> UIImage?
	{
		guard let rotated = self.cgImage?.rotated(radians: radians) else
		{
			return nil
		}

		return UIImage(cgImage: rotated, scale: self.scale, orientation: self.imageOrientation)
	}

	public func rotated(degrees: CGFloat) -> UIImage?
	{
		guard let rotated = self.cgImage?.rotated(degrees: degrees) else
		{
			return nil
		}

		return UIImage(cgImage: rotated, scale: self.scale, orientation: self.imageOrientation)
	}

	public func rotated(degrees: CGFloat, flipOverHorizontalAxis: Bool, flipOverVerticalAxis: Bool) -> UIImage?
	{
		guard let rotated = self.cgImage?.rotated(degrees: degrees, flipOverHorizontalAxis: flipOverHorizontalAxis, flipOverVerticalAxis: flipOverVerticalAxis) else
		{
			return nil
		}

		return UIImage(cgImage: rotated, scale: self.scale, orientation: self.imageOrientation)
	}

	public func rotated(radians: CGFloat, flipOverHorizontalAxis: Bool, flipOverVerticalAxis: Bool) -> UIImage?
	{
		guard let rotated = self.cgImage?.rotated(radians: radians, flipOverHorizontalAxis: flipOverHorizontalAxis, flipOverVerticalAxis: flipOverVerticalAxis) else
		{
			return nil
		}

		return UIImage(cgImage: rotated, scale: self.scale, orientation: self.imageOrientation)
	}

	public func pixelsRotated(degrees: Float) -> UIImage?
	{
		guard let rotated = self.cgImage?.pixelsRotated(degrees: degrees) else
		{
			return nil
		}

		return UIImage(cgImage: rotated, scale: self.scale, orientation: self.imageOrientation)
	}

	public func pixelsRotated(radians: Float) -> UIImage?
	{
		guard let rotated = self.cgImage?.pixelsRotated(radians: radians) else
		{
			return nil
		}

		return UIImage(cgImage: rotated, scale: self.scale, orientation: self.imageOrientation)
	}

	public func reflected(height: Int = 0, fromAlpha: CGFloat = 1.0, toAlpha: CGFloat = 0.0) -> UIImage?
	{
		guard let reflected = self.cgImage?.reflected(height: height, fromAlpha: fromAlpha, toAlpha: toAlpha) else
		{
			return nil
		}

		return UIImage(cgImage: reflected, scale: self.scale, orientation: self.imageOrientation)
	}
}
