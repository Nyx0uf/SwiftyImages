// UIImage+Filtering.swift
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
import Accelerate


// MARK: - Edge detect kernel
fileprivate let __s_edgedetect_kernel_3x3: [Int16] = [
	-1, -1, -1,
	-1, 8, -1,
	-1, -1, -1
]

// MARK: - Emboss kernel
fileprivate let __s_emboss_kernel_3x3: [Int16] = [
	-2, 0, 0,
	0, 1, 0,
	0, 0, 2
]

// MARK: - Sharpen kernel
fileprivate let __s_sharpen_kernel_3x3: [Int16] = [
	-1, -1, -1,
	-1, 9, -1,
	-1, -1, -1
]

// MARK: - Unsharpen kernel
fileprivate let __s_unsharpen_kernel_3x3: [Int16] = [
	-1, -1, -1,
	-1, 17, -1,
	-1, -1, -1
]

// MARK: - Sepia values for manual filtering
fileprivate var __sepiaFactorRedRed: Float = 0.393
fileprivate var __sepiaFactorRedGreen: Float = 0.349
fileprivate var __sepiaFactorRedBlue: Float = 0.272
fileprivate var __sepiaFactorGreenRed: Float = 0.769
fileprivate var __sepiaFactorGreenGreen: Float = 0.686
fileprivate var __sepiaFactorGreenBlue: Float = 0.534
fileprivate var __sepiaFactorBlueRed: Float = 0.189
fileprivate var __sepiaFactorBlueGreen: Float = 0.168
fileprivate var __sepiaFactorBlueBlue: Float = 0.131

// MARK: -  Negative multiplier to invert a number
fileprivate var __negativeMultiplier: Float = -1.0


