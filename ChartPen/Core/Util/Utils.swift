//
//  Utils.swift
//  ChartPen
//
//  Created by Yiqiang Zeng on 2020/3/23.
//  Copyright © 2020 Yiqiang Zeng. All rights reserved.
//

import UIKit

class Utils {
    
    //MARK: - 贝塞尔曲线计算函数
    
    /// 牛顿法求解t值
    /// - Parameters:
    ///   - points: 节点
    ///   - target: 目标值，x或者y
    ///   - t: 时间值，[0, 1]
    class func NTBezierFunc(points: [CGFloat], target: CGFloat, t: CGFloat) -> CGFloat  {
        return (1.0-t)*(1.0-t)*(1.0-t)*points[0]+3*(1.0-t)*(1.0-t)*t*points[1]+3*(1.0-t)*t*t*points[2]+t*t*t*points[3]-target
    }
    
    /// 贝塞尔导数函数
    /// - Parameters:
    ///   - points: 节点
    ///   - target: 目标值，x或者y
    ///   - t: 时间值，[0, 1]
    class func DeltaNTBezierFunc(points: [CGFloat], target: CGFloat, t: CGFloat) -> CGFloat
    {
        let dt: CGFloat = 1e-8
        return (NTBezierFunc(points: points, target: target, t: t)-NTBezierFunc(points: points, target: target, t: t-dt))/dt
    }
    
    /// 已知x求y
    /// - Parameters:
    ///   - points: 节点
    ///   - target: 目标值，x或者y
    class func caculateT(points: [CGPoint], target: CGFloat) -> CGFloat {
        let x: [CGFloat] = points.map { $0.x }
        let _: [CGFloat] = points.map { $0.y }
        var t: CGFloat=0.5 // 设置t的初值
        for _ in 0..<1000 {
            t=t-NTBezierFunc(points: x, target: target, t: t)/DeltaNTBezierFunc(points: x, target: target, t: t )
            if NTBezierFunc(points: x, target: target, t: t) <= 1e-5 {
                break
            }
        }
//        // 用求出的t来算出对应的y值
//        print(NTBezierFunc(ps: y, targ: 0, t: t))
        
        return t
    }
    
    // 1 -> 0, 0 -> 1, 2 -> 3, 3 -> 2
    class func getCorPos(_ pos: Int) -> Int {
        if pos == 2 {
            return 3
        } else {
            return Int(abs(1-pos))
        }
    }
}
