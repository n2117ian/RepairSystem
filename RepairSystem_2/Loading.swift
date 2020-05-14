//
//  Loading.swift
//  RepairSystem_2
//
//  Created by 李翌臣 on 2020/5/8.
//  Copyright © 2020 gentlemans. All rights reserved.
//

import UIKit

var aView :UIView?

extension UIViewController{
    
    func showLoading(){
        aView = UIView(frame: self.view.bounds)
        aView?.backgroundColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
        
        let loading = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.large)
        loading.center = aView!.center
        aView?.addSubview(loading)
        loading.startAnimating()
        self.view.addSubview(aView!)
        
        
        Timer.scheduledTimer(withTimeInterval: 15.0, repeats: false) { (t) in
            self.removeLoading()
        }
    }
    
    func removeLoading(){
            aView?.removeFromSuperview()
            aView = nil
            
            print("remove Loading")
        
        
        
    }
    
}

