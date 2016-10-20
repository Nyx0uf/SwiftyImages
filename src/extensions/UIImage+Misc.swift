// UIImage+Misc.swift
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
	public class func makeGrayGradient(width: Int, height: Int, fromAlpha: CGFloat, toAlpha: CGFloat) -> UIImage?
	{
		guard let gradientImage = CGImage.makeGrayGradient(width: width, height: height, fromAlpha: fromAlpha, toAlpha: toAlpha) else
		{
			return nil
		}

		return UIImage(cgImage: gradientImage)
	}

	public class func makeFromString(_ string: String, font: UIFont, fontColor: UIColor, backgroundColor: UIColor, maxSize: CGSize) -> UIImage?
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
		let goodSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, osef, nil, trueMaxSize, &osef).ceil()
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

		// Save
		if let imageRef = bmContext.makeImage()
		{
			let img = UIImage(cgImage:imageRef)
			return img
		}
		else
		{
			return nil
		}
	}

	public func tinted(withColor color: UIColor, opacity: CGFloat = 0.0) -> UIImage?
	{
		let renderer = UIGraphicsImageRenderer(size: size)
		return renderer.image() { rendererContext in
			let rect = CGRect(origin: CGPoint.zero, size: self.size)
			color.set()
			UIRectFill(rect)

			draw(in: rect, blendMode:.destinationIn, alpha:1.0)

			if (opacity > 0.0)
			{
				draw(in: rect, blendMode:.sourceAtop, alpha:opacity)
			}
		}
	}
}
