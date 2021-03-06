//
//  Panel.swift
//  ChartPen
//
//  Created by Yiqiang Zeng on 2020/3/22.
//  Copyright © 2020 Yiqiang Zeng. All rights reserved.
//

import UIKit
import BezierKit

/// 绘图面板

class Panel: UIView {
    
    //MARK: - 声明区域
    var curves: [CubicCurve] = []       // 曲线
    var nodelist: [[CGPoint]] = []      // 曲线节点，每个节点包含两个锚点和控制点
    var anchorslist: [[CGPoint]] = []   // 路径锚点，可以成为锚点的点集
    var actions: [Action] = []          // 动作
    var isTouched: Bool = false
    var isLandscape: Bool = false       // 横竖屏
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setupUI()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    //MARK: - 私有成员
    fileprivate var labl_coordinates = UILabel()    // 坐标文本
    fileprivate var currentTool: Tool!              // 当前工具
    fileprivate var v_degree_lv = UIView()          // 垂直刻度线
    fileprivate var v_degree_lh = UIView()          // 水平刻度线
    fileprivate var density = 10                    // 刻度密度
}

//MARK: - 初始化
extension Panel {
    
    fileprivate func setupUI() {
        // 坐标文本
        self.addSubview(labl_coordinates)
        labl_coordinates.font = UIFont.preferredFont(forTextStyle: .subheadline)
        labl_coordinates.textColor = UIColor.black.withAlphaComponent(0.2)
        labl_coordinates.isHidden = true
        // 刻度线
        self.addSubview(self.v_degree_lh)
        v_degree_lh.frame = .init(x: 0, y: 0, width: self.frame.width, height: 1)
        v_degree_lh.backgroundColor = UIColor.black.withAlphaComponent(0.1)
        v_degree_lh.isHidden = true
        self.addSubview(self.v_degree_lv)
        v_degree_lv.frame = .init(x: 0, y: 0, width: 1, height: self.frame.height)
        v_degree_lv.backgroundColor = UIColor.black.withAlphaComponent(0.1)
        v_degree_lv.isHidden = true
        // 添加手势
        setupGesture()
        // 添加横竖屏监听
        NotificationCenter.default.addObserver(self, selector: #selector(handleOrientationChange), name: UIDevice.orientationDidChangeNotification, object: nil)
    }
    
    fileprivate func setupGesture() {
        // 拖动手势
        let pan = UIPanGestureRecognizer(target: self, action: #selector(self.didPan(pan:)))
        pan.maximumNumberOfTouches = 1
        self.addGestureRecognizer(pan)
        // 长按手势
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(self.longPress(longPress:)))
        self.addGestureRecognizer(longPress)
        // 单击手势
        let tapOne = UITapGestureRecognizer(target: self, action: #selector(self.tapOne))
        self.addGestureRecognizer(tapOne)
        // 双击手势
        let tapDouble = UITapGestureRecognizer(target: self, action: #selector(self.tapDouble))
        tapDouble.numberOfTapsRequired = 2
        self.addGestureRecognizer(tapDouble)
        // 声明单击事件需要双击事件检测失败后才会执行
        tapOne.require(toFail: tapDouble)
        // 上滑手势
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(self.swipeGesture(swipe:)))
        swipeUp.direction = .up
        self.addGestureRecognizer(swipeUp)
        // 下滑手势
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(self.swipeGesture(swipe:)))
        swipeDown.direction = .down
        self.addGestureRecognizer(swipeDown)
        // 左滑手势
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.swipeGesture(swipe:)))
        swipeLeft.direction = .left
        self.addGestureRecognizer(swipeLeft)
        // 右滑手势
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(self.swipeGesture(swipe:)))
        swipeRight.direction = .right
        self.addGestureRecognizer(swipeRight)
        // 捏合手势
        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(self.didPinch(pinch:)))
        self.addGestureRecognizer(pinch)
        // 旋转手势
        let rotation = UIRotationGestureRecognizer(target: self, action: #selector(self.didRotation(rotation:)))
        self.addGestureRecognizer(rotation)
    }
}

