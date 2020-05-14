//
//  StartVC.swift
//  RepairSystem_2
//
//  Created by 李翌臣 on 2020/4/28.
//  Copyright © 2020 gentlemans. All rights reserved.
//

import UIKit
import Firebase
class StartVC: UIViewController{
    
    @IBOutlet var btnSignUp: UIButton!
    @IBOutlet var btnLogin: UIButton!
    @IBOutlet var btnSignUpOrSignIn: UIButton!
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.title = "登入"
        btnLogin.layer.cornerRadius = 5.0
        btnLogin.layer.borderWidth = 2
        btnLogin.layer.borderColor = UIColor.white.cgColor
        btnLogin.isHidden = true
        btnSignUp.layer.cornerRadius = 5.0
        btnSignUp.layer.borderWidth = 2
        btnSignUp.layer.borderColor = UIColor.white.cgColor
        btnSignUp.isHidden = true
        btnSignUpOrSignIn.layer.cornerRadius = 5.0
        btnSignUpOrSignIn.layer.borderWidth = 2
        btnSignUpOrSignIn.layer.borderColor = UIColor.white.cgColor
        self.navigationItem.setHidesBackButton(true, animated: true)
        //print(Auth.auth().currentUser!)
        if Auth.auth().currentUser != nil{
            self.performSegue(withIdentifier: "AlreadyLogin_VC", sender: self)
        }else{
            print("no user login")
        }
        

        }

}
