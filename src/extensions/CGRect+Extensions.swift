// CGRect+Extensions.swift
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


public extension CGRect
{
	// MARK: - Initializers
	public init(_ origin: CGPoint, _ size: CGSize)
	{
		self.origin = origin
		self.size = size
	}

	public init(_ x: CGFloat, _ y: CGFloat, _ width: CGFloat, _ height: CGFloat)
	{
		self.origin = CGPoint(x, y)
		self.size = CGSize(width, height)
	}

	public init(_ x: CGFloat, _ y: CGFloat, _ size: CGSize)
	{
		self.origin = CGPoint(x, y)
		self.size = size
	}

	public init(_ origin: CGPoint, _ width: CGFloat, _ height: CGFloat)
	{
		self.origin = origin
		self.size = CGSize(width, height)
	}

	// MARK: - Shortcuts
	public var x: CGFloat
	{
		get {return origin.x}
		set {origin.x = newValue}
	}

	public var y: CGFloat
	{
		get {return origin.y}
		set {origin.y = newValue}
	}

	public var centerX: CGFloat
	{
		get {return x + width * 0.5}
		set {x = newValue - width * 0.5}
	}

	public var centerY: CGFloat
	{
		get {return y + height * 0.5}
		set {y = newValue - height * 0.5}
	}

	// MARK: - Edges
	public var left: CGFloat
	{
		get {return self.origin.x}
		set {origin.x = newValue}
	}

	public var right: CGFloat
	{
		get {return x + width}
		set {x = newValue - width}
	}

	public var top: CGFloat
	{
		get {return y}
		set {y = newValue}
	}

	public var bottom: CGFloat
	{
		get {return y + height}
		set {y = newValue - height}
	}

	// MARK: - Points
	public var topLeft: CGPoint
	{
		get {return CGPoint(x:left, y:top)}
		set {left = newValue.x; top = newValue.y}
	}

	public var topCenter: CGPoint
	{
		get {return CGPoint(x:centerX, y:top)}
		set {centerX = newValue.x; top = newValue.y}
	}

	public var topRight: CGPoint
	{
		get {return CGPoint(x:right, y:top)}
		set {right = newValue.x; top = newValue.y}
	}

	public var centerLeft: CGPoint
	{
		get {return CGPoint(x:left, y:centerY)}
		set {left = newValue.x; centerY = newValue.y}
	}

	public var center: CGPoint
	{
		get {return CGPoint(x:centerX, y:centerY)}
		set {centerX = newValue.x; centerY = newValue.y}
	}

	public var centerRight: CGPoint
	{
		get {return CGPoint(x:right, y:centerY)}
		set {right = newValue.x; centerY = newValue.y}
	}

	public var bottomLeft: CGPoint
	{
		get {return CGPoint(x:left, y:bottom)}
		set {left = newValue.x; bottom = newValue.y}
	}

	public var bottomCenter: CGPoint
	{
		get {return CGPoint(x:centerX, y:bottom)}
		set {centerX = newValue.x; bottom = newValue.y}
	}

	public var bottomRight: CGPoint
	{
		get {return CGPoint(x:right, y:bottom)}
		set {right = newValue.x; bottom = newValue.y}
	}
}
