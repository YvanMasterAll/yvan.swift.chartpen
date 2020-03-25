////
////  ZoomView.swift
////  ZoomDemo
////
////  Created by nguyen.ngoc.ban on 4/1/19.
////  Copyright © 2019 nguyen.ngoc.ban. All rights reserved.
////
//import UIKit
//
///// 缩放控件
///// 待解决问题：1.视图拖动
///// let zoomView = ZoomView.init(frame: .init(x: 0, y: 0, width: 400, height: 400))
///// self.view.addSubview(zoomView)
///// zoomView.loadImage(image: UIImage(named: "0"))
//
//protocol ZoomViewDelegate: class {
//    func zoomViewDidTap(_ tap: UITapGestureRecognizer)
//}
//
//class ZoomView: UIView {
//
//    //MARK: - 声明区域
//    weak var delegate: ZoomViewDelegate?
//
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//
//        loadView()
//    }
//
//    required init?(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//
//        loadView()
//    }
//
//    override func layoutSubviews() {
//        super.layoutSubviews()
//
//        updateLayout()
//    }
//
//    //MARK: - 私有成员
//    fileprivate var scrollView: UIScrollView!
//    fileprivate var imageView: UIImageView!
//    fileprivate var url = ""
//    fileprivate var imageLoaded: UIImage?
//    fileprivate var maximumDoubleTapZoomScale: CGFloat = 0
//    fileprivate var minimumDoubleTapZoomScale: CGFloat = 0
//}
//
////MARK: - 初始化
//extension ZoomView {
//
//    fileprivate func loadView() {
//        configView()
//        addTapAction()
//        // 关闭边距调整
//        scrollView.contentInsetAdjustmentBehavior = .never
//    }
//
//    fileprivate func configView() {
//        self.backgroundColor = .clear
//        // ScrollView
//        self.scrollView = UIScrollView(frame: self.bounds)
//        self.addSubview(scrollView)
//        scrollView.boundsToSuperView()
//        scrollView.backgroundColor = .clear
//        scrollView.delegate = self
//        scrollView.delaysContentTouches = false
//        scrollView.showsHorizontalScrollIndicator = true
//        scrollView.showsVerticalScrollIndicator = true
//        scrollView.decelerationRate = UIScrollView.DecelerationRate.fast
//        scrollView.panGestureRecognizer.minimumNumberOfTouches = 2
//        // ImageView
//        self.imageView = UIImageView(frame: self.bounds)
//        self.imageView.isUserInteractionEnabled = true // true if handle tap event to image
//        imageView.backgroundColor = .clear
//        scrollView.addSubview(imageView)
//    }
//
//    fileprivate func addTapAction() {
//        // 双击手势
//        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(_:)))
//        doubleTap.numberOfTapsRequired = 2
//        self.scrollView.addGestureRecognizer(doubleTap)
//        // 单击手势
//        let singleTap = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
//        singleTap.numberOfTapsRequired = 1
//        self.scrollView.addGestureRecognizer(singleTap)
//        singleTap.require(toFail: doubleTap)
//    }
//
//    fileprivate func updateLayout() {
//        // Center the image as it becomes smaller than the size of the screen
//        let boundsSize = self.bounds.size
//        var frameToCenter = imageView.frame
//        // Horizontally
//        if frameToCenter.size.width < boundsSize.width {
//            frameToCenter.origin.x = CGFloat(floorf(Float((boundsSize.width - frameToCenter.size.width) / 2.0)))
//        } else {
//            frameToCenter.origin.x = 0
//        }
//        // Vertically
//        if frameToCenter.size.height < boundsSize.height {
//            let y = CGFloat(floorf(Float((boundsSize.height - frameToCenter.size.height) / 2.0)))
//            frameToCenter.origin.y = y
//        } else {
//            frameToCenter.origin.y = 0
//        }
//        // Center
//        if !imageView.frame.equalTo(frameToCenter) {
//            imageView.frame = frameToCenter
//        }
//    }
//}
//
////MARK: - 内容加载
//extension ZoomView {
//
//    func loadImage(image: UIImage?) {
//        self.imageLoaded = image
//        self.imageView.image = image
//        self.displayImage()
//    }
//
//    func displayImage() {
//        scrollView.maximumZoomScale = 1
//        scrollView.minimumZoomScale = 1
//        scrollView.zoomScale = 1
//        scrollView.contentSize = .zero
//
//        if let image = self.imageLoaded {
//            imageView.frame = CGRect(origin: .zero, size: image.size)
//            scrollView.contentSize = image.size
//            setMaxMinZoomScalesForCurrentBounds()
//        }
//        self.setNeedsLayout()
//    }
//
//    func setMaxMinZoomScalesForCurrentBounds() {
//        guard let image = self.imageLoaded else { return }
//        var boundsSize = self.bounds.size
//        boundsSize.width -= 0.1
//        boundsSize.height -= 0.1
//        let imageSize = image.size
//        let xScale = boundsSize.width/imageSize.width
//        let yScale = boundsSize.height/imageSize.height
//        var minScale = min(xScale, yScale)
//        minScale = minScale > 1 ? 1:minScale
//        let maxScale: CGFloat = 4.0
//        // Calculate Max Scale Of Double Tap
//        var maxDoubleTapZoomScale = 4.0*minScale
//        // Make sure maxDoubleTapZoomScale isn't larger than maxScale
//        maxDoubleTapZoomScale = min(maxDoubleTapZoomScale, maxScale)
//        // Set ScrollView Zoom Scale
//        scrollView.maximumZoomScale = maxScale
//        scrollView.minimumZoomScale = minScale
//        scrollView.zoomScale = minScale
//        self.maximumDoubleTapZoomScale = maxDoubleTapZoomScale
//        self.minimumDoubleTapZoomScale = minScale
//        // Reset position
//        imageView.frame = CGRect(origin: .zero, size: imageView.frame.size)
//
//        self.setNeedsLayout()
//    }
//}
//
////MARK: - 事件处理
//extension ZoomView {
//
//    @objc func handleTap(_ sender: UITapGestureRecognizer) {
//        delegate?.zoomViewDidTap(sender)
//    }
//
//    @objc fileprivate func handleDoubleTap(_ sender: UITapGestureRecognizer) {
//        let touchPoint = sender.location(in: imageView)
//        if scrollView.zoomScale == self.maximumDoubleTapZoomScale {
//            scrollView.setZoomScale(self.minimumDoubleTapZoomScale, animated: true)
//        } else {
//            let targetSize = CGSize(width: self.frame.width/self.maximumDoubleTapZoomScale, height: self.frame.height/self.maximumDoubleTapZoomScale)
//            let targetPoint = CGPoint(x: touchPoint.x-targetSize.width / 2, y: touchPoint.y-targetSize.height/2)
//            scrollView.zoom(to: CGRect(origin: targetPoint, size: targetSize), animated: true)
//        }
//    }
//}
//
////MARK: - UIScrollViewDelegate
//extension ZoomView: UIScrollViewDelegate {
//
//    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
//        return imageView
//    }
//
//    func scrollViewDidZoom(_ scrollView: UIScrollView) {
//        self.setNeedsLayout()
//        self.layoutIfNeeded()
//    }
//}
//
////MARK: - 实用方法
//fileprivate extension UIView {
//
//    func boundsToSuperView() {
//        if let superView = self.superview {
//            self.frame = superView.bounds
//            self.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//            self.translatesAutoresizingMaskIntoConstraints = true
//        }
//    }
//}