public extension UIImage
{
	public func alphaed(value: CGFloat) -> UIImage?
	{
		guard let cgImage = self.cgImage else
		{
			return nil
		}

		// Create an ARGB bitmap context
		let width = Int(self.size.width)
		let height = Int(self.size.height)
		guard let bmContext = CGContext.ARGBBitmapContext(width: width, height: height, withAlpha: true) else
		{
			return nil
		}

		// Set the alpha value and draw the image in the bitmap context
		bmContext.setAlpha(value)
		bmContext.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))

		guard let transparentImageRef = bmContext.makeImage() else
		{
			return nil
		}

		return UIImage(cgImage: transparentImageRef, scale: self.scale, orientation: self.imageOrientation)
	}

	// Value should be in the range (-255, 255)
	public func brightened(value: Float) -> UIImage?
	{
		guard let cgImage = self.cgImage else
		{
			return nil
		}

		// Create an ARGB bitmap context
		let width = Int(self.size.width)
		let height = Int(self.size.height)
		guard let bmContext = CGContext.ARGBBitmapContext(width: width, height: height, withAlpha: cgImage.hasAlpha()) else
		{
			return nil
		}

		// Get image data
		bmContext.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
		guard let data = bmContext.data else
		{
			return nil
		}

		let pixelsCount = UInt(width * height)
		let pixelsCountInt = Int(pixelsCount)
		let dataAsFloat = UnsafeMutablePointer<Float>.allocate(capacity: pixelsCountInt)
		var min = Float(minPixelComponentValue), max = Float(maxPixelComponentValue)

		// Calculate red components
		var v = value
		let t: UnsafeMutablePointer<UInt8> = data.assumingMemoryBound(to: UInt8.self)
		vDSP_vfltu8(t + 1, 4, dataAsFloat, 1, pixelsCount)
		vDSP_vsadd(dataAsFloat, 1, &v, dataAsFloat, 1, pixelsCount)
		vDSP_vclip(dataAsFloat, 1, &min, &max, dataAsFloat, 1, pixelsCount)
		vDSP_vfixu8(dataAsFloat, 1, t + 1, 4, pixelsCount)

		// Calculate green components
		vDSP_vfltu8(t + 2, 4, dataAsFloat, 1, pixelsCount)
		vDSP_vsadd(dataAsFloat, 1, &v, dataAsFloat, 1, pixelsCount)
		vDSP_vclip(dataAsFloat, 1, &min, &max, dataAsFloat, 1, pixelsCount)
		vDSP_vfixu8(dataAsFloat, 1, t + 2, 4, pixelsCount)

		// Calculate blue components
		vDSP_vfltu8(t + 3, 4, dataAsFloat, 1, pixelsCount)
		vDSP_vsadd(dataAsFloat, 1, &v, dataAsFloat, 1, pixelsCount)
		vDSP_vclip(dataAsFloat, 1, &min, &max, dataAsFloat, 1, pixelsCount)
		vDSP_vfixu8(dataAsFloat, 1, t + 3, 4, pixelsCount)

		// Cleanup
		dataAsFloat.deallocate(capacity: pixelsCountInt)

		guard let brightenedImageRef = bmContext.makeImage() else
		{
			return nil
		}

		return UIImage(cgImage: brightenedImageRef, scale: self.scale, orientation: self.imageOrientation)
	}

	/// (-255, 255)
	public func contrasted(value: Float) -> UIImage?
	{
		guard let cgImage = self.cgImage else
		{
			return nil
		}

		// Create an ARGB bitmap context
		let width = Int(self.size.width)
		let height = Int(self.size.height)
		guard let bmContext = CGContext.ARGBBitmapContext(width: width, height: height, withAlpha: cgImage.hasAlpha()) else
		{
			return nil
		}

		// Get image data
		bmContext.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
		guard let data = bmContext.data else
		{
			return nil
		}

		let pixelsCount = UInt(width * height)
		let pixelsCountInt = Int(pixelsCount)
		let dataAsFloat = UnsafeMutablePointer<Float>.allocate(capacity: pixelsCountInt)
		var min = Float(minPixelComponentValue), max = Float(maxPixelComponentValue)

		// Contrast correction factor
		var factor = (259.0 * (value + 255.0)) / (255.0 * (259.0 - value))
		var v1 = Float(-128.0), v2 = Float(128.0)

		// Calculate red components
		let t: UnsafeMutablePointer<UInt8> = data.assumingMemoryBound(to: UInt8.self)
		vDSP_vfltu8(t + 1, 4, dataAsFloat, 1, pixelsCount)
		vDSP_vsadd(dataAsFloat, 1, &v1, dataAsFloat, 1, pixelsCount)
		vDSP_vsmul(dataAsFloat, 1, &factor, dataAsFloat, 1, pixelsCount)
		vDSP_vsadd(dataAsFloat, 1, &v2, dataAsFloat, 1, pixelsCount)
		vDSP_vclip(dataAsFloat, 1, &min, &max, dataAsFloat, 1, pixelsCount)
		vDSP_vfixu8(dataAsFloat, 1, t + 1, 4, pixelsCount)

		// Calculate green components
		vDSP_vfltu8(t + 2, 4, dataAsFloat, 1, pixelsCount)
		vDSP_vsadd(dataAsFloat, 1, &v1, dataAsFloat, 1, pixelsCount)
		vDSP_vsmul(dataAsFloat, 1, &factor, dataAsFloat, 1, pixelsCount)
		vDSP_vsadd(dataAsFloat, 1, &v2, dataAsFloat, 1, pixelsCount)
		vDSP_vclip(dataAsFloat, 1, &min, &max, dataAsFloat, 1, pixelsCount)
		vDSP_vfixu8(dataAsFloat, 1, t + 2, 4, pixelsCount)

		// Calculate blue components
		vDSP_vfltu8(t + 3, 4, dataAsFloat, 1, pixelsCount)
		vDSP_vsadd(dataAsFloat, 1, &v1, dataAsFloat, 1, pixelsCount)
		vDSP_vsmul(dataAsFloat, 1, &factor, dataAsFloat, 1, pixelsCount)
		vDSP_vsadd(dataAsFloat, 1, &v2, dataAsFloat, 1, pixelsCount)
		vDSP_vclip(dataAsFloat, 1, &min, &max, dataAsFloat, 1, pixelsCount)
		vDSP_vfixu8(dataAsFloat, 1, t + 3, 4, pixelsCount)

		// Cleanup
		dataAsFloat.deallocate(capacity: pixelsCountInt)

		guard let contrastedImageRef = bmContext.makeImage() else
		{
			return nil
		}

		return UIImage(cgImage: contrastedImageRef, scale: self.scale, orientation: self.imageOrientation)
	}

	public func edgeDetected(_ bias: Int32 = 0) -> UIImage?
	{
		guard let cgImage = self.cgImage else
		{
			return nil
		}

		// Create an ARGB bitmap context
		let width = Int(self.size.width)
		let height = Int(self.size.height)
		guard let bmContext = CGContext.ARGBBitmapContext(width: width, height: height, withAlpha: cgImage.hasAlpha()) else
		{
			return nil
		}

		// Get image data
		bmContext.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
		guard let data = bmContext.data else
		{
			return nil
		}

		let size = width * height * numberOfComponentsPerARBGPixel
		let bufferOut = UnsafeMutablePointer<UInt8>.allocate(capacity: size)
		let bytesPerRow = width * numberOfComponentsPerARBGPixel
		var src = vImage_Buffer(data: data, height: vImagePixelCount(height), width: vImagePixelCount(width), rowBytes: bytesPerRow)
		var dst = vImage_Buffer(data: bufferOut, height: vImagePixelCount(height), width: vImagePixelCount(width), rowBytes: bytesPerRow)
		vImageConvolveWithBias_ARGB8888(&src, &dst, nil, 0, 0, __s_edgedetect_kernel_3x3, 3, 3, 1, bias, nil, vImage_Flags(kvImageCopyInPlace))

		// Cleanup
		memcpy(data, bufferOut, size)
		bufferOut.deallocate(capacity: size)

		guard let edgedImageRef = bmContext.makeImage() else
		{
			return nil
		}

		return UIImage(cgImage: edgedImageRef, scale: self.scale, orientation: self.imageOrientation)
	}

	public func embossed(_ bias: Int32 = 0) -> UIImage?
	{
		guard let cgImage = self.cgImage else
		{
			return nil
		}

		// Create an ARGB bitmap context
		let width = Int(self.size.width)
		let height = Int(self.size.height)
		guard let bmContext = CGContext.ARGBBitmapContext(width: width, height: height, withAlpha: cgImage.hasAlpha()) else
		{
			return nil
		}

		// Get image data
		bmContext.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
		guard let data = bmContext.data else
		{
			return nil
		}

		let size = width * height * numberOfComponentsPerARBGPixel
		let bufferOut = UnsafeMutablePointer<UInt8>.allocate(capacity: size)
		let bytesPerRow = width * numberOfComponentsPerARBGPixel
		var src = vImage_Buffer(data: data, height: vImagePixelCount(height), width: vImagePixelCount(width), rowBytes: bytesPerRow)
		var dst = vImage_Buffer(data: bufferOut, height: vImagePixelCount(height), width: vImagePixelCount(width), rowBytes: bytesPerRow)
		vImageConvolveWithBias_ARGB8888(&src, &dst, nil, 0, 0, __s_emboss_kernel_3x3, 3, 3, 1/*divisor*/, bias, nil, vImage_Flags(kvImageCopyInPlace))

		// Cleanup
		memcpy(data, bufferOut, size)
		bufferOut.deallocate(capacity: size)

		guard let embossImageRef = bmContext.makeImage() else
		{
			return nil
		}

		return UIImage(cgImage: embossImageRef, scale: self.scale, orientation: self.imageOrientation)
	}

	/// (0.01, 8)
	public func gammaCorrected(value: Float) -> UIImage?
	{
		guard let cgImage = self.cgImage else
		{
			return nil
		}

		// Create an ARGB bitmap context
		let width = Int(self.size.width)
		let height = Int(self.size.height)
		guard let bmContext = CGContext.ARGBBitmapContext(width: width, height: height, withAlpha: cgImage.hasAlpha()) else
		{
			return nil
		}

		// Get image data
		bmContext.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
		guard let data = bmContext.data else
		{
			return nil
		}

		let pixelsCount = UInt(width * height)
		let pixelsCountInt = Int(pixelsCount)
		let dataAsFloat = UnsafeMutablePointer<Float>.allocate(capacity: pixelsCountInt)
		let temp = UnsafeMutablePointer<Float>.allocate(capacity: pixelsCountInt)
		var min = Float(minPixelComponentValue), max = Float(maxPixelComponentValue)

		// Need a vector with same size :(
		var v = value
		vDSP_vfill(&v, temp, 1, pixelsCount)

		// Calculate red components
		let t: UnsafeMutablePointer<UInt8> = data.assumingMemoryBound(to: UInt8.self)
		var bla = Int32(pixelsCount)
		vDSP_vfltu8(t + 1, 4, dataAsFloat, 1, pixelsCount)
		vDSP_vsdiv(dataAsFloat, 1, &max, dataAsFloat, 1, pixelsCount)
		vvpowf(dataAsFloat, temp, dataAsFloat, &bla)
		vDSP_vsmul(dataAsFloat, 1, &max, dataAsFloat, 1, pixelsCount)
		vDSP_vclip(dataAsFloat, 1, &min, &max, dataAsFloat, 1, pixelsCount)
		vDSP_vfixu8(dataAsFloat, 1, t + 1, 4, pixelsCount)

		// Calculate green components
		vDSP_vfltu8(t + 2, 4, dataAsFloat, 1, pixelsCount)
		vDSP_vsdiv(dataAsFloat, 1, &max, dataAsFloat, 1, pixelsCount)
		vvpowf(dataAsFloat, temp, dataAsFloat, &bla)
		vDSP_vsmul(dataAsFloat, 1, &max, dataAsFloat, 1, pixelsCount)
		vDSP_vclip(dataAsFloat, 1, &min, &max, dataAsFloat, 1, pixelsCount)
		vDSP_vfixu8(dataAsFloat, 1, t + 2, 4, pixelsCount)

		// Calculate blue components
		vDSP_vfltu8(t + 3, 4, dataAsFloat, 1, pixelsCount)
		vDSP_vsdiv(dataAsFloat, 1, &max, dataAsFloat, 1, pixelsCount)
		vvpowf(dataAsFloat, temp, dataAsFloat, &bla)
		vDSP_vsmul(dataAsFloat, 1, &max, dataAsFloat, 1, pixelsCount)
		vDSP_vclip(dataAsFloat, 1, &min, &max, dataAsFloat, 1, pixelsCount)
		vDSP_vfixu8(dataAsFloat, 1, t + 3, 4, pixelsCount)

		// Cleanup
		temp.deallocate(capacity: pixelsCountInt)
		dataAsFloat.deallocate(capacity: pixelsCountInt)

		guard let gammaImageRef = bmContext.makeImage() else
		{
			return nil
		}

		return UIImage(cgImage: gammaImageRef, scale: self.scale, orientation: self.imageOrientation)
	}

	public func grayscaled() -> UIImage?
	{
		guard let cgImage = self.cgImage else
		{
			return nil
		}

		// Create an ARGB bitmap context
		let width = Int(self.size.width)
		let height = Int(self.size.height)

		guard let bmContext = CGContext.GrayBitmapContext(width: width, height: height) else
		{
			return nil
		}

		// Image quality
		bmContext.setShouldAntialias(false)
		bmContext.interpolationQuality = .high

		// Draw the image in the bitmap context
		let imageRect = CGRect(x: 0, y: 0, width: width, height: height)
		bmContext.draw(cgImage, in: imageRect)

		// Create an image object from the context
		guard let grayscaledImageRef = bmContext.makeImage() else
		{
			return nil
		}

		// Preserve alpha channel by creating context with 'alpha only' values
		// and using it as a mask for previously generated `grayscaledImageRef`
		// based on: http://incurlybraces.com/convert-transparent-image-to-grayscale-in-ios.html
		guard let bmContext2 = CGContext(data: nil, width: width, height: height, bitsPerComponent: 8, bytesPerRow: 0, space: cgImage.colorSpace!, bitmapInfo: CGImageAlphaInfo.alphaOnly.rawValue) else
		{
			return nil
		}
		bmContext2.draw(cgImage, in: imageRect)
		guard let mask = bmContext2.makeImage() else
		{
			return nil
		}
		guard let final = grayscaledImageRef.masking(mask) else
		{
			return nil
		}

		return UIImage(cgImage:final , scale: self.scale, orientation: self.imageOrientation)
	}

	public func inverted() -> UIImage?
	{
		guard let cgImage = self.cgImage else
		{
			return nil
		}

		// Create an ARGB bitmap context
		let width = Int(self.size.width)
		let height = Int(self.size.height)
		guard let bmContext = CGContext.ARGBBitmapContext(width: width, height: height, withAlpha: cgImage.hasAlpha()) else
		{
			return nil
		}

		// Get image data
		bmContext.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
		guard let data = bmContext.data else
		{
			return nil
		}

		let pixelsCount = UInt(width * height)
		let pixelsCountInt = Int(pixelsCount)
		let dataAsFloat = UnsafeMutablePointer<Float>.allocate(capacity: pixelsCountInt)
		var min = Float(minPixelComponentValue), max = Float(maxPixelComponentValue)

		let t: UnsafeMutablePointer<UInt8> = data.assumingMemoryBound(to: UInt8.self)
		let dataRed = t + 1
		let dataGreen = t + 2
		let dataBlue = t + 3

		// Calculate red components
		vDSP_vfltu8(dataRed, 4, dataAsFloat, 1, pixelsCount)
		vDSP_vsmsa(dataAsFloat, 1, &__negativeMultiplier, &max, dataAsFloat, 1, pixelsCount)
		vDSP_vclip(dataAsFloat, 1, &min, &max, dataAsFloat, 1, pixelsCount)
		vDSP_vfixu8(dataAsFloat, 1, dataRed, 4, pixelsCount)

		// Calculate green components
		vDSP_vfltu8(dataGreen, 4, dataAsFloat, 1, pixelsCount)
		vDSP_vsmsa(dataAsFloat, 1, &__negativeMultiplier, &max, dataAsFloat, 1, pixelsCount)
		vDSP_vclip(dataAsFloat, 1, &min, &max, dataAsFloat, 1, pixelsCount)
		vDSP_vfixu8(dataAsFloat, 1, dataGreen, 4, pixelsCount)

		// Calculate blue components
		vDSP_vfltu8(dataBlue, 4, dataAsFloat, 1, pixelsCount)
		vDSP_vsmsa(dataAsFloat, 1, &__negativeMultiplier, &max, dataAsFloat, 1, pixelsCount)
		vDSP_vclip(dataAsFloat, 1, &min, &max, dataAsFloat, 1, pixelsCount)
		vDSP_vfixu8(dataAsFloat, 1, dataBlue, 4, pixelsCount)

		// Cleanup
		dataAsFloat.deallocate(capacity: pixelsCountInt)

		guard let invertedImageRef = bmContext.makeImage() else
		{
			return nil
		}

		return UIImage(cgImage: invertedImageRef, scale: self.scale, orientation: self.imageOrientation)
	}

	public func sepiaed() -> UIImage?
	{
		guard let cgImage = self.cgImage else
		{
			return nil
		}

		// Create an ARGB bitmap context
		let width = Int(self.size.width)
		let height = Int(self.size.height)
		guard let bmContext = CGContext.ARGBBitmapContext(width: width, height: height, withAlpha: cgImage.hasAlpha()) else
		{
			return nil
		}

		// Get image data
		bmContext.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
		guard let data = bmContext.data else
		{
			return nil
		}

		let pixelsCount = UInt(width * height)
		let pixelsCountInt = Int(pixelsCount)
		let reds = UnsafeMutablePointer<Float>.allocate(capacity: pixelsCountInt)
		let greens = UnsafeMutablePointer<Float>.allocate(capacity: pixelsCountInt)
		let blues = UnsafeMutablePointer<Float>.allocate(capacity: pixelsCountInt)
		let tmpRed = UnsafeMutablePointer<Float>.allocate(capacity: pixelsCountInt)
		let tmpGreen = UnsafeMutablePointer<Float>.allocate(capacity: pixelsCountInt)
		let tmpBlue = UnsafeMutablePointer<Float>.allocate(capacity: pixelsCountInt)
		let finalRed = UnsafeMutablePointer<Float>.allocate(capacity: pixelsCountInt)
		let finalGreen = UnsafeMutablePointer<Float>.allocate(capacity: pixelsCountInt)
		let finalBlue = UnsafeMutablePointer<Float>.allocate(capacity: pixelsCountInt)
		var min = Float(minPixelComponentValue), max = Float(maxPixelComponentValue)

		// Convert byte components to float
		let t: UnsafeMutablePointer<UInt8> = data.assumingMemoryBound(to: UInt8.self)
		vDSP_vfltu8(t + 1, 4, reds, 1, pixelsCount)
		vDSP_vfltu8(t + 2, 4, greens, 1, pixelsCount)
		vDSP_vfltu8(t + 3, 4, blues, 1, pixelsCount)

		// Calculate red components
		vDSP_vsmul(reds, 1, &__sepiaFactorRedRed, tmpRed, 1, pixelsCount)
		vDSP_vsmul(greens, 1, &__sepiaFactorGreenRed, tmpGreen, 1, pixelsCount)
		vDSP_vsmul(blues, 1, &__sepiaFactorBlueRed, tmpBlue, 1, pixelsCount)
		vDSP_vadd(tmpRed, 1, tmpGreen, 1, finalRed, 1, pixelsCount)
		vDSP_vadd(finalRed, 1, tmpBlue, 1, finalRed, 1, pixelsCount)
		vDSP_vclip(finalRed, 1, &min, &max, finalRed, 1, pixelsCount)
		vDSP_vfixu8(finalRed, 1, t + 1, 4, pixelsCount)

		// Calculate green components
		vDSP_vsmul(reds, 1, &__sepiaFactorRedGreen, tmpRed, 1, pixelsCount)
		vDSP_vsmul(greens, 1, &__sepiaFactorGreenGreen, tmpGreen, 1, pixelsCount)
		vDSP_vsmul(blues, 1, &__sepiaFactorBlueGreen, tmpBlue, 1, pixelsCount)
		vDSP_vadd(tmpRed, 1, tmpGreen, 1, finalGreen, 1, pixelsCount)
		vDSP_vadd(finalGreen, 1, tmpBlue, 1, finalGreen, 1, pixelsCount)
		vDSP_vclip(finalGreen, 1, &min, &max, finalGreen, 1, pixelsCount)
		vDSP_vfixu8(finalGreen, 1, t + 2, 4, pixelsCount)

		// Calculate blue components
		vDSP_vsmul(reds, 1, &__sepiaFactorRedBlue, tmpRed, 1, pixelsCount)
		vDSP_vsmul(greens, 1, &__sepiaFactorGreenBlue, tmpGreen, 1, pixelsCount)
		vDSP_vsmul(blues, 1, &__sepiaFactorBlueBlue, tmpBlue, 1, pixelsCount)
		vDSP_vadd(tmpRed, 1, tmpGreen, 1, finalBlue, 1, pixelsCount)
		vDSP_vadd(finalBlue, 1, tmpBlue, 1, finalBlue, 1, pixelsCount)
		vDSP_vclip(finalBlue, 1, &min, &max, finalBlue, 1, pixelsCount)
		vDSP_vfixu8(finalBlue, 1, t + 3, 4, pixelsCount)

		// Cleanup
		reds.deallocate(capacity: pixelsCountInt)
		greens.deallocate(capacity: pixelsCountInt)
		blues.deallocate(capacity: pixelsCountInt)
		tmpRed.deallocate(capacity: pixelsCountInt)
		tmpGreen.deallocate(capacity: pixelsCountInt)
		tmpBlue.deallocate(capacity: pixelsCountInt)
		finalRed.deallocate(capacity: pixelsCountInt)
		finalGreen.deallocate(capacity: pixelsCountInt)
		finalBlue.deallocate(capacity: pixelsCountInt)

		guard let sepiaImageRef = bmContext.makeImage() else
		{
			return nil
		}

		return UIImage(cgImage: sepiaImageRef, scale: self.scale, orientation: self.imageOrientation)
	}

	public func sharpened(_ bias: Int32 = 0) -> UIImage?
	{
		guard let cgImage = self.cgImage else
		{
			return nil
		}

		// Create an ARGB bitmap context
		let width = Int(self.size.width)
		let height = Int(self.size.height)
		guard let bmContext = CGContext.ARGBBitmapContext(width: width, height: height, withAlpha: cgImage.hasAlpha()) else
		{
			return nil
		}

		// Get image data
		bmContext.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
		guard let data = bmContext.data else
		{
			return nil
		}

		let size = width * height * numberOfComponentsPerARBGPixel
		let bufferOut = UnsafeMutablePointer<UInt8>.allocate(capacity: size)
		let bytesPerRow = width * numberOfComponentsPerARBGPixel
		var src = vImage_Buffer(data: data, height: vImagePixelCount(height), width: vImagePixelCount(width), rowBytes: bytesPerRow)
		var dst = vImage_Buffer(data: bufferOut, height: vImagePixelCount(height), width: vImagePixelCount(width), rowBytes: bytesPerRow)
		vImageConvolveWithBias_ARGB8888(&src, &dst, nil, 0, 0, __s_sharpen_kernel_3x3, 3, 3, 1/*divisor*/, bias, nil, vImage_Flags(kvImageCopyInPlace))

		// Cleanup
		memcpy(data, bufferOut, size)
		bufferOut.deallocate(capacity: size)

		guard let sharpenedImageRef = bmContext.makeImage() else
		{
			return nil
		}

		return UIImage(cgImage: sharpenedImageRef, scale: self.scale, orientation: self.imageOrientation)
	}

	public func unsharpened(_ bias: Int32 = 0) -> UIImage?
	{
		guard let cgImage = self.cgImage else
		{
			return nil
		}

		// Create an ARGB bitmap context
		let width = Int(self.size.width)
		let height = Int(self.size.height)
		guard let bmContext = CGContext.ARGBBitmapContext(width: width, height: height, withAlpha: cgImage.hasAlpha()) else
		{
			return nil
		}

		// Get image data
		bmContext.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
		guard let data = bmContext.data else
		{
			return nil
		}

		let size = width * height * numberOfComponentsPerARBGPixel
		let bufferOut = UnsafeMutablePointer<UInt8>.allocate(capacity: size)
		let bytesPerRow = width * numberOfComponentsPerARBGPixel
		var src = vImage_Buffer(data: data, height: vImagePixelCount(height), width: vImagePixelCount(width), rowBytes: bytesPerRow)
		var dst = vImage_Buffer(data: bufferOut, height: vImagePixelCount(height), width: vImagePixelCount(width), rowBytes: bytesPerRow)
		vImageConvolveWithBias_ARGB8888(&src, &dst, nil, 0, 0, __s_unsharpen_kernel_3x3, 3, 3, 1/*divisor*/, bias, nil, vImage_Flags(kvImageCopyInPlace))

		// Cleanup
		memcpy(data, bufferOut, size)
		bufferOut.deallocate(capacity: size)

		guard let unsharpenedImageRef = bmContext.makeImage() else
		{
			return nil
		}

		return UIImage(cgImage: unsharpenedImageRef, scale: self.scale, orientation: self.imageOrientation)
	}
}
