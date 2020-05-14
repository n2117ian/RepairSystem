//
//  Extension.swift
//  RepairSystem_2
//
//  Created by 李翌臣 on 2020/4/30.
//  Copyright © 2020 gentlemans. All rights reserved.
//
import Foundation
import UIKit

extension UIViewController{
    func hidekeyboardWhenTappedAround(){
        let tap = UITapGestureRecognizer(
          target: self,
          action:#selector(hideKeyboard))


        // 加在最基底的 self.view 上
        view.addGestureRecognizer(tap)
    }
    @objc func hideKeyboard(){
        view.endEditing(true)
    }
    
    
}
