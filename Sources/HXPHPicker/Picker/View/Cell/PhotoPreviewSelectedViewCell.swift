//
//  PhotoPreviewSelectedViewCell.swift
//  HXPHPickerExample
//
//  Created by Slience on 2020/12/29.
//  Copyright © 2020 Silence. All rights reserved.
//

import UIKit
import Photos
#if canImport(Kingfisher)
import Kingfisher
#endif

open class PhotoPreviewSelectedViewCell: UICollectionViewCell {
    
    public lazy var imageView: UIImageView = {
        let imageView = UIImageView.init()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    public lazy var selectedView: UIView = {
        let selectedView = UIView.init()
        selectedView.isHidden = true
        selectedView.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        selectedView.addSubview(tickView)
        return selectedView
    }()
    
    public lazy var tickView: AlbumTickView = {
        let tickView = AlbumTickView.init(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        return tickView
    }()
    
    open var tickColor: UIColor? {
        didSet {
            tickView.tickLayer.strokeColor = tickColor?.cgColor
        }
    }
    
    public var requestID: PHImageRequestID?
    
    open var photoAsset: PhotoAsset! {
        didSet {
            reqeustAssetImage()
        }
    }
    /// 获取图片，重写此方法可以修改图片
    open func reqeustAssetImage() {
        if photoAsset.isNetworkAsset ||
            photoAsset.mediaSubType == .localVideo {
            #if canImport(Kingfisher)
            imageView.setImage(for: photoAsset, urlType: .thumbnail)
            #else
            imageView.setVideoCoverImage(for: photoAsset) { [weak self] (image, photoAsset) in
                guard let self = self else { return }
                if self.photoAsset == photoAsset {
                    self.imageView.image = image
                }
            }
            #endif
        }else {
            requestID = photoAsset.requestThumbnailImage(targetWidth: width * 2, completion: { [weak self] (image, asset, info) in
                guard let self = self else { return }
                if let info = info, info.isCancel { return }
                if self.photoAsset == asset {
                    self.imageView.image = image
                }
            })
        }
    }
    
    open override var isSelected: Bool {
        didSet {
            selectedView.isHidden = !isSelected
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
        contentView.addSubview(selectedView)
    }
    
    public func cancelRequest() {
        if requestID != nil {
            PHImageManager.default().cancelImageRequest(requestID!)
            requestID = nil
        }
    }
    open override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = bounds
        selectedView.frame = bounds
        tickView.center = CGPoint(x: width * 0.5, y: height * 0.5)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
