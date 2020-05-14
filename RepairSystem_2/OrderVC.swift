//
//  OrderVC.swift
//  RepairSystem_2
//
//  Created by 李翌臣 on 2020/4/27.
//  Copyright © 2020 gentlemans. All rights reserved.
//

import UIKit
import Firebase

class OrderVC: UIViewController {
    @IBOutlet var btnConfirm: UIButton!
    @IBOutlet var textOrder: UITextView!
    @IBOutlet var btnComplete: UIButton!
    @IBOutlet var lbInfo: UILabel!
    let db = Firestore.firestore()
    var phoneNumber :String?
    var orderService = ""
    var orderCoName: String?
    var orderName: String?
    var orderPhone: String?
    var orderAddress: String?
    var orderVAT: String?
    var orderProblem: String?
    var orderPayment: String?
    var orderSendTime: String?
    var orderTravelpay = ""
    let today = Date()
    let dateFormatter = DateFormatter()
    var mailMessage = ""
    var orderTime = ""
    var checkstatus :String = ""
    var documentName :String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("in OrderVC")
        lbInfo.text = ""
        btnComplete.isHidden = true
        dateFormatter.dateFormat = "yyyyMMddhhmm"
        let month = dateFormatter.string(from: today)
        self.title = "訂單詳細內容"
        phoneNumber = Auth.auth().currentUser?.phoneNumber!
        let defValue = db.collection("users").document(phoneNumber!)
        
