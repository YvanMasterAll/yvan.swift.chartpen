//
//  ToolBar.swift
//  ChartPen
//
//  Created by Yiqiang Zeng on 2020/3/23.
//  Copyright © 2020 Yiqiang Zeng. All rights reserved.
//

import UIKit

/// 工具栏

protocol ToolBarDelegate {
    func item_click(toolItem: ToolItem) // 选项点击事件
}

class ToolBar: UIView {
    
    //MARK: - 声明区域
    var tools = [
        ["type": "pen", "icon": "pen"],
        ["type": "select", "icon": "select"],
        ["type": "undo", "icon": "undo"],
        ["type": "submit", "icon": "submit"],
        ["type": "delete", "icon": "delete"]
    ]
    var delegate: ToolBarDelegate?
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setupUI()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    //MARK: - 私有成员
    fileprivate var v_content = UIView()
    fileprivate var v_split = UIView()
    fileprivate var selectType: ToolType = .empty
    fileprivate var toolitems: [ToolItem] = []
}

//MARK: - 初始化
extension ToolBar {
    
    fileprivate func setupUI() {
        self.backgroundColor = .white
        // 分割线
        self.addSubview(v_split)
        v_split.backgroundColor = UIColor.darkGray.withAlphaComponent(0.2)
        v_split.snp.makeConstraints { make in
            make.height.equalTo(1)
            make.top.equalTo(self)
            make.left.equalTo(self)
            make.right.equalTo(self)
        }
        self.addSubview(v_content)
        v_content.snp.makeConstraints { make in
            make.centerX.equalTo(self.snp.centerX)
            make.width.equalTo(self.tools.count*toolitem_width)
            make.top.equalTo(self).offset(1)
            make.bottom.equalTo(self)
        }
    }
    
    func setupTools(panel: Panel) {
        // 添加工具选项
        for (index, tool) in tools.enumerated() {
            let item = ToolItem()
            item.setupLayout(tool: tool, panel: panel)
            v_content.addSubview(item)
            toolitems.append(item)
            item.snp.makeConstraints { make in
                make.width.equalTo(toolitem_width)
                make.left.equalTo(toolitem_width*index)
                make.top.equalTo(v_content)
                make.bottom.equalTo(v_content)
            }
            item.isUserInteractionEnabled = true
            item.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onItemClick)))
        }
        // 默认选中钢笔工具
        let toolItem = toolitems.filter{ $0.type == .pen }[0]
        toolItem.toggle()
        self.delegate?.item_click(toolItem: toolItem)
    }
}

//MARK: - 事件处理
extension ToolBar {
    
    @objc fileprivate func onItemClick(tap: UITapGestureRecognizer) {
        let target = tap.view as! ToolItem
        // 切换选项
        if selectType != target.type {
            selectType = target.type
        }
        switch selectType {
        case .delete, .submit, .undo:
            break
        default:
            // 选项高亮
            toolitems.forEach { item in
                if item == target {
                    item.toggle()
                } else {
                    item.untoggle()
                }
            }
        }
        // 触发代理
        self.delegate?.item_click(toolItem: target)
    }
}