//MARK: - 绘制逻辑
extension Panel {

    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        // 清空曲线
        curves.removeAll()
        // 绘制曲线
        var curve: CubicCurve!
        for node in nodelist {
            curve = CubicCurve(
               p0: node[0],
               p1: node[1],
               p2: node[2],
               p3: node[3]
            )
            curves.append(curve)
            Draw.drawSkeleton(context, curve: curve)  // draws visual representation of curve control points
            Draw.drawCurve(context, curve: curve)     // draws the curve itself
        }
        // 清空路径锚点
        anchorslist.removeAll()
        // 计算路径锚点
        for node in nodelist {
            let path = BezierPath()
            path.move(to: node[0])
            path.addCurve(to: node[3], controlPoint1: node[1], controlPoint2: node[2])
            path.generateLookupTable()
            anchorslist.append(path.lookupTable)
        }
        drawDegree(context: context)
    }
    
    fileprivate func drawDegree(context: CGContext) {
        // 绘制刻度
        let dl: CGFloat = 10 // 刻度长度
        let h1: CGFloat = isLandscape ? self.frame.width-CGFloat(toolbar_height):self.frame.height
        let w1: CGFloat = isLandscape ? self.frame.height+CGFloat(toolbar_height):self.frame.width
        var x1: CGFloat = 0
        let y1: CGFloat = h1
        context.beginPath()
        while x1 < w1 {
            x1 += CGFloat(density)
            if Int(x1)%(5*density) == 0 {
                context.setStrokeColor(UIColor.black.cgColor)
                context.move(to: CGPoint(x: x1, y: y1))
                context.addLine(to: CGPoint(x: x1, y: y1-dl))
                let paragraphStyle = NSParagraphStyle()
                let attrs: [NSAttributedString.Key : Any] = [
                    .paragraphStyle: paragraphStyle,
                    .font: UIFont.systemFont(ofSize: 12.0),
                    .foregroundColor: UIColor.black.withAlphaComponent(0.5)
                ]
                let string = "\(Int(x1/5))"
                string.draw(with: CGRect(x: x1-8, y: y1-dl-14, width: 40, height: 20), options: .usesLineFragmentOrigin, attributes: attrs, context: nil)
            } else {
                context.setStrokeColor(UIColor.black.cgColor)
                context.move(to: CGPoint(x: x1, y: y1))
                context.addLine(to: CGPoint(x: x1, y: y1-dl/2))
            }
        }
        let x2: CGFloat = 0
        var y2: CGFloat = h1
        while y2 > 0 {
            y2 -= CGFloat(density)
            if Int(h1 - y2)%(5*density) == 0 {
                context.setStrokeColor(UIColor.black.cgColor)
                context.move(to: CGPoint(x: x2, y: y2))
                context.addLine(to: CGPoint(x: x2+dl, y: y2))
                let paragraphStyle = NSParagraphStyle()
                let attrs: [NSAttributedString.Key : Any] = [
                    .paragraphStyle: paragraphStyle,
                    .font: UIFont.systemFont(ofSize: 12.0),
                    .foregroundColor: UIColor.black.withAlphaComponent(0.5)
                ]
                let string = "\(Int(h1 - y2)/5)"
                string.draw(with: CGRect(x: x2+dl+4, y: y2-8, width: 40, height: 20), options: .usesLineFragmentOrigin, attributes: attrs, context: nil)
            } else {
                context.setStrokeColor(UIColor.black.cgColor)
                context.move(to: CGPoint(x: x2, y: y2))
                context.addLine(to: CGPoint(x: x2+dl/2, y: y2))
            }
        }
        context.strokePath()
    }
}

//MARK: - 手势
extension Panel {

    // 捏合手势
    @objc func didPinch(pinch: UIPinchGestureRecognizer) {
        print("捏合比例:\(pinch.scale)")
        print("捏合速度:\(pinch.velocity)")
        
//        imageView.transform = CGAffineTransform(scaleX: pinch.scale, y: pinch.scale)
        currentTool.handle(event: .pinch(ges: pinch))
    }
    
