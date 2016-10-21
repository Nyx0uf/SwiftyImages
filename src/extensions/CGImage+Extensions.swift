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


// MARK: - Image generators
public extension CGImage
{
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

	public class func makeFromString(_ string: String, font: UIFont, fontColor: UIColor, backgroundColor: UIColor, maxSize: CGSize) -> CGImage?
	{
		// Create an attributed string with string and font information
		let paragraphStyle = NSMutableParagraphStyle()
		paragraphStyle.lineBreakMode = .byWordWrapping
		paragraphStyle.alignment = .center
		let attributes = [NSFontAttributeName : font, NSForegroundColorAttributeName : fontColor, NSParagraphStyleAttributeName : paragraphStyle]
		let attrString = NSAttributedString(string:string, attributes:attributes)
		let scale = UIScreen.main.scale
		let trueMaxSize = maxSize * scale

		// Figure out how big an image we need
		let framesetter = CTFramesetterCreateWithAttributedString(attrString)
		var osef = CFRange(location:0, length:0)
		let goodSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, osef, nil, trueMaxSize, &osef).ceilled()
		let rect = CGRect((trueMaxSize.width - goodSize.width) * 0.5, (trueMaxSize.height - goodSize.height) * 0.5, goodSize.width, goodSize.height)
		let path = CGPath(rect: rect, transform: nil)
		let frame = CTFramesetterCreateFrame(framesetter, CFRange(location:0, length:0), path, nil)

		// Create the context and fill it
		guard let bmContext = CGContext.ARGBBitmapContext(width:Int(trueMaxSize.width), height:Int(trueMaxSize.height), withAlpha:true) else
		{
			return nil
		}
		bmContext.setFillColor(backgroundColor.cgColor)
		bmContext.fill(CGRect(CGPoint.zero, trueMaxSize))

		// Draw the text
		bmContext.setAllowsAntialiasing(true)
		bmContext.setAllowsFontSmoothing(true)
		bmContext.interpolationQuality = .high
		CTFrameDraw(frame, bmContext)

		return bmContext.makeImage()
	}
}

// MARK: -
public extension CGImage
{
	public func hasAlpha() -> Bool
	{
		let alphaInfo = self.alphaInfo
		return (alphaInfo == .first || alphaInfo == .last || alphaInfo == .premultipliedFirst || alphaInfo == .premultipliedLast)
	}
}
