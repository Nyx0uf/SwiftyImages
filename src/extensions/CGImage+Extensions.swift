// CGImage+Extensions.swift
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


public extension CGImage
{
	public func hasAlpha() -> Bool
	{
		let alpha = self.alphaInfo
		return (alpha == .first || alpha == .last || alpha == .premultipliedFirst || alpha == .premultipliedLast);
	}

	public class func makeGrayGradient(width: Int, height: Int, fromAlpha: CGFloat, toAlpha: CGFloat) -> CGImage?
	{
		guard let gradientBitmapContext = CGContext.GrayBitmapContext(width: width, height: height) else
		{
			return nil
		}

		// Create a CGGradient
		let colors: [CGFloat] = [toAlpha, 1.0, fromAlpha, 1.0]
		guard let grayScaleGradient = CGGradient(colorSpace: CGColorSpaceCreateDeviceGray(), colorComponents: colors, locations: nil, count: 2) else
		{
			return nil
		}

		// Draw the gradient into the gray bitmap context
		gradientBitmapContext.drawLinearGradient(grayScaleGradient, start: CGPoint.zero, end: CGPoint(x: 0, y: height), options: [.drawsAfterEndLocation])

		return gradientBitmapContext.makeImage()
	}
}
