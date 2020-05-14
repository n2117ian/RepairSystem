//
//  SignUpVC.swift
//  RepairSystem_2
//
//  Created by 李翌臣 on 2020/4/30.
//  Copyright © 2020 gentlemans. All rights reserved.
//
import Firebase
import FirebaseAnalytics
import UIKit

class SignUpVC: UIViewController ,UITextFieldDelegate{
    
    @IBOutlet var signInPhone: UITextField!
    @IBOutlet var signInPassword: UITextField!
    @IBOutlet var signInVerify: UITextField!
    @IBOutlet var infoLabel: UILabel!
    @IBOutlet var btnSignIn: UIButton!
    @IBOutlet var btnVerify: UIButton!
    let userDefault = UserDefaults.standard
    var timeStop :Int!
    var timer:Timer?
    var counter = 20
    var phoneCheck = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        hidekeyboardWhenTappedAround()
        btnSignIn.isEnabled = false
        infoLabel.text = ""
        self.signInPhone.delegate = self
        // Do any additional setup after loading the view.
    }
    override func viewWillDisappear(_ animated: Bool) {
           super.viewWillDisappear(animated)
           if self.timer != nil{
               self.timer?.invalidate()
           }
       }
    func isPasswordValid(_ password :String)->Bool{
        let passwordTest = NSPredicate(format:"SELF MATCHES %@","^(?=.*[a-z])(?=.*[0-9])[A-Za-z\\d$@$#!%*?&]{8,}")
        return passwordTest.evaluate(with: password)
    }
    
    @IBAction func btngetCode(_ sender: Any) {
        
        self.infoLabel.text = ""
        guard var phoneNumber = signInPhone.text else{return}
        phoneNumber = "+886\(phoneNumber)"
        print(phoneNumber)
        var checkexist = 0
        let db = Firestore.firestore()
        db.collection("users").getDocuments { (querySnapshot, error) in
           if let querySnapshot  = querySnapshot{
               for document in querySnapshot.documents{
                    var dbphoneNumber : String
                    dbphoneNumber = document.data()["Phonenumber"] as! String
                    if self.signInPhone.text == dbphoneNumber{
                        checkexist = 1
                    }
               }
           }
            if checkexist == 1{
                self.infoLabel.text = "電話已被註冊"
                print("phone is already exist!")
            }else if self.phoneCheck == 1 {
                    PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil){(verifcationId,error) in
                        
                        if error == nil {
                            guard let veriftId = verifcationId else{return}
                            self.userDefault.set(veriftId, forKey: "verificationId")
                            self.userDefault.synchronize()
                            print(verifcationId!)
                            self.btnVerify.isEnabled = false
                            self.timerEanbled()
                            self.btnSignIn.isEnabled = true
                            
                            
                            let controller = UIAlertController(title: "通知", message: "稍等簡訊馬上為您送達！", preferredStyle: .alert)
                               let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                               controller.addAction(okAction)

                        }
                    }
                }else{
                    self.infoLabel.text = "電話格式錯誤"
                }
        }
        
    }
    @IBAction func signInClicked(_ sender: Any) {
        guard let code = signInVerify.text else { return }
        guard let verifiactionId = userDefault.string(forKey:"verificationId") else { return }
        let credential = PhoneAuthProvider.provider().credential(withVerificationID: verifiactionId, verificationCode: code)
        Auth.auth().signIn(with: credential){(success ,error) in
            let cleanPassword = self.signInPassword.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            if self.signInPhone.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || self.signInPassword.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
                self.signInVerify.text?.trimmingCharacters(in: .whitespacesAndNewlines) == ""{
                self.infoLabel.text = "尚有空格未填滿"
            }else if self.isPasswordValid(cleanPassword) == false{
                self.infoLabel.text = "密碼需要8位以上,包含字母及數字"
            }else if error == nil {
                print(success!)
                print("loggin")
                // create user
                let phoneNumber = self.signInPhone.text!.trimmingCharacters(in: .whitespacesAndNewlines)
                let password = self.signInPassword.text!.trimmingCharacters(in: .whitespacesAndNewlines)
                
               
                let db = Firestore.firestore()
                db.collection("users").addDocument(data: ["Phonenumber" : phoneNumber,"Password":password,"uid":success!.user.uid]) { (error) in
                    if error != nil{
                        print("user data error")
                    }
                }
                    
                
                // success alert
                let alertController = UIAlertController(title: "註冊成功!",
                                                        message: nil, preferredStyle: .alert)
                //显示提示框
                self.present(alertController, animated: true, completion: nil)
                //两秒钟后自动消失
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
                    self.infoLabel.textColor = UIColor.green
                    self.infoLabel.text =  "註冊成功"
                    self.presentedViewController?.dismiss(animated: false, completion: nil)
                    print(Auth.auth().currentUser?.phoneNumber)
                    self.backViewBtnFnc()
                }
                
            }else{
                print("wrong \(error!.localizedDescription)")
                self.infoLabel.text = "驗證碼錯誤"
            }
            
            
            
            
        }
    }
    @objc func backViewBtnFnc(){
           self.navigationController?.popViewController(animated: true)
       }
    @objc func resend(){
        if(self.counter > 1 ){
            self.counter = self.counter - 1
            self.btnVerify.setTitle("\(self.counter)s", for: .normal)
        }else{
            self.btnVerify.setTitle("重新發送簡訊", for: .normal)
            self.timer?.invalidate()
            self.btnVerify.isEnabled = true
            counter = 20
        }
    }
    func timerEanbled(){
        self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector:#selector(resend), userInfo: nil, repeats: true)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let countOfWords = string.count +  signInPhone.text!.count - range.length
        
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