    // 滑动手势
    @objc func swipeGesture(swipe: UISwipeGestureRecognizer) {
        switch swipe.direction
        {
        case UISwipeGestureRecognizer.Direction.up:
            print("向上滑动")
            currentTool.handle(event: .swipeUp(ges: swipe))
        case UISwipeGestureRecognizer.Direction.down:
            print("向下滑动")
            currentTool.handle(event: .swipeDown(ges: swipe))
        case UISwipeGestureRecognizer.Direction.left:
            print("向左滑动")
            currentTool.handle(event: .swipeLeft(ges: swipe))
        case UISwipeGestureRecognizer.Direction.right:
            print("向右滑动")
            currentTool.handle(event: .swipeRight(ges: swipe))
        default:
            print("不明滑动")
        }
    }
    
    // 点击手势
    @objc func tapOne(pan: UIPanGestureRecognizer) {
        currentTool.handle(event: .tap(ges: pan))
    }
    
    // 双击手势
    @objc func tapDouble() {
        print("双击")
        currentTool.handle(event: .doubleTap)
    }
    
    // 长按手势
    @objc func longPress(longPress: UILongPressGestureRecognizer) {
        currentTool.handle(event: .longPress(ges: longPress))
    }
    
    // 旋转手势
    @objc func didRotation(rotation: UIRotationGestureRecognizer) {
        print("旋转的角度: \(rotation.rotation*(180/(CGFloat(Double.pi))))")
//        imageView.transform = CGAffineTransform(rotationAngle: rotation.rotation)
        currentTool.handle(event: .rotation(res: rotation))
    }
    
    // 拖动手势
    @objc func didPan(pan: UIPanGestureRecognizer) {
        let point = pan.location(in: self)
        switch pan.state {
        case .began, .changed:
            // 更新坐标
            self.showDegreeLine(point)
        case .cancelled, .ended, .failed:
            self.hideDegreeLine()
        default:
            break
        }
        currentTool.handle(event: .pan(ges: pan))
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        if touches.count == 1 { // 单点触控
            let point = touches.first!.location(in: self)
            currentTool.handle(event: .touchesBegan(point: point))
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

//MARK: - 事件处理
extension Panel {
    
    fileprivate func showDegreeLine(_ point: CGPoint) {
        self.labl_coordinates.isHidden = false
        self.v_degree_lh.isHidden = false
        self.v_degree_lv.isHidden = false
        v_degree_lh.frame.origin.y = point.y
        v_degree_lh.frame.size.width = self.frame.width
        v_degree_lv.frame.origin.x = point.x
        v_degree_lv.frame.size.height = self.frame.height
        self.labl_coordinates.text = "\(Int(point.x/5))，\(Int((self.frame.height-point.y)/5))"
        self.labl_coordinates.frame.origin = point
        self.labl_coordinates.sizeToFit()
    }
    
    fileprivate func hideDegreeLine() {
        self.labl_coordinates.isHidden = true
        self.v_degree_lh.isHidden = true
        self.v_degree_lv.isHidden = true
    }
    
    @objc private func handleOrientationChange(notification: Notification) {
        // 获取设备方向
        let statusBarOrientation = UIApplication.shared.statusBarOrientation
        if statusBarOrientation.isPortrait {
            isLandscape = false
        } else if statusBarOrientation.isLandscape {
            isLandscape = true
        }
        self.setNeedsDisplay()
    }
}

//MARK: - ToolBarDelegate
extension Panel: ToolBarDelegate {
    
    func item_click(toolItem: ToolItem) {
        print("选中了: " + toolItem.type.value)
        switch toolItem.type {
        case .delete: // 清空绘图
            self.nodelist.removeAll()
            self.actions.removeAll()
            self.setNeedsDisplay()
        case .submit: // 提交数据
            break
        case .undo: // 撤销
            toolItem.tool.handle(event: .undo)
        case .select:
            if currentTool != nil { // 更新工具
                self.currentTool.reset()
            }
            self.currentTool = toolItem.tool
            self.isUserInteractionEnabled = false
        default:
            if currentTool != nil { // 更新工具
                self.currentTool.reset()
            }
            self.currentTool = toolItem.tool
            self.isUserInteractionEnabled = true
        }
    }
}

