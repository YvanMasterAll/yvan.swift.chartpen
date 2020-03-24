 //
//  PenTool.swift
//  ChartPen
//
//  Created by Yiqiang Zeng on 2020/3/24.
//  Copyright © 2020 Yiqiang Zeng. All rights reserved.
//

import UIKit

/// 钢笔工具

class PenTool: Tool {
    
    required init(panel: Panel) {
        self.p = panel
    }
    
    func handle(event: Event) {
        switch event {
        case let .pan(ges):
            self.didPan(pan: ges)
        case let .tap(ges):
            self.tapOne(pan: ges)
        case let .longPress(ges):
            self.longPress(longPress: ges)
        case let .touchesBegan(point):
            self.touchesBegan(point: point)
        default:
            break
        }
    }
    
    //MARK: - 私有成员
    fileprivate var p: Panel!
    fileprivate var addingAnchor = false            // 拖动方式添加锚点
    fileprivate var operatePos: [Int] = []          // 当前操作的点位置
    fileprivate var anchorPos: [Int] = []           // 要添加的锚点位置
    fileprivate var movingAction: Action!           // 当前的移动动作
}

//MARK: - 处理事件
extension PenTool {
    
    // 点击手势
    fileprivate func tapOne(pan: UIPanGestureRecognizer) {
        // 添加路劲锚点
        if anchorPos.count > 0 {
            let curve = p.curves[anchorPos[0]]
            let point = p.anchorslist[anchorPos[0]][anchorPos[1]]
            let t = Utils.caculateT(points: curve.points, target: point.x)
            let subcurve = curve.split(at: t)
            let left = subcurve.left.points
            let right = subcurve.right.points
            
            p.nodelist.remove(at: anchorPos[0])
            p.nodelist.insert(left, at: anchorPos[0])
            p.nodelist.insert(right, at: anchorPos[0]+1)
            p.setNeedsDisplay()
            // 记录动作
            p.actions.append(Action(type: .add_path_anchor(pos: anchorPos[0], node: curve.points, left: left, right: right)))
        }
    }

    // 长按手势
    fileprivate func longPress(longPress: UILongPressGestureRecognizer) {
        let point = longPress.location(in: p)
        if longPress.state == .began
        {
            // 添加新锚点
            if p.nodelist.last != nil {
                let lastnode = p.nodelist.last!
                let lastpoint = lastnode[3]
                // 计算p1
                let x1 = lastnode[2].x
                let y1 = lastnode[2].y
                let x2 = lastpoint.x
                let y2 = lastpoint.y
                let p1 = CGPoint(x: 2*x2-x1, y: 2*y2-y1)
                let node = [lastpoint, p1, point, point]
                p.nodelist.append(node)
                p.setNeedsDisplay()
                // 记录动作
                p.actions.append(Action(type: .add_anchor(pos: p.nodelist.count-1, node: node)))
            }
        }
    }
    