        defValue.getDocument(source: .cache) { (document, error) in
            if let document = document{
                self.showLoading()
                let deftravelpay = document.get("travelpay")
                let status = document.get("status") as! String
                
                if status == "1"{
                    self.checkstatus = "1"
                }
                
                if deftravelpay != nil{
                    self.orderTravelpay = deftravelpay as! String
                    print(self.orderTravelpay)
                }
            }else{
                print("Document does not exist in cache")
            }
            
            self.textOrder.layer.borderColor = UIColor.lightGray.cgColor
            self.textOrder.layer.borderWidth = 2
            self.textOrder.isSelectable = false
            
            self.db.collection("users").document(self.phoneNumber!).collection("order").getDocuments { (querySnapshot, error) in
                if error == nil{
                    if let querySnapshot  = querySnapshot{
                        for document in querySnapshot.documents{
                            self.documentName = document.documentID
                        }
                    }
                }else{
                    print(error!.localizedDescription)
                }
                
                if self.checkstatus == "1"{
                    self.navigationItem.setHidesBackButton(true, animated: true)
                    self.db.collection("users").document(self.phoneNumber!).collection("order").document(self.documentName).getDocument(source: .cache) { (document, error) in
                        if let document = document{
                            let time = document.get("Time")
                            let serviceType = document.get("ServiceType")
                            let companyName = document.get("CompanyName")
                            let vat = document.get("CompanyVAT")
                            let name = document.get("Name")
                            let phone = document.get("Phone")
                            let address = document.get("Address")
                            let problem = document.get("Problem")
                            let payment = document.get("Payment")
                            let travelPay = document.get("TravelPay")
                            let sendTIme = document.get("SendTime")
                            
                            self.orderTime = time as! String
                            self.orderService = serviceType as! String
                            self.orderCoName = companyName as? String
                            self.orderVAT = vat as? String
                            self.orderName = name as? String
                            self.orderPhone = phone as? String
                            self.orderAddress = address as? String
                            self.orderProblem = problem as? String
                            self.orderPayment = payment as? String
                            self.orderTravelpay = travelPay as! String
                            self.orderSendTime = sendTIme as? String
                            
                            print(self.orderTime)
                            print(self.orderService)
                            print(self.orderCoName)
                            print(self.orderVAT)
                            print(self.orderName)
                            print(self.orderPhone)
                            print(self.orderAddress)
                            print(self.orderProblem)
                            print(self.orderPayment)
                            print(self.orderTravelpay)
                            print(self.orderSendTime)
                        }else{
                             print("Document does not exist in cache")
                        }
                        
                        
                        if self.orderService == "到府維修"{
                            self.textOrder.text = ("\(self.orderTime)\n\n服務方式：\(self.orderService)\n\n公司名稱：\(self.orderCoName!)\n\n公司統編：\(self.orderVAT!)\n\n聯絡人姓名：\(self.orderName!)\n\n聯絡人電話：\(self.orderPhone!)\n\n地址：\(self.orderAddress!)\n\n問題描述：\(self.orderProblem!)\n\n付款方式：\(self.orderPayment!)\n\n服務金額：車馬費\(self.orderTravelpay)元+1小時500元\n")
                        }else if self.orderService == "到府收送"{
                            self.textOrder.text = ("\(self.orderTime)\n\n服務方式：\(self.orderService)\n\n公司名稱：\(self.orderCoName!)\n\n公司統編：\(self.orderVAT!)\n\n聯絡人姓名：\(self.orderName!)\n\n聯絡人電話：\(self.orderPhone!)\n\n地址：\(self.orderAddress!)\n\n問題描述：\(self.orderProblem!)\n\n付款方式：\(self.orderPayment!)\n\n服務金額：車馬費\(self.orderTravelpay)元+檢測費500元\n")
                        }else{
                            self.textOrder.text = ("\(self.orderTime)\n\n服務方式：\(self.orderService)\n\n公司名稱：\(self.orderCoName!)\n\n公司統編：\(self.orderVAT!)\n\n聯絡人姓名：\(self.orderName!)\n\n聯絡人電話：\(self.orderPhone!)\n\n地址：\(self.orderAddress!)\n\n問題描述：\(self.orderProblem!)\n\n付款方式：\(self.orderPayment!)\n\n服務金額：檢測費500元 (後續依檢測結果額外報價)\n\n自行送件時間：\(self.orderSendTime!)")
                        }
                        self.removeLoading()
                        self.btnConfirm.isHidden = true
                        self.btnComplete.isHidden = false
                        self.lbInfo.text = "已收到您的訂單，請稍待人員回電"
                        
                    }
                }else{
                    if self.orderService == "到府維修"{
                       self.textOrder.text = ("\(month)\n\n服務方式：\(self.orderService)\n\n公司名稱：\(self.orderCoName!)\n\n公司統編：\(self.orderVAT!)\n\n聯絡人姓名：\(self.orderName!)\n\n聯絡人電話：\(self.orderPhone!)\n\n地址：\(self.orderAddress!)\n\n問題描述：\(self.orderProblem!)\n\n付款方式：\(self.orderPayment!)\n\n服務金額：車馬費\(self.orderTravelpay)元+1小時500元\n")
                    }else if self.orderService == "到府收送"{
                       self.textOrder.text = ("\(month)\n\n服務方式：\(self.orderService)\n\n公司名稱：\(self.orderCoName!)\n\n公司統編：\(self.orderVAT!)\n\n聯絡人姓名：\(self.orderName!)\n\n聯絡人電話：\(self.orderPhone!)\n\n地址：\(self.orderAddress!)\n\n問題描述：\(self.orderProblem!)\n\n付款方式：\(self.orderPayment!)\n\n服務金額：車馬費\(self.orderTravelpay)元+檢測費500元\n")
                    }else{
                        self.textOrder.text = ("\(month)\n\n服務方式：\(self.orderService)\n\n公司名稱：\(self.orderCoName!)\n\n公司統編：\(self.orderVAT!)\n\n聯絡人姓名：\(self.orderName!)\n\n聯絡人電話：\(self.orderPhone!)\n\n地址：\(self.orderAddress!)\n\n問題描述：\(self.orderProblem!)\n\n付款方式：\(self.orderPayment!)\n\n服務金額：檢測費500元 (後續依檢測結果額外報價)\n\n自行送件時間：\(self.orderSendTime!)")
                    }
                    
                    if self.orderService == "到府維修"{
                        self.mailMessage =  "<p>服務方式：\(self.orderService)</p><p>公司名稱：\(self.orderCoName!)</p><p>公司統編：\(self.orderVAT!)</p><p>聯絡人姓名：\(self.orderName!)</p><p>聯絡人電話：\(self.orderPhone!)</p><p>地址：\(self.orderAddress!)</p><p>問題描述：\(self.orderProblem!)</p><p>付款方式：\(self.orderPayment!)</p><p>服務金額：車馬費\(self.orderTravelpay)元+1小時500元</p>"
                    }else if self.orderService == "到府收送"{
                        self.mailMessage = "<p>服務方式：\(self.orderService)</p><p>公司名稱：\(self.orderCoName!)</p><p>公司統編：\(self.orderVAT!)</p><p>聯絡人姓名：\(self.orderName!)</p><p>聯絡人電話：\(self.orderPhone!)</p><p>地址：\(self.orderAddress!)</p><p>問題描述：\(self.orderProblem!)</p><p>付款方式：\(self.orderPayment!)</p><p>服務金額：車馬費\(self.orderTravelpay)元+檢測費500元</p>"
                    }else{
                        self.mailMessage = "<p>服務方式：\(self.orderService)</p><p>公司名稱：\(self.orderCoName!)</p><p>公司統編：\(self.orderVAT!)</p><p>聯絡人姓名：\(self.orderName!)</p><p>聯絡人電話：\(self.orderPhone!)</p><p>地址：\(self.orderAddress!)</p><p>問題描述：\(self.orderProblem!)</p><p>付款方式：\(self.orderPayment!)</p><p>服務金額：檢測費500元 (後續依檢測結果額外報價)</p><p>自行送件時間：\(self.orderSendTime!)</p>"
                    }
                    self.removeLoading()
                }
                
                
            }
            
            
            
        }
        // Do any additional setup after loading the view.
       
