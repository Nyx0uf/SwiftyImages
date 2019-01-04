// NYXProgressiveImageView.swift
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
import ImageIO


public protocol NYXProgressiveImageViewDelegate : class
{
	func imageDidLoadWithImage(image: UIImage)
	func imageDownloadCompletedWithImage(image: UIImage)
	func imageDownloadFailedWithData(data: Data?)
}

public class NYXProgressiveImageView : UIImageView
{
	// MARK: - Public properties
	// Delegate
	public weak var delegate: NYXProgressiveImageViewDelegate? = nil
	// Downloading flag
	public fileprivate(set) var isDownloading: Bool = false
	// Enable / Disable caching
	public var isCaching: Bool = false
	// Timeout
	public var timeoutInterval: TimeInterval = 10.0

	// MARK: - Private properties
	// Download queue
	private var _queue: DispatchQueue! = nil
	// Image to download URL
	fileprivate var _url: URL! = nil
	// Downloaded data
	fileprivate var _incomingData: Data! = nil
	// Task
	private var _sessionTask: URLSessionTask?
	// Session configuration
	private var _localURLSessionConfiguration: URLSessionConfiguration {
		let cfg = URLSessionConfiguration.default
		cfg.httpShouldUsePipelining = true
		return cfg
	}
	// Session
	private var _localURLSession: Foundation.URLSession {
		return Foundation.URLSession(configuration:_localURLSessionConfiguration, delegate:self, delegateQueue:nil)
	}
	// Image source for progressive display
	fileprivate var _imageSource: CGImageSource! = nil
	// Width of the downloaded image
	fileprivate var _imageWidth: Int = -1
	// Height of the downloaded image
	fileprivate var _imageHeight: Int = -1
	// Expected image size
	fileprivate var _expectedSize: Int64 = 0
	// Image orientation
    fileprivate var _imageOrientation: UIImage.Orientation = .up

	// MARK: - Initializers
	override public init(frame: CGRect)
	{
		super.init(frame: frame)

		self._queue = DispatchQueue(label:"io.whine.pdliv.queue", qos:.default, attributes:[], autoreleaseFrequency:.inherit, target: nil)
	}

	override public init(image: UIImage?)
	{
		super.init(image: image)

		self._queue = DispatchQueue(label:"io.whine.pdliv.queue", qos:.default, attributes:[], autoreleaseFrequency:.inherit, target: nil)
	}

	override public init(image: UIImage?, highlightedImage: UIImage?)
	{
		super.init(image: image, highlightedImage: highlightedImage)

		self._queue = DispatchQueue(label:"io.whine.pdliv.queue", qos:.default, attributes:[], autoreleaseFrequency:.inherit, target: nil)
	}
	
	required public init?(coder aDecoder: NSCoder)
	{
		super.init(coder: aDecoder)

		self._queue = DispatchQueue(label:"io.whine.pdliv.queue", qos:.default, attributes:[], autoreleaseFrequency:.inherit, target: nil)
	}

	// MARK: - Public
	public func loadImage(atUrl url: URL)
	{
		if isDownloading
		{
			return
		}

		_url = url

		if isCaching
		{
			// check if file exists on cache
			if let cachesDirectoryURL = NYXProgressiveImageView.cachesDirectoryURL(),
				let cachedImageName = cachedImageName()
			{
				let cachedImageURL = cachesDirectoryURL.appendingPathComponent(cachedImageName)

				if FileManager.default.fileExists(atPath: cachedImageURL.path)
				{
					if let localImage = UIImage(contentsOfFile: cachedImageURL.path)
					{
						DispatchQueue.main.async {
							self.image = localImage
							self.delegate?.imageDidLoadWithImage(image: localImage)
						}
						return
					}
					else
					{
						resetCache()
					}
				}
			}
		}

		_queue.async {
			var request = URLRequest(url: self._url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: self.timeoutInterval)
			request.addValue("image/*", forHTTPHeaderField: "Accept")

			self._sessionTask = self._localURLSession.dataTask(with: request)
			self._sessionTask!.resume()
		}
	}

	// MARK: - Private
	fileprivate func cachedImageName() -> String?
	{
		return _url != nil ? _url.absoluteString.base64Encoded().lowercased() : nil
	}

	fileprivate func resetCache()
	{
		guard let cachesDirectoryURL = NYXProgressiveImageView.cachesDirectoryURL() else {return}
		guard let imageName = cachedImageName() else {return}
		try! FileManager.default.removeItem(at: cachesDirectoryURL.appendingPathComponent(imageName))
	}

