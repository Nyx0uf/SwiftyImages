// UIImage+Saving.swift
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
	// MARK: - URL style
	public func save(to url: URL) -> Bool
	{
		guard let ret = self.cgImage?.save(to: url) else
		{
			return false
		}
		return ret
	}

	public func save(to url: URL, type: NYXImageType) -> Bool
	{
		guard let ret = self.cgImage?.save(to: url, type: type) else
		{
			return false
		}
		return ret
	}

	public func save(to url: URL, type: NYXImageType, backgroundFillColor: UIColor) -> Bool
	{
		guard let ret = self.cgImage?.save(to: url, type: type, backgroundFillColor: backgroundFillColor) else
		{
			return false
		}
		return ret
	}

	// MARK: - Paths style
	public func save(toPath path: String) -> Bool
	{
		guard let ret = self.cgImage?.save(toPath: path) else
		{
			return false
		}
		return ret
	}

	public func save(toPath path: String, type: NYXImageType) -> Bool
	{
		guard let ret = self.cgImage?.save(toPath: path, type: type) else
		{
			return false
		}
		return ret
	}

	public func save(toPath path: String, type: NYXImageType, backgroundFillColor: UIColor?) -> Bool
	{
		guard let ret = self.cgImage?.save(toPath: path, type: type, backgroundFillColor: backgroundFillColor) else
		{
			return false
		}
		return ret
	}
}
