// Pixel.swift
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


import Foundation



// MARK: - Public constants
public let numberOfComponentsPerARBGPixel = 4
public let numberOfComponentsPerRGBAPixel = 4
public let numberOfComponentsPerGrayPixel = 3
public let minPixelComponentValue = UInt8(0)
public let maxPixelComponentValue = UInt8(255)


// MARK: - RGBA Pixel struct
public struct RGBAPixel
{
	public var r: UInt8
	public var g: UInt8
	public var b: UInt8
	public var a: UInt8

	public init(r: UInt8, g: UInt8, b: UInt8, a: UInt8)
	{
		self.r = r
		self.g = g
		self.b = b
		self.a = a
	}
}

// MARK: - ARGB Pixel struct
public struct ARGBPixel
{
	public var a: UInt8
	public var r: UInt8
	public var g: UInt8
	public var b: UInt8

	public init(a: UInt8, r: UInt8, g: UInt8, b: UInt8)
	{
		self.a = a
		self.r = r
		self.g = g
		self.b = b
	}
}
