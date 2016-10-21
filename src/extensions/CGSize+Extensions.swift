// CGSize+Extensions.swift
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


public extension CGSize
{
	// MARK: - Initializers
	public init(_ width: CGFloat, _ height: CGFloat)
	{
		self.width = width
		self.height = height
	}

	public init(_ width: Int, _ height: Int)
	{
		self.width = CGFloat(width)
		self.height = CGFloat(height)
	}

	public func ceilled() -> CGSize
	{
		return CGSize(CoreGraphics.ceil(width), CoreGraphics.ceil(height))
	}

	public func floored() -> CGSize
	{
		return CGSize(CoreGraphics.floor(width), CoreGraphics.floor(height))
	}

	public func rounded() -> CGSize
	{
		return CGSize(CoreGraphics.round(width), CoreGraphics.round(height))
	}
}

public func * (lhs: CGSize, rhs: CGFloat) -> CGSize
{
	return CGSize(lhs.width * rhs, lhs.height * rhs)
}
