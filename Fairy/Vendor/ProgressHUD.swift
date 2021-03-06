//
//  ProgressHUD.swift
//  Fairy
//
//  Created by 丁鹏飞 on 2017/6/7.
//  Copyright © 2017年 丁鹏飞. All rights reserved.
//

import UIKit

enum HudMode:Int {
    case Indicator
    case CustomeView
    case Text
}

let margin:CGFloat = 10.0

class ProgressHUD: UIView {
    
    private var contentView:UIView = UIView()
    private var indicatorView:UIActivityIndicatorView?
    private var textLabel:UILabel?
    
    private var mode:Int = HudMode.Indicator.rawValue
    private var timer:Timer?
    
    var text:String = "" {
        didSet {
            textLabel?.text = text
            
            switch mode {
            case HudMode.CustomeView.rawValue:
                let indictorW = (indicatorView?.frame.width)!
                var size = sizeWithText(text: text)
                size = CGSize(width: max(size.height + margin + indictorW, size.width), height: size.height)
                
                contentView.bounds.size = CGSize(width: size.width + margin * 2.0, height: size.height + indictorW + margin * 3.0)
                indicatorView?.center = CGPoint(x: (size.width + margin * 2.0) * 0.5, y: margin + indictorW * 0.5)
                textLabel?.frame = CGRect(origin: CGPoint(x: margin, y: indictorW + margin * 2), size: size)
                
            case HudMode.Text.rawValue:
                let size = sizeWithText(text: text)
                contentView.bounds.size = CGSize(width: size.width + margin * 2.0, height: size.height + margin * 2.0)
                textLabel?.frame = CGRect(origin: CGPoint(x: margin, y: margin), size: size)
                
            default:
                return
            }
        }
    }
    
    //MARK: - public
    ///加载
    class func loading() {
        ProgressHUD.loading(backView: nil, text: nil)
    }
    
    class func loading(backView:UIView?,text:String?) {
        var backView = backView
        if backView == nil {
            backView = UIApplication.shared.windows.last
        }
        
        var hud:ProgressHUD
        if text != nil && text?.count != 0 {
            hud = ProgressHUD(backView: backView!, mode: .CustomeView)
            hud.text = text!
        } else {
            hud = ProgressHUD(backView: backView!, mode: .Indicator)
        }
        
        backView?.addSubview(hud)
    }
    
    ///提示
    class func showSuccess(text:String?) {
        let successText = text ?? "操作成功"
        ProgressHUD.showMessage(text: successText)
    }
    
    class func showError(text:String?) {
        let errorText = text ?? "操作失败"
        ProgressHUD.showMessage(text: errorText)
    }
    
    class func hideForView(backView:UIView?) {
        ProgressHUD.hideForView(backView: backView, animated: true)
    }
    
    class func hideForView(backView:UIView?, animated:Bool) {
        var backView = backView
        if backView == nil {
            backView = UIApplication.shared.windows.last
        }
        
        if let hud = ProgressHUD.HUDForView(backView: backView!) {
            if animated {
                hud.hideAnimated()
            } else {
                hud.removeFromSuperview()
            }
        }
    }
    
    //MARK:
    private class func HUDForView(backView:UIView) -> ProgressHUD? {
        for subview in backView.subviews.reversed() {
            if subview.isKind(of: self) {
                return subview as? ProgressHUD
            }
        }
        return nil
    }
    
    private class func showMessage(text:String) {
        let backView = UIApplication.shared.windows.last
        let hud = ProgressHUD(backView: backView!, mode: .Text)
        hud.text = text
        
        backView?.addSubview(hud)
        hud.hideHudAfterDealy(dealyTime: 1.5)
    }
    
    //MARK: - init
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private override init(frame: CGRect) {
        super.init(frame: frame)
        
        initilize()
    }
    
    func initilize() {
        backgroundColor = UIColor.clear
        
        contentView.center = center
        contentView.backgroundColor = KBackgroundColor
        addSubview(contentView)
        
        indicatorView = UIActivityIndicatorView(style: .whiteLarge)
        indicatorView?.color = UIColor.gray
        indicatorView?.startAnimating()
        contentView.addSubview(indicatorView!)
        
        textLabel = UILabel()
        textLabel?.numberOfLines = 0
        textLabel?.textAlignment = .center
        textLabel?.font = UIFont.systemFont(ofSize: 15)
        contentView.addSubview(textLabel!)
    }
    
    convenience init(backView:UIView?) {
        var backView = backView
        if backView == nil {
            backView = UIApplication.shared.windows.last
        }
        self.init(backView: backView!, mode: .CustomeView)
    }
    
    convenience init(backView:UIView, mode:HudMode) {
        self.init(frame: backView.bounds)
        self.mode = mode.rawValue
        
        if mode == .Indicator {
            textLabel?.removeFromSuperview()
            textLabel = nil
            
            let hudWidth = frame.width * 0.2
            contentView.bounds = CGRect(x: 0.0, y: 0.0, width: hudWidth, height:hudWidth)
            indicatorView?.center = CGPoint(x: hudWidth * 0.5, y: hudWidth * 0.5)
            
        } else if mode == .CustomeView {
            self.setValue("加载中", forKey: "text")
            
        } else if mode == .Text {
            indicatorView?.removeFromSuperview()
            indicatorView = nil
            self.setValue("加载中", forKey: "text")
        }
    }
    
    //MARK:
    private func hideHudAfterDealy(dealyTime:TimeInterval) {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + dealyTime) {
            self.hideAnimated()
        }
    }
    
    @objc private func hideAnimated() {
        UIView.animate(withDuration: 0.3, animations: {
            self.contentView.transform = CGAffineTransform.init(scaleX: 0.5, y: 0.5)
        }) { _ in
            self.removeFromSuperview()
        }
    }
    
    //MARK:
    private func sizeWithText(text:String) -> CGSize {
        let textS = NSString(string: (textLabel?.text)!)
        let size = textS.boundingRect(with: CGSize(width: frame.width * 0.8, height: 0.0),
                                      options: NSStringDrawingOptions.usesLineFragmentOrigin,
                                      attributes: [NSAttributedString.Key.font: textLabel?.font! as Any],
                                      context: nil).size
        return size
    }
}