        //print(orderService)
        //print(orderCoName!)
        //print(orderName!)
        //print(orderPhone!)
        //print(orderAddress!)
        //print(orderVAT!)
        //print(orderProblem!)
        //print(orderSendTime!)
        //print(orderPayment!)
        //print(orderTravelpay)
        
    }

    @IBAction func btnConfirmTapped(_ sender: Any) {
        self.showLoading()
        self.navigationItem.setHidesBackButton(true, animated: true)
        self.btnConfirm.isHidden = true
        dateFormatter.dateFormat = "yyyyMMddhhmm"
        let month = dateFormatter.string(from: today)
        orderTime = month
        db.collection("users").document(phoneNumber!).collection("order").document(orderTime).setData(["ServiceType":orderService,"CompanyName":orderCoName!,"CompanyVAT":orderVAT!,"Name":orderName!,"Phone":orderPhone!,"Address":orderAddress!,"Problem":orderProblem!,"Payment":orderPayment!,"SendTime":orderSendTime!,"Time":orderTime,"TravelPay":orderTravelpay])
        
        let smtpSession = MCOSMTPSession()
        smtpSession.hostname = "smtp.gmail.com"
        smtpSession.username = "as50761721@gmail.com"
        smtpSession.password = "tibmbdxyvwpqigge"
        smtpSession.port = 465
        smtpSession.authType = MCOAuthType.saslPlain
        smtpSession.connectionType = MCOConnectionType.TLS
        smtpSession.connectionLogger = {(connectionID, type, data) in
            if data != nil {
                if let string = NSString(data: data!, encoding: String.Encoding.utf8.rawValue){
                    NSLog("Connectionlogger: \(string)")
                }
            }
        }

        let builder = MCOMessageBuilder()
        builder.header.to = [MCOAddress(displayName: "傑特漫系統程式開發有限公司", mailbox: "as50761721@gmail.com")!]
        builder.header.from = MCOAddress(displayName: "傑特漫系統程式開發有限公司", mailbox: "as50761721@gmail.com")
        builder.header.subject = month
        builder.htmlBody = mailMessage
        let rfc822Data = builder.data()
        let sendOperation = smtpSession.sendOperation(with: rfc822Data)
        sendOperation?.start { (error) -> Void in
            if (error != nil) {
                NSLog("Error sending email: \(error!)")
                self.removeLoading()
            } else {
                NSLog("Successfully sent email!")
                let controller = UIAlertController(title: "通知", message: "已收到您的訂單，請稍等公司人員回電", preferredStyle: .alert)
                
                let okAction = UIAlertAction(title: "是", style: .default) { (_) in
                   
                    
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
                        self.removeLoading()
                        self.lbInfo.text = "已收到您的訂單，請稍候。"
                        self.db.collection("users").document(self.phoneNumber!).collection("order").document(self.orderTime).updateData(["status":"1"])
                        self.db.collection("users").document(self.phoneNumber!).updateData(["status":"1"])
                        self.btnComplete.isHidden = false
                    }
                    //self.performSegue(withIdentifier: "segue_WaitingVC", sender: self)
                }
                controller.addAction(okAction)
                self.present(controller, animated: true, completion: nil)
                
            }
        }
            
    }
    @IBAction func btnCompleteTapped(_ sender: Any) {
        self.db.collection("users").document(self.phoneNumber!).collection("order").document(self.orderTime).updateData(["status":"3"])
        self.db.collection("users").document(self.phoneNumber!).updateData(["status":"0"])
        for controller in self.navigationController!.viewControllers as Array {
            if controller.isKind(of: ViewController.self) {
                self.navigationController!.popToViewController(controller, animated: true)
                break
            }
        }
    }
    
    
    
}
