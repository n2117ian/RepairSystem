//
//  LoginVC.swift
//  RepairSystem_2
//
//  Created by 李翌臣 on 2020/4/30.
//  Copyright © 2020 gentlemans. All rights reserved.
//

import UIKit
import Firebase

class LoginVC: UIViewController {
    @IBOutlet var signInPhone: UITextField!
    @IBOutlet var signInPassword: UITextField!
    @IBOutlet var infoLabel: UILabel!
    var checkpassword : String = ""
    var checkPhone = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        hidekeyboardWhenTappedAround()
        infoLabel.text = ""
        self.infoLabel.textColor = UIColor.red
        // Do any additional setup after loading the view.
    }
    
    @IBAction func btnLoginClicked(_ sender: Any) {
        let db = Firestore.firestore()
        if self.signInPassword.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || self.signInPhone.text?.trimmingCharacters(in: .whitespacesAndNewlines) == ""{
            self.infoLabel.text = "尚有空格未填滿"
        }else{
            db.collection("users").whereField("Phonenumber",isEqualTo: signInPhone.text!).getDocuments { (querySnapshot, error) in
            if let querySnapshot  = querySnapshot{
                    for document in querySnapshot.documents{
                        self.checkpassword = document.data()["Password"] as! String
                        print(self.checkpassword)
                        self.checkPhone = 1
                    }
                }
            
            if self.signInPassword.text! == self.checkpassword{
                self.infoLabel.textColor = UIColor.green
                self.infoLabel.text = "登入成功"
                print(Auth.auth().currentUser?.phoneNumber)
                let alertController = UIAlertController(title: "登入成功!",
                                                        message: nil, preferredStyle: .alert)
                //显示提示框
                self.present(alertController, animated: true, completion: nil)
                //两秒钟后自动消失
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
                    self.presentedViewController?.dismiss(animated: false, completion: nil)
                    self.performSegue(withIdentifier: "segue_ViewController", sender: self)
                }
                if(Auth.auth().currentUser != nil){
                    print(Auth.auth().currentUser!)
                }else{
                    print("no user")
                }
            }else if self.checkPhone == 0{
                self.infoLabel.text = "帳號尚未註冊"
            }else{
                self.infoLabel.text = "密碼錯誤"
                }
            }
        }
        
        
        
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
