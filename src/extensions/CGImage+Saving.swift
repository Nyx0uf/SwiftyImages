// CGImage+Saving.swift
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
import UIKit
import ImageIO
import MobileCoreServices


public enum NYXImageType
{
	case png
	case jpeg
	case gif
	case bmp
	case tiff
}

public extension CGImage
{
	// MARK: - URL style
	public func save(to url: URL) -> Bool
	{
		return self.saveTo(url: url, utiString: self.utiForImageType(.jpeg), backgroundFillColor: nil)
	}

	public func save(to url: URL, type: NYXImageType) -> Bool
	{
		return self.saveTo(url: url, utiString: self.utiForImageType(type), backgroundFillColor: nil)
	}

	public func save(to url: URL, type: NYXImageType, backgroundFillColor: UIColor) -> Bool
	{
		return self.saveTo(url: url, utiString: self.utiForImageType(type), backgroundFillColor: backgroundFillColor)
	}

	// MARK: - Paths style
	public func save(toPath path: String) -> Bool
	{
		let url = URL(fileURLWithPath: path)
		return self.saveTo(url: url, utiString: self.utiForImageType(.jpeg), backgroundFillColor: nil)
	}

	public func save(toPath path: String, type: NYXImageType) -> Bool
	{
		let url = URL(fileURLWithPath: path)
		return self.saveTo(url: url, utiString: self.utiForImageType(type), backgroundFillColor: nil)
	}

	public func save(toPath path: String, type: NYXImageType, backgroundFillColor: UIColor?) -> Bool
	{
		let url = URL(fileURLWithPath: path)
		return self.saveTo(url: url, utiString: self.utiForImageType(type), backgroundFillColor: backgroundFillColor)
	}

	// MARK: - Private
	private func saveTo(url: URL, utiString: CFString, backgroundFillColor: UIColor?) -> Bool
	{
		guard let dest = CGImageDestinationCreateWithURL(url as CFURL, utiString as CFString, 1, nil) else
		{
			return false
		}

		// Set the options, 1 -> lossless
		var options = [String : Any]()
		options[kCGImageDestinationLossyCompressionQuality as String] = 1.0
		if let bgColor = backgroundFillColor
		{
			options[kCGImageDestinationBackgroundColor as String] = bgColor
		}

		// Add the image
		CGImageDestinationAddImage(dest, self, options as CFDictionary?)

		// Write it to the destination
		return CGImageDestinationFinalize(dest)
	}

	private func utiForImageType(_ type: NYXImageType) -> CFString
	{
		var uti = kUTTypeJPEG
		switch (type)
		{
			case .bmp:
				uti = kUTTypeBMP
			case .jpeg:
				uti = kUTTypeJPEG
			case .png:
				uti = kUTTypePNG
			case .tiff:
				uti = kUTTypeTIFF
			case .gif:
				uti = kUTTypeGIF
		}
		return uti
	}
}
