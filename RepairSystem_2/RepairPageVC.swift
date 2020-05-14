//
//  RepairPageVC.swift
//  RepairSystem_2
//
//  Created by 李翌臣 on 2020/4/20.
//  Copyright © 2020 gentlemans. All rights reserved.
//

import UIKit
import Firebase
class RepairPageVC: UIViewController ,UIPickerViewDelegate , UIPickerViewDataSource,UITextFieldDelegate{
    let db = Firestore.firestore()
    
    var lastAddress: String?
    var distance: String?
    var phoneNumber :String?
    @IBOutlet var rService: UITextField!
    @IBOutlet var rCoName: UITextField!
    @IBOutlet var rName: UITextField!
    @IBOutlet var rPhone: UITextField!
    @IBOutlet var rAddress: UITextField!
    @IBOutlet var rVAT: UITextField!
    @IBOutlet var rType: UITextField!
    @IBOutlet var rProblem: UITextField!
    @IBOutlet var rPayment: UITextField!
    @IBOutlet var rTime: UITextField!
    @IBOutlet var myScroolView: UIScrollView!
    @IBOutlet var rTimeLabel: UILabel!
    
    @IBAction func btnNext(_ sender: Any) {
        if self.rService.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || self.rName.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || self.rPhone.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || self.rAddress.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || self.rType.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || self.rProblem.text?.trimmingCharacters(in: .whitespacesAndNewlines) == ""{
            let controller = UIAlertController(title: "通知", message: "尚有空格未填", preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "是", style: .default) { (_) in
            }
            controller.addAction(okAction)
            present(controller, animated: true, completion: nil)
        }else if self.rCoName.text != "" && self.rVAT.text?.trimmingCharacters(in: .whitespacesAndNewlines) == ""{
            let controller = UIAlertController(title: "通知", message: "統一編號未填", preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "是", style: .default) { (_) in
            }
            controller.addAction(okAction)
            present(controller, animated: true, completion: nil)
        }else{
            self.db.collection("users").document(self.phoneNumber!).updateData(["Address" : rAddress.text!,"Company" : rCoName.text!,"Name":rName.text!,"VAT":rVAT.text!,"travelpay":distance!]) { (error) in
                if error != nil{
                    print("user data error")
                }
            }
            self.performSegue(withIdentifier: "segue_RepairToOrderVC", sender: self)
            
        }
        
        
    }

    var type = ["","筆記型電腦Notebook","桌上型電腦PC","伺服器Server","儲存設備NAS","APPLE系列產品","其他"]
    var service = ["","到府維修","到府收送","自行送件"]
    let payment = ["請選擇支付方式","現金","匯款","信用卡"]
    
    var typePicker = UIPickerView()
    var servicePicker = UIPickerView()
    var datePicker = UIDatePicker()
    let paymentPicker = UIPickerView()

    override func viewDidLoad() {
            
        
        phoneNumber = Auth.auth().currentUser?.phoneNumber!
        super.viewDidLoad()
        self.title = "維修表單"
        rAddress.text = lastAddress
        rAddress.isUserInteractionEnabled = false
        rPhone.text = "0\(phoneNumber!.dropFirst(4))"
        typePicker.delegate = self
        typePicker.dataSource = self
        //datePicker.datePickerMode = .dateAndTime
        
        servicePicker.delegate = self
        servicePicker.dataSource = self
        
        paymentPicker.delegate = self
        paymentPicker.dataSource = self
        
        rService.tag = 1
        rType.tag = 2
        rPayment.tag = 3
        
        servicePicker.tag = 10
        typePicker.tag = 20
        paymentPicker.tag = 30
        
        rType.inputView = typePicker
        rService.inputView = servicePicker
        rTime.inputView = datePicker
        rPayment.inputView = paymentPicker
        
        datePicker.locale = NSLocale(
            localeIdentifier: "zh_TW") as Locale
        datePicker.minuteInterval = 30
        
        rTime.isEnabled = false
        rTimeLabel.isEnabled = false
        
        //點空白鍵盤下去
        let tap = UITapGestureRecognizer(
          target: self,
          action:
            #selector(ViewController.hideKeyboard(tapG:)))

        tap.cancelsTouchesInView = false

        // 加在最基底的 self.view 上
        self.view.addGestureRecognizer(tap)
        
        createDatePicker()
        
        let defValue = db.collection("users").document(phoneNumber!)
        
        defValue.getDocument(source: .cache) { (document, error) in
            if let document = document{
                
                let defCoName = document.get("Company")
                let defName = document.get("Name")
                let defVAT = document.get("VAT")
                if defCoName != nil {
                    self.rCoName.text = defCoName as? String
                }
                if defName != nil {
                    self.rName.text = defName as? String
                }
                if defVAT != nil{
                    self.rVAT.text = defVAT as? String
                }
            }else{
                print("Document does not exist in cache")
            }
        }
        // Do any additional setup after loading the view.
        
        
    }
    
    func createDatePicker() {
        datePicker.datePickerMode = .dateAndTime
        datePicker.addTarget(self, action: #selector(self.datePickerValueChanged(datePicker:)), for: .valueChanged)
        print("success load datepicker")
    }
    
    @objc func hideKeyboard(tapG:UITapGestureRecognizer){
        self.view.endEditing(true)
    }
    
    //有幾個區塊
    public func numberOfComponents(in pickerView: UIPickerView) -> Int{
    return 1
    }
    //裡面有幾列
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int{
        if pickerView.tag == 10{
            return service.count
        }else if pickerView.tag == 20{
            return type.count
        }else{
            return payment.count
        }
    
    
    }
    //選擇到的那列要做的事
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView.tag == 10{
            rService.text = service[row]
            if(rService.text == service[3]){
                rTimeLabel.isEnabled = true
                rTime.isEnabled = true
            }else{
                rTimeLabel.isEnabled = false
                rTime.isEnabled = false
                rTime.text = ""
            }
                
        }else if pickerView.tag == 20{
            rType.text = type[row]
        }else{
            rPayment.text = payment[row]
        }

    }
    //設定每列PickerView要顯示的內容
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView.tag == 10{
            return service[row]
        }else if pickerView.tag == 20{
            return type[row]
        }else{
            return payment[row]
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        myScroolView.setContentOffset(CGPoint(x:0,y:200), animated: true)
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        myScroolView.setContentOffset(CGPoint(x:0,y:-100), animated: true)
    }
    
    @objc func datePickerValueChanged(datePicker:UIDatePicker) {
        // 設置要顯示在 UILabel 的日期時間格式
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"

        // 更新 UILabel 的內容
        self.rTime.text = formatter.string(
            from: datePicker.date)
        //self.rTime.resignFirstResponder()
        print("datepick:\(datePicker.date)")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
           if segue.identifier == "segue_RepairToOrderVC" {
               let vc = segue.destination as! OrderVC
            vc.orderService = self.rService.text!
            vc.orderCoName = self.rCoName.text!
            vc.orderName = self.rName.text!
            vc.orderPhone = self.rPhone.text!
            vc.orderAddress = self.rAddress.text!
            vc.orderVAT = self.rVAT.text!
            vc.orderPayment = self.rPayment.text!
            vc.orderProblem = self.rProblem.text!
            vc.orderSendTime = self.rTime.text!
            
        }
    }


}
