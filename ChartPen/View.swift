//
//  View.swift
//  ChartPen
//
//  Created by Yiqiang Zeng on 2020/3/22.
//  Copyright © 2020 Yiqiang Zeng. All rights reserved.
//

import UIKit
import BezierKit

class View: UIView {
    
    var pointslist: [[CGPoint]] = [[CGPoint(x: 100, y: 125), CGPoint(x: 150, y: 90), CGPoint(x: 410, y: 120), CGPoint(x: 450, y: 195)]]
    
    var anchorslist: [[CGPoint]] = []
    
    var curves: [CubicCurve] = []
    var needDraw_pointslist: [[CGPoint]] = []
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
//        DispatchQueue.main.asyncAfter(
//                   deadline: DispatchTime.now() + Double(Int64(2*Double(NSEC_PER_SEC)))/Double(NSEC_PER_SEC), execute: {
//                       print("hello")
//                    self.curve.p3 = CGPoint(x: 0, y: 100)
//                    self.setNeedsDisplay()
//               }
//            )
        
        
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
       // MARK: 拖动手势
       let pan = UIPanGestureRecognizer(target: self, action: #selector(self.didPan(pan:)))
       pan.maximumNumberOfTouches = 1
       self.addGestureRecognizer(pan)
       
       
       // MARK: 长按手势
       let longPress = UILongPressGestureRecognizer(target: self, action: #selector(self.longPress(longPress:)))
       self.addGestureRecognizer(longPress)

       
       // MARK: 点击手势
       // 单击
       let tapOne = UITapGestureRecognizer(target: self, action: #selector(self.tapOne))
       self.addGestureRecognizer(tapOne)
       
       // 双击
       let tapDouble = UITapGestureRecognizer(target: self, action: #selector(self.tapDouble))
       tapDouble.numberOfTapsRequired = 2
       self.addGestureRecognizer(tapDouble)
       
       // 声明单击事件需要双击事件检测失败后才会执行
       tapOne.require(toFail: tapDouble)
       
       
       // MARK: 滑动手势
       // 上滑
       let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(self.swipeGesture(swipe:)))
       swipeUp.direction = .up
       self.addGestureRecognizer(swipeUp)
       
       // 下滑
       let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(self.swipeGesture(swipe:)))
       swipeDown.direction = .down
       self.addGestureRecognizer(swipeDown)
       
       // 左滑
       let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.swipeGesture(swipe:)))
       swipeLeft.direction = .left
       self.addGestureRecognizer(swipeLeft)
       
       // 右滑
       let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(self.swipeGesture(swipe:)))
       swipeRight.direction = .right
       self.addGestureRecognizer(swipeRight)
       
       
       // MARK: 捏合手势
       let pinch = UIPinchGestureRecognizer(target: self, action: #selector(self.didPinch(pinch:)))
       self.addGestureRecognizer(pinch)
       
       
       // MARK: 旋转手势
       let rotation = UIRotationGestureRecognizer(target: self, action: #selector(self.didRotation(rotation:)))
       self.addGestureRecognizer(rotation)
        
    }

    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        var curve: CubicCurve!
        curves.removeAll()
        
//        if needDraw_pointslist.count > 0 {
//            for points in needDraw_pointslist {
//                curve = CubicCurve(
//                   p0: points[0],
//                   p1: points[1],
//                   p2: points[2],
//                   p3: points[3]
//                )
//
//                curves.append(curve)
//                Draw.drawSkeleton(context, curve: curve)  // draws visual representation of curve control points
//                Draw.drawCurve(context, curve: curve)     // draws the curve itself
//            }
//        } else {
//
//        }
        for points in pointslist {
            curve = CubicCurve(
               p0: points[0],
               p1: points[1],
               p2: points[2],
               p3: points[3]
            )
            
            curves.append(curve)
            Draw.drawSkeleton(context, curve: curve)  // draws visual representation of curve control points
            Draw.drawCurve(context, curve: curve)     // draws the curve itself
        }
//        needDraw_pointslist.removeAll()
        anchorslist.removeAll()
        for points in pointslist {
            let path = BezierPath()
            path.move(to: points[0])
            path.addCurve(to: points[3], controlPoint1: points[1], controlPoint2: points[2])
            path.generateLookupTable()
            anchorslist.append(path.lookupTable)
            print(path.lookupTable.count)
        }
        // 获取贝塞尔曲线d坐标点
//        let points = pointslist[0]
//        let path = BezierPath()
//        path.move(to: points[0])
//        path.addCurve(to: points[3], controlPoint1: points[1], controlPoint2: points[2])
////        let pathLayer = CAShapeLayer()
////        pathLayer.path = path.cgPath
////        pathLayer.strokeColor = UIColor.green.cgColor
////        pathLayer.lineWidth = 2.0
////        pathLayer.fillColor = UIColor.clear.cgColor
////        self.layer.addSublayer(pathLayer)
//        path.generateLookupTable()
//        print(path.lookupTable[20])
//        print(path.lookupTable.count)
////        for point in path.lookupTable {
////            drawDot(onLayer: pathLayer, atPoint: point)
////        }
//
    }
    
    func NTBezierFunc(ps: [CGFloat], targ: CGFloat, t: CGFloat) -> CGFloat  //targ为目标值
    {
        return (1.0-t) * (1.0-t) * (1.0-t) * ps[0] + 3 * (1.0-t) * (1.0-t) * t * ps[1] + 3 * (1.0-t) * t * t * ps[2] + t * t * t * ps[3] - targ
    }
     
    func DeltaNTBezierFunc(ps: [CGFloat], targ: CGFloat, t: CGFloat) -> CGFloat      //导数函数，如果你数学好的话自己求导一下吧~~
    {
        let dt: CGFloat = 1e-8
        return (NTBezierFunc(ps: ps,targ: targ,t: t)-NTBezierFunc(ps: ps,targ: targ,t:t-dt))/dt
    }
     
     
    func caculateT(points: [CGPoint], targ: CGFloat) -> CGFloat
    {
        let x: [CGFloat] = points.map { $0.x }
        let y: [CGFloat] = points.map { $0.y }
        //假设已知x为70
//        let targ: CGFloat = 400
     
        var t: CGFloat=0.5 //设置t的初值
        for i in 0..<1000 {
            t=t-NTBezierFunc(ps: x, targ: targ, t: t)/DeltaNTBezierFunc(ps: x, targ: targ, t: t )
            if NTBezierFunc(ps: x, targ: targ, t: t) <= 1e-5 {
                break
            }
        }
//        print(t)
        //用求出的t来算出对应的y值
//        print(NTBezierFunc(ps: y, targ: 0, t: t))
        
        return t
    }
