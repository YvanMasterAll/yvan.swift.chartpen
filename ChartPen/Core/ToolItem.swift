//
//  ToolItem.swift
//  ChartPen
//
//  Created by Yiqiang Zeng on 2020/3/23.
//  Copyright © 2020 Yiqiang Zeng. All rights reserved.
//

import UIKit
import SnapKit

/// 工具选项

class ToolItem: UIView {
    
    //MARK: - 声明区域
    var type: ToolType!
    var tool: Tool!
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setupUI()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        setupSUI()
    }
    
    //MARK: - 私有成员
    fileprivate var img_icon = UIImageView()
}

//MARK: - 初始化
extension ToolItem {
    
    fileprivate func setupUI() {
        // icon
        self.addSubview(img_icon)
        img_icon.contentMode = .scaleAspectFill
        img_icon.snp.makeConstraints {make in
            make.center.equalTo(self.snp.center)
            make.width.equalTo(toolitem_icon_width)
            make.height.equalTo(toolitem_icon_width)
        }
    }
    
    fileprivate func setupSUI() {
        
    }
    
    func setupLayout(tool: Dictionary<String, String>, panel: Panel) {
        self.type = ToolType(tool["type"]!)
        switch type {
        case .pen:
            self.tool = PenTool(panel: panel)
        case .select:
            self.tool = SelectTool(panel: panel)
        case .undo:
            self.tool = UndoTool(panel: panel)
        default:
            break
        }
        img_icon.image = UIImage(named: tool["icon"]!)
    }

}

//MARK: - 事件处理
extension ToolItem {
    
    func toggle() {
        self.backgroundColor = UIColor.blue.withAlphaComponent(0.2)
    }
    
    func untoggle() {
        self.backgroundColor = .white
    }
}
