//
//  UndoTool.swift
//  ChartPen
//
//  Created by Yiqiang Zeng on 2020/3/24.
//  Copyright © 2020 Yiqiang Zeng. All rights reserved.
//

import UIKit

/// 选中工具

class UndoTool: Tool {
    
    required init(panel: Panel) {
        self.p = panel
    }
    
    func handle(event: Event) {
        switch event {
        case .undo:
            self.undo()
        default:
            break
        }
    }
   
    //MARK: - 私有成员
    fileprivate var p: Panel!
}

//MARK: - 事件处理
extension UndoTool {
    
    // 撤销
    func undo() {
        guard let action = p.actions.last else { return }
        switch action.type {
        case let .add_anchor(pos, _): // 删除锚点
            p.nodelist.remove(at: pos)
            p.setNeedsDisplay()
            p.actions.removeLast()
        case let .add_path_anchor(pos, node, _, _): // 删除路径锚点
            p.nodelist.remove(at: pos)
            p.nodelist.remove(at: pos)
            p.nodelist.append(node)
            p.setNeedsDisplay()
            p.actions.removeLast()
        case let .move_point(loc, node, _, withAnchor): // 回撤移动
            let operatePos = loc
            if withAnchor { // 如果是添加锚点的时候移动路径，直接删除锚点
                p.nodelist.remove(at: operatePos[0])
            } else {
                let point = node[operatePos[1]]
                let currentNode = action.target // 当前操作节点
                let currentPoint = currentNode[operatePos[1]] // 当前操作点
                let corPos = [operatePos[0], Utils.getCorPos(operatePos[1])] // 点对应位置，0 -> 1，1 -> 0，2 -> 3，3 -> 2
                let corNode = p.nodelist[corPos[0]] // 对应节点
                let corPoint = corNode[corPos[1]] // 对应点
                let distance = [point.x-currentPoint.x, point.y-currentPoint.y] // 移动距离
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
                if operatePos[1] == 2 && p.nodelist[operatePos[0]][3] == p.nodelist[operatePos[0]][2] {
                    p.nodelist[operatePos[0]][2] = point
                    p.nodelist[operatePos[0]][3] = point
                }
                p.nodelist[operatePos[0]][operatePos[1]] = point
                p.actions.removeLast()
                // 如果只剩下初始节点，删除
                if p.actions.count == 1 {
                    p.nodelist.removeAll()
                    p.actions.removeAll()
                }
            }
            p.setNeedsDisplay()
        default:
            break
        }
    }
    
    // 切换工具时重置操作
    func reset() {
        
    }
}
