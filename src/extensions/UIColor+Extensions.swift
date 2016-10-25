// UIColor+Extensions.swift
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


public extension UIColor
{
	// MARK: - Static
	public class func fromRGBA(_ RGB: Int32, alpha: CGFloat) -> UIColor
	{
		let red = ((CGFloat)((RGB & 0xFF0000) >> 16)) / 255
		let green = ((CGFloat)((RGB & 0xFF00) >> 8)) / 255
		let blue = ((CGFloat)(RGB & 0xFF)) / 255
		return UIColor(red: red, green: green, blue: blue, alpha: alpha)
	}

	public class func fromRGB(_ RGB: Int32) -> UIColor
	{
		return UIColor.fromRGBA(RGB, alpha: 1.0)
	}

	public func colorWithMinimumSaturation(_ minSaturation: CGFloat) -> UIColor
	{
		var h: CGFloat = 0.0, s: CGFloat = 0.0, v: CGFloat = 0.0, a: CGFloat = 0.0
		getHue(&h, saturation: &s, brightness: &v, alpha: &a)

		if (s < minSaturation)
		{
			return UIColor(hue: h, saturation: s, brightness: v, alpha: a)
		}

		return self
	}

	public func inverted() -> UIColor
	{
		var r: CGFloat = 0.0, g: CGFloat = 0.0, b: CGFloat = 0.0, a: CGFloat = 0.0
		getRed(&r, green: &g, blue: &b, alpha: &a)
		return UIColor(red: 1.0 - r, green: 1.0 - g, blue: 1.0 - b, alpha: 1.0)
	}

	func isBlackOrWhite() -> Bool
	{
		var r: CGFloat = 0.0, g: CGFloat = 0.0, b: CGFloat = 0.0, a: CGFloat = 0.0
		getRed(&r, green: &g, blue: &b, alpha: &a)
		if (r > 0.91 && g > 0.91 && b > 0.91)
		{
			return true // white
		}
		if (r < 0.09 && g < 0.09 && b < 0.09)
		{
			return true // black
		}
		return false
	}

	public func isContrasting(fromColor color: UIColor) -> Bool
	{
		var r1: CGFloat = 0.0, g1: CGFloat = 0.0, b1: CGFloat = 0.0, a1: CGFloat = 0.0
		var r2: CGFloat = 0.0, g2: CGFloat = 0.0, b2: CGFloat = 0.0, a2: CGFloat = 0.0
		getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
		color.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)

		let lum1 = 0.2126 * r1 + 0.7152 * g1 + 0.0722 * b1
		let lum2 = 0.2126 * r2 + 0.7152 * g2 + 0.0722 * b2
		var contrast: CGFloat = 0.0

		if (lum1 > lum2)
		{
			contrast = (lum1 + 0.05) / (lum2 + 0.05)
		}
		else
		{
			contrast = (lum2 + 0.05) / (lum1 + 0.05)
		}
		return contrast > 1.6
	}

	public func isDark() -> Bool
	{
		var r: CGFloat = 0.0, g: CGFloat = 0.0, b: CGFloat = 0.0, a: CGFloat = 0.0
		getRed(&r, green: &g, blue: &b, alpha: &a)

		let lum = 0.2126 * r + 0.7152 * g + 0.0722 * b

		return (lum < 0.5)
	}

	public func isDistinct(fromColor color: UIColor) -> Bool
	{
		var r1: CGFloat = 0.0, g1: CGFloat = 0.0, b1: CGFloat = 0.0, a1: CGFloat = 0.0
		var r2: CGFloat = 0.0, g2: CGFloat = 0.0, b2: CGFloat = 0.0, a2: CGFloat = 0.0
		self.getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
		color.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)

		let threshold: CGFloat = 0.25

		if (fabs(r1 - r2) > threshold || fabs(g1 - g2) > threshold || fabs(b1 - b2) > threshold || fabs(a1 - a2) > threshold)
		{
			// Prevent multiple gray colors
			if (fabs(r1 - g1) < 0.03 && fabs(r1 - b1) < 0.03)
			{
				if (fabs(r2 - g2) < 0.03 && fabs(r2 - b2) < 0.03)
				{
					return false
				}
			}

			return true
		}

		return false
	}
}

public prefix func ~(color: UIColor) -> UIColor
{
	return color.inverted()
}
