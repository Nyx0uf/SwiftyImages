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
	// MARK: - Image generators
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
		guard let image = CGImage.makeFromString(string, font: font, fontColor: fontColor, backgroundColor: backgroundColor, maxSize: maxSize) else
		{
			return nil
		}

		return UIImage(cgImage: image)
	}

	public func tinted(withColor color: UIColor, opacity: CGFloat = 0.0) -> UIImage?
	{
		if #available(iOS 10, *)
		{
			let renderer = UIGraphicsImageRenderer(size: size)
			return renderer.image() { rendererContext in
				let rect = CGRect(0.0, 0.0, self.size.width, self.size.height)
				color.set()
				UIRectFill(rect)

				draw(in: rect, blendMode: .destinationIn, alpha: 1.0)

				if (opacity > 0.0)
				{
					draw(in: rect, blendMode: .sourceAtop, alpha: opacity)
				}
			}
		}
		else
		{
			UIGraphicsBeginImageContextWithOptions(size, false, 0.0)

			let rect = CGRect(0.0, 0.0, size.width, size.height)
			color.set()
			UIRectFill(rect)

			draw(in: rect, blendMode: .destinationIn, alpha: 1.0)

			if (opacity > 0.0)
			{
				draw(in: rect, blendMode: .sourceAtop, alpha: opacity)
			}
			let image = UIGraphicsGetImageFromCurrentImageContext()
			UIGraphicsEndImageContext()

			return image
		}
	}
}
