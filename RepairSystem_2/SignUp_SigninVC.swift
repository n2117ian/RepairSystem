//
//  SignUp_SigninVC.swift
//  RepairSystem_2
//
//  Created by 李翌臣 on 2020/5/7.
//  Copyright © 2020 gentlemans. All rights reserved.
//

import UIKit
import Firebase
class SignUp_SigninVC: UIViewController,UITextFieldDelegate {

    @IBOutlet var tf_Phone: UITextField!
    @IBOutlet var btn_submit: UIButton!
    @IBOutlet var lb_errormsg: UILabel!
    let userDefault = UserDefaults.standard
    var phoneCheck = 0
    var timeStop :Int!
    var timer:Timer?
    var counter = 20
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "註冊/登入"
        hidekeyboardWhenTappedAround()
        tf_Phone.delegate = self
        tf_Phone.text = ""
        lb_errormsg.text = ""
        if Auth.auth().currentUser != nil{
            print(Auth.auth().currentUser!.phoneNumber)
        }
        
     
        
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func btn_submit_tapped(_ sender: Any) {
        showLoading()
        self.lb_errormsg.text = ""
        guard var phoneNumber = tf_Phone.text else{return}
        phoneNumber = "+886\(phoneNumber.dropFirst())"
        print(phoneNumber)
        var checkexist = 0
        let db = Firestore.firestore()
        db.collection("users").getDocuments { (querySnapshot, error) in
           if let querySnapshot  = querySnapshot{
               for document in querySnapshot.documents{
                    var dbphoneNumber : String
                    dbphoneNumber = document.data()["Phonenumber"] as! String
                    dbphoneNumber = "0\(dbphoneNumber.dropFirst(4))"
                    if self.tf_Phone.text == dbphoneNumber{
                        checkexist = 1
                    }
               }
           }
            if checkexist == 1{
                self.btn_submit.setTitle("登入", for: .normal)
                print("SignIn Mode")
            }else{
                self.btn_submit.setTitle("註冊", for: .normal)
                print("SignUp Mode")
            }
            if self.phoneCheck == 1 {
                    PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil){(verifcationId,error) in
                        self.btn_submit.isEnabled = false
                        if error == nil {
                            guard let veriftId = verifcationId else{return}
                            self.btn_submit.isEnabled = false
                            self.timerEanbled()
                            self.userDefault.set(veriftId, forKey: "verificationId")
                            self.userDefault.synchronize()
                            print(verifcationId!)
                            
                            //self.btnSignIn.isEnabled = true
                            
                            
                            let controller = UIAlertController(title: "登入", message: "請輸入簡訊驗證碼共六碼", preferredStyle: .alert)
                            if checkexist == 0 {
                                controller.title = "註冊"
                            }
                            controller.addTextField { (textField) in
                               textField.placeholder = "驗證碼"
                                textField.keyboardType = UIKeyboardType.numberPad
                            }

                            let okAction = UIAlertAction(title: "OK", style: .default) { (_) in
                                guard let code = controller.textFields?[0].text else { return }
                                guard let verifiactionId = self.userDefault.string(forKey:"verificationId") else { return }
                                let credential = PhoneAuthProvider.provider().credential(withVerificationID: verifiactionId, verificationCode: code)
                                Auth.auth().signIn(with: credential){(success ,error) in
                                    if error == nil {
                                        print(success!)
                                        print("loggin")
                                        // create user
                                        //let phoneNumber = self.tf_Phone.text!.trimmingCharacters(in: .whitespacesAndNewlines)
                                        if(checkexist == 0){
                                            let db = Firestore.firestore()
                                            db.collection("users").document(phoneNumber).setData(["Phonenumber" : phoneNumber,"uid":success!.user.uid,"status":"0"]) { (error) in
                                                if error != nil{
                                                    print("user data error")
                                                }
                                            }
                                            

                                        }
                                            
                                        
                                        // success alert
                                        let alertController = UIAlertController(title: "註冊成功!",message: "直接為您跳轉登入", preferredStyle: .alert)
                                        if checkexist == 1 {
                                            alertController.title = "登入成功!"
                                            alertController.message = nil
                                        }
            
                                        //显示提示框
                                        self.present(alertController, animated: true, completion: nil)
                                        //两秒钟后自动消失
                                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
                                            //self.lb_errormsg.textColor = UIColor.green
                                            //self.lb_errormsg.text =  "註冊成功"
                                            self.presentedViewController?.dismiss(animated: false, completion: nil)
                                            print(Auth.auth().currentUser?.phoneNumber!)
                                            self.performSegue(withIdentifier: "segue_toVC", sender: self)
                                            
                                        }
                                        
                                    }else{
                                        self.removeLoading()
                                        print("wrong \(error!.localizedDescription)")
                                        //self.lb_errormsg.text = "驗證碼錯誤"
                                        controller.title = "驗證碼錯誤"
                                        self.present(controller, animated: true, completion: nil)
                                    }
                                }
                            }
                            controller.addAction(okAction)
                            let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
                            controller.addAction(cancelAction)
                            self.present(controller, animated: true, completion: nil)

                        }
                    }
                }else{
                    self.removeLoading()
                    self.btn_submit.isEnabled = true
                    self.lb_errormsg.text = "電話格式錯誤"
                    
                }
        }
    }
    
    @objc func resend(){
        if(self.counter > 1 ){
            self.counter = self.counter - 1
            self.btn_submit.setTitle("\(self.counter)s", for: .normal)
        }else{
            self.btn_submit.setTitle("重新發送簡訊", for: .normal)
            self.timer?.invalidate()
            self.btn_submit.isEnabled = true
            counter = 20
        }
    }
    func timerEanbled(){
        self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector:#selector(resend), userInfo: nil, repeats: true)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let countOfWords = string.count +  tf_Phone.text!.count - range.length
        
        if countOfWords > 10{
              //signInPhone.text = String(countOfWords)
            return false
        }else if countOfWords != 10{
            phoneCheck = 0
        }else{
            phoneCheck = 1
        }
        return true
    }
   

}