    // 拖动手势
    fileprivate func didPan(pan: UIPanGestureRecognizer) {
        let point = pan.location(in: p)
        if operatePos.count > 0 { // 操作点不为空
            let currentNode = p.nodelist[operatePos[0]] // 当前操作节点
            let currentPoint = currentNode[operatePos[1]] // 当前操作点
            let corPos = [operatePos[0], Utils.getCorPos(operatePos[1])] // 点对应位置，0 -> 1，1 -> 0，2 -> 3，3 -> 2
            let corNode = p.nodelist[corPos[0]] // 对应节点
            let corPoint = corNode[corPos[1]] // 对应点
            let distance = [point.x-currentPoint.x, point.y-currentPoint.y] // 移动距离
//            let nextNode = nodelist[operatePos[0]+1]
            // 当添加第一条路径时需要额外处理
            if addingAnchor && p.nodelist.count == 1 {
                p.nodelist[operatePos[0]][2] = .init(x: point.x - 100, y: point.y)
            } else {
//                // 当操作两个路径相交的锚点时，同时移动两个锚点和相应的控制点
//                if operatePos[0] < p.nodelist.count-1
//                    && currentPoint == currentNode[3]
//                    && p.nodelist[operatePos[0]+1][0] == currentNode[3] {
//                    if p.nodelist[operatePos[0]+1][1] == p.nodelist[operatePos[0]][operatePos[1]] { // 判断要不要移动控制点
//                        p.nodelist[operatePos[0]+1][1] = point
//                    }
//                    p.nodelist[operatePos[0]][3] = point
//                    p.nodelist[operatePos[0]+1][0] = point
//                }
//                // 当控制点和锚点重叠时，两者同时移动
//                if !addingAnchor && operatePos[1] == 2 && p.nodelist[operatePos[0]][3] == p.nodelist[operatePos[0]][2] {
//                    p.nodelist[operatePos[0]][2] = point
//                    p.nodelist[operatePos[0]][3] = point
//                }
                // 当操作两个路径相交的锚点时，同时移动两个锚点和相应的控制点
                if operatePos[0] < p.nodelist.count-1
                    && currentPoint == currentNode[3]
                    && p.nodelist[operatePos[0]+1][0] == currentNode[3] {
                    p.nodelist[corPos[0]][corPos[1]] = CGPoint(x: distance[0]+corPoint.x, y: distance[1]+corPoint.y)
                    var target = p.nodelist[operatePos[0]+1][0]
                    p.nodelist[operatePos[0]+1][0] = CGPoint(x: distance[0]+target.x, y: distance[1]+target.y)
                    target = p.nodelist[operatePos[0]+1][1]
                    p.nodelist[operatePos[0]+1][1] = CGPoint(x: distance[0]+target.x, y: distance[1]+target.y)
                }
                // 如果操作的是锚点，同时移动控制点
                if operatePos[1] == 0 || operatePos[1] == 3 {
                    p.nodelist[corPos[0]][corPos[1]] = CGPoint(x: distance[0]+corPoint.x, y: distance[1]+corPoint.y)
                }
                // 当控制点和锚点重叠时，两者同时移动
                if !addingAnchor && operatePos[1] == 2 && p.nodelist[operatePos[0]][3] == p.nodelist[operatePos[0]][2] {
                    p.nodelist[operatePos[0]][2] = point
                    p.nodelist[operatePos[0]][3] = point
                }
            }
            p.nodelist[operatePos[0]][operatePos[1]] = point
            p.setNeedsDisplay()
            // 记录动作
            let target = p.nodelist[operatePos[0]]
            if movingAction == nil {
                movingAction = Action(type: .move_point(loc: operatePos, node: currentNode, target: target, withAnchor: addingAnchor))
                p.actions.append(movingAction)
            } else {
                movingAction.target = target
            }
        } else {
            // 添加新锚点，之所以添加状态是为了将长按添加锚点和拖动添加锚点进行区分
            addingAnchor = true
            if p.nodelist.last != nil {
                let lastpoints = p.nodelist.last!
                let lastpoint = lastpoints[3]
                // 计算p1
//                let x1 = lastpoints[2].x
//                let y1 = lastpoints[2].y
//                let x2 = lastpoint.x
//                let y2 = lastpoint.y
//                let p1 = CGPoint(x: 2*x2-x1, y: 2*y2-y1)
                let p1 = CGPoint(x: lastpoint.x, y: lastpoint.y)
                let node = [lastpoint, p1, point, point]
                p.nodelist.append(node)
                operatePos = [p.nodelist.count-1, 2]
                p.setNeedsDisplay()
                // 记录动作
                p.actions.append(Action(type: .add_anchor(pos: p.nodelist.count-1, node: node)))
            } else { // 添加首个锚点
                let node = [point, .init(x: point.x + 100, y: point.y), point, point]
                p.nodelist.append(node)
                operatePos = [p.nodelist.count-1, 3]
                p.setNeedsDisplay()
                // 记录动作
                p.actions.append(Action(type: .add_anchor(pos: p.nodelist.count-1, node: node)))
            }
        }
        switch pan.state {
        case .ended, .cancelled:
            if addingAnchor == true { // 释放状态
                addingAnchor = false
            }
            movingAction = nil
        default:
            break
        }
    }
    
    fileprivate func touchesBegan(point: CGPoint) {
        // 重置当前操作点
        operatePos = []
        // 遍历可操作点，判断点击位置是否坐落在操作点上
        for (i, node) in p.nodelist.enumerated() {
            for (j, cpoint) in node.enumerated() {
                let rect = CGRect.init(x: cpoint.x - 10, y: cpoint.y - 10, width: 20, height: 20)
                if rect.contains(point) { // 找到当前操作的点位置
                    operatePos = [i, j]
                    break
                }
            }
            if operatePos.count > 0 {
                break
            }
        }
        if operatePos.count == 0 { // 如果不存在操作点，判断点击位置是否坐落在锚点上
            anchorPos = []
            for (i, node) in p.anchorslist.enumerated() {
                for (j, cpoint) in node.enumerated() {
                    let rect = CGRect.init(x: cpoint.x - 10, y: cpoint.y - 10, width: 20, height: 20)
                    if rect.contains(point) { // 找到要添加的锚点位置
                        anchorPos = [i, j]
                        break
                    }
                }
                if anchorPos.count > 0 {
                    break
                }
            }
        }
        if anchorPos.count > 0 {
            print(anchorPos)
        }
    }
    
    // 切换工具时重置操作
    func reset() {
        
    }
}

