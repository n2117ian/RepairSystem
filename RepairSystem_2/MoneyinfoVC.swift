//
//  MoneyinfoVC.swift
//  RepairSystem_2
//
//  Created by 李翌臣 on 2020/4/22.
//  Copyright © 2020 gentlemans. All rights reserved.
//

import UIKit

class MoneyinfoVC: UIViewController ,UIPickerViewDelegate,UIPickerViewDataSource{
    
    var orderService: String?
    var orderCoName: String?
    var orderName: String?
    var orderPhone: String?
    var orderAddress: String?
    var orderVAT: String?
    var orderProblem: String?
    var orderPayment: String?
    var orderSendTime: String?
    @IBOutlet var mainLabel: UILabel!
    @IBOutlet var paypicker: UITextField!
    @IBOutlet var textView: UITextView!
    @IBAction func btnNext(_ sender: Any) {
        self.performSegue(withIdentifier: "segue_OrderVC", sender: self)
               print("to orderVC")
    }
    let payment = ["請選擇支付方式","現金","匯款","信用卡"]
    let paymentPicker = UIPickerView()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "付款方式確認"
        mainLabel.numberOfLines = 0
        mainLabel.sizeToFit()
        
        paymentPicker.delegate = self
        paymentPicker.dataSource = self
        paypicker.inputView = paymentPicker
        
        textView.isEditable = false
        
        //點空白鍵盤下去
        let tap = UITapGestureRecognizer(
          target: self,
          action:
            #selector(ViewController.hideKeyboard(tapG:)))

        tap.cancelsTouchesInView = false

        // 加在最基底的 self.view 上
        self.view.addGestureRecognizer(tap)
        // Do any additional setup after loading the view.
    }
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return payment.count
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        paypicker.text = payment[row]
        if(paypicker.text == payment[1]){
            textView.text = "選現金"
        }else if(paypicker.text == payment[2]){
            textView.text = "選匯款"
        }else if(paypicker.text == payment[3]){
            textView.text = "選信用卡"
        }

    }
    //設定每列PickerView要顯示的內容
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return payment[row]
    }
    //鍵盤下去方法
    @objc func hideKeyboard(tapG:UITapGestureRecognizer){
        self.view.endEditing(true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segue_OrderVC" {
            let vc = segue.destination as! OrderVC
            vc.orderPayment = self.paypicker.text!
            vc.orderService = self.orderService!
            vc.orderCoName = self.orderCoName
            vc.orderName = self.orderName
            vc.orderPhone = self.orderPhone
            vc.orderAddress = self.orderAddress
            vc.orderVAT = self.orderVAT
            vc.orderProblem = self.orderProblem
            vc.orderSendTime = self.orderSendTime
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