//    func caculateT(points: [CGPoint])
//    {
//        let x: [Double] = [100,150,410,450]
//        let y: [Double] = [125,90,120,195]
//        //假设已知x为70
//        let targ: Double = 400
//
//        var t: Double=0.5 //设置t的初值
//        for i in 0..<1000 {
//            t=t-NTBezierFunc(ps: x, targ: targ, t: t)/DeltaNTBezierFunc(ps: x, targ: targ, t: t )
//            if NTBezierFunc(ps: x, targ: targ, t: t) <= 1e-5 {
//                break
//            }
//        }
//        print(t)
//        //用求出的t来算出对应的y值
//        print(NTBezierFunc(ps: y, targ: 0, t: t))
//    }
    
    @discardableResult
    private func drawDot(onLayer parentLayer: CALayer, atPoint point: CGPoint) -> CAShapeLayer {
        let layer = CAShapeLayer()
        let width: CGFloat = 4.0
        let path = UIBezierPath(ovalIn: CGRect(origin: CGPoint(x: point.x - width * 0.5, y: point.y - width * 0.5), size: CGSize(width: width, height: width)))
        layer.path = path.cgPath
        layer.lineWidth = 1.0
        layer.strokeColor = UIColor.magenta.withAlphaComponent(0.65).cgColor
        layer.fillColor = UIColor.clear.cgColor
        parentLayer.addSublayer(layer)
        return layer
    }
    
    @objc func didRotation(rotation: UIRotationGestureRecognizer)
    {
        print("旋转的角度:\(rotation.rotation*(180/(CGFloat(Double.pi))))")
//        imageView.transform = CGAffineTransform(rotationAngle: rotation.rotation)
    }
    
    @objc func didPinch(pinch: UIPinchGestureRecognizer)
    {
        print("捏合比例:\(pinch.scale)")
        print("捏合速度:\(pinch.velocity)")
        
//        imageView.transform = CGAffineTransform(scaleX: pinch.scale, y: pinch.scale)
    }
    
    @objc func swipeGesture(swipe: UISwipeGestureRecognizer)
    {
        switch swipe.direction
        {
        case UISwipeGestureRecognizer.Direction.up:
            print("向上滑动")
        case UISwipeGestureRecognizer.Direction.down:
            print("向下滑动")
        case UISwipeGestureRecognizer.Direction.left:
            print("向左滑动")
        case UISwipeGestureRecognizer.Direction.right:
            print("向右滑动")
        default:
            print("不明滑动")
        }
    }
    
    @objc func tapOne(pan: UIPanGestureRecognizer)
    {
//        print(pan.location(in: self))
//        let point = pan.location(in: self)
        print("单击")
//        // 添加新的Point
////        let points: [CGPoint] = [CGPoint(x: 100, y: 25), CGPoint(x: 10, y: 90), CGPoint(x: 110, y: 100), CGPoint(x: 150, y: 195)]
//        let lastpoints = pointslist.last!
//        let lastpoint = lastpoints[3]
//        // 计算p1
//        let x1 = lastpoints[2].x
//        let y1 = lastpoints[2].y
//        let x2 = lastpoint.x
//        let y2 = lastpoint.y
//        let p1 = CGPoint(x: 2*x2-x1, y: 2*y2-y1)
//        let points = [lastpoint, p1, point, point]
//        pointslist.append(points)
//        self.setNeedsDisplay()
        
        // 添加路劲锚点
        if anchorPoint.count > 0 {
            let curve = curves[anchorPoint[0]]
            let t = caculateT(points: curve.points, targ: anchorslist[anchorPoint[0]][anchorPoint[1]].x)
            let subcurve = curve.split(at: t) // or try (leftCurve, rightCurve) = curve.split(at:)
            let left = subcurve.left.points
            let right = subcurve.right.points
            
            pointslist.remove(at: anchorPoint[0])
            pointslist.insert(left, at: anchorPoint[0])
            pointslist.insert(right, at: anchorPoint[0]+1)
            self.setNeedsDisplay()
        }

    }
    
    @objc func tapDouble()
    {
        print("双击")
    }
    
    @objc func longPress(longPress: UILongPressGestureRecognizer)
    {
        let point = longPress.location(in: self)
        if longPress.state == .began
        {
            print("长按开始")
            // 添加新锚点
            let lastpoints = pointslist.last!
            let lastpoint = lastpoints[3]
            // 计算p1
            let x1 = lastpoints[2].x
            let y1 = lastpoints[2].y
            let x2 = lastpoint.x
            let y2 = lastpoint.y
            let p1 = CGPoint(x: 2*x2-x1, y: 2*y2-y1)
            let points = [lastpoint, p1, point, point]
            pointslist.append(points)
            self.setNeedsDisplay()
        }
        else
        {
            print("长按结束")
        }
    }
    
    var drag: Bool = false
    var isTouched: Bool = false
    var currentPoint: [Int] = []
    var anchorPoint: [Int] = []
    var addCubic: Bool = false
    
    @objc func didPan(pan: UIPanGestureRecognizer)
    {
        let point = pan.location(in: self)
        if currentPoint.count > 0 {
            print(point)
            if currentPoint.count > 0 {
                if currentPoint[0] < pointslist.count-1 && pointslist[currentPoint[0]][3] == pointslist[currentPoint[0]+1][0] {
                    if currentPoint[1] == 3 || currentPoint[1] == 2 {
                        print("hello222")
                        pointslist[currentPoint[0]+1][0] = point
                    }
                }
                if !addCubic && pointslist[currentPoint[0]][3] == pointslist[currentPoint[0]][2] {
                    pointslist[currentPoint[0]][2] = point
                    pointslist[currentPoint[0]][3] = point
                }
//                if pointslist[currentPoint[0]][3] == pointslist[currentPoint[0]][2] {
//                    pointslist[currentPoint[0]][2] = point
//                    pointslist[currentPoint[0]][3] = point
//                }
//                if pointslist[currentPoint[0]][0] == pointslist[currentPoint[0]][1] {
//                    pointslist[currentPoint[0]][0] = point
//                    pointslist[currentPoint[0]][1] = point
//                }
                pointslist[currentPoint[0]][currentPoint[1]] = point
//                needDraw_pointslist.append(pointslist[currentPoint[0]])
                self.setNeedsDisplay()
            }
        } else {
            // 添加新锚点
            addCubic = true
            let lastpoints = pointslist.last!
            let lastpoint = lastpoints[3]
            // 计算p1
            let x1 = lastpoints[2].x
            let y1 = lastpoints[2].y
            let x2 = lastpoint.x
            let y2 = lastpoint.y
            let p1 = CGPoint(x: 2*x2-x1, y: 2*y2-y1)
            let points = [lastpoint, p1, point, point]
            pointslist.append(points)
            currentPoint = [pointslist.count-1, 2]
            self.setNeedsDisplay()
        }
        switch pan.state {
        case .ended, .cancelled:
            addCubic = false
        default:
            break
        }
        
//        imageView.center = point
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        if touches.count == 1 {
            currentPoint = []
            let point = touches.first!.location(in: self)
            for (i, points) in pointslist.enumerated() {
                for (j, cpoint) in points.enumerated() {
                    let rect = CGRect.init(x: cpoint.x - 10, y: cpoint.y - 10, width: 20, height: 20)
                    if rect.contains(point) {
                        currentPoint = [i, j]
                        break
                    }
                }
                if currentPoint.count > 0 {
                    break
                }
            }
            if currentPoint.count == 0 {
                anchorPoint = []
                for (i, points) in anchorslist.enumerated() {
                    for (j, cpoint) in points.enumerated() {
                        let rect = CGRect.init(x: cpoint.x - 10, y: cpoint.y - 10, width: 20, height: 20)
                        if rect.contains(point) {
                            anchorPoint = [i, j]
                            break
                        }
                    }
                    if anchorPoint.count > 0 {
                        break
                    }
                }
            }
            if anchorPoint.count > 0 {
                print(anchorPoint)
            }
//            let cpoint = pointslist[0][0]
//            let rect = CGRect.init(x: cpoint.x - 100, y: cpoint.y - 100, width: 200, height: 200)
//            if rect.contains(point) {
//                pointslist[0][0] = point
//            }
//
//            self.setNeedsDisplay()
        }
        isTouched = true
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        isTouched = false
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        isTouched = false
    }
}