	fileprivate func createTransitoryImage(fromPartialImage image: CGImage) -> CGImage?
	{
		guard let bmContext = CGContext.ARGBBitmapContext(width: _imageWidth, height: _imageHeight, withAlpha: image.hasAlpha()) else {return nil}

		let partialHeight = image.height
		bmContext.draw(image, in: CGRect(0, 0, _imageWidth, partialHeight))
		return bmContext.makeImage()
	}
}

// MARK: - NSURLSessionDelegate
extension NYXProgressiveImageView : URLSessionDelegate
{
	func URLSession(_ session: Foundation.URLSession, dataTask: URLSessionDataTask, didReceiveResponse response: URLResponse, completionHandler: (Foundation.URLSession.ResponseDisposition) -> Void)
	{
		isDownloading = true
		_imageSource = CGImageSourceCreateIncremental(nil)
		_imageWidth = -1
		_imageHeight = -1
		_expectedSize = response.expectedContentLength
		_incomingData = Data()

		completionHandler(.allow)
	}

	func URLSession(_ session: Foundation.URLSession, dataTask: URLSessionDataTask, didReceiveData data: Data)
	{
		_incomingData.append(data)

		let len = Int64(_incomingData.count)
		CGImageSourceUpdateData(_imageSource, _incomingData as CFData, (len == _expectedSize) ? true : false)

		if _imageHeight > 0 && _imageWidth > 0
		{
			guard let cgImage = CGImageSourceCreateImageAtIndex(_imageSource, 0, nil) else {return}

			if let imgTmp = self.createTransitoryImage(fromPartialImage: cgImage)
			{
				let img = UIImage(cgImage: imgTmp, scale: 1.0, orientation: _imageOrientation)
				DispatchQueue.main.async {
					self.image = img
				}
			}
		}
		else
		{
			if let dic = CGImageSourceCopyPropertiesAtIndex(_imageSource, 0, nil) as NSDictionary?,
				dic.count > 0
			{
				if let heightPtr = dic[kCGImagePropertyPixelHeight] as! NSNumber?
				{
					_imageHeight = heightPtr.intValue
				}

				if let widthPtr = dic[kCGImagePropertyPixelWidth] as! NSNumber?
				{
					_imageWidth = widthPtr.intValue
				}

				if let orientPtr = dic[kCGImagePropertyOrientation] as! NSNumber?
				{
					_imageOrientation = exifOrientationToUIImageOrientation(orientPtr.intValue)
				}
				else
				{
					_imageOrientation = .up
				}
			}
		}
	}

	func URLSession(_ session: Foundation.URLSession, task: URLSessionTask, didCompleteWithError error: NSError?)
	{
		if error == nil && _incomingData != nil && _incomingData.count > 0
		{
			guard let img = UIImage(data: _incomingData) else {return}

			DispatchQueue.main.async {
				self.delegate?.imageDownloadCompletedWithImage(image: img)
				self.image = img
				self.delegate?.imageDidLoadWithImage(image: img)
			}

			if isCaching
			{
				if let cachesDirectoryURL = NYXProgressiveImageView.cachesDirectoryURL(),
					let cachedImageName = cachedImageName()
				{
					if FileManager.default.fileExists(atPath: cachesDirectoryURL.path) == false
					{
						try! FileManager.default.createDirectory(at: cachesDirectoryURL, withIntermediateDirectories: false, attributes: nil)
						let path = cachesDirectoryURL.appendingPathComponent(cachedImageName)
						try! _incomingData.write(to: path, options: .atomicWrite)
					}
				}
			}
		}
		else
		{
			DispatchQueue.main.async {
				self.delegate?.imageDownloadFailedWithData(data: self._incomingData)
			}
		}

		isDownloading = false
		_imageSource = nil
		_incomingData = nil
		_url = nil
	}
}

// MARK: - Static
public extension NYXProgressiveImageView
{
	public class func cachesDirectoryURL() -> URL?
	{
		guard let cachesDirectoryURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).last else {return nil}
		return cachesDirectoryURL.appendingPathComponent("ProgressiveImageViewCache", isDirectory: true)
	}

	public class func resetCache()
	{
		if let url = NYXProgressiveImageView.cachesDirectoryURL()
		{
			try! FileManager.default.removeItem(at: url)
		}
	}
}
